package api

import (
	"fmt"
	"strconv"

	jwt "github.com/form3tech-oss/jwt-go"
	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
	"github.com/tusharsadhwani/instachat/util"
)

// Chat is what the API will use to represent DBChat
type Chat struct {
	Chatid int    `json:"id"`
	Name   string `json:"name"`
}

// GetChats gets all chats
func GetChats(c *fiber.Ctx) error {
	db := database.GetDB()

	var chats []Chat
	db.Model(&models.DBChat{}).Find(&chats)

	return c.JSON(chats)
}

// GetChatByID gets chat by id
func GetChatByID(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var chat Chat
	res := db.Where(&models.DBChat{Chatid: id}).First(&chat)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
	}

	return c.JSON(chat)
}

// CreateChat creates a new chat
func CreateChat(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	dbuser := util.GetUserFromToken(userToken)

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
	err := db.Model(&dbchat).Association("Users").Append(&dbuser)
	if err != nil {
		return c.Status(503).SendString(err.Error())
	}

	var chat Chat
	db.Where(&models.DBChat{Chatid: dbchat.Chatid}).First(&chat)

	return c.JSON(chat)
}

// DeleteChat deletes a chat
func DeleteChat(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	res := db.Model(&models.DBChat{}).Where(&models.DBChat{Chatid: id}).First(&dbchat)
	if res.Error != nil {
		return c.Status(404).SendString(
			fmt.Sprintf("No Chat found with id: %v", id),
		)
	}

	db.Delete(&dbchat)
	return c.SendString("deleted succesfully")
}
