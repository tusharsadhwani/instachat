package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"testing"

	"github.com/gorilla/websocket"
	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/constants"
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
	resp, err := HttpGetJson(Domain)
	if err != nil {
		t.Fatal(err.Error())
	}
	output := string(resp)
	expected := "Hello, World 👋!"
	if output != expected {
		t.Fatalf("Expected %q, got %q", expected, output)
	}
}

func TestLogin(t *testing.T) {
	t.Run("login test user", func(t *testing.T) {
		resp, err := HttpGetJson(fmt.Sprintf("%s/test", Domain))
		if err != nil {
			t.Fatal(err.Error())
		}
		output := string(resp)
		expected := fmt.Sprintf("Welcome %s", api.TestUser.Name)
		if output != expected {
			t.Fatalf("Expected %q, got %q", expected, output)
		}
	})

	t.Run("login test user 2", func(t *testing.T) {
		resp, err := HttpGetJson(fmt.Sprintf("%s/test?testid=2", Domain))
		if err != nil {
			t.Fatal(err.Error())
		}
		output := string(resp)
		expected := fmt.Sprintf("Welcome %s", api.TestUser2.Name)
		if output != expected {
			t.Fatalf("Expected %q, got %q", expected, output)
		}
	})
}

func TestChats(t *testing.T) {
	testChat := api.Chat{
		Name:    "Test Chat",
		Address: "dbtestchat",
	}

	t.Run("create a chat and get chat by id", func(t *testing.T) {
		resp, err := HttpPostJson(fmt.Sprintf("%s/chat", Domain), testChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != testChat.Name || respChat.Address != testChat.Address {
			t.Fatalf("Expected %#v, got %#v", testChat, respChat)
		}

		url := fmt.Sprintf("%s/public/chat/%d", Domain, respChat.Chatid)
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
		_, err := HttpPostJson(fmt.Sprintf("%s/chat", Domain), tempChat)
		if err != nil {
			t.Fatal(err.Error())
		}

		_, err = HttpGetJson(fmt.Sprintf("%s/public/chat/0", Domain))
		if err == nil {
			t.Fatal("Expected error 404, got nil")
		}
		expected := "error code 404: No Chat found with id: 0"
		if err.Error() != expected {
			t.Fatalf("Expected '%v', got '%v'", expected, err)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("%s/chat/%s", Domain, tempChat.Address))
		if err != nil {
			t.Fatal(err.Error())
		}
	})

	t.Run("delete a chat", func(t *testing.T) {
		deletionChat := api.Chat{
			Address: "deleteme",
			Name:    "Delete Me",
		}
		resp, err := HttpPostJson(fmt.Sprintf("%s/chat", Domain), deletionChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != deletionChat.Name || respChat.Address != deletionChat.Address {
			t.Fatalf("Expected %#v, got %#v", deletionChat, respChat)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("%s/chat/%s", Domain, deletionChat.Address))
		if err != nil {
			t.Fatal(err.Error())
		}

		_, err = HttpGetJson(fmt.Sprintf("%s/public/chat/%d", Domain, respChat.Chatid))
		if err == nil {
			t.Fatal("Expected error, found nil")
		}

		resp, err = HttpGetJson(fmt.Sprintf("%s/public/chat", Domain))
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

func TestUsers(t *testing.T) {
	userOneChat := api.Chat{
		Name:    "Test User 1's Chat",
		Address: "user1chat",
	}
	userTwoChat := api.Chat{
		Name:    "Test User 2's Chat",
		Address: "user2chat",
	}

	t.Run("create chat with user 1", func(t *testing.T) {
		resp, err := HttpPostJson(fmt.Sprintf("%s/chat", Domain), userOneChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != userOneChat.Name || respChat.Address != userOneChat.Address {
			t.Fatalf("Expected %#v, got %#v", userOneChat, respChat)
		}
		if respChat.Creatorid != api.TestUser.Userid {
			t.Fatalf("Expected creator id %d, got %d", api.TestUser.Userid, respChat.Creatorid)
		}
	})

	t.Run("create and delete chat with user 2", func(t *testing.T) {
		resp, err := HttpPostJson(fmt.Sprintf("%s/chat?testid=2", Domain), userTwoChat)
		if err != nil {
			t.Fatal(err.Error())
		}
		var respChat api.Chat
		json.Unmarshal(resp, &respChat)
		if respChat.Name != userTwoChat.Name || respChat.Address != userTwoChat.Address {
			t.Fatalf("Expected %#v, got %#v", userTwoChat, respChat)
		}
		if respChat.Creatorid != api.TestUser2.Userid {
			t.Fatalf("Expected creator id %d, got %d", api.TestUser2.Userid, respChat.Creatorid)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("%s/chat/%s", Domain, userTwoChat.Address))
		if err == nil {
			t.Fatal("Expected error, got nil")
		}
		expected := "error code 403: 403 Forbidden"
		if err.Error() != expected {
			t.Fatalf("Expected %q ,got %q", expected, err)
		}

		_, err = HttpDeleteJson(fmt.Sprintf("%s/chat/%s?testid=2", Domain, userTwoChat.Address))
		if err != nil {
			t.Fatal(err)
		}
	})
}

func TestWebsockets(t *testing.T) {
	testChat := api.Chat{
		Name:    "Test Chat",
		Address: "wstestchat",
	}
	_, err := HttpPostJson(fmt.Sprintf("%s/chat", Domain), testChat)
	if err != nil {
		t.Fatal(err.Error())
	}

	url := fmt.Sprintf("%s/public/chat/@%s", Domain, testChat.Address)
	resp, err := HttpGetJson(url)
	if err != nil {
		t.Fatal(err.Error())
	}
	var respChat api.Chat
	json.Unmarshal(resp, &respChat)
	testChat.Chatid = respChat.Chatid
	testChat.Creatorid = respChat.Creatorid

	t.Run("send a couple messages", func(t *testing.T) {
		url := fmt.Sprintf("%s/ws/chat/%d", WSDomain, testChat.Chatid)
		conn, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn.Close()
		defer conn.WriteMessage(websocket.CloseMessage, nil)

		testUser := api.TestUser

		msgText := "henlo"
		msg := api.WebsocketParams{
			Type: constants.NewMessage,
			Message: &api.Message{
				UUID:   fmt.Sprintf("%d", rand.Uint64()),
				Chatid: &testChat.Chatid,
				Userid: &testUser.Userid,
				Text:   &msgText,
			},
		}
		_, err = WSSendMessageAndVerify(conn, msg, testUser, testChat)
		if err != nil {
			t.Fatal(err)
		}

		msgText = "Non id pariatur dolor id Lorem ex enim proident cillum eiusmod exercitation. Laboris ut adipisicing qui minim fugiat id cupidatat velit aliquip esse commodo consequat. Excepteur deserunt duis cupidatat mollit commodo labore incididunt. Eu reprehenderit nisi commodo occaecat velit. Consequat ex officia dolor cillum exercitation incididunt occaecat ea. Culpa est veniam eiusmod aute ad adipisicing duis veniam commodo mollit exercitation dolor incididunt et."
		msg = api.WebsocketParams{
			Type: constants.NewMessage,
			Message: &api.Message{
				UUID:   fmt.Sprintf("%d", rand.Uint64()),
				Chatid: &testChat.Chatid,
				Userid: &testUser.Userid,
				Text:   &msgText,
			},
		}
		_, err = WSSendMessageAndVerify(conn, msg, testUser, testChat)
		if err != nil {
			t.Fatal(err)
		}
	})

	t.Run("send message with second user", func(t *testing.T) {
		url := fmt.Sprintf("%s/ws/chat/%d?testid=2", WSDomain, testChat.Chatid)
		conn, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn.Close()
		defer conn.WriteMessage(websocket.CloseMessage, nil)

		testUser := api.TestUser2
		msgText := ":D"
		msg := api.WebsocketParams{
			Type: constants.NewMessage,
			Message: &api.Message{
				UUID:   fmt.Sprintf("%d", rand.Uint64()),
				Chatid: &testChat.Chatid,
				Userid: &testUser.Userid,
				Text:   &msgText,
			},
		}
		_, err = WSSendMessageAndVerify(conn, msg, testUser, testChat)
		if err != nil {
			t.Fatal(err)
		}
	})

	t.Run("verify all connections receive message", func(t *testing.T) {
		testUser := api.TestUser
		msgText := "Eiusmod et veniam nulla fugiat in voluptate ullamco magna sit excepteur ex anim nulla."

		msg := api.WebsocketParams{
			Type: constants.NewMessage,
			Message: &api.Message{
				UUID:   fmt.Sprintf("%d", rand.Uint64()),
				Chatid: &testChat.Chatid,
				Userid: &testUser.Userid,
				Text:   &msgText,
			},
		}

		url := fmt.Sprintf("%s/ws/chat/%d", WSDomain, testChat.Chatid)
		conn, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn.Close()
		defer conn.WriteMessage(websocket.CloseMessage, nil)

		url2 := fmt.Sprintf("%s/ws/chat/%d?testid=2", WSDomain, testChat.Chatid)
		conn2, _, err := websocket.DefaultDialer.Dial(url2, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn2.Close()
		defer conn2.WriteMessage(websocket.CloseMessage, nil)

		recvMsg, err := WSSendMessageAndVerify(conn, msg, testUser, testChat)
		if err != nil {
			t.Fatal(err)
		}

		var recv2 api.WebsocketParams
		if err := conn2.ReadJSON(&recv2); err != nil {
			t.Fatal(err)
		}

		recvBytes, _ := json.Marshal(recvMsg)
		recvString := string(recvBytes)
		recv2Bytes, _ := json.Marshal(recv2)
		recv2String := string(recv2Bytes)
		if recvString != recv2String {
			t.Fatalf("expected %q, got %q", recvString, recv2String)
		}
	})

	t.Run("like a message", func(t *testing.T) {
		url = fmt.Sprintf("%s/public/chat/%d/message", Domain, testChat.Chatid)
		resp, err := HttpGetJson(url)
		if err != nil {
			t.Fatal(err)
		}

		var respMessagePage struct {
			Messages []api.Message
			Next     int
		}
		json.Unmarshal(resp, &respMessagePage)
		if len(respMessagePage.Messages) == 0 {
			t.Fatal("expected messages, got empty list")
		}
		messageIndex := rand.Intn(len(respMessagePage.Messages))
		message := respMessagePage.Messages[messageIndex]
		if message.Liked {
			t.Fatal("Expected message to not already be liked")
		}

		messageID := strconv.Itoa(message.ID)
		msg := api.WebsocketParams{
			Type:      constants.MessageLiked,
			MessageID: &message.UUID,
		}

		url := fmt.Sprintf("%s/ws/chat/%d", WSDomain, testChat.Chatid)
		conn, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn.Close()
		defer conn.WriteMessage(websocket.CloseMessage, nil)
		url = fmt.Sprintf("%s/ws/chat/%d?testid=2", WSDomain, testChat.Chatid)
		conn2, _, err := websocket.DefaultDialer.Dial(url, nil)
		if err != nil {
			t.Fatal(err.Error())
		}
		defer conn2.Close()
		defer conn2.WriteMessage(websocket.CloseMessage, nil)

		if err := conn.WriteJSON(msg); err != nil {
			t.Fatal(err)
		}
		var recv api.WebsocketParams
		if err := conn.ReadJSON(&recv); err != nil {
			t.Fatal(err)
		}

		msgBytes, _ := json.Marshal(msg)
		msgString := string(msgBytes)
		recvBytes, _ := json.Marshal(recv)
		recvString := string(recvBytes)
		if msgString != recvString {
			t.Fatalf("expected %q, got %q", msgString, recvString)
		}

		var recv2 api.WebsocketParams
		if err := conn2.ReadJSON(&recv2); err != nil {
			t.Fatal(err)
		}
		recv2Bytes, _ := json.Marshal(recv2)
		recv2String := string(recv2Bytes)
		if recvString != recv2String {
			t.Fatalf("expected %q, got %q", recvString, recv2String)
		}

		url = fmt.Sprintf("%s/public/chat/%d/message/%s", Domain, testChat.Chatid, messageID)
		resp, err = HttpGetJson(url)
		if err != nil {
			t.Fatal(err)
		}
		json.Unmarshal(resp, &respMessagePage)
		if len(respMessagePage.Messages) == 0 {
			t.Fatal("expected messages, got empty list")
		}
		message = respMessagePage.Messages[0]
		if !message.Liked {
			t.Fatal("Expected message to be liked, but it isn't")
		}
	})
}

// TODO: Unlike
// TODO: Reject sent messages if user not in group
// TODO: Join Group
// TODO: Message pagination
// TODO: Presigned URLs and image uploads
