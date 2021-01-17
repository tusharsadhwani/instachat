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

- Edit `.env` to add your database config
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

- Edit `.env` to add your database config
- Run:

  ```bash
  go build ./cmd/server
  ./server
  ```

### App

Note: This process will be improved sometime soon

- Edit `./instachat/lib/services/auth_service.dart` to change `domain` from `localhost:5555` to the URL of your backend domain.

- In the `./instachat` sub-folder, run:

  ```bash
  flutter build apk --target-platform=android-arm64,android-arm,android-x64 --split-per-abi
  ```

Created APKs will be present in `./build/app/outputs/flutter-apk`
