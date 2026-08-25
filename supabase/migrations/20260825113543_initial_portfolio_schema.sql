-- JON ZAP PORTFOLIO: initial application schema and authorization boundary.
-- Apply only to the positively identified Supabase project.

begin;

create table public.workflow_columns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  key text not null,
  name text not null,
  position integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint workflow_columns_user_key_unique unique (user_id, key),
  constraint workflow_columns_id_user_unique unique (id, user_id),
  constraint workflow_columns_key_not_blank check (length(btrim(key)) > 0),
  constraint workflow_columns_name_not_blank check (length(btrim(name)) > 0),
  constraint workflow_columns_position_nonnegative check (position >= 0)
);

create index workflow_columns_user_position_idx
  on public.workflow_columns (user_id, position);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  workflow_column_id uuid not null,
  name text not null,
  client text not null,
  health text not null,
  priority text not null,
  objective text,
  current_situation text,
  next_action text,
  blocker text,
  next_followup date,
  notes text,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint projects_id_user_unique unique (id, user_id),
  constraint projects_workflow_column_owner_fk
    foreign key (workflow_column_id, user_id)
    references public.workflow_columns (id, user_id),
  constraint projects_name_not_blank check (length(btrim(name)) > 0),
  constraint projects_health_valid check (health in ('green', 'amber', 'red')),
  constraint projects_priority_valid check (priority in ('High', 'Medium', 'Low')),
  constraint projects_position_nonnegative check (position >= 0)
);

create index projects_user_column_position_idx
  on public.projects (user_id, workflow_column_id, position);

create index projects_user_next_followup_idx
  on public.projects (user_id, next_followup);

create index projects_user_health_idx
  on public.projects (user_id, health);

create table public.project_history (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  user_id uuid not null references auth.users (id) on delete cascade,
  event_date date not null,
  description text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint project_history_project_owner_fk
    foreign key (project_id, user_id)
    references public.projects (id, user_id)
    on delete cascade,
  constraint project_history_description_not_blank
    check (length(btrim(description)) > 0)
);

create index project_history_project_timeline_idx
  on public.project_history (project_id, event_date desc, created_at desc);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger workflow_columns_set_updated_at
before update on public.workflow_columns
for each row execute function public.set_updated_at();

create trigger projects_set_updated_at
before update on public.projects
for each row execute function public.set_updated_at();

create trigger project_history_set_updated_at
before update on public.project_history
for each row execute function public.set_updated_at();

alter table public.workflow_columns enable row level security;
alter table public.projects enable row level security;
alter table public.project_history enable row level security;

create policy "workflow_columns_select_own"
on public.workflow_columns
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "workflow_columns_insert_own"
on public.workflow_columns
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "workflow_columns_update_own"
on public.workflow_columns
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "workflow_columns_delete_own"
on public.workflow_columns
for delete
to authenticated
using ((select auth.uid()) = user_id);

create policy "projects_select_own"
on public.projects
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "projects_insert_own"
on public.projects
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "projects_update_own"
on public.projects
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "projects_delete_own"
on public.projects
for delete
to authenticated
using ((select auth.uid()) = user_id);

create policy "project_history_select_own"
on public.project_history
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "project_history_insert_own"
on public.project_history
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "project_history_update_own"
on public.project_history
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "project_history_delete_own"
on public.project_history
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- Supabase's browser roles receive only the privileges needed by the MVP.
-- RLS policies above remain the row-level authorization boundary.
revoke all privileges on table public.workflow_columns from public, anon, authenticated;
revoke all privileges on table public.projects from public, anon, authenticated;
revoke all privileges on table public.project_history from public, anon, authenticated;

grant select, insert, update, delete on table public.workflow_columns to authenticated;
grant select, insert, update, delete on table public.projects to authenticated;
grant select, insert, update, delete on table public.project_history to authenticated;

commit;
