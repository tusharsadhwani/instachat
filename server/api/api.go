package api

import (
	"fmt"
	"log"
	"path"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/websocket/v2"
	"github.com/tusharsadhwani/instachat/config"

	jwtware "github.com/gofiber/jwt/v2"
)

// App returns the fiber.App which runs the server
func App() *fiber.App {
	cfg := config.GetConfig()

	app := fiber.New()
	app.Use(cors.New())

	InitWebsocket()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	public := app.Group("/public")

	public.Get("/chat", GetChats)
	public.Get("/chat/:id", GetChatByID)
	public.Get("/chat/:id/message/:cursor?", GetPaginatedChatMessages)
	public.Get("/chat/:id/oldmessage/:cursor?", GetOlderChatMessages)
	public.Get("/chat/:id/message/all", GetChatMessages)

	public.Get("/user", GetUsers)
	public.Get("/user/:id", GetUserByID)

	public.Get("*", func(c *fiber.Ctx) error {
		return c.Status(404).SendString("404 Not found")
	})

	app.Post("/login", LoginGoogle)

	// Don't require authentication in test mode
	if cfg.Testing {
		app.Use(TestingAuthProvider)
	} else {
		app.Use(jwtware.New(jwtware.Config{
			SigningMethod: "RS256",
			SigningKey:    cfg.PrivateKey.Public(),
			TokenLookup:   "query:token,header:Authorization",
		}))
	}

	app.Get("/test", Test)

	app.Use("/ws", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/ws/:id/chat/:chatid", websocket.New(WebsocketUpdates))

	app.Get("/user/:id/chat", GetUserChats)
	app.Get("/user/:id/message", GetUserMessages)

	app.Post("/chat", CreateChat)
	app.Post("/chat/:address", JoinChat)

	app.Get("/image/:filename", GetImagePresignedURL)

	return app
}

// RunApp runs the server
func RunApp() {
	app := App()
	cfg := config.GetConfig()

	if cfg.Testing {
		fmt.Println("NOTE: App is running in test mode.")
	}
	err := app.ListenTLS(
		fmt.Sprintf(":%s", cfg.Port),
		path.Join(cfg.RootPath, "localhost.pem"),
		path.Join(cfg.RootPath, "localhost-key.pem"),
	)
	if err != nil {
		log.Fatalln(err)
	}
}
