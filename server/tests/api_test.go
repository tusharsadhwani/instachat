package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"testing"

	"github.com/tusharsadhwani/instachat/api"
	. "github.com/tusharsadhwani/instachat/testutils"
)

func TestMain(m *testing.M) {
	os.Setenv("GO_ENV", "TESTING")
	api.Init()
	InitTestDB()

	go api.RunApp()
	m.Run()

	app := api.GetApp()
	app.Shutdown()
}

func TestHelloWorld(t *testing.T) {
	resp, err := http.Get("https://localhost:5555")
	if err != nil {
		t.Fatal(err.Error())
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	output := string(raw)
	expected := "Hello, World 👋!"
	if output != expected {
		t.Fatalf("Expected %#v, got %#v", expected, output)
	}
}

func TestDatabase(t *testing.T) {
	t.Run("empty chats in the beginning", func(t *testing.T) {
		resp, err := HttpGetJson("https://localhost:5555/public/chat")
		if err != nil {
			t.Fatal(err.Error())
		}
		var chats []api.Chat
		json.Unmarshal(resp, &chats)
		if len(chats) != 0 {
			t.Fatalf("Expected %#v, got %#v", []api.Chat{}, resp)
		}
	})

	t.Run("create a chat and get all chats and chat by id", func(t *testing.T) {
		newChat := api.Chat{
			Name:    "Test Chat",
			Address: "test",
		}
		resp, err := HttpPostJson("https://localhost:5555/chat", newChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != newChat.Name || respChat.Address != newChat.Address {
			t.Fatalf("Expected %#v, got %#v", newChat, respChat)
		}

		url := fmt.Sprintf("https://localhost:5555/public/chat/%d", respChat.Chatid)
		resp, err = HttpGetJson(url)
		if err != nil {
			t.Fatal(err.Error())
		}
		json.Unmarshal(resp, &respChat)
		if respChat.Name != newChat.Name || respChat.Address != newChat.Address {
			t.Fatalf("Expected %#v, got %#v", newChat, respChat)
		}
		_, err = HttpGetJson("https://localhost:5555/public/chat/0")
		if err == nil {
			t.Fatal("Expected error 404, got nil")
		}
		expected := "error code 404: No Chat found with id: 0"
		if err.Error() != expected {
			t.Fatalf("Expected %v, got %v", expected, err)
		}
	})

	t.Run("delete a chat", func(t *testing.T) {
		_, err := HttpDeleteJson(fmt.Sprintf("https://localhost:5555/chat/%s", "test"))
		if err != nil {
			t.Fatal(err.Error())
		}
		resp, err := HttpGetJson("https://localhost:5555/public/chat")
		if err != nil {
			t.Fatal(err.Error())
		}
		var chats []api.Chat
		json.Unmarshal(resp, &chats)
		if len(chats) != 0 {
			t.Fatalf("Expected %#v, got %#v", []api.Chat{}, resp)
		}
	})
}
