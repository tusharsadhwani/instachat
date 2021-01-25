# InstaChat

A working replica of Instagram DMs and stories, written in Flutter and Go.

> **Note:** This is currently a work in progress.

## Deploy your own

To deploy your own, you'll need an Amazon S3 bucket, a domain name and a VPS/cloud server. You can get all of these for free for limited use.

### Server

- Create an AWS S3 bucket for media hosting:

  - Be sure to un-check "Block all public access".

  - Add the following bucket policy, to allow public read access:

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::<bucket name>/*"
        }
      ]
    }
    ```

- Setup the domain:

  - Get a domain name for the backend, free domain names are available on [freenom](https://freenom.com) for example.

  - Point the domain/subdomain name (eg. `mybackend.site` or `api.instachat-server.net`) to the IP address of your VPS/cloud server, by adding an `A` DNS record, with host of `<your.domain>` and value of the IP address.

  - It can take a few minutes for the DNS records to be updated, you can use [dnschecker](https://dnschecker.org) to check the DNS records on your address.

- Add the following nginx configuration on the server (replace `<your.domain>` with your domain name):

  ```nginx
  server {
      server_name <your.domain>;

      location / {
          proxy_pass http://localhost:5555;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
      }
  }
  ```

  Then restart and test nginx with:

  ```bash
  sudo systemctl restart nginx
  sudo nginx -t
  ```

- Setup an SSL Certificate for the backend:

  - Install [certbot](https://certbot.eff.org/instructions) on your server, on Ubuntu it's just `sudo snap install --classic certbot`

  - Run `sudo certbot --nginx` to install your SSL certificate.

- Clone the repository on the server:

  ```bash
  git clone https://github.com/tusharsadhwani/instachat
  ```

- Create a postgres database for the backend.

- Edit `./server/.env` to add your database and AWS credentials.

  (Look at `./server/.env.example` for more info)

- In the `./server` subdirectory, run:

  ```bash
  go run ./cmd/genkeys
  ```

  To generate an RSA key pair for the app.

- Start the server:

  ```bash
  go build ./cmd/server
  ./server
  ```

### App

- Edit `./instachat/.env` to set `DOMAIN` as the domain name of your backend, along with your AWS S3 bucket URL.

  (Look at `./instachat/.env.example` for more info)

- In the `./instachat` subdirectory, run:

  ```bash
  flutter build apk --target-platform=android-arm64,android-arm,android-x64 --split-per-abi
  ```

Created APKs will be present in `./instachat/build/app/outputs/flutter-apk/`

## Local Development

You will need [go](https://golang.org) and [flutter](https://flutter.dev) installed on your system.

### Backend

- Create an AWS S3 bucket for media hosting:

  - Be sure to un-check "Block all public access".

  - Add the following bucket policy, to allow public read access:

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::<bucket name>/*"
        }
      ]
    }
    ```

- Setup a local SSL Certificate:

  - Install [mkcert](https://github.com/filosottile/mkcert) to generate a self-signed certificate:

  - On Linux, first install `certutil`:

    ```bash
    sudo apt install libnss3-tools
        -or-
    sudo yum install nss-tools
        -or-
    sudo pacman -S nss
        -or-
    sudo zypper install mozilla-nss-tools
    ```

  - Then install mkcert:

    ```bash
    git clone https://github.com/filosottile/mkcert
    cd mkcert
    go install -ldflags "-X main.Version=$(git describe --tags)"
    ```

  - Move to the instachat `./server` subdirectory, and install the certificate:

    ```bash
    mkcert -install
    mkcert localhost
    ```

    This will generate `localhost.pem` and `localhost-key.pem` files for your local HTTPS server.

- Create a postgres database for the backend.

- Clone the repository:

  ```bash
  git clone https://github.com/tusharsadhwani/instachat
  ```

- In the `./server` subdirectory, run:

  ```bash
  go run ./cmd/genkeys
  ```

  To generate an RSA key pair for the app.

- Edit `./server/.env` to add your database and AWS credentials.

  (Look at `./server/.env.example` for more info)

- Run the server:

  To get live reloading, use [air](https://github.com/cosmtrek/air):

  ```bash
  go get -u github.com/cosmtrek/air
  ```

  > Make sure $(go env GOPATH) is in your PATH.

  Then run the command in `./server` subdirectory:

  ```bash
  air -c .air.toml
  ```

  to start the server with HTTPS and hot reload.

### Frontend

- Edit `./instachat/.env` to set your AWS S3 bucket URL.

  (Look at `./instachat/.env.example` for more info)

- In the `./instachat` subdirectory, run:

  ```bash
  flutter run
  ```
