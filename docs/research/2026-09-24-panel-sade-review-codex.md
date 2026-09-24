# Panel Sade review — Codex, 24 September 2026

Scope: `git diff ebe6239..9efb7c9`, with HEAD at `9efb7c9`. This range contains **five commits after the base**, not six. Reviewed both panel entry points and the shared theme's client-app callers. Formed the findings before reading Claude's slices 1–3 review. No product decisions are reopened.

**Verdict:** keep the direction and the shared components. Fix the new draft-count shortcut before calling slice 4b complete, and include the layout/accessibility gaps below in the remaining work. Six findings; no P0/P1 issue found. Older problems are explicitly distinguished from changes introduced by this range.

Validation: `dart run melos run analyze` and `dart run melos run test` both **passed across all three packages**. The panel finished with 112 passing tests and one skipped screenshot test. The SDK needed its documented PATH and cache access. No Supabase operations, emulator, app launch against real data, or screenshot regeneration. Layout findings below use source constraints and, where stated, measurements of the bundled Figtree font; they are not claimed as device reproductions. No live TalkBack/VoiceOver session was performed.

## Bugs and implementation gaps, ranked

### 1. P2 — The new “onay bekliyor” shortcut silently does nothing when its destination is not built

[overview_screen.dart:33](apps/dietitian_panel/lib/screens/overview_screen.dart:33), [overview_screen.dart:50](apps/dietitian_panel/lib/screens/overview_screen.dart:50), [overview_screen.dart:77](apps/dietitian_panel/lib/screens/overview_screen.dart:77).

**New in 4b.** `_showDrafts` returns when `_draftsKey.currentContext` is null. Its heading is a separate child after the entire triage card in a lazy `ListView`. On a fresh phone view with large text and enough triage rows to put that heading beyond the viewport/cache, activating the enabled count cannot reach the drafts. Building a list of widgets does not mount all their elements. The seeded stale weigh-ins, unanswered messages and no-show make this a relevant interview scenario, not just a huge-data case.

Make the destination reachable without requiring it to have been laid out first. This repository already handles the same problem explicitly in [client_detail_screen.dart:59](apps/dietitian_panel/lib/screens/client_detail_screen.dart:59). Test the shortcut from scroll offset zero at both phone widths and all three scales, with the target initially unmounted. The current counts test only taps “4 randevu” ([demo_widget_test.dart:60](apps/dietitian_panel/test/demo_widget_test.dart:60)).

### 2. P2 — The draft rows still cannot fit enlarged phone text

[overview_screen.dart:317](apps/dietitian_panel/lib/screens/overview_screen.dart:317), [overview_screen.dart:323](apps/dietitian_panel/lib/screens/overview_screen.dart:323), [tone_pill.dart:27](apps/dietitian_panel/lib/widgets/tone_pill.dart:27).

**Retained layout defect in a row changed by 4a, not wholly introduced here.** A `ListTile` reserves width for the leading icon and trailing “İncele”; inside its title, only the client name is flexible. The waiting pill receives unbounded horizontal space from the `Row`, so its own `Flexible` does not make it wrap to the available title width.

Concrete case: scroll to Elif's seeded “3 gün bekliyor” draft at 2.0×. Bundled Figtree advances plus the explicit padding give that pill approximately **186 dp**. The title has only approximately **118 dp at 360**, or **170 dp at 412**, before its additional 12 dp gap and the client name. It must overflow. At 360/1.3× the name gets only about 7 dp. These are font/constraint calculations, not screenshot measurements; inherited letter spacing can make the deficit slightly larger.

Stack the name/status and action on phones, or constrain and wrap the whole group. Scroll through the draft card in the phone matrix: the current overview test stops after reaching triage and dragging 300 dp ([demo_widget_test.dart:425](apps/dietitian_panel/test/demo_widget_test.dart:425)). Passing that test does not establish that these rows fit.

### 3. P2 — Wide client tables clip text instead of growing

[clients_screen.dart:199](apps/dietitian_panel/lib/screens/clients_screen.dart:199), [real_overview_screen.dart:367](apps/dietitian_panel/lib/panel/real_overview_screen.dart:367), [app_density.dart:45](packages/core/lib/src/theme/tokens/app_density.dart:45).

**Pre-existing, relevant to the changed status pills and the requested rail review.** Both real and demo table rows use `height: density.rowHeight`, which is 44 dp on wide windows. At, for example, 800 dp and 2.0×, a draft label or long invited email must wrap within its fractional column. Two compact body lines require 64–72 dp, so a fixed 44 dp row clips them. The phones already use a minimum height and can grow.

Use minimum heights for wide data rows too, and check the demo's fixed-height header. Add a wide enlarged-text case for each entry point; the real-panel matrix currently covers only the phone branch ([widget_test.dart:347](apps/dietitian_panel/test/widget_test.dart:347)). This does not require changing the locked compact density or the deferred tablet touch policy.

### 4. P2 — Sign-out text fails AA while hovered or focused

[real_profile_screen.dart:73](apps/dietitian_panel/lib/panel/real_profile_screen.dart:73), [auth_gate.dart:106](packages/core/lib/src/auth/auth_gate.dart:106), [app_theme.dart:154](packages/core/lib/src/theme/app_theme.dart:154).

**An inherited shared-theme state problem remains at the newly changed callers**, not a failure caused by using `TextButton`. These sign-out buttons inherit `primary` text on `ground`: 4.84:1 at rest. `TextButton.styleFrom(foregroundColor: primary)` derives an 8% primary hover overlay and a 10% focus/pressed overlay. Compositing those over the ground lowers text contrast to approximately **4.36:1 hovered / 4.24:1 focused**, below 4.5 at normal text size. This also affects the existing client Profil sign-out ([profile_tab.dart:94](apps/client/lib/home/profile_tab.dart:94)).

Keep the chosen quiet button type; use a measured foreground/state combination, such as the neutral foreground already used for “Danışanı aç”, and test resolved state composites. Current contrast tests measure the ground only at rest ([core_test.dart:107](packages/core/test/core_test.dart:107)). The SDK overlay derivation is in [text_button.dart:225](/home/can/development/flutter/packages/flutter/lib/src/material/text_button.dart:225). Hover/focus text is included by [WCAG 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).

### 5. P3 — The destructive dialogs still fall back to a non-Figtree title

[app_typography.dart:43](packages/core/lib/src/theme/tokens/app_typography.dart:43), [intake_form_screen.dart:86](apps/dietitian_panel/lib/screens/intake_form_screen.dart:86), [panel_shell.dart:206](apps/dietitian_panel/lib/panel_shell.dart:206).

**Pre-existing omission in the dialogs touched by slice 3.** The supplied `TextTheme` does not fill `headlineSmall`, and the theme sets no overall Figtree family or dialog-title override. Material 3 `AlertDialog` uses `headlineSmall` ([dialog.dart:1988](/home/can/development/flutter/packages/flutter/lib/src/material/dialog.dart:1988)); `ThemeData` fills the missing slot from its platform default. Opening “Demoyu sıfırla”, cancelling an appointment, or leaving a dirty intake form therefore violates the Figtree-only decision despite the correctly red confirm button.

Fill the consumed slot or theme dialog titles explicitly. Include dialogs in the sweep and assert the resolved title family; the existing font test checks only selected text-theme slots.

### 6. P3 — The new colour guard misses the rich text it is meant to protect

[demo_widget_test.dart:50](apps/dietitian_panel/test/demo_widget_test.dart:50), [overview_screen.dart:401](apps/dietitian_panel/lib/screens/overview_screen.dart:401).

**New test gap.** The “no violet” assertion reads only `RichText.text.style?.color`. The new counts line assigns colours on child `TextSpan`s. Changing its number back to violet would pass the guard, as would introducing a violet background without a violet root text style or icon. Inspect descendant spans and relevant fills, or assert the effective colours of the specific counts/status components. Preserve the existing useful checks for amber reason text and grey icons.

## Counts-line accessibility and tap targets

The use of `Text.rich` is **not itself an accessibility bug**. These spans have no recognizers; each is inside one enabled `TextButton` ([overview_screen.dart:394](apps/dietitian_panel/lib/screens/overview_screen.dart:394)). Flutter supplies button semantics, tap activation and keyboard focus. Expected semantic names are “5 danışan”, “3 onay bekliyor”, and “4 randevu”, each with a button role—not separate controls for each number and word. Actual spoken role wording depends on the OS and screen-reader language; this is source-derived, not a recorded announcement.

The phone theme retains padded material tap targets and standard visual density ([app_theme.dart:55](packages/core/lib/src/theme/app_theme.dart:55)). Consequently `minimumSize.width = 0` and zero padding in the counts line do **not** remove Flutter's 48 × 48 minimum hit area. The client “Yaz” button explicitly preserves padded targets too ([today_tab.dart:306](apps/client/lib/home/today_tab.dart:306)); its existing 48 dp height assertion passes. I found no newly introduced sub-48 phone target in these changes. This is not a blanket certification of all pre-existing controls.

**I'd do differently:** give the middle count an explicit name containing “plan”, exclude decorative separator dots from semantics, and move focus to a meaningful draft destination after activation. Currently `_showDrafts` only scrolls: even when its target exists, it requests no keyboard or accessibility focus and announces no result. Test the three accessible names, keyboard activation, destination visibility/focus, and updated counts after approval. Do not add another tap recognizer to the spans or duplicate the button role.

## Contrast and colour meaning

Recomputed from the actual token RGB values using relative luminance, with alpha compositing for interaction states. The introduced/reassigned resting pairs all pass 4.5:1; the state exception is finding 4. Sources: [app_theme.dart:18](packages/core/lib/src/theme/app_theme.dart:18), [app_theme.dart:111](packages/core/lib/src/theme/app_theme.dart:111), [app_theme.dart:141](packages/core/lib/src/theme/app_theme.dart:141), [tone_pill.dart:21](apps/dietitian_panel/lib/widgets/tone_pill.dart:21), and the overview call sites above.

| Foreground / background | Use | Ratio |
|---|---|---:|
| `primaryHover / primaryTint` | Secondary pills, both apps | 6.53 |
| Same, 8% / 10% foreground overlay | Hover / focus and press | 5.81 / 5.64 |
| `textMuted / surfaceSubtle` | Disabled secondary pill | 4.76 |
| `textPrimary / surfaceSubtle` | Approved pill and black tick | 14.16 |
| `textSecondary / surfaceSubtle` | Neutral pills | 6.90 |
| `aiDraft / aiDraftTint` | Draft status | 7.01 |
| `warning / warningTint` | Late waiting status | 5.19 |
| `warning / surface` | Triage reason | 5.92 |
| `textPrimary / surface` | Selected rail label/icon | 16.54 |
| `textMuted / surface` | Rail, triage and draft icons | 5.56 |
| `textSecondary / surface` | Quiet row action | 8.06 |
| Same, 8% / 10% foreground overlay | Quiet row hover / focus | 7.14 / 6.92 |
| `textPrimary / ground` | Count numbers | 14.98 |
| `textSecondary / ground` | Count labels | 7.30 |
| `textMuted / ground` | Date and count separators | 5.04 |
| `white / error` | Destructive confirmation | 7.56 |
| Same, 8% / 10% white overlay | Hover / focus and press | 6.56 / 6.30 |
| `primary / ground` | Sign-out text | 4.84 resting; **4.36 / 4.24** hover/focus |

Counts inherit the green TextButton state overlay, but their explicitly dark spans remain above AA (the secondary label remains approximately 6.40:1 with the 10% overlay). Disabled controls are exempt, although this disabled text still passes. Pale fills and white-card separation are not text, so their low contrast alone is not a failed text pair; labelled buttons need not acquire a border solely for that reason. See [WCAG non-text contrast, component identification](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html).

No new colour is used outside its token meaning: approved/active states are neutral with a tick, drafts violet, late waits amber, and destructive confirms red. The overview now keeps green plus amber; the draft wording remains when its icon becomes grey. The deliberately dashed AI **container** is still permitted; it should not be stripped to enforce borderless **status pills**. Green progress in Takip is also permitted by [design rule 15:203](docs/design-system.md:203).

## Tests and the remaining slices

Existing tests genuinely cover theme shapes, secondary/disabled colours, destructive fill, rail colour, both phone sizes at 1.0/1.3/2.0, and both plan editors through their last meal. Keep those. They do not establish whole-screen visual or accessibility correctness: some tab tests only open the tab ([phone_layout_test.dart:150](apps/dietitian_panel/test/phone_layout_test.dart:150)); there are no new counts semantics/focus assertions; wide enlarged text is not covered. The font-loading screenshot suite is explicitly a capture tool, not a regression suite ([screenshots_test.dart:12](apps/dietitian_panel/test/screenshots_test.dart:12)). Load bundled fonts in a small set of layout checks and exercise the relevant off-screen content rather than relying only on default test-font metrics.

Recommended order, without broadening the product:

- **Repair 4b and its phone draft rows first.** Include the targeted shortcut and semantics checks. Shared state contrast and dialog typography can be a small accompanying core fix, validated in both apps.
- **Slice 5:** keep the planned filter work and Claude's already identified selected-chip fix; add finding 3's wide row growth to this slice, including the real table. Preserve active filters and make clearing them reachable. Search visibility remains Can's C28 decision. Do not add real-panel search ahead of [PLANNING #119](PLANNING.md:393).
- **Slice 6:** the red confirmation is already done. C29 still decides which row action retains green; preserve the cancellation and reminder behavior while changing their presentation ([appointments_screen.dart:169](apps/dietitian_panel/lib/screens/appointments_screen.dart:169)).
- **Slice 7:** retain the existing phone list → thread route and independently scrolling wide list ([messages_screen.dart:85](apps/dietitian_panel/lib/screens/messages_screen.dart:85), [messages_screen.dart:118](apps/dietitian_panel/lib/screens/messages_screen.dart:118)). C27 remains open; Claude already lists the bubble, timestamp and unread-state work. Check a sent message and keyboard-visible composer, not just an empty thread.
- **Slice 9:** keep the proposed detail/Takip/intake/editor sweep, but explicitly include settings, dialogs, real-panel detail/profile and shared auth states. Review validation errors and edited/approved states as well as seed data. Keep cosmetic work separate from C21's undecided phone editing scope ([QUESTIONS.md:186](QUESTIONS.md:186)); do not fold in the compact Takip redesign deferred until after interviews ([PLANNING.md:392](PLANNING.md:392)).
- **Slice 8 is independent.** Claude's Android/iOS/web naming checklist is still applicable; do it whenever convenient. Do not postpone functional/accessibility fixes until after app naming. No new platform-name finding is added here.

## Differences from Claude's review

Read after forming the findings above: [2026-09-24-panel-sade-review.md](docs/research/2026-09-24-panel-sade-review.md).

- Its slice-3 requests about the auth sign-out widget, pill/rail tests, approved colour, button shape and red confirmations are already implemented at this HEAD. I do not repeat them as outstanding findings. My sign-out addition concerns computed interaction-state contrast.
- Its “nothing else [in the real panel] breaks Sade” assessment is too broad: fixed-height wide rows and the shared dialog font fallback remain (findings 3 and 5).
- I would not automatically remove green/amber progress from Takip: the token meanings allow progress and status. Count simultaneous hues on client detail, but do not infer that an individual progress token is wrong merely because it is coloured.
- “Order is right” now needs qualification: fix the new count shortcut and lower draft rows before continuing cosmetic slices. The added sweep is useful, but core accessibility fixes should not wait for it.
- The prior contrast report is correct about the resting pill pairs. This review adds hover/focus composites and does not repeat its selected-chip or chat-timestamp findings. The borderless pills and grey approved status are accepted decisions, not new questions.
