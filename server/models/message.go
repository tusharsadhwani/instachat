package models

import "gorm.io/gorm"

// DBMessage is the database model for messages in a chat
type DBMessage struct {
	gorm.Model
	ID     int
	Chatid *int   `gorm:"not null"`
	Userid *int   `gorm:"not null"`
	Text   string `gorm:"not null"`
}

// TableName for DBChat
func (DBMessage) TableName() string {
	return "messages"
}
