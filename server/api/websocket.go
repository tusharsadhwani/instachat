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
	Type      string   `json:"type"`
	Message   *Message `json:"message"`
	MessageID *string  `json:"messageId"`
}

// WebsocketUpdates receives all websocket updates in a chatroom
func WebsocketUpdates(c *websocket.Conn) {
	//TODO: do we really need to ask for userid? also check if it's the same user
	userid, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		log.Fatalln(err)
	}
	//TODO: verify person exists in the chat and so on
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

		//TODO: error handling
		switch params.Type {
		case "MESSAGE":
			savedMsg, _ := SaveMessage(chatid, userid, params.Message)
			params.Message.ID = savedMsg.ID
			msg, _ = json.Marshal(params)
		case "LIKE":
			LikeMessage(chatid, userid, *params.MessageID)
		case "UNLIKE":
			UnlikeMessage(chatid, userid, *params.MessageID)
		}

		for _, member := range chats[chatid] {
			if err = member.conn.WriteMessage(mt, msg); err != nil {
				log.Println("write:", err)
				break
			}
		}
	}

}
