# JON ZAP PORTFOLIO

JON ZAP PORTFOLIO is a small personal project portfolio manager with a Kanban board, configurable workflow columns, project history, RAG health, follow-up tracking, filters, and a 90-Second View.

## Architecture

The application intentionally uses a minimal architecture:

```text
GitHub Pages
  -> Plain HTML, CSS, and JavaScript
  -> Supabase JavaScript client
  -> Supabase Auth
  -> Supabase PostgreSQL with Row Level Security
```

There is no build step or custom backend. Supabase is the authoritative persistence layer, and portfolio data is loaded only for an authenticated user through Row Level Security policies.

## Deployment

Production is deployed directly from the root of the `main` branch with GitHub Pages:

https://jhaz07.github.io/Jon_zap_portafolio/

Development changes are integrated and verified on `development` before they are fast-forwarded to `main`. The GitHub Pages deployment uses the repository root and requires no GitHub Actions or build process.

## Files

- `index.html` is the GitHub Pages application entry point.
- `prototype/project_managmetn.html` is the preserved Phase 1 reference copy.
- `supabase/` contains the reviewed database documentation and schema migration.

## Security

No privileged Supabase credentials may be committed to this repository or included in browser code. In particular, never add a Supabase secret or `service_role` key, PostgreSQL password, database connection string, or other server credential. The frontend uses only the browser-safe Supabase project URL and publishable key, with access enforced by Supabase Auth and Row Level Security.

Supabase email/password authentication protects the application flow, and Supabase PostgreSQL is the authoritative portfolio store. All portfolio operations use the authenticated user identity and remain subject to Row Level Security.

When compatible legacy localStorage data is detected for an empty cloud portfolio, the application requires a JSON backup before offering a retry-safe one-time migration. The legacy portfolio keys are retained for rollback and are never silently deleted. After migration, JSON export reads the cloud-backed in-memory portfolio; generic JSON import is temporarily disabled to prevent destructive or partial cloud overwrites.

Password-reset emails use the current HTTPS application directory as their redirect target. Supabase Auth must allow the production GitHub Pages URL in its Site URL and Redirect URLs configuration.
