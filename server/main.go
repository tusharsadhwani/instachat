package main

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// Chat is a database field for chats in instachat
type Chat struct {
	gorm.Model
	Chatid int    `gorm:"primaryKey;unique;default:floor(random() * 9000000 + 1000000)::int"`
	Name   string `gorm:"not null"`
}

func main() {
	dsn := "user=postgres password=password database=instachat port=5432 sslmode=disable TimeZone=Asia/Kolkata"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

	db.AutoMigrate(&Chat{})

	// Create
	for {
		chatQuery := db.Create(&Chat{Name: "Test Chat 2"})
		if chatQuery.Error == nil {
			break
		}
	}
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
}
