package incident

import (
	"errors"
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

// ─── POST /api/v1/incidents/trigger  [Auth required] ─────────────────────────
func (h *Handler) TriggerSOS(c *fiber.Ctx) error {
	reporterID := c.Locals("userID").(string)

	var req TriggerSOSRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Body request tidak valid")
	}
	if req.Latitude == 0 && req.Longitude == 0 {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Koordinat GPS wajib diisi")
	}
	if req.TriggerMethod == "" {
		req.TriggerMethod = "user"
	}

	resp, err := h.svc.TriggerSOS(reporterID, &req)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utils.CreatedResponse(c, resp)
}

// ─── POST /api/v1/incidents/:id/cancel  [Auth required] ──────────────────────
func (h *Handler) CancelSOS(c *fiber.Ctx) error {
	reporterID := c.Locals("userID").(string)

	id, err := parseID(c)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "ID insiden tidak valid")
	}

	if err := h.svc.CancelSOS(id, reporterID); err != nil {
		status := fiber.StatusInternalServerError
		if err.Error() == "unauthorized" {
			status = fiber.StatusForbidden
		}
		return utils.ErrorResponse(c, status, err.Error())
	}

	return utils.SuccessResponse(c, fiber.Map{"cancelled": true})
}

// ─── PUT /api/v1/incidents/:id/location  [Auth required] ─────────────────────
func (h *Handler) UpdateLocation(c *fiber.Ctx) error {
	id, err := parseID(c)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "ID insiden tidak valid")
	}

	var req UpdateLocationRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Body request tidak valid")
	}

	if err := h.svc.UpdateLocation(id, req.Latitude, req.Longitude); err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utils.SuccessResponse(c, fiber.Map{"updated": true})
}

// ─── GET /api/v1/incidents/active  [Auth required] ───────────────────────────
func (h *Handler) GetActive(c *fiber.Ctx) error {
	reporterID := c.Locals("userID").(string)

	resp, err := h.svc.GetActive(reporterID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}
	if resp == nil {
		return utils.SuccessResponse(c, nil)
	}

	return utils.SuccessResponse(c, resp)
}

// ─── POST /api/v1/incidents/:id/resolve  [Auth required] ─────────────────────
func (h *Handler) Resolve(c *fiber.Ctx) error {
	responderID := c.Locals("userID").(string)

	id, err := parseID(c)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "ID insiden tidak valid")
	}

	resp, err := h.svc.Resolve(id, responderID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, err.Error())
	}

	return utils.SuccessResponse(c, resp)
}

// ─── helpers ──────────────────────────────────────────────────────────────────

func parseID(c *fiber.Ctx) (uint, error) {
	idStr := c.Params("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		return 0, errors.New("invalid id")
	}
	return uint(id), nil
}
