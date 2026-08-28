# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start here

**Read `HANDOFF.md` first.** It records where the last session stopped, what was
learned about how Turkish dietitians actually build diet plans, which decisions are
blocking, and the traps worth avoiding.

## Project status

`PLANNING.md` (in Turkish) is the product/technical plan. Read it at the start of every
session; it is a living document that gets updated, not rewritten. Big decisions move into
its "Kilitlenen Kararlar" (locked decisions) sections.

Built so far: the Flutter monorepo skeleton, the Supabase identity schema (applied to the
live EU project), and real Supabase auth in both apps — `packages/core/lib/src/auth/` holds
the repository interfaces, Supabase implementations, in-memory fakes, and the shared
`AuthGate` router. Both apps reach a real "login → first screen" (PLANNING.md §12 steps 1–5,
done). `apps/dietitian_panel` has a second, separate entry point, `lib/main_demo.dart` — the
unauthenticated interview prototype with fake data, used to drive discovery interviews; don't
confuse it with `lib/main.dart`, the real app. Not built yet: everything in Phase 1 (client
management, the real plan editor, matching) — gated on the diet-plan-model question in
HANDOFF.md §2.

**Wellkit** is a two-sided dietitian marketplace app for the Turkish market: dietitians get a
management panel + marketplace visibility; clients get affordable dietitian access or an
AI-only diet plan tier.

## Locked decisions (do not relitigate without asking Can)

- AI drafts diet plans, the dietitian approves; clients never see unapproved AI plans (on the human-service side).
- All communication stays in-app (chat + embedded video) to protect commission revenue.
- Build order: shared core → dietitian marketplace → AI-only tier.
- No per-dietitian-type screens; one general management panel.
- No Mac available: iOS builds go through Codemagic (cloud CI). Daily development is web-first via `flutter run -d web-server`, opened from the Windows browser; the Android emulator arrives as an early Phase 1 slice.

## Tech stack (decided)

- **Flutter** for the client app (iOS + Android) and **Flutter Web** for the dietitian panel, sharing a `core` package in a single **Melos** monorepo.
- **Supabase (EU region)** for auth, Postgres, storage, realtime. EU region is deliberate: the app holds personal health data and must be **KVKK**-compliant.
- **Supabase Edge Functions** for all LLM calls — API keys never live in the client.
- Payments: **iyzico** for human dietitian services (commission-based, IAP not required — Uber/Airbnb model); **RevenueCat + in-app purchase** for the AI subscription tier (Apple/Google requirement).
- Video SDK not chosen yet (candidates: Agora / 100ms / Daily).

## Planned repo structure

```
apps/client/           Flutter customer app (iOS + Android)
apps/dietitian_panel/  Flutter Web panel
packages/core/         shared models, Supabase client, auth, theme
supabase/migrations/   SQL schema versions
supabase/functions/    Edge Functions (AI calls)
pubspec.yaml           pub workspace root; Melos config lives under its `melos:` key
```

## Flutter commands

Flutter 3.47.2 / Dart 3.13.2 lives at `~/development/flutter` (on PATH via `~/.bashrc`).
The repo is a **Dart pub workspace**: one `.dart_tool/` and one `pubspec.lock` at the root,
and every package declares `resolution: workspace`.

Melos 8 is a dev dependency rather than a global install, and its config lives under the
`melos:` key in the root `pubspec.yaml` — **not** in a `melos.yaml`, which Melos 8 ignores
when the root declares a pub workspace. Run scripts from the repo root:

```bash
dart run melos run analyze   # dart analyze --fatal-infos in every package
dart run melos run format    # dart format . (writes files)
dart run melos run test      # flutter test in every package that has test/
flutter pub get              # resolve the whole workspace at once
```

Run an app from its own directory; the config file is required or `AppConfig` comes up empty:

```bash
cd apps/client   # or apps/dietitian_panel
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
  --dart-define-from-file=../../env/dev.json
```

Then open `http://localhost:8080` from the Windows browser. Note that `flutter devices` does
**not** list the `web-server` device in this WSL setup even though `-d web-server` works —
don't chase that. There is no Chrome, no Android SDK, and no Linux desktop toolchain inside
WSL, so `flutter doctor` shows three expected failures.

`apps/dietitian_panel` has a second entry point: add `-t lib/main_demo.dart` to the command
above to run the unauthenticated interview prototype (fake data, no login) instead of the
real auth-gated app. See HANDOFF.md §1.

## Supabase (working commands)

The repo is linked to the cloud project `jpkvulcszsutacritttk` (eu-central-1). CLI v2.116
lives at `~/.local/bin/supabase`. No local Docker stack — everything targets the cloud
project directly.

```bash
supabase migration new <name>   # create a new timestamped SQL file
supabase db push --dry-run      # show which migrations would apply
supabase db push                # apply them to the EU cloud project
supabase migration list         # compare local vs remote migration state
```

Never create or edit schema from the dashboard UI — every change is a versioned file in
`supabase/migrations/`. `supabase/config.toml` only configures the (unused) local stack;
remote auth settings are changed in the dashboard.

Real values for `--dart-define-from-file` are in `env/dev.json` (gitignored). The key
stored there is the **publishable** key (`sb_publishable_...`), not the legacy anon JWT.

## Working rules (from PLANNING.md §13)

- The Miro board (ID: `uXjVH1k8Rq8=`) is the source of truth for product decisions; on conflict, check the board or ask Can.
- When unsure, **ask — don't assume**.
- UI text in Turkish; code and commit messages in English.
- Work in small, working slices — no big-bang PRs.
- Update PLANNING.md each session.

## First milestone (PLANNING.md §12)

Scaffold the Melos monorepo → `packages/core` models + mocked Supabase wrapper → create
the Supabase project together (EU) with the first migration → auth flow with role
selection (`client`/`dietitian`/`admin`) → both apps reach "login → empty home screen".
Store/Codemagic accounts come after this milestone.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (yangull/DiyetApp), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one root `CONTEXT.md` + `docs/adr/`. See `docs/agents/domain.md`.
