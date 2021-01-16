package api

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/rhnvrm/simples3"
	"github.com/tusharsadhwani/instachat/config"
)

//GetPresignedURL generates a pre signed url for S3
func GetPresignedURL(c *fiber.Ctx) error {
	cfg := config.GetConfig()
	// fmt.Printf("%#v", cfg)

	s3 := simples3.New(cfg.S3Region, cfg.S3AccessKey, cfg.S3SecretKey)

	url := s3.GeneratePresignedURL(simples3.PresignedInput{
		Bucket:        cfg.S3Bucket,
		ObjectKey:     "test.txt",
		Method:        "PUT",
		Endpoint:      "/",
		Timestamp:     time.Now(),
		ExpirySeconds: 86400,
	})
	return c.SendString(url)
}
