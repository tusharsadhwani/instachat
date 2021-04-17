package models

// DBMessage is the database model for messages in a chat
type DBMessage struct {
	ID       uint    `gorm:"primaryKey"`
	UUID     *string `gorm:"not null;unique"`
	Chatid   *int    `gorm:"not null"`
	Userid   *int    `gorm:"not null"`
	Text     *string
	ImageURL *string
	Likes    []DBLike `gorm:"foreignKey:Messageid;references:UUID"` //TODO: should reference ID
}

// TableName for DBChat
func (DBMessage) TableName() string {
	return "messages"
}
