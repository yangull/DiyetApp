# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

Greenfield — **no code exists yet**. The only content is `PLANNING.md` (in Turkish), the
detailed product/technical plan. Read it at the start of every session; it is a living
document that gets updated, not rewritten. Big decisions move into its "Kilitlenen Ürün
Kararları" (locked decisions) section.

This is a two-sided dietitian marketplace app for the Turkish market: dietitians get a
management panel + marketplace visibility; clients get affordable dietitian access or an
AI-only diet plan tier.

## Locked decisions (do not relitigate without asking Can)

- AI drafts diet plans, the dietitian approves; clients never see unapproved AI plans (on the human-service side).
- All communication stays in-app (chat + embedded video) to protect commission revenue.
- Build order: shared core → dietitian marketplace → AI-only tier.
- No per-dietitian-type screens; one general management panel.
- No Mac available: iOS builds go through Codemagic (cloud CI); daily development happens on Android emulator + Chrome.

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
melos.yaml             monorepo management
```

There are no build/test commands yet. Once the Flutter monorepo exists, Melos will be the
entry point for cross-package commands; document the actual commands here when they exist.

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
