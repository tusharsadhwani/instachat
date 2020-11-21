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
	_db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	_db.AutoMigrate(&m.DBChat{})
	_db.AutoMigrate(&m.DBMessage{})
	_db.AutoMigrate(&m.DBUser{})

	db = _db
}
