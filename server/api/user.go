package api

import (
	"fmt"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"

	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
	"github.com/tusharsadhwani/instachat/util"

	"log"

	jwt "github.com/form3tech-oss/jwt-go"
)

// User is what the API will use to represent DBUser
type User struct {
	Userid   int    `json:"id"`
	Name     string `json:"name"`
	GoogleID string `json:"googleID"`
}

// GetUsers gets all chats
func GetUsers(c *fiber.Ctx) error {
	db := database.GetDB()

	var users []User
	db.Model(&models.DBUser{}).Find(&users)

	return c.JSON(users)
}

// GetUserByID gets user by id
func GetUserByID(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var user User
	db.Where(&models.DBUser{Userid: &id}).Find(&user)
	if user.Userid == 0 {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	return c.JSON(user)
}

// LoginGoogle checks google ID token, creates a new user and responds with a JWT
func LoginGoogle(c *fiber.Ctx) error {
	db := database.GetDB()

	idToken := string(c.Body())

	idTokenMap, err := util.VerifyIDToken(idToken)
	if err != nil {
		return c.Status(503).SendString(err.Error())
	}

	type BodyParams struct {
		sub  string
		name string
	}

	bodyParams := BodyParams{
		sub:  idTokenMap.Claims["sub"].(string),
		name: idTokenMap.Claims["name"].(string),
	}

	var user User
	db.Where(&models.DBUser{GoogleID: &bodyParams.sub}).Find(&user)
	//TODO: check for errors instead of relying on zero value
	if user.Userid == 0 {
		// User doesn't already exist in DB
		dbuser := models.DBUser{
			Name:     &bodyParams.name,
			GoogleID: &bodyParams.sub,
		}

		//TODO: bruh moment. remove this loop
		for {
			userQuery := db.Create(&dbuser)
			if userQuery.Error == nil {
				break
			} else {
				log.Println(userQuery.Error)
			}
		}

		db.Where(&models.DBUser{Userid: dbuser.Userid}).First(&user)
	}

	token := jwt.New(jwt.SigningMethodRS256)

	// Set claims
	claims := token.Claims.(jwt.MapClaims)
	claims["name"] = user.Name
	claims["id"] = user.Userid
	claims["admin"] = true
	claims["exp"] = time.Now().Add(time.Hour * 72).Unix()

	config := config.GetConfig()
	// Generate encoded token and send it as response.
	t, err := token.SignedString(config.PrivateKey)
	if err != nil {
		log.Printf("token.SignedString: %v", err)
		return c.SendStatus(fiber.StatusInternalServerError)
	}

	return c.JSON(&fiber.Map{
		"user":  user,
		"token": t,
	})
}

// GetUserMessages gets all messages from a user
func GetUserMessages(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)

	dbuser := util.GetUserFromToken(userToken)

	var user User
	copier.Copy(&user, &dbuser)

	var messages []Message
	db := database.GetDB()
	db.Model(&dbuser).Association("Messages").Find(&messages)

	return c.JSON(messages)
}

// GetUserChats gets all chats
func GetUserChats(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)

	dbuser := util.GetUserFromToken(userToken)

	db := database.GetDB()
	var chats []Chat
	db.Model(&dbuser).Association("Chats").Find(&chats)

	return c.JSON(chats)
}

// GetUserCreatedChats gets all chats made by the user
func GetUserCreatedChats(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)

	dbuser := util.GetUserFromToken(userToken)

	db := database.GetDB()
	var chats []Chat
	db.Model(&dbuser).Association("CreatedChats").Find(&chats)

	return c.JSON(chats)
}
