# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 23 September 2026.

## Where things stand

- Phase 0 is done: both apps have real Supabase auth. The **client app** has login, a
  two-tab home, invite accept/decline and the "Hedeflerim" form. The **real panel** has a
  client list, email invites and a thin client detail screen (PLANNING §5).
- The **interview demo** (`apps/dietitian_panel/lib/main_demo.dart`) runs on fake data.
  Money UI is hidden (`kShowMoney = false`, P6); "Sıfırla" also clears screen state.
- **23 Sep 2026, one long session:**
  - Docs restructured (PLANNING = current decisions only, HANDOFF short, traps in
    CLAUDE.md, `AGENTS.md` for Codex). Miro is no longer a source.
  - Codex's UI review fixed: nine bugs plus #8, #10, #11, #15 (PLANNING #119); buttons
    use the short form (#120). Two Codex follow-up reviews applied; all three reviews are
    in `docs/research/`.
  - Can decided: exchange list is the default plan model (P4), in-app only stays with new
    reasons (P2), **the panel ships on web, phones and tablets as its own store app**
    (#38), no money at launch (P6). Most interview answers are in PLANNING §2.1
    (#121–#130). Every answer from 23 Sep is listed in QUESTIONS.md "Answered on 23 Sep"
    as open to correction.
- Analyzer clean, all tests green (core 4, client 7, panel 47).

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Interview guide | Can and Kadir during interviews; notes are shared and tagged per dietitian | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN) | Understanding the whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y |
| Project overview (TR) | The same, for Kadir | https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | The 11 demo screens with one question each | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |
| Design system (history) | The 28 Aug design decisions; the source is now `docs/design-system.md` | https://claude.ai/code/artifact/1d9436dc-cd7c-4639-a4ec-9459de2d8ea3 |

The interview guide mirrors QUESTIONS.md §2 (K) and §3 (DT) with the same numbers. After
an interview, ask Claude to "read the guide notes"; it moves the answers into QUESTIONS.md
and PLANNING.md.

## Next steps

1. **Next build: the mobile panel layout (Can, 23 Sep, was C3).** The panel now ships on web,
   phones and tablets as its own store app (#38). Start with the real panel (client list,
   invites, detail): a bottom bar and stacked screens below a width breakpoint, the
   comfortable density on phones. Needs the Android emulator slice (#3) to check it.
   Codex's inventory of what still assumes desktop (compact density hard-coded in
   `main.dart`, rail-only shells, no `android/`/`ios/` runners or panel bundle id) is in
   `docs/research/2026-09-23-decisions-review.md`.
2. **Can:** turn on email confirmation in Supabase (X1, about 1 minute). Invites depend
   on it.
3. **Can + Kadir:** give Kadir edit access to the interview guide (Share menu) and ask
   K1–K3, K2 first (is the intake form athletes-only?).
4. **Can:** the rest of the interview answers (DT1, DT7, DT8, DT10, DT15), then §0
   (I1–I16), C4 (B2B timing and bulk enrolment) and C8 (listing order).
5. **Can:** re-check QUESTIONS.md "Answered on 23 Sep" after the next talk with Kadir;
   anything wrong goes back to an open question. The panel tour's shared link shows a
   pinned older version: re-pin it from its Share menu if viewers should see the update.
6. **Build after the mobile layout:** the "Diyetisyen bul" journey or the real plan
   editor on `diet_plans`, keyed off `dietitian_client_relationships`.
7. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), RLS access tests, invite email delivery, ending a relationship, Randevular rows
   overflowing below ~900 px width.
