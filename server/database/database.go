package database

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	m "github.com/tusharsadhwani/instachat/models"
)

var db *gorm.DB

// GetDB provides global access to the database
func GetDB() *gorm.DB {
	return db
}

// Init initializes the database
func Init() {
	dsn := "user=postgres password=password database=instachat port=5432 sslmode=disable TimeZone=Asia/Kolkata"
	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&m.DBChat{})
	db.AutoMigrate(&m.DBMessage{})
	db.AutoMigrate(&m.DBUser{})
}
