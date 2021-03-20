package tests

import (
	"io/ioutil"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/database"
)

func TestMain(m *testing.M) {
	os.Setenv("GO_ENV", "TESTING")
	config.Init()
	database.Init()
	go api.RunApp()
	time.Sleep(2 * time.Second)

	m.Run()

	app := api.App()
	app.Shutdown()
}

func TestHelloWorld(t *testing.T) {
	resp, err := http.Get("https://localhost:5555")
	if err != nil {
		t.Error("Unable to make request")
	}
	body, _ := ioutil.ReadAll(resp.Body)
	if string(body) != "Hello, World 👋!" {
		t.Error("Failed hello world test.")
	}
}
