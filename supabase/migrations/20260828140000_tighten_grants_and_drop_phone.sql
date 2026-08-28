-- Migration 2: close three gaps found reviewing migration 1.
-- Safe to run as written: the tables are empty and the app has no users.

-- ---------------------------------------------------------------------------
-- 1. Drop profiles.phone.
-- RLS filters rows, never columns, so the "read approved dietitians" policy
-- hands the whole profile row -- phone included -- to every authenticated user.
-- That works against locked decision §2 #2 (all contact stays in-app). Phone
-- is unused today (signup collects e-mail, password, full name) and SMS is
-- deferred indefinitely (§2.2 #20), so the column goes rather than the policy.
-- Dropping it also drops it from the column-level UPDATE grant automatically.
-- The wider question -- which dietitian fields are public in the marketplace,
-- and where verification documents live -- is Phase 1 work (open question #19).
-- ---------------------------------------------------------------------------
alter table public.profiles drop column phone;

-- ---------------------------------------------------------------------------
-- 2. Revoke the table privileges Supabase grants by default and migration 1
-- did not remove. RLS does NOT apply to TRUNCATE: it is table-level and
-- all-or-nothing, so a policy cannot hold it back. PostgREST never emits
-- TRUNCATE, which is why this was not reachable in practice -- but migration 1
-- claimed both layers were on, and this makes that claim true.
-- ---------------------------------------------------------------------------
revoke truncate, references, trigger
  on table public.profiles, public.dietitians, public.clients
  from authenticated;

-- ---------------------------------------------------------------------------
-- 3. Postgres grants EXECUTE to PUBLIC on every new function, which exposed
-- the RLS helpers as unauthenticated RPC endpoints: anon could call
-- is_approved_dietitian(<uuid>) over /rest/v1/rpc and get a boolean back.
-- The RLS policies call these as the querying user, so authenticated keeps
-- EXECUTE; anon loses it.
-- set_updated_at() and handle_new_user() are deliberately left alone: they
-- return `trigger`, and Postgres refuses to invoke trigger functions outside
-- trigger context, so they are not RPC-callable regardless of their ACL.
-- ---------------------------------------------------------------------------
revoke execute on function
  public.is_admin(), public.is_approved_dietitian(uuid)
  from public;

grant execute on function
  public.is_admin(), public.is_approved_dietitian(uuid)
  to authenticated;
