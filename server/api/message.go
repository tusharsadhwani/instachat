package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// GetChatMessages gets all messages in a chat
func GetChatMessages(c *fiber.Ctx) error {
	db := database.GetDB()
	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	res := db.Model(&models.DBChat{}).Where(&models.DBChat{Chatid: id}).First(&dbchat)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
	}

	var messages []Message
	db.Model(&dbchat).Association("Messages").Find(&messages)

	return c.JSON(messages)
}

// SendMessage sends a message in the given chat
func SendMessage(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	res := db.Where(&models.DBChat{Chatid: id}).First(&dbchat)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
	}

	type MessageParams struct {
		Text string `json:"text"`
	}

	validateParams := func(params *MessageParams) bool {
		if params.Text == "" {
			return false
		}

		return true
	}

	var params MessageParams
	if err := c.BodyParser(&params); err != nil {
		return c.Status(503).SendString(err.Error())
	}
	if !validateParams(&params) {
		return c.Status(400).SendString("Invalid Message Body")
	}

	var dbmessage models.DBMessage
	copier.Copy(&dbmessage, &params)
	dbmessage.Chatid = dbchat.Chatid
	db.Create(&dbmessage)

	var message Message
	db.Where(&models.DBMessage{ID: dbmessage.ID}).First(&message)

	return c.JSON(message)
}
