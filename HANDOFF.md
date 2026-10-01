# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 1 October 2026 (night).

## Where things stand

- Phase 0 is done (auth, invites, real client list, interview demo on fake data; money UI
  hidden, P6).
- **The redesign is coded** (PLANNING #134–#135, `docs/design-system.md`). Both apps
  and the panel demo now ship "Bevel adapted for an app":
  - Alpino from its variable file (Figtree only for the plan PDF), HIG type sizes.
  - White canvas with Cloud Card cards (core `CloudCard`), black pill buttons, Ink text
    actions, and green only for progress, "approved" and data.
  - Red #B43622, amber #8F5F00, AI-draft violet #514196, one grey #606266, and overlays
    capped at 8 %.
  - A floating white capsule bottom bar in both apps.
  - Panel density by input: compact only in a computer browser. Rail vs bottom bar still
    switches by width.
- Decided by Can on 1 Oct 2026:
  - Accent green (was C36) and a flat Bugün top (was C40).
  - The copy study and the Bugün canvas (old slices 2–3) were skipped.
  - The green "Onaylı" pill, the one darker grey, and the wording of rules 9 and 11.
  - The compact panel scale is coded as drafted; Can judges it on the real panel.
- Checked:
  - Analyze clean. Tests: core 25, client 18, panel 197.
  - Alpino weights render correctly on the Pixel 8a emulator (panel demo).
  - A subagent reviewed the doc and the code; all its findings were fixed or recorded
    (C47).
- Captures: `C:\Users\jhana\Pictures\Wellkit revamp\2026-10-01 Bevel theme\` and
  `…\2026-10-01 Bevel review fixes\`.
- Direction B's 24 Sep Randevular agenda is still in `git stash` ("Randevular agenda (WIP,
  24 Sep)"); it predates the redesign, so treat it as reference, not code to pop.

## Next steps

1. **Web check:** run the panel with `flutter run -d web-server` and open it in the
   Windows browser. Confirm Alpino weights (headings must not look Black) and judge the
   compact scale (13 px body, 32 px controls). Adjust `AppDensity.compact` /
   `AppTypography` if Can wants it larger.
2. **Real client app on the emulator:** the emulator has no DNS (Supabase host lookup
   fails). Toggle Wi-Fi in the emulator or cold-boot it, then check Bugün, Profil and the
   login on the phone.
3. **Artifact pages:**
   - Add `CloudCard` / `inset` to the private Design System artifact
     (https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV).
   - Refresh the panel tour (still pre-Sade).
4. **Screen polish found on the captures:** the Danışanlar filter field still floats its
   label inside the border (the doc wants the label above, via a core wrapper), and
   number columns other than the agenda times (kg, kcal, measurements) don't use fixed
   slots yet (`numberSlotWidth` in core).
5. Outside the redesign, unchanged: data features (weigh-ins first), C17 dev project + CI +
   RLS tests; DT3 and C13 remain Can's most blocking product answers.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Wellkit Bevel system | The design system now in the code (private: Alpino's licence) | https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV |
| Genel Bakış revamp canvas | Direction B proposals and results (history) | https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4 |
| Wellkit design system (Sade) | History | https://claude.ai/artifact/GKBbEfa4zHLzjQtQ6ZZpYh |
| Redesign canvas (23 Sep) | The three older directions | https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |
| Interview guide | Can and Kadir during interviews | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN / TR) | The whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y · https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | 11 demo screens (**pre-Sade**, refresh after the redesign) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |

## Sources and how to read them

- styles.refero.design's robots.txt disallows Claude agents and its API has a bot check:
  read single pages with WebFetch only; values come only from the DESIGN.md file Can
  provides.
- Apple's HIG pages come as exact text from
  `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`.
- Font checks: `uv run --with fonttools python …`. Alpino's zip:
  `/mnt/c/Users/jhana/Desktop/Alpino_Complete.zip`.

## What Can needs to do

- The web check (next step 1) and fixing the emulator's network (step 2).
- C47 (tablets in "desktop site" mode), when the panel goes to tablets.
- Still open from before: C43 (dark mode), C23 (interaction half), DT3, C13, C21, C17,
  DT7, C4, C46.
