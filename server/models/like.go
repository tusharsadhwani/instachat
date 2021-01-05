package models

import "gorm.io/gorm"

// DBLike is the database model for a like on a message in a chat
type DBLike struct {
	gorm.Model
	ID        int
	Messageid string
	Userid    int
}

// TableName for DBLike
func (DBLike) TableName() string {
	return "likes"
}
