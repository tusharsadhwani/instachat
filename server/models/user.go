package models

// DBUser is a database model for users in instachat
type DBUser struct {
	ID           uint        `gorm:"primaryKey"`
	Userid       *int        `gorm:"primaryKey;unique;default:floor(random() * 900000 + 100000)::int"`
	Name         *string     `gorm:"not null;primaryKey"`
	GoogleID     *string     `gorm:"not null;unique"`
	Messages     []DBMessage `gorm:"foreignKey:Userid;references:Userid"`
	Chats        []DBChat    `gorm:"many2many:user_chats"`
	Likes        []DBLike    `gorm:"foreignKey:Userid;references:Userid"`
	CreatedChats []DBChat    `gorm:"foreignKey:Creatorid;references:Userid"`
}

// TableName for DBUser
func (DBUser) TableName() string {
	return "users"
}
