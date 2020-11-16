package api

import (
	"os"

	"github.com/gofiber/fiber/v2"
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
	app := fiber.New(fiber.Config{
		Prefork: os.Getenv("GO_ENV") == "production",
	})

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", GetChats)
	app.Get("/chat/:id", GetChatByID)
	app.Post("/chat", CreateChat)
	app.Delete("/chat/:id", DeleteChat)

	app.Get("/chat/:id/message", GetChatMessages)
	app.Post("/chat/:id/message", SendMessage)

	app.Listen(":3000")
}
