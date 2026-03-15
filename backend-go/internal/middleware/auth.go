package middleware

import (
	"strings"

	"siagakita-backend/internal/config"
	"siagakita-backend/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// Auth returns a Fiber middleware that validates JWT from the Authorization header.
// On success it injects "userID" and "userRole" into c.Locals for downstream handlers.
func Auth(cfg *config.Config) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Authorization header missing atau tidak valid")
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := utils.ParseToken(tokenStr, cfg.JWTSecret)
		if err != nil {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Token tidak valid atau sudah kedaluwarsa")
		}

		c.Locals("userID", claims.UserID)
		c.Locals("userRole", claims.Role)
		return c.Next()
	}
}

// APIKeyGateway returns a Fiber middleware that validates a static API key header.
// Used for the SMS fallback endpoint which must bypass JWT but still be secured.
func APIKeyGateway(cfg *config.Config) fiber.Handler {
	return func(c *fiber.Ctx) error {
		key := c.Get("X-Gateway-Secret")
		if key == "" || key != cfg.SMSGatewaySecret {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Gateway secret tidak valid")
		}
		return c.Next()
	}
}
