package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"github.com/tusharsadhwani/instachat/constants"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// Message is what the API will use to represent DBMessage
type Message struct {
	ID       int     `json:"id"`
	UUID     string  `json:"uuid"` //TODO: make *string
	Chatid   *int    `json:"chatid"`
	Userid   *int    `json:"userid"`
	Text     *string `json:"text"`
	ImageURL *string `json:"imageUrl"`
	// Likes  []Like `json:"likes"` //TODO: replace Liked
	Liked bool `json:"liked"`
}

/*
Issue:
	currently you can't get a message response object to be nested with chat object or user object:

		message: {
			id: 101,
			chat: {
				id: 14987292,
				name: "Test Chat",
				imageUrl: "...",
			},
			user: {
				id: 123456,
				name: "John Doe"
				imageUrl: "...",
			},
			text: "Hello"
		}

	Proposal: instead of doing

		db.Model(&dbmessage{ID: ...}).Find(&message)

	Do:

		db.Model(&DBMessage{ID: ...}).Find(&dbmessage)
		copier.Copy(&message, &dbmessages)

		db.Model(&DBUser{ID: dbmessage.Userid}).Find(&dbuser)
		copier.Copy(&user, &dbuser)
		message.User = user

		db.Model(&DBChat{ID: dbmessage.Chatid}).Find(&dbchat)
		copier.Copy(&chat, &dbchat)
		message.Chat = chat

I Don't think this is optimal at all.
*/

// Like is what the API will use to represent DBLike
type Like struct {
	ID        int    `json:"id"`
	Messageid string `json:"messageId"`
	Userid    int    `json:"userId"`
}

func fetchMessagesWithLikes(dbmessages []models.DBMessage) []Message {
	db := database.GetDB()

	messages := make([]Message, 0, len(dbmessages))
	for _, dbmessage := range dbmessages {
		var likes []Like
		db.Model(dbmessage).Association("Likes").Find(&likes)

		var message Message
		copier.Copy(&message, &dbmessage)
		message.Liked = len(likes) > 0

		messages = append(messages, message)
	}
	return messages
}

// GetChatMessages gets all messages in a chat
func GetChatMessages(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	chatid, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbchat.Chatid == nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", chatid))
	}

	var dbmessages []models.DBMessage
	db.Model(&dbchat).Association("Messages").Find(&dbmessages)

	messages := fetchMessagesWithLikes(dbmessages)
	return c.JSON(messages)
}

// GetPaginatedChatMessages gets a page of messages in a chat
func GetPaginatedChatMessages(c *fiber.Ctx) error {
	pageSize := constants.PageSize

	db := database.GetDB()

	idStr := c.Params("id")
	chatid, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbchat.Chatid == nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", chatid))
	}

	cursorStr := c.Params("cursor")
	var cursor int
	if cursorStr == "" {
		cursor = 0
	} else {
		cursor, err = strconv.Atoi(cursorStr)
	}
	if err != nil {
		return c.Status(400).SendString(
			fmt.Sprintf("Invalid cursor value: %v", cursorStr),
		)
	}

	var dbmessages []models.DBMessage
	query := db.Where("chatid = ?", chatid)
	if cursor != 0 {
		query = query.Where("id >= ?", cursor)
	}
	query.Order("id asc").Limit(pageSize + 1).Find(&dbmessages)

	var nextCursor int

	if len(dbmessages) < pageSize+1 {
		// We have no more results after current page, i.e. this is the last page
		nextCursor = -1
	} else {
		dbmessages = dbmessages[:pageSize]
		lastMessage := dbmessages[pageSize-1]
		nextCursor = int(lastMessage.ID) + 1
	}

	messages := fetchMessagesWithLikes(dbmessages)

	return c.JSON(fiber.Map{
		"messages": messages,
		"next":     nextCursor,
	})
}

// GetOlderChatMessages gets a page of older messages in a chat
func GetOlderChatMessages(c *fiber.Ctx) error {
	pageSize := constants.PageSize

	db := database.GetDB()

	idStr := c.Params("id")
	chatid, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("Chat ID must be an integer")
	}

	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbchat.Chatid == nil {
		return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", chatid))
	}

	query := db.Where("chatid = ?", chatid)

	cursorStr := c.Params("cursor")
	if cursorStr != "" {
		cursor, err := strconv.Atoi(cursorStr)
		if err != nil {
			return c.Status(400).SendString(
				fmt.Sprintf("Invalid cursor value: %v", cursorStr),
			)
		}
		query = query.Where("id <= ?", cursor)
	}

	var dbmessages []models.DBMessage
	query.Order("id desc").Limit(pageSize + 1).Find(&dbmessages)

	var nextCursor int

	if len(dbmessages) < pageSize+1 {
		// We have no more results after current page, i.e. this is the last page
		nextCursor = -1
	} else {
		dbmessages = dbmessages[:pageSize]
		lastMessage := dbmessages[pageSize-1]
		nextCursor = int(lastMessage.ID) - 1
	}

	messages := fetchMessagesWithLikes(dbmessages)

	return c.JSON(fiber.Map{
		"messages": messages,
		"next":     nextCursor,
	})
}

// SaveMessage saves given message to the database
func SaveMessage(chatid int, userid int, msg *Message) (Message, error) {
	db := database.GetDB()

	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbchat.Chatid == nil {
		return Message{}, fmt.Errorf("no Chat found with id: %v", chatid)
	}
	var dbuser models.DBUser
	db.Where(&models.DBUser{Userid: &userid}).Find(&dbuser)
	if dbuser.Userid == nil {
		return Message{}, fmt.Errorf("no User found with id: %v", userid)
	}

	var dbmessage models.DBMessage
	copier.Copy(&dbmessage, &msg)
	dbmessage.ID = 0 // will be decided by the database
	dbmessage.Chatid = dbchat.Chatid
	dbmessage.Userid = dbuser.Userid
	result := db.Create(&dbmessage)
	if result.Error != nil {
		return Message{}, result.Error
	}

	var message Message
	db.Where(
		&models.DBMessage{
			Chatid: dbmessage.Chatid,
			Userid: dbmessage.Userid,
			UUID:   dbmessage.UUID,
		},
	).First(&message)
	return message, nil
}

// LikeMessage likes a message
func LikeMessage(chatid int, likerid int, messageID string) error {
	db := database.GetDB()

	var dbuser models.DBUser
	db.Where(&models.DBUser{Userid: &likerid}).Find(&dbuser)
	if dbuser.Userid == nil {
		return fmt.Errorf("no User found with id: %v", likerid)
	}
	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbuser.Userid == nil {
		return fmt.Errorf("no Chat found with id: %v", chatid)
	}
	var dbmessage models.DBMessage
	db.Where(&models.DBMessage{UUID: &messageID}).Find(&dbmessage)

	if dbmessage.ID == 0 {
		return fmt.Errorf("no Message found with uuid: %v", messageID)
	}

	var dblike models.DBLike
	dblike.Messageid = messageID
	dblike.Userid = likerid
	db.Create(&dblike)

	return nil
}

// UnlikeMessage likes a message
func UnlikeMessage(chatid int, likerid int, messageID string) error {
	db := database.GetDB()

	var dbuser models.DBUser
	db.Where(&models.DBUser{Userid: &likerid}).Find(&dbuser)
	if dbuser.Userid == nil {
		return fmt.Errorf("no User found with id: %v", likerid)
	}
	var dbchat models.DBChat
	db.Where(&models.DBChat{Chatid: &chatid}).Find(&dbchat)
	if dbuser.Userid == nil {
		return fmt.Errorf("no Chat found with id: %v", chatid)
	}
	var dbmessage models.DBMessage
	db.Where(&models.DBMessage{UUID: &messageID}).Find(&dbmessage)

	if dbmessage.ID == 0 {
		return fmt.Errorf("no Message found with uuid: %v", messageID)
	}

	var dblike models.DBLike
	dblike.Messageid = messageID
	dblike.Userid = likerid
	db.Where(&dblike).Delete(&dblike)

	return nil
}
