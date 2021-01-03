package models

import "gorm.io/gorm"

// DBChat is a database model for chats in instachat
type DBChat struct {
	gorm.Model
	Chatid   int         `gorm:"primaryKey;unique;default:floor(random() * 9000000 + 1000000)::int"`
	Name     *string     `gorm:"not null"`
	Address  *string     `gorm:"not null;unique"`
	Messages []DBMessage `gorm:"foreignKey:Chatid;references:Chatid"`
	Users    []DBUser    `gorm:"many2many:user_chats"`
}

// TableName for DBChat
func (DBChat) TableName() string {
	return "chats"
}
