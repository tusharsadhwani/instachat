package api

import (
	jwt "github.com/form3tech-oss/jwt-go"
	"github.com/gofiber/fiber/v2"
)

func TestingAuthProvider(c *fiber.Ctx) error {
	user := jwt.Token{Claims: jwt.MapClaims{
		"sub":   "123",
		"name":  "Test user",
		"email": "test@example.com",
	}}
	c.Locals("user", &user)
	return c.Next()
}

// Test tests if a user is logged in
func Test(c *fiber.Ctx) error {
	user := c.Locals("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)
	name := claims["name"].(string)
	return c.SendString("Welcome " + name)
}
