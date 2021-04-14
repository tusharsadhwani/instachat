package util

import (
	"github.com/form3tech-oss/jwt-go"

	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

// GetUserFromToken finds user in db from auth token
func GetUserFromToken(token *jwt.Token) models.DBUser {
	db := database.GetDB()

	cfg := config.GetConfig()
	if cfg.Testing {
		var dbuser models.DBUser
		db.Where(&models.DBUser{}).First(&dbuser)
		return dbuser
	}

	claims := token.Claims.(jwt.MapClaims)

	userIDfloat := claims["id"].(float64)
	userID := int(userIDfloat)

	var dbuser models.DBUser
	db.Where(&models.DBUser{Userid: &userID}).Find(&dbuser)
	return dbuser
}
