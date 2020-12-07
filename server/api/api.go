package api

import (
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/tusharsadhwani/instachat/config"

	jwtware "github.com/gofiber/jwt/v2"
)

// RunApp runs the server
func RunApp() {
	app := fiber.New(fiber.Config{
		Prefork: os.Getenv("GO_ENV") == "production",
	})

	InitStore()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", GetChats)
	app.Get("/chat/:id", GetChatByID)
	app.Post("/chat", CreateChat)
	app.Delete("/chat/:id", DeleteChat)

	app.Get("/chat/:id/message", GetChatMessages)
	app.Post("/chat/:id/message", SendMessage)

	app.Get("/user", GetUsers)
	app.Get("/user/:id", GetUserByID)

	app.Post("/login", LoginGoogle)

	config := config.GetConfig()
	app.Use(jwtware.New(jwtware.Config{
		SigningMethod: "RS256",
		SigningKey:    config.PrivateKey.Public(),
	}))

	app.Get("/restricted", Restricted)

	app.Get("/user/:id/message", GetUserMessages)
	app.Get("/user/:id/chat", GetUserChats)

	app.Listen(":3000")
}
