package tests

import (
	"io/ioutil"
	"net/http"
	"testing"
	"time"

	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/database"
)

// TestApi runs api tests
func TestApi(t *testing.T) {
	config.Init()
	database.Init()
	app := api.App()
	go api.RunApp()
	time.Sleep(2 * time.Second)

	// Run tests here
	resp, err := http.Get("https://localhost:5555")
	if err != nil {
		t.Error("Unable to make request")
	}
	body, _ := ioutil.ReadAll(resp.Body)
	if string(body) != "Hello, World 👋!" {
		t.Error("Failed hello world test.")
	}

	app.Shutdown()
}
