package config

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"io/ioutil"
	"log"
)

// Config object
type Config struct {
	PrivateKey *rsa.PrivateKey
}

var config *Config

// GetConfig gets the config
func GetConfig() *Config {
	return config
}

//Init initializes the config object
func Init() {
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
		PrivateKey: privateKey,
	}
}
