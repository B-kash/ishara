# Ishara database plan (Supabase PostgreSQL)

This document describes the PostgreSQL schema for Ishara. The API defaults to **mock mode** (`DATA_SOURCE=mock`) and does not require a database. Set `DATA_SOURCE=postgres` to read from PostgreSQL instead.

## Goals

- Store dictionary data in normalized tables.
- Support English and Nepali word search.
- Link each searchable word to one concept and one sign video.
- Keep category browsing and sign metadata ready for a future API swap.

## Entity relationships

```text
categories 1 ── * concepts 1 ── * words
                      │
                      └── 1 signs
```

| Table | Role |
|-------|------|
| `categories` | Group signs (Family, Education, …). `id` is a URL slug (`family`). |
| `concepts` | One meaning unit. Holds English and Nepali definitions. |
| `words` | Searchable surface forms. `language` is `en` or `ne`. |
| `signs` | Nepali Sign Language video metadata for a concept. |

A user searches a **word** → the API resolves a **concept** → returns **sign** metadata and **category** name.

## SQL files

| File | Purpose |
|------|---------|
| [`supabase/migrations/001_initial_schema.sql`](../supabase/migrations/001_initial_schema.sql) | Tables and indexes |
| [`supabase/seeds/`](../supabase/seeds/) | Seed SQL files (tracked separately) |
| [`supabase/schema.sql`](../supabase/schema.sql) | Legacy psql runner |

Tracked table (migrations only):

- `schema_migrations` — which migration files already ran

`npm run db:seed` always clears dictionary tables and reloads seed files (safe to run again).

## Indexes (search)

| Index | Purpose |
|-------|---------|
| `words_language_word_idx` | Filter by language, match word text |
| `words_word_lower_idx` | Case-insensitive search (`lower(word)`) |
| `words_concept_id_idx` | Load all words for a concept |
| `concepts_category_id_idx` | List concepts in a category |
| `signs_concept_id_idx` | Join sign to concept |

Later we can add `pg_trgm` or full-text search if prefix/substring search needs to scale.

## Mapping to the current API (future)

| API response field | Source |
|------------------|--------|
| `SignSearchResult.id` | `signs.id` |
| `englishWord` | `words.word` where `language = 'en'` |
| `nepaliWord` | `words.word` where `language = 'ne'` |
| `category` | `categories.name` via `concepts.category_id` |
| `meaning` | `concepts.meaning_english` or `meaning_nepali` by `lang` |
| `videoUrl` / `thumbnailUrl` | `signs.video_url`, `signs.thumbnail_url` |

Category endpoints map to `categories` and `concepts.category_id`.

## Sample seed data

| Sign id | English | Nepali | Category |
|---------|---------|--------|----------|
| `mother` | mother | आमा | Family |
| `father` | father | बुबा | Family |
| `school` | school | विद्यालय | Education |

Videos are `null` in seed data until object storage URLs are added.

## Local database (`ishara`)

Create a local PostgreSQL database and load the schema:

```bash
# Create database (PostgreSQL CLI)
createdb ishara

# Migrate (skips already-applied files), then seed (always reloads data)
npm run db:migrate
npm run db:seed
```

Or with `psql` directly:

```bash
psql -d ishara -f supabase/migrations/001_initial_schema.sql
psql -d ishara -f supabase/seeds/001_mock_signs.sql
```

On Windows with `psql` in PATH:

```powershell
psql -U postgres -c "CREATE DATABASE ishara;"
npm run db:migrate
npm run db:seed
```

Copy `.env.example` to `.env` at the repo root when using postgres mode:

```env
DATA_SOURCE=postgres
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ishara
```

Start the API:

```bash
npm run dev
```

Check `GET /health` — response includes `"dataSource": "mock"` or `"postgres"`.

## API data source

| `DATA_SOURCE` | Behavior |
|---------------|----------|
| `mock` (default) | Reads `data/mock-signs.json`. No PostgreSQL required. |
| `postgres` | Reads from PostgreSQL using `DATABASE_URL`. |

Flutter always talks to the API over HTTP, never to the database directly.

## Hosted PostgreSQL (later)

The same `supabase/schema.sql` file can run in Supabase SQL editor or any PostgreSQL host. Use a standard `DATABASE_URL` connection string — no Supabase SDK in the API.

## Out of scope

- Supabase-specific client libraries
- Auth, RLS policies, admin panel
- Flutter database access
