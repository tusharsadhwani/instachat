package api

import (
	"encoding/json"
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

	type ChatMember struct {
		id   int
		conn *websocket.Conn
	}
	type Chatroom map[int]ChatMember
	chats := make(map[int]Chatroom)
	app.Get("/ws/:id/chat/:chatid", websocket.New(func(c *websocket.Conn) {
		userid, err := strconv.Atoi(c.Params("id"))
		if err != nil {
			log.Fatalln(err)
		}
		chatid, err := strconv.Atoi(c.Params("chatid"))
		if err != nil {
			log.Fatalln(err)
		}

		if chats[chatid] == nil {
			chats[chatid] = make(Chatroom)
		}
		chats[chatid][userid] = ChatMember{id: userid, conn: c}

		// websocket.Conn bindings https://pkg.go.dev/github.com/fasthttp/websocket?tab=doc#pkg-index
		var (
			mt  int
			msg []byte
		)
		for {
			if mt, msg, err = c.ReadMessage(); err != nil {
				log.Println("read:", err)
				delete(chats[chatid], userid)
				break
			}

			type InputParams struct {
				UUID   string `json:"uuid"`
				Userid int    `json:"userid"`
				Text   string `json:"text"`
			}
			var inputParams InputParams
			json.Unmarshal(msg, &inputParams)

			msgParams := MessageParams{
				UUID: inputParams.UUID,
				Text: inputParams.Text,
			}
			SaveMessage(chatid, userid, msgParams)

			for _, member := range chats[chatid] {
				if err = member.conn.WriteMessage(mt, msg); err != nil {
					log.Println("write:", err)
					break
				}
			}
		}

	}))

	app.Get("/restricted", Restricted)

	app.Get("/user/:id/chat", GetUserChats)
	app.Get("/user/:id/message", GetUserMessages)

	app.Post("/chat", CreateChat)

	app.Listen(":3000")
}
