package main

import (
	"encoding/json"
	"fmt"
	"os"
	"testing"

	"github.com/gorilla/websocket"
	"github.com/tusharsadhwani/instachat/api"
	. "github.com/tusharsadhwani/instachat/testutils"
)

func TestMain(m *testing.M) {
	os.Setenv("GO_ENV", "TESTING")
	api.Init()

	go api.RunApp()
	m.Run()

	app := api.GetApp()
	app.Shutdown()
}

func TestHelloWorld(t *testing.T) {
	resp, err := HttpGetJson("https://localhost:5555")
	if err != nil {
		t.Fatal(err.Error())
	}
	output := string(resp)
	expected := "Hello, World 👋!"
	if output != expected {
		t.Fatalf("Expected %#v, got %#v", expected, output)
	}
}

func TestDatabase(t *testing.T) {
	testChat := api.Chat{
		Name:    "Test Chat",
		Address: "dbtestchat",
	}

	t.Run("create a chat and get all chats and chat by id", func(t *testing.T) {
		resp, err := HttpPostJson("https://localhost:5555/chat", testChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != testChat.Name || respChat.Address != testChat.Address {
			t.Fatalf("Expected %#v, got %#v", testChat, respChat)
		}

		url := fmt.Sprintf("https://localhost:5555/public/chat/%d", respChat.Chatid)
		resp, err = HttpGetJson(url)
		if err != nil {
			t.Fatal(err.Error())
		}
		json.Unmarshal(resp, &respChat)
		if respChat.Name != testChat.Name || respChat.Address != testChat.Address {
			t.Fatalf("Expected %#v, got %#v", testChat, respChat)
		}
	})

	t.Run("chat id 0 test", func(t *testing.T) {
		tempChat := api.Chat{
			Address: "chatid0test",
			Name:    "Temp Chat",
		}
		_, err := HttpPostJson("https://localhost:5555/chat", tempChat)
		if err != nil {
			t.Fatal(err.Error())
		}

		_, err = HttpGetJson("https://localhost:5555/public/chat/0")
		if err == nil {
			t.Fatal("Expected error 404, got nil")
		}
		expected := "error code 404: No Chat found with id: 0"
		if err.Error() != expected {
			t.Fatalf("Expected '%v', got '%v'", expected, err)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("https://localhost:5555/chat/%s", tempChat.Address))
		if err != nil {
			t.Fatal(err.Error())
		}
	})

	t.Run("delete a chat", func(t *testing.T) {
		deletionChat := api.Chat{
			Address: "deleteme",
			Name:    "Delete Me",
		}
		resp, err := HttpPostJson("https://localhost:5555/chat", deletionChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != deletionChat.Name || respChat.Address != deletionChat.Address {
			t.Fatalf("Expected %#v, got %#v", deletionChat, respChat)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("https://localhost:5555/chat/%s", deletionChat.Address))
		if err != nil {
			t.Fatal(err.Error())
		}

		_, err = HttpGetJson(fmt.Sprintf("https://localhost:5555/public/chat/%d", respChat.Chatid))
		if err == nil {
			t.Fatal("Expected error, found nil")
		}

		resp, err = HttpGetJson("https://localhost:5555/public/chat")
		if err != nil {
			t.Fatal(err.Error())
		}
		var chats []api.Chat
		json.Unmarshal(resp, &chats)
		if len(chats) != 1 {
			t.Fatalf("Expected 1 test chat to exist after deletion, found %d", len(chats))
		}
	})
}

func TestWebsockets(t *testing.T) {
	testChat := api.Chat{
		Name:    "Test Chat",
		Address: "wstestchat",
	}
	_, err := HttpPostJson("https://localhost:5555/chat", testChat)
	if err != nil {
		t.Fatal(err.Error())
	}

	t.Run("connect to websocket", func(t *testing.T) {
		url := fmt.Sprintf("https://localhost:5555/public/chat/@%s", testChat.Address)
		resp, err := HttpGetJson(url)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)

		url = fmt.Sprintf("wss://localhost:5555/ws/%d/chat/%d", api.TestUser.Userid, respChat.Chatid)
		conn, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn.Close()
		msgText := "henlo"
		msg := api.WebsocketParams{
			Type: "MESSAGE",
			Message: &api.Message{
				UUID:   "123456",
				Chatid: &respChat.Chatid,
				Userid: &api.TestUser.Userid,
				Text:   &msgText,
			},
		}
		msgBytes, _ := json.Marshal(msg)
		msgString := string(msgBytes)

		if err = conn.WriteJSON(msg); err != nil {
			t.Fatal(err.Error())
		}
		var recv api.WebsocketParams
		if err := conn.ReadJSON(&recv); err != nil {
			t.Fatal(err.Error())
		}
		recvBytes, _ := json.Marshal(recv)
		recvString := string(recvBytes)
		if recvString != msgString {
			t.Fatalf("Expected %#v, got %#v", msgString, recvString)
		}
	})
}
