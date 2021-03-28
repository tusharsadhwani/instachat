package tests

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
)

func TestMain(m *testing.M) {
	os.Setenv("GO_ENV", "TESTING")
	api.Init()
	go api.RunApp()
	time.Sleep(2 * time.Second) //TODO: remove

	m.Run() //TODO: app.Shutdown() hangs forever
}

func TestHelloWorld(t *testing.T) {
	resp, err := http.Get("https://localhost:5555")
	if err != nil {
		t.Fatal(err.Error())
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	if string(body) != "Hello, World 👋!" {
		t.Fatal("Failed hello world test.")
	}
}

func TestDatabase(t *testing.T) {
	db := database.GetDB()
	db.Exec("TRUNCATE chats CASCADE")
	db.Exec("TRUNCATE users CASCADE")

	stringPtr := func(s string) *string {
		return &s
	}
	dbuser := models.DBUser{
		Name:     stringPtr("Test"),
		GoogleID: stringPtr("123"),
	}
	db.Create(&dbuser)

	resp, err := HttpGetJson("https://localhost:5555/public/chat")
	if err != nil {
		t.Fatal(err.Error())
	}
	chats := make([]api.Chat, 0)
	json.Unmarshal(resp, &chats)
	if len(chats) != 0 {
		t.Fatalf("Expected %#v, got %#v", []api.Chat{}, resp)
	}
	newChat := api.Chat{
		Name:    "Test Chat",
		Address: "test",
	}
	chatStr, _ := json.Marshal(newChat)
	newChatReader := strings.NewReader(string(chatStr))
	resp, err = HttpPostJson("https://localhost:5555/chat", newChatReader)
	if err != nil {
		t.Fatal(err.Error())
	}
	var respChat api.Chat
	json.Unmarshal(resp, &respChat)
	fmt.Printf("%#v\n", newChat)
	fmt.Printf("%#v\n", respChat)
	if respChat.Name != newChat.Name || respChat.Address != newChat.Address {
		t.Fatalf("Expected %#v, got %#v", newChat, respChat)
	}
}
