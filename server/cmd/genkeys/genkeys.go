package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

func generateRsaKeyPair() *rsa.PrivateKey {
	privkey, _ := rsa.GenerateKey(rand.Reader, 4096)
	return privkey
}

func stringifyPrivateKey(privkey *rsa.PrivateKey) string {
	privKeyBytes := x509.MarshalPKCS1PrivateKey(privkey)
	privKeyPem := pem.EncodeToMemory(
		&pem.Block{
			Type:  "RSA PRIVATE KEY",
			Bytes: privKeyBytes,
		},
	)
	return string(privKeyPem)
}

func main() {
	priv := generateRsaKeyPair()
	privString := stringifyPrivateKey(priv)
	err := os.MkdirAll("config/keys", os.ModePerm)
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile("config/keys/private.key", []byte(privString), 0644)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Sucess! key saved in config/keys/private.key")
}
