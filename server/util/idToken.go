package util

import (
	"github.com/tusharsadhwani/instachat/config"
	"golang.org/x/oauth2"
	"google.golang.org/api/idtoken"
)

// VerifyIDToken verifies a google id token generated on the frontend
func VerifyIDToken(token string) (*idtoken.Payload, error) {
	cfg := config.GetConfig()
	return idtoken.Validate(oauth2.NoContext, token, cfg.GCPClientID)
}
