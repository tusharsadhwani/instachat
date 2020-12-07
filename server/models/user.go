package models

import "gorm.io/gorm"

// DBUser is a database model for users in instachat
type DBUser struct {
	gorm.Model
	Userid   int         `gorm:"primaryKey;unique;default:floor(random() * 900000 + 100000)::int"`
	Name     *string     `gorm:"not null"`
	GoogleID *string     `gorm:"not null;unique"`
	Messages []DBMessage `gorm:"foreignKey:Userid;references:Userid"`
}

// TableName for DBUser
func (DBUser) TableName() string {
	return "users"
}
