package testutils

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/gorilla/websocket"
	"github.com/tusharsadhwani/instachat/api"
)

func HttpGetJson(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("error code %v: %s", resp.StatusCode, body)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	return body, nil
}

func HttpDeleteJson(url string) ([]byte, error) {
	client := &http.Client{}
	req, err := http.NewRequest(http.MethodDelete, url, http.NoBody)
	if err != nil {
		return nil, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("error code %v: %v", resp.StatusCode, resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	return body, nil
}

func HttpPostJson(url string, reqBody interface{}) ([]byte, error) {
	reqStr, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}
	reqReader := strings.NewReader(string(reqStr))
	resp, err := http.Post(url, "application/json", reqReader)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("error code %v: %v", resp.StatusCode, resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	return body, nil
}

func WSSendAndVerify(
	conn *websocket.Conn,
	msg api.WebsocketParams,
	user api.User,
	chat api.Chat,
) (*api.WebsocketParams, error) {
	if err := conn.WriteJSON(msg); err != nil {
		return nil, err
	}
	var recv api.WebsocketParams
	if err := conn.ReadJSON(&recv); err != nil {
		return nil, err
	}
	recvBytes, _ := json.Marshal(recv)
	var recvMsg api.WebsocketParams
	json.Unmarshal(recvBytes, &recvMsg)

	if recvMsg.Message.ID == 0 {
		return nil, errors.New("received message id 0")
	}
	msg.Message.ID = recvMsg.Message.ID

	msgBytes, _ := json.Marshal(msg)
	msgString := string(msgBytes)
	recvString := string(recvBytes)
	if recvString != msgString {
		return nil, fmt.Errorf("expected %q, got %q", msgString, recvString)
	}

	url := fmt.Sprintf("https://localhost:5555/public/chat/%d/message/%d", chat.Chatid, recv.Message.ID)
	resp, err := HttpGetJson(url)
	if err != nil {
		return nil, err
	}

	var respMessagePage struct {
		Messages []api.Message
		Next     int
	}

	err = json.Unmarshal(resp, &respMessagePage)
	if err != nil {
		return nil, err
	}

	if len(respMessagePage.Messages) == 0 {
		return nil, fmt.Errorf("expected messages, got empty list")
	}
	respMessage := respMessagePage.Messages[0]
	if respMessage.Text == nil {
		return nil, fmt.Errorf("message text: expected %q, got nil", *msg.Message.Text)
	}

	respBytes, err := json.Marshal(respMessage)
	if err != nil {
		return nil, err
	}
	respString := string(respBytes)

	msg.Message.ID = respMessage.ID
	msgBytes, err = json.Marshal(msg.Message)
	if err != nil {
		return nil, err
	}
	msgString = string(msgBytes)

	if respString != msgString {
		return nil, fmt.Errorf("expected message %q, got %q", msgString, respString)
	}

	return &recv, nil
}
