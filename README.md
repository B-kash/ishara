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
  admin.md        # future admin panel plan (not implemented)
```

Mock dictionary data for the API lives in `data/mock-signs.json`.

Copy environment settings when needed:

```bash
cp .env.example .env
```

| Variable | Default | Purpose |
|----------|---------|---------|
| `PORT` | `3000` | API port |
| `HOST` | `0.0.0.0` | API bind address |
| `DATA_SOURCE` | `mock` | `mock` = JSON file, `postgres` = PostgreSQL |
| `DATABASE_URL` | — | Required when `DATA_SOURCE=postgres` |
| `CORS_ORIGIN` | (allow all) | Comma-separated web app origins; set in production |

See [Database plan](docs/database.md) for creating a local `ishara` database.

PostgreSQL setup (after `DATABASE_URL` is in `.env`):

```bash
npm run db:migrate   # runs new migrations only
npm run db:seed      # clears and reloads seed data (safe to re-run)
npm run db:import    # merge JSON signs into Postgres (skips duplicates)
```

Bulk import from JSON (default: `data/mock-signs.json`):

```bash
npm run db:import
npm run db:import -- data/my-signs.json
```

See [admin.md](docs/admin.md) for the future admin UI; import is the interim bulk tool.

## Tests

```bash
npm test                              # API tests (mock data, no Postgres)
cd apps/mobile && flutter test        # Flutter widget + unit tests
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
  "items": [
    {
      "id": "hello",
      "englishWord": "hello",
      "nepaliWord": "नमस्ते",
      "category": "Greetings",
      "meaning": "A greeting used when meeting someone."
    }
  ]
}
```

List categories:

```bash
curl http://127.0.0.1:3000/categories
```

Browse signs in a category:

```bash
curl "http://127.0.0.1:3000/categories/family/signs?lang=en"
```

Get one sign by id:

```bash
curl http://127.0.0.1:3000/signs/hello
```

Example detail response:

```json
{
  "id": "hello",
  "englishWord": "hello",
  "nepaliWord": "नमस्ते",
  "category": "Greetings",
  "meaning": "A greeting used when meeting someone.",
  "videoUrl": null,
  "thumbnailUrl": null
}
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
flutter run -d android   # Android (emulator: use 10.0.2.2 for API — see apps/mobile/README.md)
flutter run -d ios       # iOS (macOS with Xcode)
```

**Themes:** palette icon on the home screen (5 themes, saved locally).

**App language:** globe icon — English / Nepali UI (ARB files in `apps/mobile/lib/l10n/`).

Platform notes: [apps/mobile/README.md](apps/mobile/README.md)

Run tests:

```bash
flutter test
```

## CI

GitHub Actions runs on push/PR to `main` or `master`: API build + tests, Flutter analyze + tests. See [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Docs

- [Product brief](docs/product.md)
- [Architecture](docs/architecture.md)
- [Database plan](docs/database.md)
- [Deployment](docs/deployment.md)
- [Admin plan (future)](docs/admin.md)
