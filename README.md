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
data/
  mock-signs.json   # shared mock dictionary (single source)
docs/
  product.md
  architecture.md
```

Mock dictionary data for the API lives in `data/mock-signs.json`.

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
npm run dev
```

(`npm run api:dev` is the same command.)

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

Start the API first, then run the app:

```bash
cd apps/mobile
flutter pub get
flutter run -d chrome
```

The app calls `http://127.0.0.1:3000` by default. Override with:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Examples:

- Search `mother` (English) → `GET /signs/search?q=mother&lang=en`
- Search `आमा` (Nepali) → `GET /signs/search?q=आमा&lang=ne`

Other platforms:

```bash
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
