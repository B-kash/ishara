# Ishara Admin Panel

Staff-facing web UI for adding dictionary entries to PostgreSQL. The public Flutter app stays read-only.

**URL (local):** [http://localhost:3000/admin/](http://localhost:3000/admin/) — served as static files from `apps/admin/public/` by the API.

## What is implemented

| Feature | Status |
|---------|--------|
| Login (username + password) | Done |
| Session tokens (signed, TTL from env) | Done |
| Add one sign (form) | Done |
| Bulk import (CSV or JSON upload) | Done |
| Video/thumbnail **URLs** in forms | Done |
| Video file upload | Not yet |
| Edit existing signs | Not yet |
| Draft / review / publish workflow | Not yet |
| Multiple admin users or roles | Not yet |

Writes require `DATA_SOURCE=postgres`. Mock mode still serves the public API but admin sign endpoints return an error.

## Setup

1. Copy [`.env.example`](../.env.example) to `.env` if you have not already.
2. Set PostgreSQL:

   ```env
   DATA_SOURCE=postgres
   DATABASE_URL=postgresql://user:password@localhost:5432/ishara
   ```

3. Set **all three** admin variables (panel is disabled if any are missing):

   ```env
   ADMIN_USERNAME=editor
   ADMIN_PASSWORD=change-me-in-production
   ADMIN_SESSION_SECRET=replace-with-long-random-string
   ```

   Optional: `ADMIN_SESSION_TTL_HOURS` (default `12`).

4. Migrate and seed if needed:

   ```bash
   npm run db:migrate
   npm run db:seed
   ```

5. Start the API: `npm run dev`
6. Open http://localhost:3000/admin/ and sign in.

Generate a session secret (example):

```bash
openssl rand -base64 32
```

Never commit real passwords or secrets to the repo.

## Authentication

- `POST /admin/login` with `{ "username", "password" }` returns `{ token, expiresAt, username }`.
- Protected routes expect `Authorization: Bearer <token>`.
- Invalid or expired tokens receive `401` with code `UNAUTHORIZED`.
- Tokens are HMAC-signed; verification uses `ADMIN_SESSION_SECRET` only (no database session table).

This is a single shared admin account from environment variables, not multi-user auth.

## Admin UI

### Add word

Creates category (if new), concept, English/Nepali words, and sign in one transaction.

| Field | Required | Notes |
|-------|----------|-------|
| Sign ID | Yes | URL slug, e.g. `thank-you` |
| Concept ID | No | Defaults to `concept-<signId>` |
| English word | Yes | Stored lowercase for search |
| Nepali word | Yes | |
| Category | Yes | Name shown in app; id derived from name (e.g. `Food & Drink` → `food-drink`) |
| English / Nepali meaning | Yes | Shown as sign “meaning” in the app |
| Video / thumbnail URL | No | Point to hosted media or `http://127.0.0.1:3000/media/…` in dev |

Duplicate sign ids are skipped with a message. Conflicts (existing concept id or word already on another concept) return `400`.

### Bulk import

Upload `.csv` or `.json`:

- **JSON:** array of objects, same fields as [`data/mock-signs.json`](../data/mock-signs.json).
- **CSV:** header row required. Canonical columns:

  `id,conceptId,englishWord,nepaliWord,meaningEnglish,meaningNepali,category,videoUrl,thumbnailUrl`

  Snake_case aliases work (`sign_id`, `english_word`, `category_name`, etc.).

The import runs in a single database transaction. If any row fails validation, **nothing** from that upload is committed. Rows that already exist (same sign id) are reported as skipped when the batch succeeds.

Alternative: `POST /admin/signs/bulk` with JSON body `{ "records": [ ... ] }` (same record shape).

## Admin API reference

All paths below except `/admin/login` require a valid Bearer token.

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/admin/login` | Issue session token |
| `GET` | `/admin/session` | Verify session; returns `{ username }` |
| `GET` | `/admin/categories` | List categories for the form |
| `POST` | `/admin/signs` | Create one sign |
| `POST` | `/admin/signs/bulk` | Bulk import (multipart file or JSON body) |

### Create sign body (`POST /admin/signs`)

```json
{
  "signId": "thank-you",
  "conceptId": "concept-thank-you",
  "englishWord": "thank you",
  "nepaliWord": "धन्यवाद",
  "meaningEnglish": "Expression of gratitude.",
  "meaningNepali": "कृतज्ञता व्यक्त गर्ने शब्द।",
  "category": "Greetings",
  "videoUrl": null,
  "thumbnailUrl": null
}
```

`conceptId` may be omitted to use `concept-<signId>`.

Success: `201` with `{ outcome: { status: "inserted", signId } }`, or `200` if sign id already exists (`status: "skipped"`).

### Bulk response (`POST /admin/signs/bulk`)

```json
{
  "result": {
    "inserted": 2,
    "skipped": 0,
    "failed": 0,
    "outcomes": [ { "status": "inserted", "signId": "..." } ],
    "errors": []
  }
}
```

If `failed > 0`, the HTTP status is `400` and the transaction was rolled back.

## Data model

Admin writes map to PostgreSQL tables (see [architecture.md](architecture.md)):

| Table | Admin action |
|-------|----------------|
| `categories` | Insert on conflict do nothing (by category id from name) |
| `concepts` | Insert new concept |
| `words` | Insert `en` and `ne` rows |
| `signs` | Insert sign with optional media URLs |

Import logic is shared with the CLI: `npm run db:import` uses the same rules as the admin bulk endpoint.

## Code layout

```
apps/admin/public/     # HTML, CSS, JS (no build step)
apps/api/src/
  admin/               # auth + session verification
  data/sign-import.ts  # record validation
  data/sign-import-csv.ts
  repositories/postgres-sign-import.ts
  routes/admin.ts
```

## Interim tools (still useful)

| Task | Tool |
|------|------|
| Reset sample data | `npm run db:seed` |
| Merge JSON without UI | `npm run db:import` |
| Schema changes | `supabase/migrations/` + `npm run db:migrate` |
| Sample MP4 in dev | `data/media/` → `GET /media/<file>.mp4` |

## Planned next (not built)

- **Edit sign** — update meanings, words, category, URLs
- **Media upload** — MP4/poster to storage; API sets `video_url` / `thumbnail_url`
- **Publish workflow** — `draft` → `pending_review` → `published`; hide drafts from public API
- **Review queue** — approve / reject with notes
- **Roles** — editor, reviewer, admin (SSO or hosted auth TBD)
- **Audit log** — who changed what

Public API today returns all rows in the database; there is no `status` column yet.

## Open questions

- Multiple synonyms per language per concept?
- Soft delete vs hard delete for signs?
- Nepali-only or English-only entries?
- Production video host (S3, R2, CDN)?

Resolve these before adding publish workflow and edit flows.

## Related docs

- [README — Admin panel](../README.md#admin-panel)
- [Architecture](architecture.md)
- [Deployment — admin env vars](deployment.md#environment-variables-api)
- [Database setup](database.md)
