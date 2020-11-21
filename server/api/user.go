package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"

	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"

	"log"
	"time"

	jwt "github.com/form3tech-oss/jwt-go"
)

// User is what the API will use to represent DBUser
type User struct {
	Userid int    `json:"id"`
	Name   string `json:"name"`
}

// Login logs in the user by creating and returning a JWT
func Login(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.FormValue("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var user User
	res := db.Where(&models.DBUser{Userid: id}).First(&user)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	// TODO: implement password
	if false {
		return c.SendStatus(fiber.StatusUnauthorized)
	}

	// Create token
	token := jwt.New(jwt.SigningMethodRS256)

	// Set claims
	claims := token.Claims.(jwt.MapClaims)
	claims["name"] = user.Name
	claims["admin"] = true
	claims["exp"] = time.Now().Add(time.Hour * 72).Unix()

	// Generate encoded token and send it as response.
	t, err := token.SignedString(privateKey)
	if err != nil {
		log.Printf("token.SignedString: %v", err)
		return c.SendStatus(fiber.StatusInternalServerError)
	}

	return c.JSON(fiber.Map{"token": t})
}

// Restricted tests if a user is logged in
func Restricted(c *fiber.Ctx) error {
	user := c.Locals("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)
	name := claims["name"].(string)
	return c.SendString("Welcome " + name)
}

// GetUsers gets all chats
func GetUsers(c *fiber.Ctx) error {
	db := database.GetDB()

	var users []User
	db.Model(&models.DBUser{}).Find(&users)

	return c.JSON(users)
}

// GetUserByID gets user by id
func GetUserByID(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var user User
	res := db.Where(&models.DBUser{Userid: id}).First(&user)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	return c.JSON(user)
}

// CreateUser creates a new user
func CreateUser(c *fiber.Ctx) error {
	db := database.GetDB()

	type UserParams struct {
		Name string `json:"name"`
	}

	validateParams := func(params *UserParams) bool {
		if params.Name == "" {
			return false
		}

		return true
	}

	var params UserParams
	if err := c.BodyParser(&params); err != nil {
		return c.Status(503).SendString(err.Error())
	}
	if !validateParams(&params) {
		return c.Status(400).SendString("Invalid User Name")
	}

	var dbuser models.DBUser
	copier.Copy(&dbuser, &params)
	for {
		userQuery := db.Create(&dbuser)
		if userQuery.Error == nil {
			break
		}
	}

	var user User
	db.Where(&models.DBUser{Userid: dbuser.Userid}).First(&user)

	return c.JSON(user)
}

// GetUserMessages gets all messages from a user
func GetUserMessages(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var dbuser models.DBUser
	res := db.Where(&models.DBUser{Userid: id}).First(&dbuser)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	var messages []Message
	db.Model(&dbuser).Association("Messages").Find(&messages)

	return c.JSON(messages)
}
