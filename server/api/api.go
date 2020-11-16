package api

import (
	"fmt"
	"os"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"

	db "github.com/tusharsadhwani/instachat/database"
	m "github.com/tusharsadhwani/instachat/models"
)

// Chat is what the API will use to represent DBChat
type Chat struct {
	Chatid int    `json:"id"`
	Name   string `json:"name"`
}

// Message is what the API will use to represent DBMessage
type Message struct {
	ID     int    `json:"id"`
	Text   string `json:"text"`
	Chatid int    `json:"chatid"`
}

// RunApp runs the server
func RunApp() {
	db := db.GetDB()

	app := fiber.New(fiber.Config{
		Prefork: os.Getenv("GO_ENV") == "production",
	})

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", func(c *fiber.Ctx) error {
		var chats []Chat
		db.Model(&m.DBChat{}).Find(&chats)

		return c.JSON(chats)
	})

	app.Get("/chat/:id", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var chat Chat
		res := db.Model(&m.DBChat{}).Where(&m.DBChat{Chatid: id}).First(&chat)
		if res.Error != nil {
			return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
		}

		return c.JSON(chat)
	})

	app.Get("/chat/:id/message", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var dbchat m.DBChat
		res := db.Model(&m.DBChat{}).Where(&m.DBChat{Chatid: id}).First(&dbchat)
		if res.Error != nil {
			return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
		}

		var messages []Message
		db.Model(&dbchat).Association("Messages").Find(&messages)

		return c.JSON(messages)
	})

	app.Post("/chat", func(c *fiber.Ctx) error {
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

		var dbchat m.DBChat
		copier.Copy(&dbchat, &params)
		for {
			chatQuery := db.Create(&dbchat)
			if chatQuery.Error == nil {
				break
			}
		}

		var chat Chat
		db.Where(&m.DBChat{Chatid: dbchat.Chatid}).First(&chat)

		return c.JSON(chat)
	})

	app.Post("/chat/:id/message", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var dbchat m.DBChat
		res := db.Where(&m.DBChat{Chatid: id}).First(&dbchat)
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

		var dbmessage m.DBMessage
		copier.Copy(&dbmessage, &params)
		dbmessage.Chatid = dbchat.Chatid
		db.Create(&dbmessage)

		var message Message
		db.Where(&m.DBMessage{ID: dbmessage.ID}).First(&message)

		return c.JSON(message)
	})

	app.Delete("/chat/:id", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var dbchat m.DBChat
		res := db.Model(&m.DBChat{}).Where(&m.DBChat{Chatid: id}).First(&dbchat)
		if res.Error != nil {
			return c.Status(404).SendString(
				fmt.Sprintf("No Chat found with id: %v", id),
			)
		}

		db.Delete(&dbchat)
		return c.SendString("deleted succesfully")
	})

	app.Listen(":3000")
}
