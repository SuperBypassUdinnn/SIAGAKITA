package incident

import (
	"strconv"

	"siagakita-backend/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// Handler holds HTTP handlers for the incident domain.
type Handler struct {
	svc *Service
}

// NewHandler creates a new incident Handler.
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// Resolve handles POST /api/v1/incidents/:id/resolve  [Auth required]
func (h *Handler) Resolve(c *fiber.Ctx) error {
	responderID := c.Locals("userID").(string)

	idParam := c.Params("id")
	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "ID insiden tidak valid")
	}

	resp, err := h.svc.Resolve(uint(id), responderID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utils.SuccessResponse(c, resp)
}
