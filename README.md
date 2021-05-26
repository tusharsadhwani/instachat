# InstaChat

A working replica of Instagram DMs and stories, written in Flutter and Go.

<img src="https://user-images.githubusercontent.com/43412083/105750515-d9ca0680-5f6a-11eb-8681-0451f21fd935.png" width="300" hspace="10" vspace="20"> <img src="https://user-images.githubusercontent.com/43412083/105750622-fbc38900-5f6a-11eb-884b-71de91ed4f2b.png" width="300" hspace="10" vspace="20">

> **Note:** This is currently a work in progress.
> 
> The stories aren't integrated, but you can take a look at them as a separate project: [insta_stories](https://github.com/tusharsadhwani/insta_stories)

## Deploy your own

You will need [go](https://golang.org) and [flutter](https://flutter.dev) installed on your system.

### Before you start

To run your own instance, you'll need:

- a GCP project (for OAuth)
- an Amazon S3 bucket
- a domain name
- a VPS/cloud server

You can get all of these for free for limited use.

1. Create a GCP Project and setup OAuth:

   - Log into [Google Cloud Console](https://console.cloud.google.com/) and create a new project.

2. Create an AWS S3 bucket for media hosting:

   - Be sure to un-check "Block all public access".

   - Add the following bucket policy, to allow public read access
     (replace `<bucket name>` with your S3 bucket name):

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

- Edit `./instachat/.env` to set `DOMAIN` as the domain name of your backend, along with your AWS S3 bucket URL.

  (Look at `./instachat/.env.example` for more info)

- Create a release build of the app for use:

  ```bash
  flutter build apk --target-platform=android-arm64,android-arm,android-x64 --split-per-abi
  ```

  Created APKs will be present in `./instachat/build/app/outputs/flutter-apk/`

- Setup the backend domain:

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

- Edit `./server/.env` to add your database and GCP/AWS credentials.

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

## Local Development

You will need [go](https://golang.org) and [flutter](https://flutter.dev) installed on your system.

### App

- Clone the repository:

  ```bash
  git clone https://github.com/tusharsadhwani/instachat
  ```

- Edit `./instachat/android/app/build.gradle`, change package name from:

  ```gradle
  defaultConfig {
        applicationId "com.tusharsadhwani.instachat"
        ...
  ```

  to your own package name, eg. `com.yourdomain.instachat`

  ```gradle
  defaultConfig {
        applicationId "com.yourdomain.instachat"
        ...
  ```

<!-- TODO: move this content somewhere more sensible.
Maybe move the common AWS and GCP instructions to their own specific blocks -->

- Log into [Google Cloud Console](https://console.cloud.google.com/)

  - Go to APIs & Services > OAuth consent screen, and:

    - Choose the User Type to be **External**
    - Add the required fields:
      - App Name
      - User Support Email
      - Application Home Page (eg. `https://mydomain.com`)
      - Application privacy policy link (eg. `https://mydomain.com/policy`)
      - Application terms of service link (eg. `https://mydomain.com/terms`)
      - Authorized domains (set it the same as the domain of above links)
    - Save and Continue.

  - Go to APIs & Services > Credentials, and:

    - Click Create Credentials > OAuth Client ID
    - Choose Application type: **Android**
    - Add the package name (eg. `com.yourdomain.instachat`) and the SHA-1 key

      (use `./gradlew signingReport` command in `./instachat/android/` subdirectory to get the SHA-1 value)

    - Give it any name, and click Create.

    - Click Create Credentials > OAuth Client ID (again)
    - Choose Application type: **Web**
    - Give it any name, and click Create.

    - Copy the **Web Application** Client ID

    - Now, create a file: `./instachat/app/src/main/res/values/strings.xml`
    - Set its contents to be:

      ```xml
      <?xml version="1.0" encoding="utf-8"?>
      <resources>
          <string name="default_web_client_id">XXXXXXXXXXXX-YOUR_GCP_CLIENT_ID.apps.googleusercontent.com</string>
      </resources>
      ```

      Replace the dummy client ID with the ID you copied from GCP.

- Edit `./instachat/.env` to set `DOMAIN` as the domain name of your backend, along with your AWS S3 bucket URL.

  (Look at `./instachat/.env.example` for more info)

- In the `./instachat` subdirectory, run the following:

  - Web:

    ```bash
    flutter run --web-port 5000 --web-renderer html
    ```

  - Android:

    ```bash
    adb reverse tcp:5555 tcp:5555
    flutter run
    ```

- To create Release builds of the app for use, run:

  ```bash
  flutter build apk --target-platform=android-arm64,android-arm,android-x64 --split-per-abi
  ```

  Created APKs will be present in `./instachat/build/app/outputs/flutter-apk/`

### Backend

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
    cd /tmp
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

- In the `./server` subdirectory, run:

  ```bash
  go run ./cmd/genkeys
  ```

  To generate an RSA key pair for the app.

- Edit `./server/.env` to add your database and GCP/AWS credentials.

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

## Testing

To run tests:

- In the `./server` subfolder, run:

  ```bash
  go test ./tests
  ```
