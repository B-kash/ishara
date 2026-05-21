# Ishara Admin (static web UI)

HTML/CSS/JS served by the API at `/admin/`. No build step.

## Local use

1. Set `DATA_SOURCE=postgres`, `DATABASE_URL`, and admin env vars in the repo root `.env` (see [`.env.example`](../../.env.example)).
2. Run `npm run dev` from the repo root.
3. Open http://localhost:3000/admin/

## Documentation

- [docs/admin.md](../../docs/admin.md) — authentication, API, CSV/JSON formats
- [README — Admin panel](../../README.md#admin-panel)

## Files

| File | Purpose |
|------|---------|
| `public/index.html` | Login + add word + bulk import |
| `public/admin.js` | API client and session storage |
| `public/admin.css` | Styles |

API routes live in `apps/api/src/routes/admin.ts`.
