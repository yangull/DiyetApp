# Wellkit A2 polish pass: plan (7 sessions, all 119 audit items)

Audit page (items X1.., C1.1.., R1.., D1..): https://claude.ai/artifact/DPUhmDFvF1otcXXEa6VqMM
"Before" captures: `C:\Users\jhana\Pictures\Wellkit polish\00 before\`

## How it works
- **Everything gets fixed** unless Can marks an item **Skip** on the audit page. Claude reads the marks (ArtifactData, collection `audit`, doc `marks`) at the start of every session. A **Fix** mark means "do it first".
- Order is by root cause: shared code in `packages/core` first, then screens, so one fix lands everywhere.
- One session = one new chat in this folder (no worktree). Inside a session Claude works in small slices: analyze + tests, a subagent review, before/after captures in `C:\Users\jhana\Pictures\Wellkit polish\<slice>\`, then stops and shows Can. Commit only when Can says "commit", push only on "push".
- Some items are decisions, not code. Claude asks them at the start of the session (listed under each session).
- The model that writes the code is the one selected in the app's model picker. Reviews run as separate subagents on a stronger model.
- Baseline tests (after Session 2): core 51, client 21 (+1 skipped capture), panel 199 (+3 skipped captures). Analyze must stay clean.

## Session 1: labelled fields and shared states (core)
To-do:
- [ ] **S1 `LabeledField`** in core: label above in `titleSmall`, field below, helper and error drawn by the wrapper (fixes the 12 px indent), optional show/hide for passwords, real `TextField` inside. Items: X1, C1.2, C2.1, C6.1, R1.2, R1.3, R4.1, D6.1 (D6.1 is checked again in session 6).
- [ ] Wire it into the 4 auth screens, `goals_edit_screen.dart`, the invite dialog, `intake_form_screen.dart`, the `clients_screen.dart` filter and dropdowns (drop the duplicated padding hack).
- [ ] Update tests that find fields by label: `apps/client/test/widget_test.dart` (212, 216, 268), `apps/dietitian_panel/test/layout_width_test.dart` (82-90), `demo_widget_test.dart` (632).
- [ ] **S2 `AppLoading`, `AppErrorView`, `EmptyState`** in core; replace AuthGate's private widgets, `_ErrorCard`, `_Message`, `_NamesErrorNotice` and the hand-built spinners. AuthGate stops printing raw exceptions. Retry is the main action. Items: X10, X11, C7.1-C7.4, R7.1, R7.2, R3.8, R3.9, R5 error state.
- [ ] Wrong-app screen says which app to use, per app (`mismatchBuilder`).
Ask Can: nothing blocking.
Done when: analyze and tests green, captures of login, signup, Hedeflerim, invite dialog, loading and error screens shown.

## Session 2: controls, brand, dark outline, compact size
Status: **S3 and S4 are committed** (b769363, ee71e38). **S5 and S6 are done in the working tree, awaiting Can's commit.** Session 2 is complete.
Decisions (Can, 2 Oct 2026):
- **"Düzenle" rule:** an Ink text action at the row's right end; the pill only for the first-time "Yaz". Done in S3.
- **Compact text:** in the web check (8080) the smallest writing was pixelated and too small. Secondary text in the computer layout goes from 11 to **12 px**, and everything else in the compact scale moves up a little to match, only where needed for readability (S6).
- The selected segment of "Görünüm" stays Charcoal (design system: Black does the acting).
To-do:
- [x] **S3 Actions** (X9, C1.3, R1.4, C5.2, C5.3, C5.5): `AuthSwitchLink`, `SignOutRow`, full-width `ThemeChoiceSelector`, Bugün "Düzenle" as text action.
- [x] **S4 `WellkitMark`** (placeholder "W", drawn in code, no asset) on the 4 auth screens and in `AppLoading`. Items: X3, C1.1, C2.2.
- [x] **S5 dark input outline**: dark `borderStrong` `#74777E` to `#696C73` (3.53 on canvas, 3.10 on a card); `core_test.dart` pairs unchanged (they only need 3:1). Item: X8.
- [x] **S6 compact scale**: 11 px text is now 12; the slots above moved up one step (13 / 14, line heights 15 / 16 / 18); `AppTypography` and the `docs/design-system.md` table updated, all panel layout tests pass. Item: X7. Can judges it on the real panel in a browser.
- [ ] Optional follow-up from the S3 review: `EdgeButton`'s outer 12 px is not tappable (hit-testing stops at the parent's box).
Done when: login, Bugün, Profil, Genel Bakış shown on phone and computer, light and dark.

## Session 3: client app screens (all C items not done above)
To-do:
- [ ] **Bugün** (C3.1-C3.8): fill or remove the empty lower half; "Yakında" as a small card or merged into the steps; the first step stands out; step rows aligned to the title; 0/3 bar visible in dark; one main action when an invite is waiting; the dietitian row with an avatar and something to tap or no false affordance; remove the duplicate "Yakında" tag.
- [ ] **Bugün at 200% text** (C4.1-C4.3): ring alignment, the "Düzenle" action, bottom bar scaling (decision).
- [ ] **Profil** (C5.1, C5.4, C5.6, C5.7): one empty state, no duplicated "Diyetisyenin", label contrast, 200% layout of the control and the logout icon.
- [ ] **Hedeflerim** (C6.2-C6.4): privacy line as a proper note, hints for the empty fields, snackbar theme in `app_theme.dart` (floating, margin, no heavy outline, retry), a way to cancel.
Ask Can: what should fill Bugün's lower half (client app features don't exist yet; rule 4 allows only real things); the bottom bar at 200%.
Done when: every C screen is re-captured at normal and 200% text, light and dark.

## Session 4: real panel screens (all R items not done above)
To-do:
- [ ] **Auth and status** (R1.1, R2.1-R2.3): desktop card width, "Başvuru" icons, reject screen with a contact line (needs C16: ask Can for the address).
- [ ] **Genel Bakış** (R3.1-R3.7, R3.9): shorter heading, focal card alignment, invites before clients on phone, invite row and pill alignment, a distinct pill for declined, thicker client rows, rail width and labels on desktop, empty-state copy without "Diyetisyen bul", error retry as main action.
- [ ] **Invite dialog** (R4.2, R4.3): honest, shorter helper; an error when the email is empty or invalid.
- [ ] **Client information** (R5.1-R5.3, R5.5): `readablePadding`, rail stays reachable, values bold only where they are data, one empty state.
- [ ] **Profil** (R6.1-R6.3): avatar, "Uzmanlık alanları" not shown as data, card width, control size.
Ask Can: the support address for rejected dietitians; what a desktop rail should hold.
Done when: every R screen re-captured on phone and computer, light and dark.

## Session 5: demo panel, part 1 (D1-D5)
To-do:
- [ ] **D1 Genel Bakış**: "Demo" button no longer takes a row on phones; first card shorter; seed times that don't roll past midnight (D1.3); one name for the "Ölçümler / Ölçümleri incele" action; chevron and action don't duplicate; rail label no longer wraps; bottom bar spacing.
- [ ] **D2 Danışanlar**: phone controls on one row; desktop table columns tighter, avatars, `numberSlotWidth` for kg; subtitle size; filter sheet ("Tüm hedefler" semantics, "Temizle" inside).
- [ ] **D3 Danışan kartı**: primary action up, measurement and weight tables in number slots, one date format, `readablePadding`.
- [ ] **D4 Plan editor**: phone order (plan before the macro tiles), fewer bordered boxes, a labelled time field, macro unit baseline, desktop sidebar split.
- [ ] **D5 Değişim listesi**: steppers and kcal in number slots, no clipped second line, a clearer summary.
- [ ] **X5, X6 for the demo**: `trMonthsShort` in core replaces the panel's private list; appointments `_when` uses `formatTime`.
Ask Can: the interview paragraphs (D1.8, D3.5, D10.1): keep as they are because you use them live in interviews, move them behind an info toggle, or delete?
Done when: demo screens re-captured and `demo_widget_test.dart` and `demo_codec_test.dart` pass.

## Session 6: demo panel, part 2 (D6-D11), lira sign, icons
To-do:
- [ ] **D6 Yeni danışan**: grouped intake fields (after the DT7 answer, otherwise tidy only), consistent grid, a sticky action bar.
- [ ] **D7 Randevular**: action alignment on phone, bigger time, table header on desktop, a status pill for "Gelmedi".
- [ ] **D8 Görüşme**: remove "PLANNING.md §3" from the UI, Turkish tooltips on the icon buttons, a back path.
- [ ] **D9 Mesajlar**: avatars and times on the list, thread header, labelled send button, no large empty gap, unread meaning in words.
- [ ] **D10 Takip**: lighter intro, chart labels, a summary row.
- [ ] **D11 Ayarlar and reset**: header on phone, "Açık/Kapalı" with the switches, wider reset dialog.
- [ ] **X2 lira sign**: a fallback font in core so ₺ draws in a matching style; check on the Pixel.
- [ ] **X4 icons**: pick one icon pack (Claude proposes two with a preview; adds a dependency, needs Can's OK) and replace Material icons everywhere.
Ask Can: the icon pack; the fallback font for ₺.
Done when: every D screen re-captured on phone and computer, light and dark.

## Session 7: wrap-up
To-do:
- [ ] A full re-capture of all 170 screens and a final before/after on the audit page (updated in place).
- [ ] Refresh the private design-system artifact and the panel tour (HANDOFF to-do 2).
- [ ] Update `docs/design-system.md` (labels above, shared states, mark, compact scale, icon pack) and `CLAUDE.md` gotchas if new traps appeared; PLANNING.md only for decisions that changed.
- [ ] Rewrite `HANDOFF.md`; ask before commit and push; fast-forward the Codex branch after Can's OK.
Done when: all 119 items are Fixed or Skipped on the page.

## Starting prompts (paste one per new chat)
Every prompt starts: `Read CLAUDE.md, HANDOFF.md and docs/a2-polish-plan.md.` Then:
1. `Do Session 1.`
2. `Do Session 2. S3 is committed; continue with S4, S5, S6 (see the plan).`
3. `Do Session 3. Check each screen at 200% text and in dark mode.`
4. `Do Session 4. Check phone and computer, light and dark.`
5. `Do Session 5.`
6. `Do Session 6.`
7. `Do Session 7.`
Always add: `Read the marks from the audit page first. One slice at a time: analyze + tests, a subagent review, before/after captures in my Pictures folder, then stop and show me. Do not commit unless I say so.`
