-- Migration 4: the dietitian<->client relationship, and the first policy that
-- lets a dietitian read a client's row.
--
-- Closes Open Question #18 and delivers what PLANNING.md §2.2 #34 promised:
-- "Diyetisyen<->danisan iliski tablosu Faz 1'de gelene kadar politika yazmak
-- icin guvenli bir anahtar yok; erisim o zaman kendi acik politikasiyla
-- eklenir." That key now exists, so the access policy is written here -- and
-- only here, scoped to an active relationship with a still-approved dietitian.
--
-- Connection model: the dietitian invites by email, the client accepts from
-- their own app. This is an interim stand-in for marketplace matching
-- ("Diyetisyen listeleme + filtreleme + secim"), which is a separate, larger
-- slice; the `origin` column exists so that flow can be added without having
-- to reinterpret these rows.
--
-- Nothing in this migration notifies an invited client. The invite becomes
-- visible when they sign up and open the app. Real delivery (an Edge Function
-- over inviteUserByEmail) is future work.

create type public.relationship_status as enum ('pending', 'active', 'declined');

create table public.dietitian_client_relationships (
  id uuid not null default gen_random_uuid() primary key,
  dietitian_id uuid not null references public.dietitians (user_id) on delete cascade,
  -- Null until the invited person signs up and accepts: at invite time all we
  -- have is an email address, which may not belong to an account yet.
  client_id uuid references public.clients (user_id) on delete cascade,
  invited_email text not null,
  -- Discriminator for the eventual client-initiated matching flow, so it does
  -- not have to infer intent from `client_id is null`. Only one value today.
  origin text not null default 'dietitian_invite',
  status public.relationship_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  responded_at timestamptz
);

comment on table public.dietitian_client_relationships is
  'The key that authorizes a dietitian to read a client''s health data '
  '(PLANNING.md §2.2 #34). Only status = ''active'' grants anything.';

comment on column public.dietitian_client_relationships.invited_email is
  'Stored lowercased by the app. The accept/decline policies compare it to '
  'the JWT email claim, so this is an authorization input, not just a label.';

-- One live pending invite per (dietitian, email) ...
create unique index dietitian_client_relationships_pending_unique
  on public.dietitian_client_relationships (dietitian_id, lower(invited_email))
  where status = 'pending';

-- ... and one relationship per (dietitian, client) once the client is known,
-- so an already-connected client cannot be re-invited into a second row.
create unique index dietitian_client_relationships_active_unique
  on public.dietitian_client_relationships (dietitian_id, client_id)
  where client_id is not null;

create trigger set_relationships_updated_at
  before update on public.dietitian_client_relationships
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Table privileges. As in migration 2: RLS filters ROWS, grants restrict
-- COLUMNS and VERBS, and truncate/references/trigger are revoked because RLS
-- does not cover them.
-- ---------------------------------------------------------------------------
revoke all on table public.dietitian_client_relationships from anon;
revoke insert, update, delete, truncate, references, trigger
  on table public.dietitian_client_relationships from authenticated;

-- The dietitian may only ever write these two columns; status, client_id and
-- the timestamps are not theirs to set at insert time.
grant insert (dietitian_id, invited_email)
  on table public.dietitian_client_relationships to authenticated;

-- The client may only write the three columns an accept/decline touches.
grant update (client_id, status, responded_at)
  on table public.dietitian_client_relationships to authenticated;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.dietitian_client_relationships enable row level security;

create policy "relationships: dietitian inserts own invites"
  on public.dietitian_client_relationships for insert to authenticated
  with check (
    dietitian_id = (select auth.uid())
    and public.is_approved_dietitian(dietitian_id)
  );

create policy "relationships: dietitian reads own"
  on public.dietitian_client_relationships for select to authenticated
  using (dietitian_id = (select auth.uid()));

-- The invited person can see a pending invite addressed to their verified
-- email before any row points at them, plus everything already theirs.
create policy "relationships: client reads own or invited"
  on public.dietitian_client_relationships for select to authenticated
  using (
    client_id = (select auth.uid())
    or (
      status = 'pending'
      and client_id is null
      and lower(invited_email) = lower((select auth.jwt() ->> 'email'))
    )
  );

-- Accept and decline share eligibility (USING) and differ only in the row
-- they are allowed to produce (WITH CHECK). Permissive policies OR together,
-- so between them exactly two transitions are reachable: pending -> active
-- while claiming yourself, and pending -> declined while claiming nobody.
-- Any other status, or claiming someone else's user id, satisfies neither.
create policy "relationships: client accepts own invite"
  on public.dietitian_client_relationships for update to authenticated
  using (
    status = 'pending'
    and client_id is null
    and lower(invited_email) = lower((select auth.jwt() ->> 'email'))
  )
  with check (client_id = (select auth.uid()) and status = 'active');

create policy "relationships: client declines own invite"
  on public.dietitian_client_relationships for update to authenticated
  using (
    status = 'pending'
    and client_id is null
    and lower(invited_email) = lower((select auth.jwt() ->> 'email'))
  )
  with check (client_id is null and status = 'declined');

-- ---------------------------------------------------------------------------
-- The access this table exists to authorize.
--
-- Additive to migration 1's "clients: read own or admin" (permissive policies
-- OR), so the owner's own access is unchanged. Gated on is_approved_dietitian
-- as well as the relationship: a dietitian whose verification is later revoked
-- loses access to clients they had already matched with.
-- ---------------------------------------------------------------------------
create policy "clients: read via active relationship"
  on public.clients for select to authenticated
  using (
    public.is_approved_dietitian((select auth.uid()))
    and exists (
      select 1 from public.dietitian_client_relationships r
      where r.client_id = clients.user_id
        and r.dietitian_id = (select auth.uid())
        and r.status = 'active'
    )
  );

-- Client names for the panel's list. Deliberately a projection function and
-- NOT a "profiles: dietitian reads matched clients" policy: a row policy on
-- profiles would publish every column the table ever grows to every matched
-- dietitian, which is the leak shape migrations 2 and 3 were written to close
-- on `dietitians`. Adding a column here is a publication decision, as it is
-- for list_approved_dietitians(). It also answers the whole list in one round
-- trip instead of one fetch per client.
create function public.list_my_clients()
returns table (client_id uuid, full_name text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.full_name
  from public.profiles p
  join public.dietitian_client_relationships r on r.client_id = p.id
  where r.dietitian_id = (select auth.uid())
    and r.status = 'active'
    and public.is_approved_dietitian((select auth.uid()));
$$;

-- EXECUTE is granted to PUBLIC by default; take it back first (migration 3).
revoke all on function public.list_my_clients() from public;
grant execute on function public.list_my_clients() to authenticated;
