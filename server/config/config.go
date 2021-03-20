package config

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

// Config object
type Config struct {
	// Absolute path of root directory
	RootPath string

	// What port the app runs on
	Port string

	// Tells if app is running in test mode
	Testing bool

	// Postgres parameters
	DBUser     string
	DBPassword string
	DBName     string
	DBPort     string

	// RSA Private key for JWT tokens
	PrivateKey *rsa.PrivateKey

	GCPClientID string

	S3Bucket    string
	S3Region    string
	S3AccessKey string
	S3SecretKey string
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
	goEnv, _ := os.LookupEnv("GO_ENV")
	testing := goEnv == "TESTING"
	if testing {
		fmt.Println("NOTE: App is running in test mode.")
	}

	var (
		rootPath string
		err      error
	)
	if testing {
		rootPath, err = filepath.Abs("..")
	} else {
		rootPath, err = filepath.Abs(".")
	}

	if err != nil {
		log.Fatalln("Weird error")
	}

	err = godotenv.Load(filepath.Join(rootPath, ".env"))
	if err != nil {
		log.Fatalln("Error loading .env file")
	}

	port := getEnvVar("PORT")

	DBUser := getEnvVar("DB_USER")
	DBPassword := getEnvVar("DB_PASSWORD")
	DBName := getEnvVar("DB_NAME")
	DBPort := getEnvVar("DB_PORT")

	GCPClientID := getEnvVar("GCP_CLIENT_ID")

	S3Bucket := getEnvVar("S3_BUCKET")
	S3Region := getEnvVar("S3_REGION")
	S3AccessKey := getEnvVar("S3_ACCESS_KEY")
	S3SecretKey := getEnvVar("S3_SECRET_KEY")

	privKeyBytes, err := ioutil.ReadFile(filepath.Join(rootPath, "config/keys/private.key"))
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
	privateKey, ok := parsedKey.(*rsa.PrivateKey)
	if !ok {
		log.Fatalln("Unable to parse RSA private key")
	}

	config = &Config{
		RootPath:    rootPath,
		Testing:     testing,
		Port:        port,
		DBUser:      DBUser,
		DBPassword:  DBPassword,
		DBName:      DBName,
		DBPort:      DBPort,
		PrivateKey:  privateKey,
		GCPClientID: GCPClientID,
		S3Bucket:    S3Bucket,
		S3Region:    S3Region,
		S3AccessKey: S3AccessKey,
		S3SecretKey: S3SecretKey,
	}
}
