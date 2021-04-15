package api

import (
	jwt "github.com/form3tech-oss/jwt-go"
	"github.com/gofiber/fiber/v2"
	"github.com/tusharsadhwani/instachat/constants"
)

var TestUser User = User{
	Userid:   constants.TestUserID,
	GoogleID: constants.TestUserGoogleID,
	Name:     constants.TestUserName,
}

func TestingAuthProvider(c *fiber.Ctx) error {
	user := jwt.Token{Claims: jwt.MapClaims{
		"sub":  constants.TestUserGoogleID,
		"name": constants.TestUserName,
	}}

	c.Locals("user", &user)
	return c.Next()
}

// TestLogin tests if a user is logged in
func TestLogin(c *fiber.Ctx) error {
	user := c.Locals("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)
	name := claims["name"].(string)
	return c.SendString("Welcome " + name)
}
