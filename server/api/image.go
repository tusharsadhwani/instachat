package api

import (
	"fmt"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofrs/uuid"
	"github.com/rhnvrm/simples3"
	"github.com/tusharsadhwani/instachat/config"
)

//GetImagePresignedURL generates a pre signed url for image upload on S3
func GetImagePresignedURL(c *fiber.Ctx) error {
	filename := c.Params("filename")

	cfg := config.GetConfig()

	s3 := simples3.New(cfg.S3Region, cfg.S3AccessKey, cfg.S3SecretKey)

	timestamp := time.Now()
	uuid, err := uuid.NewV4()
	if err != nil {
		return c.Status(500).SendString("Error in generating uuid")
	}
	randomHex := strings.ReplaceAll(uuid.String(), "-", "")
	objectKey := fmt.Sprintf("%x%s-%s", timestamp.Unix(), randomHex, filename)

	url := s3.GeneratePresignedURL(simples3.PresignedInput{
		Bucket:        cfg.S3Bucket,
		ObjectKey:     objectKey,
		Method:        "PUT",
		Timestamp:     timestamp,
		ExpirySeconds: 1000,
	})
	return c.SendString(url)
}
