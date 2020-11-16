package main

import (
	"github.com/tusharsadhwani/instachat/api"
	"github.com/tusharsadhwani/instachat/database"
)

func main() {
	database.Init()
	api.RunApp()
}
