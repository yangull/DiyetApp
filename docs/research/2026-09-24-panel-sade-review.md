# Panel in "Sade": review of slices 1–3 and the plan for 4–8

Second opinion, 24 Sep 2026. Scope: `git show c6b4af8` (slice 1), `git show 9f4a9dc`
(slice 2), the uncommitted slice 3 (`git diff` plus the new
`apps/dietitian_panel/lib/widgets/tone_pill.dart`), and the demo and real panel screens
under `lib/screens/`, `lib/widgets/` and `lib/panel/`. The emulator was not used.

`dart run melos run analyze`: no issues in all three packages. `dart run melos run test`:
core 8, client 14, dietitian_panel 110 (1 skipped, the screenshot captures), all pass.

## Verdict

Slices 1 and 2 are correct and small; nothing to undo. Slice 3 works and is the right
kind of change. Before it is committed, fix the one missed call site, update the docs it
contradicts, and have Can decide whether the green "Onaylı" status pill can look exactly
like a green action button. The 8-slice plan is in the right order, but it leaves out
half of what HANDOFF "Next steps" item 1 asked for (client detail, Takip, the plan
editors' colours, the intake form). It also misses a contrast bug on the Danışanlar filter
chips and some colour problems on Mesajlar that affect Can's bubble decision.

## Must fix before committing slice 3

1. **Docs now contradict the code.** `docs/design-system.md` says the code wins and the
   file gets fixed, and CLAUDE.md says to update PLANNING in place.
   - `docs/design-system.md:63`: `surfaceSubtle` is "secondary buttons"; it is now only
     the disabled pill and the neutral status pill. Same stale comment at
     `packages/core/lib/src/theme/tokens/app_colors.dart:21`.
   - `docs/design-system.md:74`: `primaryTint` is "the one place the accent is a
     background". Slice 3 also uses it behind the approved status pill
     (`tone_pill.dart:19`). PLANNING #55 (`PLANNING.md:280`) says the same.
   - The colour table has no `aiDraftTint` row (`#EEEBF6`, aiDraft on it 7.01:1).
   - `docs/design-system.md:88` and PLANNING #57 (`PLANNING.md:286`) define an AI draft
     as "violet + 1.5 px dashed border + label, together". The draft pill is now violet
     on a tint with no border (Can's call today). Reword it: the dashed border marks a
     draft container (`AiDraftBanner`), and a pill is violet text on `aiDraftTint` plus
     the label. The old pill had a solid border, so it never matched #57 literally either.
   - `packages/core/test/core_test.dart:83`: the test is still named "the one tinted
     fill".
   - Add a line on buttons: `OutlinedButton` *is* the pale-green secondary pill. Neutral
     secondary actions use `TextButton`, or the grey `FilledButton` of
     `apps/client/lib/home/today_tab.dart` "Reddet".

2. **Missed call site: sign-out became a green pill in both apps.**
   `packages/core/lib/src/auth/auth_gate.dart:104-107` ("Çıkış yap" on the role-mismatch
   screen) is an `OutlinedButton`, so it now renders as the green action pill in the
   client app and in the panel. Slice 3 moved the same action to a quiet
   `TextButton.icon` in `apps/dietitian_panel/lib/panel/real_profile_screen.dart:69-77`
   for exactly this reason. Do the same here. The other `OutlinedButton`s are fine as
   green pills: "Tekrar dene" (`auth_gate.dart:142`, `real_overview_screen.dart:457`,
   `real_client_detail_screen.dart:155`), "PDF olarak ver", "Değişim listesiyle dene" and
   "Görüşmeye başla" are all real secondary actions, and none is destructive.

3. **Decision for Can: the approved status pill looks like the action pill.**
   `PillTone.approved` (`tone_pill.dart:19`) is `primaryTint` fill + `primaryHover` ink +
   stadium shape. That is exactly the themed `OutlinedButton`
   (`app_theme.dart:132-143`), only smaller: about 24 px tall against 48 on phones, and
   22 against 36 on wide screens. Sade's own rule is that green marks what you can press.
   On client detail, "Diyet planı [Onaylı]" sits a few pixels above the "Planı aç" and
   "Değişim listesiyle dene" buttons (`client_detail_screen.dart:161`, `:176-197`). On
   Danışanlar, every approved row carries one. Options:
   - (a) Approved becomes neutral grey with a black check icon. That matches Sade's black
     ticks (the design doc's Bugün description), and violet drafts stand out on the
     client list.
   - (b) Green text with a check and no fill.
   - (c) Keep it as is.

   I recommend (a). Cheap now, since the change is one line in `tone_pill.dart`.

4. **Pin the theme decision in a test.** Slice 3 changes what every `OutlinedButton` in
   both apps looks like, and only an indirect client test (`widget_test.dart:261`)
   notices. Add a core test next to "one bundled family", checking three things:
   `outlinedButtonTheme` resolves no side, `primaryTint` fill and a `StadiumBorder`. Add
   the disabled pair `textMuted`/`surfaceSubtle` to the contrast test (4.76:1, passes).

## Correctness of slices 1–3

- **Slice 1 (plan editor overflow).** Sound. Meal headers wrap, "Besin ekle" moves under
  the rows, the PDF hint wraps, and the phone app bar drops the pill
  (`plan_editor_layout.dart:96-103`), with "Onaylı" shown at the top of the page instead
  (`:138-144`). The 12 new phone tests exercise this. No regressions found.
- **Slice 2 (shell).** Sound. The rail takes `backgroundColor`/`indicatorColor` from the
  theme (`app_theme.dart:104-116`), so the real panel (`real_panel_shell.dart:37`, same
  `AdaptiveNavScaffold`) gets it too. Nit: the `phoneTopActions` doc comment still says
  "a slim strip" (`adaptive_nav_scaffold.dart:43-44`).
- **Slice 3, theming `OutlinedButton` as a filled pill.** Sound, and better than a new
  widget: one style for every secondary action in both apps, and no Flutter widget the
  panel uses builds an `OutlinedButton` internally (dialogs, pickers and snack bars use
  `TextButton`). The cost is the name: anyone who reaches for an "outlined" neutral or
  destructive button gets a green pill (finding 2). The doc line in finding 1 covers it.
  A thin `TintButton` wrapper would only add value if a real outlined button is ever
  needed. `_TintButton` in `today_tab.dart:327-341` now only sets the 40 px height and
  looks the same as before; I checked that fill, ink, padding, shape and text style
  match the old `FilledButton` version.
- **Rule 7 (one radius scale).** Strictly, yes, it breaks it. A stadium at 48 px is a
  24 px radius next to 14 px controls and 20 px cards on phones; at 36 px it is 18 next
  to 8 and 10 on wide screens. You can see it where the two shapes touch:
  `client_detail_screen.dart:176-197` puts a rounded-rect `FilledButton` and a stadium
  pill side by side, and on Genel Bakış the triage pills sit above the rect "İncele"
  buttons in the same column. The client app already does this: Bugün's pills are on
  the same screen as the rect "Kabul et / Reddet" of the invite card. **Decision for
  Can:**
  - either amend rule 7 to name "full pill" as a second shape class, for secondary
    actions and status pills only,
  - or make `FilledButton` a stadium too, which gives one shape for all buttons (my
    preference: it is one line in `app_theme.dart:126`).
- **Pill fill against the ground is invisible.** `primaryTint` is 1.16:1 on white and
  1.05:1 on the ground; the disabled `surfaceSubtle` is 1.06:1 on the ground. In a white
  card the pill reads as a pill. On the ground it reads as green text: "PDF olarak ver"
  in the plan editor panel (`plan_editor_layout.dart:71` places it outside a card), the
  error-state "Tekrar dene", and the auth gate. Disabled "PDF olarak ver" on a draft
  reads as a grey label. It is accessible (the text carries it, and disabled controls
  are exempt), but it is not the Bugün look. Consider putting the export row in the
  energy card.
- **Keyboard focus (consider later).** No pill has a border in any state, so web focus
  is only Material's 10 % overlay on the tint. Consider a 2 px `primary` side on
  `WidgetState.focused`. The panel is a desktop tool.

## Contrast (recomputed, WCAG relative luminance)

| Pair | Ratio | Needed | Tested in `core_test.dart` |
|---|---|---|---|
| aiDraft `#514196` on aiDraftTint `#EEEBF6` | 7.01 | 4.5 | yes (new, `:80`) |
| textMuted on surfaceSubtle (disabled pill) | 4.76 | exempt (disabled) | no; add it |
| textSecondary on surfaceSubtle (neutral pill) | 6.90 | 4.5 | yes (loop `:61-69`) |
| primaryHover on primaryTint (action and approved pill) | 6.53 | 4.5 | yes |
| warning on warningTint (late waiting pill) | 5.19 | 4.5 | yes |
| white on warning (triage count badge) | 5.92 | 4.5 | no (badge likely goes in slice 4) |
| **textPrimary on primary: selected FilterChip** | **3.09** | 4.5 | no; **fails** (below) |
| textMuted timestamp on dietitian bubble over ground (phone) | 4.43 | 4.5 | no; **fails** (below) |
| primaryTint / surfaceSubtle fill on ground | 1.05 / 1.06 | none (decorative) | — |

All new slice 3 pairs pass. The two failures are older, and the audit did not list them.

## What the audit missed

Ranked, most important first.

1. **Selected filter chip fails contrast (Danışanlar, wide and phone).** The theme sets
   no `secondaryContainer`, so Flutter's `ColorScheme` falls back to `secondary`, which
   is `primary`. It uses that for a selected `FilterChip`'s fill, while the theme's
   `chipTheme.labelStyle` pins the label to `textPrimary` (`app_theme.dart:155-158`). A
   selected "Onay bekleyen" chip is therefore near-black on green, 3.09:1, with a grey
   border. I confirmed it by rendering a `FilterChip` with a copy of the theme in a
   scratch package: label `#16211D`, fill `#18795C`, side `#7E8C86`. Fix it in slice 5
   (e.g. selected = `primaryTint` fill, `primaryHover` label, no side) and add a test.
2. **Destructive confirmations are brand green.** "İptal et" when cancelling an
   appointment (`appointments_screen.dart:238-241`), "Sil ve çık" when leaving the
   intake form (`intake_form_screen.dart:96-99`) and "Sıfırla" when resetting the demo
   (`panel_shell.dart:217-219`) are all green `FilledButton`s. The design doc says
   `error` means destructive and green means "you can press this / approved". Decision
   for Can: red confirm buttons, or neutral ones. Either way it is not in any slice.
3. **Mesajlar: Can's bubble decision does not work on wide screens as built.**
   - On wide screens the thread sits inside a white `Card`
     (`messages_screen.dart:142-147`), so white client bubbles would vanish (1.00:1).
     To honour "client white, dietitian pale green", the wide thread has to sit on the
     ground, or the client bubbles need a border. Decide in slice 7.
   - The bubble radius is a hard-coded 12 (`messages_screen.dart:471`), on neither
     density scale (rule 7). Use the density's card or control radius.
   - The dietitian bubble is `primary` at 10 % alpha (`:469`), an unmeasured colour. Its
     timestamp is 4.43:1 on the phone. Opaque `primaryTint` gives 4.78.
   - Mesajlar has no title on wide screens either, not only on phones. Every other tab
     has a `headlineLarge`.
4. **Screens missing from the plan.** HANDOFF "Next steps" item 1 lists client detail,
   the plan editors, Takip and "count the colours" on every screen. The 8 slices touch
   only the plan editors' overflow. Examples:
   - Client detail with a draft plan and an off-track weight shows green, violet and
     amber together (`client_detail_screen.dart:161`, `:468-472`).
   - Takip colours deltas green and amber (`reports_screen.dart:86-90`).
   - The AI banner fill is violet at 4 % alpha (`ai_draft_banner.dart:111`), unmeasured.
     It could be `aiDraftTint`.

   Add a sweep slice for these.
5. **Genel Bakış, beyond the audit's list.**
   - Slice 3 already turned the triage task buttons into pills, so the "pill task
     buttons" part of slice 4 is done.
   - What is left in `overview_screen.dart`:
     - the solid amber count badge (`:377-401`);
     - the violet plan icons (`:334`), where the row has no "Yapay zekâ" label, only
       "taslak hazır";
     - the violet stat number (`:432-435`: violet used for a count, not for AI content);
     - two green actions per triage row: the pill and "Danışanı aç" (`:212-216`).
   - With Can's grey triage icons and amber reason text, the screen would still be
     green + amber + violet unless the plan icon turns grey too.
6. **Slice 8 scope is bigger than `android:label`.** Also:
   - `ios/Runner/Info.plist` `CFBundleDisplayName` ("Client", "Panel");
   - `web/index.html` `<title>` and `apple-mobile-web-app-title`;
   - `web/manifest.json` `name`, `short_name`, and `theme_color`/`background_color`
     `#0175C2` (Flutter blue, which shows in Android Chrome's UI).

   `MaterialApp.title` is already "Wellkit" / "Wellkit Panel". Launcher icons are
   presumably still Flutter's; that is a question for Can, not a code task.
7. **Minor.** On phones, the first list row draws its top divider against the card's top
   edge, because there is no header row above it (`clients_screen.dart:288-290`,
   `real_overview_screen.dart:340-342`). On a card with no clip, the line crosses the
   rounded corners. Use `showDivider: i > 0` as Randevular does.

Real panel (`lib/main.dart`, `lib/panel/`): slice 3 covered its pills and profile
sign-out. Nothing else there breaks Sade in code. The emulator check with an approved
account from HANDOFF is still open and in no slice.

## The plan (slices 4–8)

- **Order is right.** Shared pieces (3) before the screens, and 8 is independent (do it
  any time).
- **Slice 4 is the biggest; split it.**
  - 4a: colours only. Grey triage icons, amber reason text, drop the count badge and the
    violet tile number, and decide the draft-row icon.
  - 4b: date + greeting header and the slim tappable counts line replacing the tiles.
    This is a layout change the interview demo will be judged on. The tiles were moved
    below the work on purpose (`overview_screen.dart:112-114`), so let Can see 4a first.
  - Also settle "one green action per row" here, not only in Randevular.
- **Slice 5.**
  - Include the chip contrast fix (miss 1).
  - Decide whether search stays visible on phones. I'd keep search full width and put
    only goal + plan status behind "Filtrele", with the active count on the button.
    PLANNING #119 deferred real search and filter (#9) until the real client list
    grows, so this is demo polish.
- **Slice 6.** "One green action per row" needs a choice for online appointments:
  "Görüşmeye başla" (pill) or "Hatırlatma gönder" (green text). Can should pick.
  Fold in the destructive-confirm colour (miss 2) if Can decides it.
- **Slice 7.** Needs the wide-thread background decision (miss 3), a radius token, and an
  unread label (e.g. bold name + "Yeni", not just a green dot).
- **Add slice 9:** a sweep of client detail, Takip, the intake form, settings and the plan
  editors against rule 15, plus the alpha-derived fills.

## Decisions to put to Can

1. Approved pill: neutral + black tick, green text, or unchanged (must-fix 3).
2. Button shapes: amend rule 7 for pills, or make every button a stadium.
3. Destructive confirms: red, neutral or green.
4. Wide Mesajlar: thread on the ground (white bubbles work) or in a card (they don't).
5. Danışanlar on phones: search visible plus "Filtrele", or everything in the sheet.
6. Randevular: which action keeps the green.
7. Genel Bakış draft rows: keep the violet icon (then add the "Yapay zekâ taslağı" label)
   or grey.

Record them in QUESTIONS.md, per repo rules.

## Tests

- Slice 1: good. It overflow-tests both editors at 360/412 dp and scales 1.0/1.3/2.0,
  down to the footer.
- Slice 2: nothing pins the rail (white, no indicator). A two-line core theme assertion
  would do.
- Slice 3: the contrast pair was added. Missing: the `OutlinedButton` theme assertion and
  the disabled pair (must-fix 4); the `auth_gate` fix needs no new test.
- Slice 5 must add a selected-chip contrast test. It would have caught miss 1.
- Regenerate `test/screenshots_test.dart` captures at wrap-up so the tour artifact
  (HANDOFF item 4) can be refreshed.
- `.claude/settings.local.json` is untracked. Keep it out of the slice 3 commit.
