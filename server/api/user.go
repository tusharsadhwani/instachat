package api

import (
	"fmt"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"

	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// User is what the API will use to represent DBUser
type User struct {
	Userid int    `json:"id"`
	Name   string `json:"name"`
}

// GetMe returns current logged in user
func GetMe(c *fiber.Ctx) error {
	store := GetStore()

	sess, err := store.Get(c)
	if err != nil {
		panic(err)
	}

	userid := sess.Get("user")
	return c.JSON(fiber.Map{
		"id": userid,
	})
}

// Login logs you in
func Login(c *fiber.Ctx) error {
	db := database.GetDB()
	store := GetStore()

	sess, err := store.Get(c)
	if err != nil {
		panic(err)
	}
	defer sess.Save()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var user User
	res := db.Where(&models.DBUser{Userid: id}).First(&user)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	sess.Set("user", user.Userid)
	return c.JSON(user)
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
	res := db.Where(&models.DBUser{Userid: id}).First(&user)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	return c.JSON(user)
}

// CreateUser creates a new user
func CreateUser(c *fiber.Ctx) error {
	db := database.GetDB()

	type UserParams struct {
		Name string `json:"name"`
	}

	validateParams := func(params *UserParams) bool {
		if params.Name == "" {
			return false
		}

		return true
	}

	var params UserParams
	if err := c.BodyParser(&params); err != nil {
		return c.Status(503).SendString(err.Error())
	}
	if !validateParams(&params) {
		return c.Status(400).SendString("Invalid User Name")
	}

	var dbuser models.DBUser
	copier.Copy(&dbuser, &params)
	for {
		userQuery := db.Create(&dbuser)
		if userQuery.Error == nil {
			break
		}
	}

	var user User
	db.Where(&models.DBUser{Userid: dbuser.Userid}).First(&user)

	return c.JSON(user)
}

// GetUserMessages gets all messages from a user
func GetUserMessages(c *fiber.Ctx) error {
	db := database.GetDB()

	idStr := c.Params("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		return c.Status(400).SendString("User ID must be an integer")
	}

	var dbuser models.DBUser
	res := db.Where(&models.DBUser{Userid: id}).First(&dbuser)
	if res.Error != nil {
		return c.Status(404).SendString(fmt.Sprintf("No User found with id: %v", id))
	}

	var messages []Message
	db.Model(&dbuser).Association("Messages").Find(&messages)

	return c.JSON(messages)
}
