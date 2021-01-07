package api

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
	"github.com/tusharsadhwani/instachat/config"

	jwtware "github.com/gofiber/jwt/v2"
)

// RunApp runs the server
func RunApp() {
	app := fiber.New()

	InitWebsocket()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", GetChats)
	app.Get("/chat/:id", GetChatByID)

	app.Get("/chat/:id/message/:cursor?", GetPaginatedChatMessages)
	app.Get("/chat/:id/message/all", GetChatMessages)

	app.Get("/user", GetUsers)
	app.Get("/user/:id", GetUserByID)

	app.Post("/login", LoginGoogle)

	config := config.GetConfig()
	app.Use(jwtware.New(jwtware.Config{
		SigningMethod: "RS256",
		SigningKey:    config.PrivateKey.Public(),
	}))

	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/ws/:id/chat/:chatid", websocket.New(WebsocketUpdates))

	app.Get("/restricted", Restricted)

	app.Get("/user/:id/chat", GetUserChats)
	app.Get("/user/:id/message", GetUserMessages)

	app.Post("/chat", CreateChat)
	app.Post("/chat/:address", JoinChat)

	app.Listen(":3000")
}
