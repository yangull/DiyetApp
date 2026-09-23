# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 23 September 2026.

## Where things stand

- Phase 0 is done: both apps have real Supabase auth, and the real panel has a client
  list, email invites and a thin client detail screen (PLANNING §5 has the table).
- The **interview demo** (`apps/dietitian_panel/lib/main_demo.dart`) is ready for
  interviews. Since 23 Sep all money UI is hidden (`kShowMoney = false`, PLANNING P6).
- **23 Sep 2026 session (docs and direction, little code):**
  - Docs restructured: PLANNING holds only current decisions, HANDOFF is short, traps
    are in CLAUDE.md, `AGENTS.md` sets Codex up (review mode / work mode, own worktree).
  - The Miro board is no longer a source. Every open question is in `QUESTIONS.md`.
  - The GitHub repo was public by mistake and is now private. Triage and wayfinder
    labels exist on GitHub.
  - Can decided: no money in the app at launch (P6), Harris-Benedict as the default
    energy formula, B2B + ads + dietitians' own clients as the acquisition plan, a
    "Diyetisyen bul" section, no client limit, Kutay's Excel dropped, placeholder logo.
  - An example intake form is in `docs/reference/`.
  - The design rules moved into the repo (`docs/design-system.md`, 14 rules). Demo
    buttons now follow rule 13: reset is labelled, cancelling an appointment is labelled
    and asks for confirmation, and the video mockup's dead buttons are disabled.
  - Codex reviewed the panel UI: `docs/research/2026-09-23-ui-review.md`, 15 findings,
    all verified against the code. Fixed the same day: the nine bugs plus #8, #11, #15
    (PLANNING #119), and buttons now use the short form (#120).
- **Later on 23 Sep:** the UI review fixes shipped (PLANNING #119, #120), plus two reset
  gaps from Codex's follow-up review. Can decided: exchange list is the default plan
  model (P4), in-app-only stays with new reasons (P2), **the panel ships on web, phones
  and tablets as its own store app** (#38), next slice is the mobile panel layout. Most
  interview answers are filed in PLANNING §2.1 (#121–#130).
- Analyzer clean, all tests green.

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

1. **Next build: UI review #10 (PLANNING #119).** Put both plan editors in the same
   layout (narrower working column, energy/status/approve kept in view) so dietitians
   compare the model, not the page. Design it for phone widths too (#38).
2. **Then: the mobile panel layout (Can, 23 Sep, was C3).** The panel now ships on web,
   phones and tablets as its own store app (#38). Start with the real panel (client list,
   invites, detail): a bottom bar and stacked screens below a width breakpoint, the
   comfortable density on phones. Needs the Android emulator slice (#3) to check it.
   Codex's inventory of what still assumes desktop (compact density hard-coded in
   `main.dart`, rail-only shells, no `android/`/`ios/` runners or panel bundle id) is in
   `docs/research/2026-09-23-decisions-review.md`.
3. **Can:** turn on email confirmation in Supabase (X1, about 1 minute). Invites depend
   on it.
4. **Can + Kadir:** give Kadir edit access to the interview guide (Share menu) and ask
   K1–K3, K2 first (is the intake form athletes-only?).
5. **Can:** the rest of the interview answers (DT1, DT7, DT8, DT10, DT15), then §0
   (I1–I16), C4 (B2B timing and bulk enrolment) and C8 (listing order).
6. **Can:** re-check QUESTIONS.md "Answered on 23 Sep" after the next talk with Kadir;
   anything wrong goes back to an open question. The panel tour's shared link shows a
   pinned older version: re-pin it from its Share menu if viewers should see the update.
7. **Build after the mobile layout:** the "Diyetisyen bul" journey or the real plan
   editor on `diet_plans`, keyed off `dietitian_client_relationships`.
8. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), RLS access tests, invite email delivery, ending a relationship, Randevular rows
   overflowing below ~900 px width.
