# Ishara

A multilingual Nepali Sign Language dictionary for Android, iOS, and Web.

## Goal

English/Nepali word → concept → Nepali Sign Language sign video.

## Stack

- Flutter (`apps/mobile`)
- Node.js + Fastify (`apps/api`)
- Supabase PostgreSQL (later)

## Repository layout

```
apps/
  mobile/   # Flutter app (Android, iOS, Web)
  api/      # Dictionary API
docs/
  product.md
  architecture.md
```

## Prerequisites

- [Node.js](https://nodejs.org/) 20+ (22 recommended)
- [Flutter](https://docs.flutter.dev/get-started/install) 3.5+ with Android, iOS, and Web tooling as needed

## Local development

Install dependencies from the repo root:

```bash
npm install
```

### API

Start the API in watch mode:

```bash
npm run api:dev
```

The server listens on `http://127.0.0.1:3000` by default. Override with `PORT` and `HOST` if needed.

Check health:

```bash
curl http://127.0.0.1:3000/health
```

Expected response:

```json
{"status":"ok"}
```

Search signs (English):

```bash
curl "http://127.0.0.1:3000/signs/search?q=hello&lang=en"
```

Search signs (Nepali):

```bash
curl "http://127.0.0.1:3000/signs/search?q=%E0%A4%A8%E0%A4%AE%E0%A4%B8%E0%A5%8D%E0%A4%A4%E0%A5%87&lang=ne"
```

Example search response:

```json
{
  "query": "hello",
  "lang": "en",
  "count": 1,
  "results": [
    {
      "id": "hello",
      "conceptId": "concept-hello",
      "englishWord": "Hello",
      "nepaliWord": "नमस्ते",
      "meaningEnglish": "A greeting used when meeting someone.",
      "meaningNepali": "कसैलाई भेट्दा प्रयोग गरिने अभिवादन।",
      "category": "Greetings",
      "videoUrl": null
    }
  ]
}
```

Get one sign by id:

```bash
curl http://127.0.0.1:3000/signs/hello
```

`lang` accepts `en`, `english`, `ne`, or `nepali`. Responses are JSON metadata only (no video files).

Other scripts:

```bash
npm run api:build   # compile TypeScript to dist/
npm run api:start   # run compiled server
```

### Mobile app

```bash
cd apps/mobile
flutter pub get
```

Run on a connected device or emulator:

```bash
flutter run
```

Examples by platform:

```bash
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS (macOS with Xcode)
```

Run tests:

```bash
flutter test
```

## Docs

- [Product brief](docs/product.md)
- [Architecture](docs/architecture.md)
