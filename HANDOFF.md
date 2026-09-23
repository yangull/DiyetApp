# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; traps in `CLAUDE.md`
> ("Gotchas"); vocabulary in `CONTEXT.md`. Updated 23 September 2026.

## Where things stand

- Phase 0 is done: both apps have real Supabase auth, and the real panel has a client
  list, email invites and a thin client detail screen (PLANNING §5 has the table).
- The **interview demo** (`apps/dietitian_panel/lib/main_demo.dart`) is ready for
  discovery interviews, and the TR/EN walkthrough artifact is its fallback:
  https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de
- Paused on 30 Aug 2026, waiting for the dietitian interviews. Whether any have happened
  is QUESTIONS.md C3.
- 23 Sep: docs restructured, Codex set up
  (`AGENTS.md`), repo made private, and every open question merged into `QUESTIONS.md`. The Miro board was
  dropped as a source; its decisions still in force are listed in QUESTIONS.md §0 to confirm.
- Analyzer clean, all tests green, `main` pushed.

## The finding that drives the next slice

Research says Turkish dietitians build plans with a **değişim listesi** (exchange list:
how many exchanges from which food group at each meal) rather than food + amount.
**Unconfirmed.** The demo shows both editors side by side so a dietitian can point at
one (PLANNING P4). A dietitian's energy spreadsheet is the one real artifact we have
(`demo/energy.dart`). Ask where it came from before treating it as common practice.

The plan editor and `diet_plans` stay unbuilt until this is answered. When they are
built, key them off `dietitian_client_relationships`.

## Next steps

1. Answer `QUESTIONS.md` §1 (Can) and send §2 to Kadir.
2. Rewrite the plan model on what the answers say, then build `diet_plans` and the real
   editor into the approved panel.
3. Unblocked meanwhile: CI (analyze + test), check email confirmation (Q29), a dev/prod
   Supabase split, RLS access tests, invite email delivery, ending a relationship.

## Questions for Can

All open questions now live in **`QUESTIONS.md`**, and only there. The most blocking:

0. **§0: confirm or correct the inherited decisions** (I1–I16; I5 and I9 are done).
1. **C1: "exchange list first, freeform kept": a decision, or wait for DT2?** This
   unblocks the plan editor.
2. **C2 and C3: the interview date, and whether the next slice is the marketplace or the
   editor.**
3. **C4: B2B is the main acquisition plan. When does it enter the roadmap?**
4. **C5: does "everything in-app" still hold now that there is no commission?**
5. **Ask Kadir K1–K3**, starting with whether the intake form is for athletes only (K2).
   The guide's Kadir tab: https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB#kadir

Decided on 23 Sep 2026 and already in PLANNING: no money in the app at launch (P6),
Harris-Benedict × activity factor as the default energy formula (#95), B2B + ads +
dietitians' own clients as the acquisition plan, a "Diyetisyen bul" section in the
client app, no client limit per dietitian, Kutay's Excel dropped as a reference, and a
placeholder logo until one is designed.
