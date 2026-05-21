# Ishara Mobile App

Flutter client for Android, iOS, and Web.

## Run locally

Start the API from the repo root (`npm run api:dev`), then:

```bash
flutter pub get
flutter run -d chrome
```

## API URL per platform

Default API base is `http://127.0.0.1:3000`. Override with `--dart-define`:

| Platform | Typical `API_BASE_URL` |
|----------|-------------------------|
| Web / iOS Simulator | `http://127.0.0.1:3000` |
| Android Emulator | `http://10.0.2.2:3000` |
| Physical device | `http://<your-pc-lan-ip>:3000` |

Example (Android emulator):

```bash
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Themes

Tap the palette icon on the home screen to switch between **Ishara**, **Ocean**, **Forest**, **Slate**, and **Night**. Choice is saved on the device.

## Build

```bash
flutter analyze
flutter test
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
flutter build ios --release --dart-define=API_BASE_URL=https://api.example.com
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com
```

iOS builds require macOS with Xcode. See [deployment.md](../../docs/deployment.md) for hosting details.
