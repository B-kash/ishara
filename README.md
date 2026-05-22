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
  admin/    # Admin web UI (static files served by the API)
data/
  mock-signs.json   # shared mock dictionary (single source)
docs/
  product.md
  architecture.md
  admin.md        # admin panel guide (auth, API, bulk import)
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
| `ADMIN_USERNAME` | — | Enables admin panel when set with password + secret |
| `ADMIN_PASSWORD` | — | Admin login password (never commit real values) |
| `ADMIN_SESSION_SECRET` | — | Signs admin session tokens |
| `ADMIN_SESSION_TTL_HOURS` | `12` | Admin session lifetime |

See [Database plan](docs/database.md) for creating a local `ishara` database.

Dictionary tables are defined in `apps/api/src/db/schema.ts` (Drizzle ORM, synced with `supabase/migrations/`). See [data-model.md](docs/data-model.md).

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

### Admin panel

Staff UI for adding dictionary entries. Not part of the Flutter consumer app.

**Requirements:** `DATA_SOURCE=postgres`, `DATABASE_URL`, and all three admin variables in `.env`:

```env
ADMIN_USERNAME=editor
ADMIN_PASSWORD=change-me
ADMIN_SESSION_SECRET=replace-with-long-random-string
```

| Task | How |
|------|-----|
| Open UI | http://localhost:3000/admin/ (after `npm run dev`) |
| Add one sign | **Add word** tab — sign id, words, meanings, category, optional media URLs |
| Bulk add | **Bulk import** tab — upload `.csv` or `.json` (same fields as `data/mock-signs.json`) |
| CLI bulk (no UI) | `npm run db:import` |

CSV header example:

`id,conceptId,englishWord,nepaliWord,meaningEnglish,meaningNepali,category,videoUrl,thumbnailUrl`

Full API and auth details: [docs/admin.md](docs/admin.md).

**Not implemented yet:** edit signs, video file upload, draft/review/publish workflow, multiple users/roles.

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

### Admin panel (web)

Use PostgreSQL and admin env vars (see [Admin panel](#admin-panel) above). The API serves the UI from `apps/admin/public/` — no separate dev server.

```bash
npm run dev
# → http://localhost:3000/admin/
```

Login example (API only):

```bash
curl -X POST http://127.0.0.1:3000/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"editor","password":"change-me"}'
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

**Layout:** fixed header (title, locale, theme) and footer (Home / Browse); screen content swaps in the body navigator.

**Themes:** palette icon in the header (5 themes, saved locally).

**App language:** globe icon in the header — English / Nepali UI (ARB files in `apps/mobile/lib/l10n/`).

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
- [Data model (tables → API → app)](docs/data-model.md)
- [Admin panel](docs/admin.md)
- [Deployment](docs/deployment.md)
