package api

import (
	"encoding/json"
	"log"
	"strconv"

	"github.com/gofiber/websocket/v2"
)

// ChatMember describes the data of a member in a chatroom
type ChatMember struct {
	id   int
	conn *websocket.Conn
}

// Chatroom is a mapping of all members connected in a chat via websockets
type Chatroom map[int]ChatMember

var chats map[int]Chatroom

// InitWebsocket initializes resources for websocket server
func InitWebsocket() {
	chats = make(map[int]Chatroom)
}

// WebsocketParams defines the shape of the json received over websockets
type WebsocketParams struct {
	Type      string        `json:"type"`
	Message   MessageParams `json:"message"`
	MessageID string        `json:"messageId"`
}

// WebsocketUpdates receives all websocket updates in a chatroom
func WebsocketUpdates(c *websocket.Conn) {
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

		var params WebsocketParams
		json.Unmarshal(msg, &params)
		msgParams := MessageParams{
			UUID: params.Message.UUID,
			Text: params.Message.Text,
		}

		switch params.Type {
		case "MESSAGE":
			SaveMessage(chatid, userid, &msgParams)
		case "LIKE":
			LikeMessage(chatid, userid, params.MessageID)
		}

		for _, member := range chats[chatid] {
			if err = member.conn.WriteMessage(mt, msg); err != nil {
				log.Println("write:", err)
				break
			}
		}
	}

}
