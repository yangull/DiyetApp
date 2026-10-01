# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 1 October 2026.

## Where things stand

- Phase 0 is done (auth, invites, real client list, interview demo on fake data; money UI
  hidden, P6).
- **UI revamp, direction B** (Can, 25 Sep 2026, PLANNING #133, `docs/design-system.md`
  "Direction B"): Sade's colour plus Lifesum's hierarchy, for **every panel screen and the
  client app** (this closed C23's visual half). One focal card per screen with one big
  number; small-capital section labels; rows with an avatar or time first and one green
  text action at the right end; dashboards 1200 px with a second column; wide cards
  radius 16. Violet stays on Genel Bakış's drafts label (Can chose it over C30).
- **Slices B1 and B2 committed (not pushed):** Genel Bakış in B for the demo (drafts card
  leads, agenda column, triage by client) and for the real panel (focal card with the
  active count and "Danışan davet et", Danışanlar and Davetler, invites in a second column;
  loading, empty and error states, the invite button stays reachable on error). Shared
  core widgets: `SectionLabel`, `SectionLink`, `ActionRow`, `PersonAvatar`. Both review
  rounds' findings are fixed (wait text kept when rows stack, screen-reader taps, DST-safe
  day labels, one agenda rule `Appointment.isOnAgenda` for Genel Bakış and Randevular,
  tests independent of the time of day). Tests: core 21, client 18, panel 195.
- **Results on the canvas** ("Result" row) and in `Pictures\Wellkit revamp\02 after\`.
- **Rule narrowed, Can to confirm:** in B, a name opens the person's record only in lists
  of people (triage, clients); in draft and agenda rows the action does the thing and the
  name is plain text (docs/design-system.md "Direction B", PLANNING #133).
- `stash@{1}` still holds the 24 Sep Randevular agenda first cut.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Genel Bakış revamp canvas | Before renders, proposals A and B (412 dp, 1440 px), Lifesum refs | https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4 |
| Wellkit design system | Tokens, type, density, rules (from `docs/design-system.md`) | https://claude.ai/artifact/GKBbEfa4zHLzjQtQ6ZZpYh |
| Redesign canvas (23 Sep) | The three older directions | https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |
| Interview guide | Can and Kadir during interviews | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN / TR) | The whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y · https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | 11 demo screens (**pre-Sade**, refresh after the revamp) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |

Captures: `C:\Users\jhana\Pictures\Wellkit revamp\01 before\`. New captures:
`apps/dietitian_panel/test/device_captures_test.dart` (tagged, see its header comment).

## Next steps

1. **Validation pass on Genel Bakış** (the tests cover 360/412 × 1.0/1.3/2.0 and widths up
   to 1600): check it on the Android emulator and in the Windows browser, then an
   accessibility pass (contrast, labels, focus, tap targets) with the design plugin's
   accessibility-review method.
2. **Roll B out screen by screen**, one commit each, review subagent before each commit:
   Randevular first (pop `stash@{1}`, the 24 Sep agenda, and redraw it in B), then
   Danışanlar, client record, Mesajlar, Takip, plan editors, settings, real Profil and
   client detail (both still lack the 1100 px cap), then the client app (Bugün, Profil).
3. Refresh the panel tour artifact after the rollout.
4. Unchanged: data features (Claude recommends weigh-ins first), C17 dev project + CI +
   RLS tests; DT3 and C13 are Can's most blocking answers.

## What Can needs to do

- Nothing blocks B2. Look at the canvas when the result row is up.
- Confirm the narrowed names rule above (or ask for every name to open its record).
- Say "push" when you want the revamp commits on GitHub.
- Still open for you: C23 (interaction half), DT3, C13, C21, C17, DT7, C4.
