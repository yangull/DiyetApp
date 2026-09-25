# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 25 September 2026 (night).

## Where things stand

- Phase 0 is done (auth, invites, real client list, interview demo on fake data; money UI
  hidden, P6).
- **UI revamp, direction B** (Can, 25 Sep 2026, PLANNING #133, `docs/design-system.md`
  "Direction B"): Sade's colour plus Lifesum's hierarchy, for **every panel screen and the
  client app** (this closed C23's visual half). One focal card per screen with one big
  number; small-capital section labels; rows with an avatar or time first and one green
  text action at the right end; dashboards 1200 px with a second column; wide cards
  radius 16. Violet stays on Genel Bakış's drafts label (Can chose it over C30).
- **Slice B1 committed (`664086c`, not pushed):** the demo's Genel Bakış in B, shared core
  widgets `SectionLabel`, `ActionRow`, `PersonAvatar`, and `trUpper`/`trLower`/
  `formatDecimal` moved to core. Lifesum references committed under
  `docs/design/references/2026-09-25-lifesum/`. Tests: core 21, client 18, panel 183.
- **Slice B2 in `git stash@{0}`:** the real panel's Genel Bakış in B (focal card with the
  active count and "Danışan davet et", Danışanlar and Davetler sections, invites in a
  second column on wide screens; loading, empty, error states). Code done and analyzer
  clean; `apps/dietitian_panel/test/widget_test.dart` still expects the old table
  ("Aktif" pill, "Davet bekliyor" twice, the invite button's edge test). Also add
  `clipBehavior: Clip.antiAlias` to the demo triage card (splash at rounded corners).
- **Review of B1 (Claude subagent, 25 Sep, verified at runtime; fix before committing B2):**
  1. Wide draft rows drop the wait ("3 gündür bekliyor") when `ActionRow` stacks (700–1100 px
     at 1.3×, any width at 2×): show `meta` under the body instead.
  2. The two new wide tests fail after 22:00 (seed `today.hour + 2` rolls into tomorrow):
     keep that seed inside today or don't look for "BUGÜN".
  3. The triage name row's `Semantics(excludeSemantics)` drops the tap action: add `onTap`.
  4. `formatDayHeading`/`formatDayInSentence` break on DST days: compare calendar dates.
  5. Today's appointment leaves the agenda once it starts (`upcoming`); keep it until it ends.
  6. Draft and agenda names don't open the record, though the B rule says names do.
  7. Stale docs: CLAUDE.md and design-system.md still name `lib/util/turkish.dart`;
     PLANNING #133's older sentence about the counts line; `triage.dart` mentions "Sıradaki işler".
  8. Client app: `DietitianRow` avatar shrank 44 → 40 (default size changed).
  9. Missing tests: day helpers, empty states, which draft "İncele" opens.
  10. `_AllAppointmentsLink` duplicates `SectionLabel`'s link button.
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

1. **Fix the B1 review findings above**, then **finish B2:** `git stash pop stash@{0}`, update
   `widget_test.dart`, run melos analyze and test, review B2 with a subagent, commit.
2. **Put the Flutter renders on the canvas** next to mockup B (a "Result" row) and copy
   them to `Pictures\Wellkit revamp\02 after\`; then the validation pass: 360/412 dp,
   text 1.0/1.3/2.0, wide rail, contrast, screen-reader labels, focus, tap targets
   (design plugin's accessibility-review method; the plugin is not synced into Claude
   Code, so follow its public SKILL.md).
3. **Roll B out screen by screen:** Randevular (pop `stash@{1}` and redraw in B), then
   Danışanlar, client record, Mesajlar, Takip, plan editors, settings, real Profil and
   client detail (both still lack the 1100 px cap), then the client app (Bugün, Profil).
   One commit per screen.
4. Refresh the panel tour artifact after the rollout.
5. Unchanged from before: data features (Claude recommends weigh-ins first), C17 dev
   project + CI + RLS tests, DT3 and C13 are Can's most blocking answers.

## What Can needs to do

- Nothing blocks B2. Look at the canvas when the result row is up.
- Say "push" when you want `664086c` (and later slices) on GitHub.
- Still open for you: C23 (interaction half), DT3, C13, C21, C17, DT7, C4.
