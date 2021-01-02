package api

import (
	"log"
	"os"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/websocket/v2"
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

	app.Get("/chat/:id/message", GetChatMessages)

	app.Get("/user", GetUsers)
	app.Get("/user/:id", GetUserByID)

	app.Post("/login", LoginGoogle)

	app.Use("/ws", func(c *fiber.Ctx) error {
		// IsWebSocketUpgrade returns true if the client
		// requested upgrade to the WebSocket protocol.
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	type RoomMember struct {
		id   int
		conn *websocket.Conn
	}
	type Room map[int]RoomMember
	rooms := make(map[int]Room)
	app.Get("/ws/:id/chat/:chatid", websocket.New(func(c *websocket.Conn) {
		// // c.Locals is added to the *websocket.Conn
		// log.Println(c.Locals("allowed"))  // true
		// log.Println(c.Params("id"))       // 123
		// log.Println(c.Query("v"))         // 1.0
		// log.Println(c.Cookies("session")) // ""

		userid, e := strconv.Atoi(c.Params("id"))
		if e != nil {
			log.Fatalln(e)
		}
		chatid, e := strconv.Atoi(c.Params("chatid"))
		if e != nil {
			log.Fatalln(e)
		}

		if rooms[chatid] == nil {
			rooms[chatid] = make(Room)
		}
		rooms[chatid][userid] = RoomMember{id: userid, conn: c}
		log.Println(rooms[chatid])

		// websocket.Conn bindings https://pkg.go.dev/github.com/fasthttp/websocket?tab=doc#pkg-index
		var (
			mt  int
			msg []byte
			err error
		)
		for {
			if mt, msg, err = c.ReadMessage(); err != nil {
				log.Println("read:", err)
				delete(rooms[chatid], userid)
				break
			}

			for _, member := range rooms[chatid] {
				conn := member.conn
				if err = conn.WriteMessage(mt, msg); err != nil {
					log.Println("write:", err)
					break
				}
			}
		}

	}))

	config := config.GetConfig()
	app.Use(jwtware.New(jwtware.Config{
		SigningMethod: "RS256",
		SigningKey:    config.PrivateKey.Public(),
	}))

	app.Get("/restricted", Restricted)

	app.Get("/user/:id/chat", GetUserChats)
	app.Get("/user/:id/message", GetUserMessages)

	app.Post("/chat", CreateChat)
	// app.Delete("/chat/:id", DeleteChat)

	app.Post("/chat/:id/message", SendMessage)

	app.Listen(":3000")
}
