package database

import (
	"fmt"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/constants"
	"github.com/tusharsadhwani/instachat/models"
)

var db *gorm.DB

// GetDB provides global access to the database
func GetDB() *gorm.DB {
	return db
}

// Init initializes the database
func Init() {
	cfg := config.GetConfig()

	dsn := fmt.Sprintf("user=%s password=%s database=%s port=%s sslmode=disable",
		cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort)
	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&models.DBChat{}, &models.DBMessage{}, &models.DBUser{}, &models.DBLike{})

	if cfg.Testing {
		SetupTestDB()
	}
}

func SetupTestDB() {
	db := GetDB()
	db.Exec("TRUNCATE chats RESTART IDENTITY CASCADE")
	db.Exec("TRUNCATE users RESTART IDENTITY CASCADE")
	db.Exec("TRUNCATE messages RESTART IDENTITY CASCADE")
	db.Exec("TRUNCATE likes RESTART IDENTITY CASCADE")

	dbuser := models.DBUser{
		Userid:   &constants.TestUserID,
		Name:     &constants.TestUserName,
		GoogleID: &constants.TestUserGoogleID,
	}
	db.Create(&dbuser)
}
