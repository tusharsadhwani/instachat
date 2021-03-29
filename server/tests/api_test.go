package tests

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"testing"

	"github.com/tusharsadhwani/instachat/api"
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

	t.Run("create a chat", func(t *testing.T) {
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
	})

	t.Run("delete a chat", func(t *testing.T) {
		resp, err := HttpDeleteJson(fmt.Sprintf("https://localhost:5555/chat/%s", "test"))
		if err != nil {
			t.Fatal(err.Error())
		}
		fmt.Println("Response is:", string(resp))
		resp, err = HttpGetJson("https://localhost:5555/public/chat")
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
