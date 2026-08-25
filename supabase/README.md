# Supabase

This directory versions the PostgreSQL schema and Row Level Security (RLS) policies for JON ZAP PORTFOLIO. Migrations live in `migrations/` and must be applied in filename order only after positively identifying the intended Supabase project.

## Schema

- `workflow_columns` stores each user's ordered Kanban workflow. Its `key` is stable when its display `name` changes.
- `projects` belongs to a user and one workflow column, with a persisted position inside that column.
- `project_history` belongs to a user and one project.

Composite foreign keys include `user_id`, preventing projects from referencing another user's columns and history from referencing another user's projects. All application rows ultimately belong to `auth.users`; no separate profile table is required.

## Authorization

RLS is enabled on every application table. Explicit `SELECT`, `INSERT`, `UPDATE`, and `DELETE` policies allow the `authenticated` role to act only where `auth.uid() = user_id`. The `anon` role receives no portfolio table privileges or policies.

## Applying migrations

Review the SQL before applying it. Use the Supabase CLI migration workflow after authenticating and linking the correct project, or run the migration through that project's SQL Editor. Confirm the project reference and environment before execution, then test anonymous denial, owner CRUD, ownership reassignment, and cross-user relationships.

Never store a Supabase secret or `service_role` key, database password, connection string, JWT secret, or other privileged credential in this repository or in browser code.
