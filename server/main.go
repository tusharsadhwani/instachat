package main

import (
	"fmt"
	"os"
	"strconv"

	"github.com/gofiber/fiber/v2"
	"github.com/jinzhu/copier"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// DBChat is a database model for chats in instachat
type DBChat struct {
	gorm.Model
	Chatid int    `gorm:"primaryKey;unique;default:floor(random() * 9000000 + 1000000)::int"`
	Name   string `gorm:"not null"`
}

// TableName for DBChat
func (DBChat) TableName() string {
	return "chats"
}

// Chat is what the API will use to represent ChatModel
type Chat struct {
	Chatid int    `json:"id"`
	Name   string `json:"name"`
}

func main() {
	dsn := "user=postgres password=password database=instachat port=5432 sslmode=disable TimeZone=Asia/Kolkata"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

	db.AutoMigrate(&DBChat{})

	// // Create
	// for {
	// 	chatQuery := db.Create(&DBChat{Name: "Test Chat 1"})
	// 	if chatQuery.Error == nil {
	// 		break
	// 	}
	// }

	// // Read
	// var product Test
	// db.First(&product, "code = ?", "D42") // find product with code D42

	// // Update - update product's price to 200
	// db.Model(&product).Update("Price", 200)
	// // Update - update multiple fields
	// db.Model(&product).Updates(Test{Price: 200, Code: "F42"}) // non-zero fields
	// db.Model(&product).Updates(map[string]interface{}{"Price": 200, "Code": "F42"})

	// fmt.Println(product)

	// // Delete - delete product
	// db.Delete(&product)

	app := fiber.New(fiber.Config{
		Prefork: os.Getenv("GO_ENV") == "production",
	})

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", func(c *fiber.Ctx) error {
		var chats []Chat
		db.Model(&DBChat{}).Find(&chats)

		return c.JSON(chats)
	})

	app.Get("/chat/:id", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var chat Chat
		res := db.Model(&DBChat{}).Where(&DBChat{Chatid: id}).First(&chat)
		if res.Error != nil {
			return c.Status(404).SendString(fmt.Sprintf("No Chat found with id: %v", id))
		}

		return c.JSON(chat)
	})

	app.Post("/chat", func(c *fiber.Ctx) error {
		type ChatParams struct {
			Name string `json:"name"`
		}

		validateParams := func(params *ChatParams) bool {
			if params.Name == "" {
				return false
			}

			return true
		}

		var params ChatParams
		if err := c.BodyParser(&params); err != nil {
			return c.Status(503).SendString(err.Error())
		}
		if !validateParams(&params) {
			return c.Status(400).SendString("Invalid Chat Name")
		}

		var dbchat DBChat
		copier.Copy(&dbchat, &params)
		for {
			chatQuery := db.Create(&dbchat)
			if chatQuery.Error == nil {
				break
			}
		}

		var chat Chat
		db.Model(&DBChat{}).Where(&DBChat{Chatid: dbchat.Chatid}).First(&chat)

		return c.JSON(chat)
	})

	app.Delete("/chat/:id", func(c *fiber.Ctx) error {
		idStr := c.Params("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			return c.Status(400).SendString("Chat ID must be an integer")
		}

		var dbchat DBChat
		res := db.Model(&DBChat{}).Where(&DBChat{Chatid: id}).First(&dbchat)
		if res.Error != nil {
			return c.Status(404).SendString(
				fmt.Sprintf("No Chat found with id: %v", id),
			)
		}

		db.Delete(&dbchat)
		return c.SendString("deleted succesfully")
	})

	app.Listen(":3000")
}
