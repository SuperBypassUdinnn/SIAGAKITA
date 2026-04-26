package user

import (
	"siagakita-backend/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// Handler holds HTTP handlers for the user domain.
type Handler struct {
	svc *Service
}

// NewHandler creates a new user Handler.
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Register handles POST /api/v1/auth/register
func (h *Handler) Register(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Body request tidak valid")
	}

	resp, err := h.svc.Register(&req)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	return utils.CreatedResponse(c, resp)
}

// Login handles POST /api/v1/auth/login
func (h *Handler) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Body request tidak valid")
	}

	resp, err := h.svc.Login(&req)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusUnauthorized, err.Error())
	}

	return utils.SuccessResponse(c, resp)
}

// SaveBiodata handles POST /api/v1/users/biodata  [Auth required]
func (h *Handler) SaveBiodata(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)

	var req BiodataRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Body request tidak valid")
	}

	if err := h.svc.SaveBiodata(userID, &req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utils.SuccessResponse(c, fiber.Map{"message": "Biodata berhasil disimpan"})
}

// GetProfile handles GET /api/v1/users/profile  [Auth required]
func (h *Handler) GetProfile(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)

	profile, err := h.svc.GetProfile(userID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusNotFound, "Profil tidak ditemukan")
	}

	return utils.SuccessResponse(c, profile)
}
