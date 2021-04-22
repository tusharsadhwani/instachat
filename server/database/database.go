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

	if cfg.Testing && !cfg.NoDBFlush {
		SetupTestDB()
	}
}

func SetupTestDB() {
	db := GetDB()

	tables := []string{"chats", "users", "messages", "likes"}
	for _, tableName := range tables {
		db.Exec(fmt.Sprintf("TRUNCATE %s RESTART IDENTITY CASCADE", tableName))
	}

	dbuser := models.DBUser{
		Userid:   &constants.TestUserID,
		Name:     &constants.TestUserName,
		GoogleID: &constants.TestUserGoogleID,
	}
	db.Create(&dbuser)
	dbuser2 := models.DBUser{
		Userid:   &constants.TestUserID2,
		Name:     &constants.TestUserName2,
		GoogleID: &constants.TestUserGoogleID2,
	}
	db.Create(&dbuser2)
}
