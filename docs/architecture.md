# Ishara Architecture

## Apps

- Flutter app for Android, iOS, and Web.
- Fastify API for dictionary/search data.
- Supabase PostgreSQL for structured data.
- External object storage for sign videos.

## Data Flow

User searches word
→ app calls API
→ API normalizes word
→ API finds matching concept
→ API returns sign metadata and video URL

## Core Entities

- Concept
- Word
- Sign
- Category

## Mock data (MVP)

Sign records live in `data/mock-signs.json`. The API reads this file in memory. The Flutter app loads signs over HTTP from the API.

## MVP API

- GET /health
- GET /signs/search?q=&lang= → `{ items: SignSearchResult[] }`
- GET /signs/:id → `SignDetail`
- GET /categories → `{ items: Category[] }`
- GET /categories/:id/signs?lang= → `{ items: SignSearchResult[] }`

Search and detail responses use typed contracts in `apps/api/src/types/api-responses.ts`.