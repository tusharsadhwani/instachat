package main

import (
	api "github.com/tusharsadhwani/instachat/api"
	db "github.com/tusharsadhwani/instachat/database"
)

func main() {
	db.Init()
	api.RunApp()
}
