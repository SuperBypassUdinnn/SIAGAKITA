package utils

import "github.com/gofiber/fiber/v2"

// APIResponse is the standard JSON envelope for all responses.
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// SuccessResponse returns HTTP 200 with data.
func SuccessResponse(c *fiber.Ctx, data interface{}) error {
	return c.Status(fiber.StatusOK).JSON(APIResponse{Success: true, Data: data})
}

// CreatedResponse returns HTTP 201 with data.
func CreatedResponse(c *fiber.Ctx, data interface{}) error {
	return c.Status(fiber.StatusCreated).JSON(APIResponse{Success: true, Data: data})
}

// ErrorResponse returns an error response with the given HTTP status and message.
func ErrorResponse(c *fiber.Ctx, status int, message string) error {
	return c.Status(status).JSON(APIResponse{Success: false, Message: message})
}
