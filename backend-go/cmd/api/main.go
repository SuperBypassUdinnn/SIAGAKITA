package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"siagakita-backend/internal/config"
	"siagakita-backend/internal/database"
	incidentDomain "siagakita-backend/internal/domain/incident"
	otpDomain "siagakita-backend/internal/domain/otp"
	"siagakita-backend/internal/domain/telemetry"
	userDomain "siagakita-backend/internal/domain/user"
	"siagakita-backend/internal/hub"
	"siagakita-backend/internal/middleware"
	"siagakita-backend/internal/ws"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

func main() {
	// ── 1. Load Config ────────────────────────────────────────────────────────
	cfg := config.Load()
	if cfg.JWTSecret == "" {
		log.Fatal("[Config] JWT_SECRET tidak boleh kosong")
	}

	// ── 2. Connect to PostgreSQL & Redis ─────────────────────────────────────
	db := database.NewPostgres(cfg)
	rdb := database.NewRedis(cfg)

	// ── 3. Connection Hub (WebSocket registry) ────────────────────────────────
	wsHub := hub.New()

	// ── 4. Domain wiring ──────────────────────────────────────────────────────
	// User domain
	userRepo := userDomain.NewRepository(db)
	userSvc := userDomain.NewService(userRepo, cfg)
	userHandler := userDomain.NewHandler(userSvc)

	// Incident domain
	incidentRepo := incidentDomain.NewRepository(db)
	incidentSvc := incidentDomain.NewService(incidentRepo)
	incidentHandler := incidentDomain.NewHandler(incidentSvc)

	// OTP domain
	fonnteGateway := otpDomain.NewFonnteGateway(cfg.FonnteToken)
	otpSvc := otpDomain.NewService(rdb, fonnteGateway)
	otpHandler := otpDomain.NewHandler(otpSvc)

	// Telemetry domain
	telemetryHandler := telemetry.NewHandler(rdb, wsHub, cfg)

	// ── 5. Fiber REST API ─────────────────────────────────────────────────────
	app := fiber.New(fiber.Config{
		AppName: "SiagaKita API v1",
	})

	app.Use(recover.New())
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${status} ${method} ${path} (${latency})\n",
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, X-Gateway-Secret",
		AllowMethods: "GET, POST, PUT, DELETE, OPTIONS",
	}))

	// Health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": "SiagaKita REST API"})
	})

	// ── API v1 Routes ──────────────────────────────────────────────────────────
	v1 := app.Group("/api/v1")

	// Auth (public)
	auth := v1.Group("/auth")
	auth.Post("/register", userHandler.Register)
	auth.Post("/login", userHandler.Login)
	auth.Post("/request-otp", otpHandler.RequestOTP)
	auth.Post("/verify-otp", otpHandler.VerifyOTP)

	// Users (protected)
	authMw := middleware.Auth(cfg)
	users := v1.Group("/users", authMw)
	users.Post("/biodata", userHandler.SaveBiodata)
	users.Get("/profile", userHandler.GetProfile)

	// Incidents (protected)
	incidents := v1.Group("/incidents", authMw)
	incidents.Post("/:id/resolve", incidentHandler.Resolve)

	// Telemetry (protected)
	telemetry := v1.Group("/telemetry", authMw)
	telemetry.Put("/location", telemetryHandler.UpdateLocation)

	// SMS Fallback (API key protected — no JWT)
	v1.Post("/incidents/sms-fallback",
		middleware.APIKeyGateway(cfg),
		telemetryHandler.SMSFallback,
	)

	// ── 6. WebSocket Server (port :8081) ──────────────────────────────────────
	wsServer := ws.NewServer(wsHub, rdb, db, cfg)
	go func() {
		log.Printf("[WS] Starting WebSocket server on :%s", cfg.WSPort)
		if err := wsServer.ListenAndServe(); err != nil {
			log.Fatalf("[WS] Server error: %v", err)
		}
	}()

	// ── 7. Start Fiber REST API ───────────────────────────────────────────────
	go func() {
		log.Printf("[API] Starting REST API on :%s", cfg.HTTPPort)
		if err := app.Listen(":" + cfg.HTTPPort); err != nil {
			log.Fatalf("[API] Server error: %v", err)
		}
	}()

	// ── 8. Graceful shutdown ──────────────────────────────────────────────────
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("[Main] Shutting down gracefully...")

	if err := app.Shutdown(); err != nil {
		log.Printf("[API] Shutdown error: %v", err)
	}
	if err := wsServer.Shutdown(context.Background()); err != nil {
		log.Printf("[WS] Shutdown error: %v", err)
	}

	sqlDB, _ := db.DB()
	sqlDB.Close()
	rdb.Close()

	log.Println("[Main] Goodbye.")
}