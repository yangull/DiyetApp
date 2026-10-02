# Wellkit A2 polish pass: plan (7 sessions, all 119 audit items)

Audit page (items X1.., C1.1.., R1.., D1..): https://claude.ai/artifact/DPUhmDFvF1otcXXEa6VqMM
"Before" captures: `C:\Users\jhana\Pictures\Wellkit polish\00 before\`

## How it works
- **Everything gets fixed** unless Can marks an item **Skip** on the audit page. Claude reads the marks (ArtifactData, collection `audit`, doc `marks`) at the start of every session. A **Fix** mark means "do it first".
- Order is by root cause: shared code in `packages/core` first, then screens, so one fix lands everywhere.
- One session = one new chat in this folder (no worktree). Inside a session Claude works in small slices: analyze + tests, a subagent review, before/after captures in `C:\Users\jhana\Pictures\Wellkit polish\<slice>\`, then stops and shows Can. Commit only when Can says "commit", push only on "push".
- Some items are decisions, not code. Claude asks them at the start of the session (listed under each session).
- The model that writes the code is the one selected in the app's model picker. Reviews run as separate subagents on a stronger model.
- Baseline tests (2 Oct 2026, mid-Session 6): core 54, client 26 (+1 skipped capture), panel 212 (+3 skipped captures). Analyze must stay clean.

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
Status: **done, committed (59578ab, c987d6e) and pushed.**
Decisions (Can, 2 Oct 2026): Yakında merged into one small card; the bottom bar stays fixed at 200% text. The progress bar's empty part is a new `track` palette token.
To-do:
- [x] **Bugün** (C3.1-C3.8): fill or remove the empty lower half; "Yakında" as a small card or merged into the steps; the first step stands out; step rows aligned to the title; 0/3 bar visible in dark; one main action when an invite is waiting; the dietitian row with an avatar and something to tap or no false affordance; remove the duplicate "Yakında" tag.
- [x] **Bugün at 200% text** (C4.1-C4.3): ring alignment, the "Düzenle" action, bottom bar scaling (decision).
- [x] **Profil** (C5.1, C5.4, C5.6, C5.7): one empty state, no duplicated "Diyetisyenin", label contrast, 200% layout of the control and the logout icon.
- [x] **Hedeflerim** (C6.2-C6.4): privacy line as a proper note, hints for the empty fields, snackbar theme in `app_theme.dart` (floating, margin, no heavy outline, retry), a way to cancel.
Asked and answered: what should fill Bugün's lower half (client app features don't exist yet; rule 4 allows only real things); the bottom bar at 200%.
Done when: every C screen is re-captured at normal and 200% text, light and dark.

## Session 4: real panel screens (all R items not done above)
Status: **done, awaiting push.** R5.4 (the ₺ box) waits on X2 in Session 6.
Decisions (Can, 2 Oct 2026): the rejected screen shows a placeholder address (`kSupportEmail`, C16 still open); the desktop rail is wider with the mark on top and the dietitian's name at the bottom.
- [x] **Auth and status** (R1.1, R2.1-R2.3): login was already done; status screen has the mark, equal icon discs, a 480 px card and the contact line.
- [x] **Genel Bakış** (R3.1-R3.7, R3.9): first-name greeting, caption under the number, invites first on a phone when one waits, pill at the row's edge (amber for declined), taller rows, extended rail, empty copy without "Diyetisyen bul".
- [x] **Invite dialog** (R4.2, R4.3): shorter honest helper, inline error for an empty or invalid address, scrolls with the keyboard.
- [x] **Client information** (R5.1-R5.3, R5.5): 720 px width, record opens inside the tab so the rail stays, health note regular weight, one empty message.
- [x] **Profil** (R6.1-R6.3): avatar header, 720 px width, approval pill, no placeholder row, selector never under 40 px.
Done when: every R screen re-captured on phone and computer, light and dark (captures in `Wellkit polish\S8-S11`).

## Session 5: demo panel, part 1 (D1-D5)
Status: **done, committed locally, not pushed.**
Decisions (Can, 2 Oct 2026): the interview paragraphs (D1.8, D3.5, D10.1) stay but sit behind a "Görüşme notu" toggle (`InterviewNote`); the "Demo" button on a phone lives in Genel Bakış only.
- [x] **D1 Genel Bakış**: Demo button in the header, shorter first card, seed no longer rolls past midnight, one name per triage action and no chevron, extended rail from 900 px (compact rail with stacked utilities below), note behind a toggle.
- [x] **D2 Danışanlar**: phone controls share rows when they fit, filter sheet without "all" chips and with "Temizle", desktop table with avatars and a right-aligned kg slot.
- [x] **D3 Danışan kartı**: plan card first, equal-column fact grid, number slots for weights and measurements, three notes folded.
- [x] **D4 Plan editor**: phone order (meals before figures), borderless food rows, labelled time, notice and approve button separated.
- [x] **D5 Değişim listesi**: quiet stepper discs, kcal slot, wrapped examples, Planda / Hedef / Fark in one row (gap threshold is DT20).
- [x] **X5, X6 for the demo**: one date format (`formatDate`: "28 Eyl", year only if not current), `trMonthsShort` in core, appointments `_when` uses `formatTime`.
Done when: demo screens re-captured (captures in `Wellkit polish\S12-S15`) and `demo_widget_test.dart` and `demo_codec_test.dart` pass.

## Session 6: demo panel, part 2 (D6-D11), lira sign, icons
Status: **in progress.** Decisions (Can, 2 Oct 2026): icon pack **Lucide** (via `AppIcons` in core, fonts vendored, no wrapper package); lira fallback **Plus Jakarta Sans** (one-glyph subset `Lira`, metrics set to Alpino's).
- [x] **X2 lira sign** and **X4 icons** (also fixes R5.4). Docs updated; `fonts_and_icons_test.dart` guards both.
- [x] **D6 Yeni danışan**, **D7 Randevular** (reviewed, captured in `Wellkit polish\S17`).
- [~] **D8 Görüşme** and **D9 Mesajlar**: coded and tests green; **not yet reviewed by a subagent or captured** (before images are in `S18`). D8: notice without "PLANNING.md §3", back arrow. D9: avatars, times, "Yanıt bekliyor" pill, header with "Danışanı aç", top-anchored thread, labelled "Gönder", cautions as pills.
- [ ] **D10 Takip**: lighter intro, chart labels, a summary row; its interview paragraph goes behind `InterviewNote`.
- [ ] **D11 Ayarlar and reset**: header on phone, "Açık/Kapalı" with the switches, wider reset dialog.
- [ ] Left from session 5: **X5** (number slots in the remaining demo screens: Takip, Ödemeler if shown), check **X6** (any date left in another format).
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
