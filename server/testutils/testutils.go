package testutils

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/tusharsadhwani/instachat/database"
	"github.com/tusharsadhwani/instachat/models"
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

func InitTestDB() {
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

}
