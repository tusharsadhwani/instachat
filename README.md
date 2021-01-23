# InstaChat

A working replica of Instagram DMs and stories, written in Flutter and Go.

(_This is currently a work in progress, it may or may not work_)

## Development

### Backend

- Create a postgres database
- In the `./server` sub-folder, run:

  ```bash
  go run ./cmd/genkeys
  ```

  To generate an RSA key pair for the app.

- Edit `./server/.env` to add your database and AWS config

  Look at `./server/.env.example` for more info.

- Run:

  ```bash
  go run ./cmd/server
  ```

  to start the server.

### Frontend

- In the `./instachat` sub-folder, run:

  ```bash
  flutter run
  ```

## Deploy your own

### Server

- Clone the repo on the server
- Create a postgres database
- In the `./server` sub-folder, run:

  ```bash
  go run ./cmd/genkeys
  ```

  To generate an RSA key pair for the app.

- Edit `./server/.env` to add your database and AWS config.

  Look at `./server/.env.example` for more info.

- Run:

  ```bash
  go build ./cmd/server
  ./server
  ```

### App

- Edit `./instachat/.env` to set `DOMAIN` as the domain of your backend, along
  with your AWS S3 bucket URL.

  Look at `./instachat/.env.example` for more info.

  > NOTE: The S3 bucket should be given public access to read objects for this to work.

- In the `./instachat` sub-folder, run:

  ```bash
  flutter build apk --target-platform=android-arm64,android-arm,android-x64 --split-per-abi
  ```

Created APKs will be present in `./build/app/outputs/flutter-apk`
