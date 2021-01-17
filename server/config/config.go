package config

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"io/ioutil"
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Config object
type Config struct {
	PrivateKey  *rsa.PrivateKey
	S3Bucket    string
	S3Region    string
	S3AccessKey string
	S3SecretKey string
	Port        string
}

var config *Config

// GetConfig gets the config
func GetConfig() *Config {
	return config
}

func getEnvVar(varname string) string {
	envvar, ok := os.LookupEnv(varname)
	if !ok {
		log.Fatalf("%s not found in environment variables\n", varname)
	}
	if envvar == "" {
		log.Printf("Warning: Environment variable %s is empty\n", varname)
	}
	return envvar
}

//Init initializes the config object
func Init() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Error loading .env file")
	}

	S3Bucket := getEnvVar("S3_BUCKET")
	S3Region := getEnvVar("S3_REGION")
	S3AccessKey := getEnvVar("S3_ACCESS_KEY")
	S3SecretKey := getEnvVar("S3_SECRET_KEY")
	port := getEnvVar("PORT")

	var privateKey *rsa.PrivateKey

	privKeyBytes, err := ioutil.ReadFile("config/keys/private.key")
	if err != nil {
		log.Fatalln("No private key file found. Generate it by running genkeys")
	}

	privPem, _ := pem.Decode(privKeyBytes)
	var privPemBytes []byte
	if privPem.Type != "RSA PRIVATE KEY" {
		log.Fatalln("RSA private key is of the wrong type")
	}

	privPemBytes = privPem.Bytes

	var parsedKey interface{}
	if parsedKey, err = x509.ParsePKCS1PrivateKey(privPemBytes); err != nil {
		if parsedKey, err = x509.ParsePKCS8PrivateKey(privPemBytes); err != nil {
			log.Fatalln("Unable to parse RSA private key")
		}
	}
	var ok bool
	if privateKey, ok = parsedKey.(*rsa.PrivateKey); !ok {
		log.Fatalln("Unable to parse RSA private key")
	}

	config = &Config{
		PrivateKey:  privateKey,
		S3Bucket:    S3Bucket,
		S3Region:    S3Region,
		S3AccessKey: S3AccessKey,
		S3SecretKey: S3SecretKey,
		Port:        port,
	}
}
