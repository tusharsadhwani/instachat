package api

import "github.com/gofiber/fiber/v2/middleware/session"

var store *session.Store

// GetStore returns global session store
func GetStore() *session.Store {
	return store
}

// InitStore initialises session store
func InitStore() {
	store = session.New()
}
