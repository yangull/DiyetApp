-- Migration 1: identity, roles, and RLS baseline.
-- Scope: profiles + dietitian/client detail tables only (PLANNING.md §12 step 3).
-- diet_plans, blood_tests, chat, payments: later phases. The §2.2 #25 rule
-- (clients see only approved plans, enforced in RLS) lands with diet_plans.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type public.user_role as enum ('client', 'dietitian', 'admin');
create type public.verification_status as enum ('pending', 'approved', 'rejected');

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid not null primary key references auth.users (id) on delete cascade,
  role public.user_role not null,
  full_name text not null default '',
  phone text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- Referenced by the composite FKs below; makes (id, role) addressable.
  unique (id, role)
);

comment on table public.profiles is
  'One row per auth.users row, created by trigger at signup. role is immutable: '
  'column UPDATE is not granted to authenticated, and the composite FKs from '
  'dietitians/clients pin it. Email stays in auth.users only (data minimization).';

create table public.dietitians (
  user_id uuid not null primary key,
  role public.user_role not null default 'dietitian' check (role = 'dietitian'),
  specialties text[] not null default '{}',
  certificate_url text,
  verification_status public.verification_status not null default 'pending',
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (user_id, role) references public.profiles (id, role) on delete cascade
);

create table public.clients (
  user_id uuid not null primary key,
  role public.user_role not null default 'client' check (role = 'client'),
  goal text,
  budget_range text,
  health_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (user_id, role) references public.profiles (id, role) on delete cascade
);

comment on column public.clients.health_notes is
  'Personal health data (KVKK). Readable by the owner only until a '
  'dietitian-client relationship table exists with its own explicit policy.';

-- ---------------------------------------------------------------------------
-- updated_at maintenance
-- ---------------------------------------------------------------------------
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

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
create trigger set_dietitians_updated_at
  before update on public.dietitians
  for each row execute function public.set_updated_at();
create trigger set_clients_updated_at
  before update on public.clients
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Signup trigger: auth.users -> profiles (+ detail row)
-- security definer: runs as the function owner (postgres), because at signup
-- time there is no authenticated user context and profiles has no INSERT
-- grant for app roles anyway.
-- ---------------------------------------------------------------------------
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  final_role public.user_role;
begin
  -- raw_user_meta_data is CLIENT-CONTROLLED (signUp data:). Never trust it
  -- for privilege: only 'dietitian' is honored; anything else (including a
  -- forged 'admin', or nothing) becomes 'client'. Admin is granted only by
  -- manual promotion in the dashboard (PLANNING.md §2.2).
  if new.raw_user_meta_data ->> 'role' = 'dietitian' then
    final_role := 'dietitian';
  else
    final_role := 'client';
  end if;

  insert into public.profiles (id, role, full_name)
  values (
    new.id,
    final_role,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );

  if final_role = 'dietitian' then
    insert into public.dietitians (user_id) values (new.id);
  else
    insert into public.clients (user_id) values (new.id);
  end if;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- RLS helper functions.
-- security definer so they bypass RLS on the tables they consult:
-- is_admin() reads profiles and is used inside profiles policies -- without
-- security definer that is infinite recursion (42P17).
-- ---------------------------------------------------------------------------
create function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;

create function public.is_approved_dietitian(profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.dietitians d
    where d.user_id = profile_id
      and d.verification_status = 'approved'
  );
$$;

-- ---------------------------------------------------------------------------
-- Table privileges (column-level immutability).
-- RLS filters ROWS; these grants restrict COLUMNS and VERBS. Both layers on.
-- service_role keeps its default full access (admin/API use); do not revoke it.
-- ---------------------------------------------------------------------------
revoke all on table public.profiles, public.dietitians, public.clients from anon;

revoke insert, update, delete on table public.profiles from authenticated;
grant update (full_name, phone, avatar_url) on table public.profiles to authenticated;

revoke insert, update, delete on table public.dietitians from authenticated;
grant update (specialties, certificate_url, bio) on table public.dietitians to authenticated;
-- verification_status deliberately NOT granted: only admin/service_role may set it.

revoke insert, update, delete on table public.clients from authenticated;
grant update (goal, budget_range, health_notes) on table public.clients to authenticated;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.dietitians enable row level security;
alter table public.clients enable row level security;

-- profiles ------------------------------------------------------------------
create policy "profiles: read own"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "profiles: read approved dietitians"
  on public.profiles for select to authenticated
  using (public.is_approved_dietitian(id));

create policy "profiles: admin reads all"
  on public.profiles for select to authenticated
  using (public.is_admin());

create policy "profiles: update own"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- No INSERT/DELETE policies on purpose: rows are created by the signup
-- trigger and removed by the auth.users ON DELETE CASCADE only.

-- dietitians ----------------------------------------------------------------
create policy "dietitians: read approved, own, or admin"
  on public.dietitians for select to authenticated
  using (
    verification_status = 'approved'
    or user_id = (select auth.uid())
    or public.is_admin()
  );

create policy "dietitians: update own"
  on public.dietitians for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "dietitians: admin update"
  on public.dietitians for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());
-- Note: admin verification changes go through service_role or the dashboard
-- for now; this policy alone doesn't widen authenticated column grants --
-- an admin JWT still lacks UPDATE(verification_status).

-- clients -------------------------------------------------------------------
create policy "clients: read own or admin"
  on public.clients for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());

create policy "clients: update own"
  on public.clients for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
