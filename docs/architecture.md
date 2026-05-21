# Ishara Architecture

## Apps

| App | Path | Users |
|-----|------|--------|
| Flutter dictionary | `apps/mobile` | Public — search and sign playback |
| Dictionary API | `apps/api` | Public read API + admin write API |
| Admin web UI | `apps/admin/public` | Staff — add signs (static HTML served by API at `/admin/`) |

Infrastructure:

- PostgreSQL for structured dictionary data
- Object storage or local `data/media/` for sign videos (URLs stored in DB)

## Data flow (public app)

```
User searches word
  → Flutter app calls API
  → API normalizes word
  → API finds matching concept
  → API returns sign metadata and video URL
```

The Flutter app never connects to PostgreSQL.

## Data flow (admin)

```
Editor signs in at /admin/
  → POST /admin/login → session token
  → Add sign or upload CSV/JSON
  → POST /admin/signs or POST /admin/signs/bulk (Bearer token)
  → API writes categories, concepts, words, signs in PostgreSQL
  → Public app sees new entries on next search (no publish filter yet)
```

Admin writes require `DATA_SOURCE=postgres`. The consumer app does not include admin screens.

## Core entities

- **Category** — grouping (Family, Greetings, …)
- **Concept** — one meaning (English + Nepali glosses)
- **Word** — searchable label per language (`en` / `ne`) linked to a concept
- **Sign** — stable id, video/thumbnail URLs, links 1:1 to a concept

Schema: `supabase/migrations/`. Details: [database.md](database.md).

## Mock data (development)

Sign records live in `data/mock-signs.json`. With `DATA_SOURCE=mock`, the API reads this file in memory. Admin sign management is not available in mock mode.

## Database

PostgreSQL via `DATABASE_URL` when `DATA_SOURCE=postgres`. The API does not use Supabase-specific client libraries. See [database.md](database.md).

## Public API

| Method | Path | Response |
|--------|------|----------|
| `GET` | `/health` | `{ status, dataSource }` |
| `GET` | `/signs/search?q=&lang=` | `{ items: SignSearchResult[] }` |
| `GET` | `/signs?lang=&limit=&cursor=` | `{ items, pageInfo }` (browse) |
| `GET` | `/signs/:id` | `SignDetail` |
| `GET` | `/categories` | `{ items: Category[] }` |
| `GET` | `/categories/:id/signs?lang=` | `{ items: SignSearchResult[] }` |
| `GET` | `/media/*` | Static sample videos (dev) |

Typed contracts: `apps/api/src/types/api-responses.ts`.

## Admin API

Enabled when `ADMIN_USERNAME`, `ADMIN_PASSWORD`, and `ADMIN_SESSION_SECRET` are set. See [admin.md](admin.md).

| Method | Path | Auth |
|--------|------|------|
| `POST` | `/admin/login` | No |
| `GET` | `/admin/session` | Bearer |
| `GET` | `/admin/categories` | Bearer |
| `POST` | `/admin/signs` | Bearer |
| `POST` | `/admin/signs/bulk` | Bearer |

Static admin UI: `GET /admin/` → `apps/admin/public/index.html`.

## Mobile app shell

The Flutter app uses a fixed **header** and **footer** (`AppShell`) with a nested navigator for screen bodies (home, browse, search results, sign detail). See `apps/mobile/lib/layout/app_shell.dart`.
