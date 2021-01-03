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

// Message is what the API will use to represent DBMessage
type Message struct {
	ID     int    `json:"id"`
	UUID   string `json:"uuid"`
	Chatid *int   `json:"chatid"`
	Userid *int   `json:"userid"`
	Text   string `json:"text"`
}

// GetChatMessages gets all messages in a chat
func GetChatMessages(c *fiber.Ctx) error {
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

	var messages []Message
	db.Model(&dbchat).Association("Messages").Find(&messages)

	return c.JSON(messages)
}

// SendMessage sends a message in the given chat
func SendMessage(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	dbuser := util.GetUserFromToken(userToken)

	chatidStr := c.Params("id")
	chatid, err := strconv.Atoi(chatidStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	validateParams := func(params *MessageParams) bool {
		if len(params.UUID) != 36 {
			return false
		}
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

	message, err := SaveMessage(chatid, params, &dbuser)
	if err != nil {
		c.Status(503).SendString(err.Error())
	}

	return c.JSON(&message)
}

// MessageParams are the message params to be received from the client
type MessageParams struct {
	UUID string `json:"uuid"`
	Text string `json:"text"`
}

// SaveMessage ...
func SaveMessage(chatid int, params MessageParams, dbuser *models.DBUser) (Message, error) {
	db := database.GetDB()

	var dbchat models.DBChat
	res := db.Where(&models.DBChat{Chatid: chatid}).First(&dbchat)
	if res.Error != nil {
		return Message{}, fmt.Errorf("No Chat found with id: %v", chatid)
	}

	var dbmessage models.DBMessage
	copier.Copy(&dbmessage, &params)
	dbmessage.Chatid = &dbchat.Chatid
	dbmessage.Userid = &dbuser.Userid
	result := db.Create(&dbmessage)
	if result.Error != nil {
		return Message{}, result.Error
	}

	var message Message
	db.Where(&models.DBMessage{ID: dbmessage.ID}).First(&message)
	return message, nil
}
