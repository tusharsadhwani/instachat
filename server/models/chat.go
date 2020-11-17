package models

import "gorm.io/gorm"

// DBChat is a database model for chats in instachat
type DBChat struct {
	gorm.Model
	Chatid   int         `gorm:"primaryKey;unique;default:floor(random() * 9000000 + 1000000)::int"`
	Name     *string     `gorm:"not null"`
	Messages []DBMessage `gorm:"foreignKey:Chatid;references:Chatid"`
}

// TableName for DBChat
func (DBChat) TableName() string {
	return "chats"
}
