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
var TestUser2 User = User{
	Userid:   constants.TestUserID2,
	GoogleID: constants.TestUserGoogleID2,
	Name:     constants.TestUserName2,
}

func TestingAuthProvider(c *fiber.Ctx) error {
	var userStruct User

	altUser := c.Query("testid")
	if altUser == "2" {
		userStruct = TestUser2
	} else {
		userStruct = TestUser
	}

	user := jwt.Token{Claims: jwt.MapClaims{
		"sub":  userStruct.GoogleID,
		"name": userStruct.Name,
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
