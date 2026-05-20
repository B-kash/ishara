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

## MVP API

- GET /health
- GET /signs/search?q=&lang=
- GET /signs/:id
- GET /categories