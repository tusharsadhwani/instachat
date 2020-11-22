package config

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"io/ioutil"
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

	privKeyBytes, e := ioutil.ReadFile("private.key")
	if e != nil {
		panic("No private key file found")
	}

	privPem, _ := pem.Decode(privKeyBytes)
	var privPemBytes []byte
	if privPem.Type != "RSA PRIVATE KEY" {
		panic("RSA private key is of the wrong type")
	}

	privPemBytes = privPem.Bytes

	var parsedKey interface{}
	if parsedKey, e = x509.ParsePKCS1PrivateKey(privPemBytes); e != nil {
		if parsedKey, e = x509.ParsePKCS8PrivateKey(privPemBytes); e != nil { // note this returns type `interface{}`
			panic("Unable to parse RSA private key")
		}
	}

	var ok bool
	privateKey, ok = parsedKey.(*rsa.PrivateKey)
	if !ok {
		panic("Unable to parse RSA private key")
	}

	config = &Config{
		PrivateKey: privateKey,
	}
}
