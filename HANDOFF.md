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
- Paused on 30 Aug 2026, waiting for the dietitian interviews. On 21 Sep Codex reviewed
  the plan (`docs/research/`); on 23 Sep the docs were restructured (this file,
  PLANNING, CLAUDE.md).
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

1. Get answers to the questions below, starting with 1–3.
2. Rewrite the plan model on what the answers say, then build `diet_plans` and the real
   editor into the approved panel.
3. Unblocked meanwhile: CI (analyze + test), check email confirmation (Q29), a dev/prod
   Supabase split, RLS access tests, invite email delivery, ending a relationship.

## Questions for Can

Open decisions that block work. Answer here or in PLANNING §8, then delete the line.

1. **Are the Miro "görüşme özetleri" real interviews?** Who said them, and when? If they
   are, the "interviews haven't happened" premise is wrong. (Partner — E01.)
2. **Do Kutay's example Excel plans / intake forms exist, and can we get anonymized
   copies?** The plan editor is guesswork without them. (Q10, E02.)
3. **By what date do the interviews happen?** If they slip past it, do we decide the
   plan model without them and mark it reversible?
4. **Next real slice: the marketplace journey or the plan editor?** The confirmed
   promise is new clients, and the marketplace has no real code yet.
5. **First customer journey (D01–D07):** target audience, how clients find us, which
   dietitians and how much capacity, direct choice vs matching, what the first service
   is, and when the client pays.
6. **Sessions or packages (Q28)?** This affects payments, appointments and the listing
   all at once.
7. **WhatsApp:** competitors all use it. Does P2 (in-app only) hold for reminders and
   lead import, or only for the consultation itself?
8. **Separate Supabase dev project?** Right now dev signups land in the one live project.
9. **Issue tracking:** use GitHub Issues (`/wayfinder`, `/to-questionnaire`), or keep
   planning in markdown?
10. **Email confirmation (Q29):** is it on in the dashboard? Invites (#102) depend on it.

The full register (D01–D24, E01–E12, Miro board questions) is
`docs/research/2026-09-21-questions-and-answers.md`.
