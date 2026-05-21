# Ishara Admin Panel — Plan (not built yet)

This document describes the **future** admin experience for managing dictionary content. There is no admin UI or admin API in the MVP. Editors use scripts and database tools until this is built.

## Goals

- Let trusted editors add and update signs without touching SQL by hand.
- Keep the public Flutter app read-only (search and playback only).
- Support a simple review step before new or changed signs appear in the dictionary.

## Who uses it

| Role | Can do |
|------|--------|
| **Editor** | Create and edit drafts, upload media, submit for review |
| **Reviewer** | Approve or reject drafts, publish approved signs |
| **Admin** | Everything above plus user/role management (later) |

## Data the admin manages

Admin screens map to existing PostgreSQL entities (see [architecture.md](architecture.md)):

| Entity | Purpose |
|--------|---------|
| **Category** | Grouping (Family, Greetings, …) |
| **Concept** | One meaning (English + Nepali glosses) |
| **Word** | Searchable label per language (`en` / `ne`) linked to a concept |
| **Sign** | Video/thumbnail URLs and publish state for a concept |

Today each concept has at most one English word and one Nepali word. Synonyms may require relaxing the `unique (concept_id, language)` constraint or a separate synonyms table later.

## Planned features

### Add sign

Flow for a **new** dictionary entry:

1. Choose or create a **category**.
2. Enter **concept** meanings (English and Nepali).
3. Enter **words** for search (English and Nepali forms).
4. Assign a stable **sign id** (slug, e.g. `thank-you`).
5. Optionally upload **thumbnail** and **video** (see below).
6. Save as **draft** (not visible in the public app).

Validation:

- Required: category, both meanings, both words, sign id.
- Unique: sign id, concept id, words per language where the schema requires it.
- No duplicate concepts for the same primary English/Nepali pair (business rule TBD).

### Edit sign

Editors can change:

- Category assignment
- Meanings (English / Nepali)
- Search words (including future synonyms)
- Thumbnail and video URLs (or re-upload files)
- Sign id only with a careful migration path (discouraged once published)

Edits to a **published** sign create a new **draft revision** or mark the row as `pending_review` so the live entry stays unchanged until approval.

### Upload video

Media is stored **outside** the database (object storage or local `data/media/` in development).

Planned flow:

1. Editor selects a sign (draft or published).
2. Upload MP4 (and optional poster image) via admin UI.
3. Backend stores the file and writes `video_url` / `thumbnail_url` on the `signs` row.
4. Optional: record `video_duration_seconds` after processing.

Constraints:

- Format: MP4 (H.264) for Flutter mobile and web.
- Max file size and resolution limits TBD.
- Virus/malware scanning out of scope for first version.

Public app already reads `videoUrl`, `thumbnailUrl`, and `videoDurationSeconds` from `GET /signs/:id`.

### Publish / unpublish

Published signs appear in search and category lists. Drafts do not.

**Schema addition (planned):** add to `signs` (or a `sign_publications` table):

- `status`: `draft` | `pending_review` | `published` | `archived`
- `published_at` (timestamp, nullable)
- `updated_by` (editor user id, when auth exists)

| Action | Effect on public API |
|--------|----------------------|
| **Publish** | Sign included in search/detail/category endpoints |
| **Unpublish** | Sign hidden; existing links return 404 or “unavailable” |
| **Archive** | Hidden permanently unless restored by admin |

MVP API today returns all seeded rows; filtering by `status = published` will be added when admin and schema land.

### Review workflow

Simple two-step workflow before publish:

```
  draft → pending_review → published
              ↓
           rejected → draft (with reviewer notes)
```

1. **Editor** completes the sign form and media, then **Submit for review**.
2. **Reviewer** opens a queue of `pending_review` items.
3. Reviewer checks meanings, words, category, and watches the video.
4. **Approve** → publish (set `published`, set `published_at`).
5. **Reject** → back to draft with an optional comment for the editor.

Notifications (email/in-app) are out of scope for v1.

### Future authentication

Admin must not be open to the internet without auth.

Planned approach (decision deferred):

- **Option A:** Email/password or magic link (e.g. Supabase Auth, Auth0, or self-hosted).
- **Option B:** SSO for an organization (Google Workspace, etc.).

Requirements when implemented:

- All admin routes require a valid session.
- Role claims: `editor`, `reviewer`, `admin`.
- Public dictionary routes stay unauthenticated.
- Secrets only in environment variables, never in the repo.
- Audit log: who published, edited, or rejected what (table or append-only log).

Until auth exists, bulk changes stay in [import scripts](roadmap.md) and controlled DB access.

## Planned admin API (sketch)

Not implemented. Likely prefix: `/admin/…` behind auth.

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/admin/signs` | Create draft sign (+ concept/words) |
| PATCH | `/admin/signs/:id` | Update draft or published metadata |
| POST | `/admin/signs/:id/media` | Upload video/thumbnail |
| POST | `/admin/signs/:id/submit` | Move to `pending_review` |
| POST | `/admin/signs/:id/publish` | Approve and publish |
| POST | `/admin/signs/:id/unpublish` | Remove from public app |
| POST | `/admin/signs/:id/reject` | Reject with optional note |
| GET | `/admin/reviews` | List pending items |

## UI sketch (future)

Single web app (Flutter Web or small React app) used only by staff:

- **Dashboard** — counts: drafts, pending review, published.
- **Sign list** — filter by status/category; search by word.
- **Sign editor** — form + media upload + preview player (reuse app video component patterns).
- **Review queue** — side-by-side: proposed vs current (if edit).

## What we are not building in this step

- No admin screens in `apps/mobile` (consumer app only).
- No admin routes in `apps/api` yet.
- No authentication or role tables yet.

## Interim tools (today)

| Task | Tool |
|------|------|
| Bulk load sample data | `npm run db:seed` |
| Schema changes | `supabase/migrations/` + `npm run db:migrate` |
| One-off edits | SQL client on local Postgres |
| Sample video file | `data/media/` served at `GET /media/…` |

Step 8 in the [roadmap](roadmap.md) adds a JSON import script as the next automation step before a full admin UI.

## Open questions

- Multiple synonyms per language per concept?
- Soft delete vs hard delete for signs?
- Nepali-only or English-only entries (missing one word)?
- Who hosts production video (S3, R2, Supabase Storage, CDN)?

Resolve these before implementing the admin API and schema changes.
