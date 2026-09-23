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
    all verified against the code. The fix plan is QUESTIONS.md C18.
- Analyzer clean, all tests green, `main` pushed.

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

1. **Next build: the UI review fixes (QUESTIONS.md C18).** Waiting for Can's OK on the
   recommendation: group A (nine bugs) plus #8, #11 and #15, as one slice; then #10
   together with putting both plan editors in the same layout. Settle C19 (button
   wording) in the same go.
2. **Can:** answer QUESTIONS.md §0 (keep / change / drop for I1–I16), then C1–C5: plan
   model, interview date, next slice, B2B timing, whether "everything in-app" holds.
3. **Can:** turn on email confirmation in Supabase (X1, about 1 minute). Invites depend
   on it.
4. **Can + Kadir:** give Kadir edit access to the interview guide (Share menu) and ask
   K1–K3, K2 first (is the intake form athletes-only?).
5. **Interviews:** run them with the demo (`flutter run -t lib/main_demo.dart …`, see
   CLAUDE.md) and the guide (DT1–DT17). Afterwards: "read the guide notes".
6. **Build, once C1/C3 are answered:** the "Diyetisyen bul" journey or the real plan
   editor on `diet_plans`, keyed off `dietitian_client_relationships`.
7. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), RLS access tests, invite email delivery, ending a relationship, Randevular rows
   overflowing below ~900 px width.
