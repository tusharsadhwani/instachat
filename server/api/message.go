package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// Message is what the API will use to represent DBMessage
type Message struct {
	ID     int    `json:"id"`
	UUID   string `json:"uuid"`
	Chatid *int   `json:"chatid"`
	Userid *int   `json:"userid"`
	Text   string `json:"text"`
	// Likes  []Like `json:"likes"`
	Liked bool `json:"liked"`
}

// Like is what the API will use to represent DBLike
type Like struct {
	ID        int    `json:"id"`
	Messageid string `json:"messageId"`
	Userid    int    `json:"userId"`
}

// GetChatMessages gets all messages in a chat
func GetChatMessages(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	res := db.Where(&models.DBChat{Chatid: id}).First(&dbchat)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
	}

	var dbmessages []models.DBMessage
	messages := make([]Message, 0, len(dbmessages))
	db.Model(&dbchat).Association("Messages").Find(&dbmessages)
	for _, dbmessage := range dbmessages {
		var likes []Like
		db.Model(dbmessage).Association("Likes").Find(&likes)

		var message Message
		copier.Copy(&message, &dbmessage)
		message.Liked = len(likes) > 0

		messages = append(messages, message)
	}
	return c.JSON(messages)
}

// MessageParams are the message params to be received from the client
type MessageParams struct {
	UUID   string `json:"uuid"`
	Userid int    `json:"userid"`
	Text   string `json:"text"`
}

// SaveMessage saves given message to the database
func SaveMessage(chatid int, userid int, params *MessageParams) (Message, error) {
	db := database.GetDB()

	var dbchat models.DBChat
	res := db.Where(&models.DBChat{Chatid: chatid}).First(&dbchat)
	if res.Error != nil {
		return Message{}, fmt.Errorf("No Chat found with id: %v", chatid)
	}
	var dbuser models.DBUser
	res = db.Where(&models.DBUser{Userid: userid}).First(&dbuser)
	if res.Error != nil {
		return Message{}, fmt.Errorf("No User found with id: %v", userid)
	}

	var dbmessage models.DBMessage
	copier.Copy(&dbmessage, &params)
	dbmessage.Chatid = &dbchat.Chatid
	dbmessage.Userid = &dbuser.Userid
	result := db.Create(&dbmessage)
	if result.Error != nil {
		return Message{}, result.Error
	}

	var message Message
	db.Where(&models.DBMessage{ID: dbmessage.ID}).First(&message)
	return message, nil
}

// LikeMessage likes a message
func LikeMessage(chatid int, likerid int, messageID string) error {
	db := database.GetDB()

	var dbuser models.DBUser
	res := db.Where(&models.DBUser{Userid: likerid}).First(&dbuser)
	if res.Error != nil {
		return fmt.Errorf("No User found with id: %v", likerid)
	}
	var dbchat models.DBChat
	res = db.Where(&models.DBChat{Chatid: chatid}).First(&dbchat)
	if res.Error != nil {
		return fmt.Errorf("No Chat found with id: %v", chatid)
	}
	var dbmessage models.DBMessage
	res = db.Where(
		&models.DBMessage{
			UUID: &messageID,
		}).First(&dbmessage)

	if res.Error != nil {
		return fmt.Errorf("No Message found with uuid: %v", messageID)
	}

	var dblike models.DBLike
	dblike.Messageid = messageID
	dblike.Userid = likerid
	db.Create(&dblike)

	return nil
}
