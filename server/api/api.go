package api

import (
	"encoding/pem"
	"io/ioutil"
	"os"

	"crypto/rsa"
	"crypto/x509"

	"github.com/gofiber/fiber/v2"

	jwtware "github.com/gofiber/jwt/v2"
)

var privateKey *rsa.PrivateKey

// RunApp runs the server
func RunApp() {
	app := fiber.New(fiber.Config{
		Prefork: os.Getenv("GO_ENV") == "production",
	})

	InitStore()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World 👋!")
	})

	app.Get("/chat", GetChats)
	app.Get("/chat/:id", GetChatByID)
	app.Post("/chat", CreateChat)
	app.Delete("/chat/:id", DeleteChat)

	app.Get("/chat/:id/message", GetChatMessages)
	app.Post("/chat/:id/message", SendMessage)

	app.Get("/user", GetUsers)
	app.Get("/user/:id", GetUserByID)
	app.Post("/user", CreateUser)
	app.Get("/user/:id/message", GetUserMessages)

	privKeyBytes, e := ioutil.ReadFile("private.key")
	if e != nil {
		panic("No private key file found")
	}

	privPem, _ := pem.Decode(privKeyBytes)
	var privPemBytes []byte
	if privPem.Type != "RSA PRIVATE KEY" {
		panic("RSA private key is of the wrong type")
	}

	privPemBytes = privPem.Bytes

	var parsedKey interface{}
	if parsedKey, e = x509.ParsePKCS1PrivateKey(privPemBytes); e != nil {
		if parsedKey, e = x509.ParsePKCS8PrivateKey(privPemBytes); e != nil { // note this returns type `interface{}`
			panic("Unable to parse RSA private key")
		}
	}

	var ok bool
	privateKey, ok = parsedKey.(*rsa.PrivateKey)
	if !ok {
		panic("Unable to parse RSA private key")
	}

	// Login route
	app.Post("/login", Login)

	// JWT Middleware
	app.Use(jwtware.New(jwtware.Config{
		SigningMethod: "RS256",
		SigningKey:    privateKey.Public(),
	}))

	// Restricted Routes
	app.Get("/restricted", Restricted)

	app.Listen(":3000")
}
