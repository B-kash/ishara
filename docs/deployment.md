# Ishara Deployment Guide

This document describes how to deploy Ishara components. **Do not treat this as a one-click production setup** — adapt hosts, domains, and secrets to your environment.

## Architecture overview

```
Flutter app (web / Android / iOS)
        │ HTTPS
        ▼
   Fastify API (Node.js)
        │
        ├── PostgreSQL (dictionary data)
        └── Object storage or static host (sign MP4 + thumbnails)
```

The Flutter app never connects to PostgreSQL directly. It only calls the API.

## Environment variables (API)

Copy [`.env.example`](../.env.example) to `.env` on the server. Never commit `.env`.

| Variable | Required | Example | Purpose |
|----------|----------|---------|---------|
| `PORT` | No | `3000` | API listen port |
| `HOST` | No | `0.0.0.0` | Bind address |
| `DATA_SOURCE` | Yes | `postgres` | `mock` or `postgres` |
| `DATABASE_URL` | When postgres | `postgresql://…` | PostgreSQL connection string |
| `CORS_ORIGIN` | Production | `https://app.example.com` | Allowed Flutter web origin(s), comma-separated. Empty or `*` allows all (dev only). |

Flutter app build-time variable:

| Variable | Default | Purpose |
|----------|---------|---------|
| `API_BASE_URL` | `http://127.0.0.1:3000` | API base URL (`--dart-define`) |

## PostgreSQL hosting options

Use any standard PostgreSQL 14+ host:

| Option | Notes |
|--------|--------|
| **Local / VPS** | Install Postgres, run `npm run db:migrate` and `npm run db:seed` or `npm run db:import` |
| **Supabase** | Managed Postgres; set `DATABASE_URL` to the connection string (pooler or direct) |
| **Neon, Railway, Render** | Set `DATABASE_URL`; run migrations from CI or your machine |
| **Amazon RDS / Azure** | Same as VPS; restrict network access to API only |

The schema lives in `supabase/migrations/`. The API uses generic `DATABASE_URL` — no Supabase-specific code in the app layer.

**Production checklist**

1. Create database and user with least privilege.
2. `npm run db:migrate` against production URL (once per release with new migrations).
3. Load data via `npm run db:import` or controlled admin process.
4. Set `DATA_SOURCE=postgres` and `DATABASE_URL` on the API host.

## Video storage options

Sign videos are **not** stored in PostgreSQL. The `signs` table holds URLs only.

| Option | Fit |
|--------|-----|
| **API static files** (`data/media/`, `GET /media/…`) | Local dev and tiny demos only |
| **S3-compatible** (AWS S3, Cloudflare R2, MinIO) | Recommended for production MP4s |
| **Supabase Storage** | Works if you store public/signed URLs in `video_url` |
| **CDN in front of bucket** | Lower latency; set `video_url` to CDN URLs |

Requirements for hosted videos:

- HTTPS URLs
- MP4 (H.264) for Flutter mobile and web
- CORS enabled on the bucket if the web app loads videos cross-origin (API-served media already uses API CORS)

## API deployment

### Build

```bash
npm ci
npm run api:build
```

### Run

```bash
NODE_ENV=production node apps/api/dist/index.js
```

Or from `apps/api` after build: `npm run start`.

### Process manager

Use **systemd**, **PM2**, or your platform’s Node service:

- Set working directory to repo root (so `.env` and `data/media` resolve).
- Restart on failure.
- Put TLS termination on a reverse proxy (nginx, Caddy, cloud load balancer).

### Reverse proxy (example)

- Public: `https://api.example.com` → `http://127.0.0.1:3000`
- Set `CORS_ORIGIN=https://app.example.com` to match the Flutter web host.

### Health check

```bash
curl https://api.example.com/health
```

Expect `{"status":"ok","dataSource":"postgres"}` (or `mock` in demos).

### Platforms (no deploy automation in repo yet)

| Platform | Approach |
|----------|----------|
| **Railway / Render / Fly.io** | Node service, env vars, attach Postgres add-on |
| **VPS** | Node + nginx + Postgres on same or separate machine |
| **Docker** | Image with `node apps/api/dist/index.js`; mount `.env` via secrets |

## Flutter web deployment

### Build

```bash
cd apps/mobile
flutter pub get
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.example.com
```

Output: `apps/mobile/build/web/`

### Host static files

| Host | Notes |
|------|--------|
| **Firebase Hosting** | Upload `build/web` |
| **Netlify / Vercel** | Publish directory `apps/mobile/build/web` |
| **S3 + CloudFront** | Sync `build/web`; set index document |
| **nginx** | `root` pointing at `build/web`; SPA fallback to `index.html` |

Ensure `API_BASE_URL` points to your production API and API `CORS_ORIGIN` includes the web app origin.

## Android build

### Prerequisites

- Android Studio or SDK + command-line tools
- JDK 17+

### Debug / release APK

```bash
cd apps/mobile
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.example.com
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App bundle (Play Store)

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example.com
```

Configure signing in `android/app/build.gradle` and keystore (not covered here). The repo includes `INTERNET` permission for API and video URLs.

## iOS build

Requires **macOS** with Xcode.

```bash
cd apps/mobile
flutter pub get
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.example.com
```

Open `ios/Runner.xcworkspace` in Xcode to archive and distribute. Configure signing team and bundle identifier in Xcode.

For App Store: enable required privacy descriptions if you add camera/microphone later (not required for dictionary MVP).

## Post-deploy verification

1. `GET /health` on API
2. `GET /signs/search?q=hello&lang=en` returns items
3. Open Flutter web or app → search → open **hello** → video plays if `video_url` is set
4. Confirm CORS: web app origin listed in `CORS_ORIGIN`

## CI

Pull requests run [.github/workflows/ci.yml](../.github/workflows/ci.yml):

- API: install, build, test (mock data)
- Flutter: analyze, test

Deployment is manual until a CD pipeline is added.

## Security reminders

- Do not commit `.env`, keystores, or API keys.
- Use strong `DATABASE_URL` credentials and private networking where possible.
- Restrict `CORS_ORIGIN` in production.
- Serve API and app over HTTPS only.

## Related docs

- [Architecture](architecture.md)
- [Admin plan (future)](admin.md)
- [Database setup](database.md)
