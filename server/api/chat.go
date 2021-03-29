package api

import (
	"fmt"
	"regexp"
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
	Chatid  int    `json:"id"`
	Name    string `json:"name"`
	Address string `json:"address"`
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
	db.Where(&models.DBChat{Chatid: id}).Find(&chat)
	if chat.Chatid == 0 {
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
		Name    string `json:"name"`
		Address string `json:"address"`
	}

	validateParams := func(params *ChatParams) bool {
		if params.Name == "" {
			return false
		}

		if match, _ := regexp.MatchString(`^[A-Za-z]\w*$`, params.Address); !match {
			return false
		}

		return true
	}

	var params ChatParams
	if err := c.BodyParser(&params); err != nil {
		return c.Status(503).SendString(err.Error())
	}
	if !validateParams(&params) {
		return c.Status(400).SendString("Invalid Chat Info")
	}

	var existingChat models.DBChat
	db.Where(&models.DBChat{Address: &params.Address}).Find(&existingChat)
	if existingChat.ID != 0 {
		return c.Status(400).SendString(
			fmt.Sprintf("Chat with address %v already exists", *existingChat.Address),
		)
	}

	var dbchat models.DBChat
	copier.Copy(&dbchat, &params)
	//TODO: bruh moment #2. Remove this
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

// JoinChat adds you into a chat
func JoinChat(c *fiber.Ctx) error {
	db := database.GetDB()

	address := c.Params("address")

	var dbchat models.DBChat
	db.Where(&models.DBChat{Address: &address}).Find(&dbchat)
	if dbchat.ID == 0 {
		return c.Status(400).SendString(
			fmt.Sprintf("No chat found with address %v", address),
		)
	}

	userToken := c.Locals("user").(*jwt.Token)
	dbuser := util.GetUserFromToken(userToken)

	err := db.Model(&dbchat).Association("Users").Append(&dbuser)
	if err != nil {
		return c.Status(503).SendString(err.Error())
	}

	var chat Chat
	copier.Copy(&chat, &dbchat)
	return c.JSON(chat)
}

// DeleteChat deletes a chat
func DeleteChat(c *fiber.Ctx) error {
	db := database.GetDB()

	address := c.Params("address")

	var dbchat models.DBChat
	db.Where(&models.DBChat{Address: &address}).Find(&dbchat)
	if dbchat.ID == 0 {
		return c.Status(400).SendString(
			fmt.Sprintf("No chat found with address %v", address),
		)
	}

	// TODO: add chats cascade
	//
	// userToken := c.Locals("user").(*jwt.Token)
	// dbuser := util.GetUserFromToken(userToken)

	// err := db.Model(&dbuser).Association("Chats").Delete(&dbchat)
	// if err != nil {
	// 	return c.Status(503).SendString(err.Error())
	// }
	query := db.Delete(&dbchat)
	if query.Error != nil {
		return c.Status(503).SendString(query.Error.Error())
	}

	db.Delete(&dbchat)
	return c.SendString("deleted succesfully")
}
