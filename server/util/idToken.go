package util

import (
	"golang.org/x/oauth2"
	"google.golang.org/api/idtoken"
)

func VerifyIDToken(token string) (*idtoken.Payload, error) {
	clientID := "630044970416-onhpqa1bk4c21ogbr2cjglcn0t0n8n5b.apps.googleusercontent.com"
	return idtoken.Validate(oauth2.NoContext, token, clientID)
}
