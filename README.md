# JON ZAP PORTFOLIO

JON ZAP PORTFOLIO is a small personal project portfolio manager with a Kanban board, configurable workflow columns, project history, RAG health, follow-up tracking, filters, and a 90-Second View.

## Architecture

The application intentionally uses a minimal architecture:

```text
GitHub Pages
  -> Plain HTML, CSS, and JavaScript
  -> Supabase JavaScript client (future phase)
  -> Supabase Auth and PostgreSQL with Row Level Security (future phase)
```

There is no build step or custom backend. The current Phase 1 application persists portfolio data in browser `localStorage`; Supabase integration will later provide authenticated, shared persistence across devices.

## Files

- `index.html` is the future GitHub Pages entry point and currently matches the working prototype.
- `project_managmetn.html` is the original working file retained at the repository root.
- `prototype/project_managmetn.html` is the preserved Phase 1 reference copy.
- `supabase/` is reserved for reviewed database documentation and migrations in later phases.

## Security

No privileged Supabase credentials may be committed to this repository or included in browser code. In particular, never add a Supabase secret or `service_role` key, PostgreSQL password, database connection string, or other server credential. The future frontend will use only the browser-safe Supabase project URL and publishable key, with access enforced by Supabase Auth and Row Level Security.

Supabase email/password authentication protects the application flow, and Supabase PostgreSQL is the authoritative portfolio store. All portfolio operations use the authenticated user identity and remain subject to Row Level Security.

When compatible legacy localStorage data is detected for an empty cloud portfolio, the application requires a JSON backup before offering a retry-safe one-time migration. The legacy portfolio keys are retained for rollback and are never silently deleted. After migration, JSON export reads the cloud-backed in-memory portfolio; generic JSON import is temporarily disabled to prevent destructive or partial cloud overwrites.

Password-reset emails currently use the Supabase project's configured Site URL. Before deployment, configure the exact published GitHub Pages URL under Supabase Auth URL configuration. GitHub Pages deployment itself is not configured yet.
