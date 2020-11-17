package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// User is what the API will use to represent DBUser
type User struct {
	Userid int    `json:"id"`
	Name   string `json:"name"`
}

// GetUsers gets all chats
func GetUsers(c *fiber.Ctx) error {
	db := database.GetDB()

	var users []User
	db.Model(&models.DBChat{}).Find(&users)

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
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
	}

	return c.JSON(user)
}

// CreateUser creates a new user
func CreateUser(c *fiber.Ctx) error {
	db := database.GetDB()

	type ChatParams struct {
		Name string `json:"name"`
	}

	validateParams := func(params *ChatParams) bool {
		if params.Name == "" {
			return false
		}

		return true
	}

	var params ChatParams
	if err := c.BodyParser(&params); err != nil {
		return c.Status(503).SendString(err.Error())
	}
	if !validateParams(&params) {
		return c.Status(400).SendString("Invalid Chat Name")
	}

	var dbchat models.DBChat
	copier.Copy(&dbchat, &params)
	for {
		chatQuery := db.Create(&dbchat)
		if chatQuery.Error == nil {
			break
		}
	}

	var chat Chat
	db.Where(&models.DBChat{Chatid: dbchat.Chatid}).First(&chat)

	return c.JSON(chat)
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
