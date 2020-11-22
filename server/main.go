package main

import (
	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/config"
	"github.com/tusharsadhwani/instachat/database"
)

func main() {
	config.Init()
	database.Init()
	api.RunApp()
}
