package util

import (
	"golang.org/x/oauth2"
	"google.golang.org/api/idtoken"
)

// VerifyIDToken verifies a google id token generated on the frontend
func VerifyIDToken(token string) (*idtoken.Payload, error) {
	clientID := "181268626679-scimje5ajeq47igno7k9t837mrv8l75f.apps.googleusercontent.com"
	return idtoken.Validate(oauth2.NoContext, token, clientID)
}
