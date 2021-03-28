package util

import (
	"context"

	"github.com/tusharsadhwani/instachat/config"
	"google.golang.org/api/idtoken"
)

// VerifyIDToken verifies a google id token generated on the frontend
func VerifyIDToken(token string) (*idtoken.Payload, error) {
	cfg := config.GetConfig()
	return idtoken.Validate(context.Background(), token, cfg.GCPClientID)
}
