-- Migration 3: split the public marketplace view of a dietitian from the
-- private one. Closes open question #19 (PLANNING.md §2.4 left it explicitly
-- unresolved; HANDOFF.md marks it blocking before the first approval).
--
-- The leak: RLS filters rows, never columns, so migration 1's
-- "read approved, own, or admin" policy handed every column of every approved
-- dietitian -- certificate_url, the diploma document -- to any signed-in user.
-- Migration 2 fixed the same class of bug on profiles.phone by dropping the
-- column; certificate_url is in use and cannot go, so the row broadcast does.

-- ---------------------------------------------------------------------------
-- 1. Narrow the base table to owner-or-admin, matching the clients policy.
-- Nothing reads another dietitian's row today: fetchDietitianDetail in
-- packages/core/lib/src/auth/supabase_profile_repository.dart only ever asks
-- for the signed-in user's own row, which the first branch still allows.
-- ---------------------------------------------------------------------------
drop policy "dietitians: read approved, own, or admin" on public.dietitians;

create policy "dietitians: read own or admin"
  on public.dietitians for select to authenticated
  using (
    user_id = (select auth.uid())
    or public.is_admin()
  );

-- ---------------------------------------------------------------------------
-- 2. The marketplace projection. certificate_url is absent from the return
-- type rather than filtered in the body, so widening the where clause later
-- still cannot expose it. security definer + empty search_path follows the
-- is_admin/is_approved_dietitian shape from migration 1.
--
-- The column list is a first guess -- no marketplace screen consumes this yet
-- and open question #14 (which fields dietitians fill in) is still open. Treat
-- adding a column here as a deliberate publication decision.
-- ---------------------------------------------------------------------------
create function public.list_approved_dietitians()
returns table (
  user_id uuid,
  specialties text[],
  bio text
)
language sql
stable
security definer
set search_path = ''
as $$
  select d.user_id, d.specialties, d.bio
  from public.dietitians d
  where d.verification_status = 'approved';
$$;

comment on function public.list_approved_dietitians() is
  'Marketplace-safe projection of approved dietitians. certificate_url and '
  'verification_status are deliberately not returned. The base table is '
  'owner-or-admin only, so this function is the sole path to another '
  'dietitian s row.';

-- Postgres grants EXECUTE to PUBLIC on every new function (migration 2 §3).
revoke execute on function public.list_approved_dietitians() from public;
grant execute on function public.list_approved_dietitians() to authenticated;
