# Wellkit design system

How Wellkit looks: Bevel's DESIGN.md (`docs/design/2026-10-01-bevel/DESIGN.md`) adapted
for an app with Apple's HIG numbers and the Alpino font (PLANNING #134–#135). Written
1 Oct 2026 and coded the same day in `packages/core/lib/src/theme/`; if this file and the
code disagree, the code is right and this file gets fixed. The Sade / direction B system
it replaced is in git history (before 1 Oct 2026). The private Design System artifact
(https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV) mirrors it.

Decided on 1 Oct 2026: the accent is **green #18795C** (C36), the top of Bugün is
**flat**, with no sky gradient (C40), and the redesign went from this file straight to
Flutter, with no copy study and no canvas. Dark mode followed the same day (was C43):
"Sistem / Açık / Koyu", measured below.

## Direction

Bevel's character, adapted for an app: a **white canvas**, **pale borderless Cloud
Card surfaces** at radius 24, near-black **600-weight headings** with slightly tight
tracking, **grey supporting text**, **black pill buttons**, and colour only where it
means something. Green marks progress, "approved" and data. Red and amber are statuses.
Violet means an unapproved AI draft. Everything else is black, white, Cloud Card and
grey.

Bevel's DESIGN.md describes a marketing website. What the app takes from it and what it
does not:

| From Bevel | In Wellkit |
|---|---|
| Paper White canvas, Cloud Card surfaces, Ink headings | Kept as tokens |
| Body Gray `#747679` copy | Darkened to `#606266`: Bevel's grey fails AA on its own Cloud Card and under a hover |
| Charcoal download pill with a Cloud Card label | The one filled button, label and all |
| SF Pro, 600 headings, −0.03 em tracking at 40–80 px | Alpino, 600 headings, tracking scaled down to HIG sizes |
| Type sizes 12–80 px | HIG's sizes (touch) and HIG macOS sizes (compact panel) |
| Floating capsule navigation (radius 32, blur, no shadow) | The bottom bar: a solid floating white capsule, no blur, so it takes a shadow instead (#135) |
| 80 px section gaps, 32 px card padding | Scaled to app sizes (below) |
| Recovery Green, Sleep Lilac, Coral Signal | Not used: 1.8–2.1:1 on white, too pale for text or data |
| Metric Blue #415eee | Was the other accent candidate; not used (C36) |
| Signal Gold | Star ratings only, always next to the number |
| Hero Sky gradient | Not used (C40) |
| Device renders, laurels, partner logos, QR card | Website-only; nothing in the app |
| Backdrop blur on the nav | Not used (#135, was C41) |

What Bevel has no pattern for (inputs, lists, tab bar, dialogs, sheets, chips, progress,
empty states) follows HIG, drawn in Bevel's tone.

## Colour

Light and dark, one token set (`AppPalette.light` / `.dark`); widgets read every colour
through `context.palette`, never from `AppColors`. Every value is measured (WCAG 2 contrast). The bar for **all text is 4.5:1**:
HIG would accept 3:1 for 18 pt+ or bold text, but WCAG only allows that from 24 px
regular or 18.66 px bold, so the stricter rule wins and we don't rely on the exception.
Graphics that carry meaning and input boundaries need 3:1 (WCAG 1.4.11).

### Tokens

| Token | Hex | On white | On Cloud Card | Means |
|---|---|---|---|---|
| `canvas` | `#FFFFFF` | — | — | Page background, app bar, bottom bar, sheets, dialogs, inputs |
| `cloudCard` | `#EBF0F8` | 1.14 | — | Cards and inset surfaces; no border, no shadow |
| `ink` | `#222326` | 15.71 | 13.73 | Headings, body text, icons, text actions |
| `charcoal` | `#1F2025` | 16.26 | 14.21 | Filled button, selected chip; Cloud Card label on it 14.21 |
| `charcoalHover` | `#35363C` | 12.04 | — | Pressed/hovered filled button |
| `textSecondary` | `#606266` | 6.11 | 5.34 | All supporting text, on any surface (#135's darker grey) |
| `borderStrong` | `#83868B` | 3.65 | 3.19 | Input and checkbox boundaries |
| `divider` | `#E3E7EE` | 1.24 | — | Dividers inside a list; never carries state |
| `accent` | `#18795C` | 5.35 | 4.67 | Progress fills, "approved", the one data colour; white on it 5.35 |
| `accentStrong` | `#135F49` | 7.61 | 6.65 | Accent text on `accentTint` |
| `accentTint` | `#E4F2EC` | 1.15 | — | Fill of the "Onaylı" pill; accentStrong on it 6.60 |
| `warning` | `#8F5F00` | 5.52 | 4.82 | Waiting, needs attention |
| `warningTint` | `#FFF2D6` | — | — | Fill behind warning text: warning on it 4.97 |
| `error` | `#B43622` | 6.01 | 5.26 | Failed, rejected, destructive; white on it 6.01 |
| `errorTint` | `#FDECEB` | — | — | Fill behind error text: error on it 5.26 |
| `aiDraft` | `#514196` | 8.25 | 7.21 | **Only** AI-written content no dietitian has approved |
| `aiDraftTint` | `#EEEBF6` | — | — | Fill of a draft status pill: aiDraft on it 7.01 |
| `gold` | `#FFCA00` | 1.53 ✗ | — | Star shapes only, always beside the number |
| `onFilled` | `#FFFFFF` | — | — | Text on accent and error fills |
| `track` | `#C7CBD2` (dark `#383B40`) | — | — | The empty part of a progress bar, the same on the canvas and inside a card; accent on it 3.28 (dark 5.08) |
| `inset` | Cloud Card / white | — | — | The pale fill of something set into its surface (neutral pill, avatar, selected row): Cloud Card on the canvas, white inside a card |

On a pressed Cloud Card (`#DBE0E7`): ink 11.84, textSecondary 4.61, error 4.53, aiDraft 6.22, accent 4.03, borderStrong 2.75. Accent passes there as a graphic (3:1) only, and `borderStrong` drops below 3:1, so inputs never sit inside a pressable area.

Ink on every tint stays above 13:1 (accentTint 13.63, warningTint 14.16, aiDraftTint
13.36).

### Dark (Can, 1 Oct 2026, was C43)

Near-black, cards one step lighter, a near-white filled pill, lightened accent and
status colours, and Bevel's Sleep Lilac for AI drafts. The user picks **Sistem / Açık /
Koyu** in Profil (client app, real panel) or Ayarlar (panel demo); the default follows
the phone and the choice is saved on the device (`themeModeProvider` in core). The
overlay is Ink at 4 % / 8 % here too, which lightens. Ratios on canvas / card / pressed
card (`#2F3035`):

| Token | Hex | Ratios | Note |
|---|---|---|---|
| `canvas` | `#121316` | — | |
| `cloudCard` | `#1E2025` | 1.14 on canvas | Also the floating bottom bar, where a shadow can't show |
| `ink` | `#EDEEF0` | 16.00 / 14.04 / 11.34 | |
| `charcoal` (filled pill) | `#EDEEF0` | label `onCharcoal` `#121316` 16.00, pressed `#D5D7DB` 12.89 | |
| `textSecondary` | `#9A9DA3` | 6.83 / 6.00 / 4.84 | |
| `borderStrong` | `#696C73` | 3.53 / 3.10 | Lowered from `#74777E` (4.14 / 3.63): the old outline read as heavy on a dark input |
| `divider` | `#2C2F35` | 1.38 / 1.21 | |
| `accent` | `#4CC38A` | 8.39 / 7.36 / 5.94 | `onFilled` `#121316` on it 8.39 |
| `accentStrong` on `accentTint` | `#7FD9AE` on `#173327` | 8.08 | "Onaylı" |
| `warning` / tint | `#E6B04A` / `#3A2E12` | 9.44 / 8.28 / 6.69; on tint 6.76 | |
| `error` / tint | `#FF8A7A` / `#3D1E1B` | 8.11 / 7.12 / 5.75; on tint 6.55; `onFilled` on it 8.11 | |
| `aiDraft` / tint | `#B9A6FF` / `#2A2445` | 8.81 / 7.73 / 6.25; on tint 6.93 | Bevel's Sleep Lilac |

**Overlays.** Hover, focus and press darken whatever they sit on, and text must keep
4.5:1 in every state. So the theme caps every overlay at Ink **4 % for hover and 8 % for
focus and press** (Material's defaults go to 10–12 %), and the ratios below were checked
on the darkest case, Cloud Card under 8 % Ink (`#DBE0E7`). A status pill's tint sits
above the overlay, so its text is unaffected.

**Why each new value:**
- `textSecondary` `#606266`: Bevel's Body Gray `#747679` is 4.56 on white but 3.98 on
  its own Cloud Card and 3.43 on Cloud Card under a hover. `#606266` keeps its hue (the
  same small blue lean) and is the lightest grey that holds 4.5 on a pressed Cloud Card
  (4.61). One grey everywhere, so no widget has to know which surface it sits on. It is
  visibly darker than Bevel's; that is the price of AA on Bevel's own cards (Can, 1 Oct
  2026).
- `error` `#B43622`: a red pulled towards Bevel's coral (hue about 9°, Coral Signal is
  13°) and dark enough for white text on a destructive button. Sade's `#A32017` read
  brown-red next to the cool greys.
- `warning` `#8F5F00`: an amber pulled towards Signal Gold's hue, with a step of margin
  above 4.5 on Cloud Card (4.82; Sade's `#8A5A0B` was browner). Amber and green text sit
  on their tints or on white, never as plain text on a pressable Cloud Card (4.16 and
  4.03 there under the press overlay).
- `aiDraft`: Sade's `#514196` was re-measured against Bevel's palette. It sits at hue
  251°, next to Sleep Lilac's 253°, so it belongs to the palette rather than clashing
  with it, and it is 7.21:1 on Cloud Card. It stays.
- `accent` (C36): green `#18795C` won over Metric Blue `#415eee` (5.17 on white, 4.52 on
  Cloud Card, 4.04 on the sky). Both were barely AA on Cloud Card; green is 4.67.
- `borderStrong` `#83868B`: 3.65 on white and 3.19 on Cloud Card, so an input keeps a
  visible boundary on either.

### Colour rules

- **Black does the acting.** Filled buttons are Charcoal pills with a Cloud Card label
  (Bevel's own pairing), text actions are Ink.
  Green is no longer an action colour: it marks what fills (progress, the meals ring,
  the week count, the weight line) and "approved".
- **One accent, one data colour.** Charts and rings use green on the `track` grey. A second data series is Ink or grey, told apart by a label, never a second hue.
- **Status colours have one meaning each.** Amber is waiting or needs attention, red is
  failure or destructive, violet is an unapproved AI draft and nothing else (#57).
- **Colour never carries meaning alone** (rule 10): every status has a word or an icon.
- **"Onaylı" is a green pill** (Can, 1 Oct 2026, reversing the 24 Sep grey pill, #55).
  Under Sade a green pill would have looked like a button; buttons are black now, so the
  approved status is `accentStrong` text and a tick on `accentTint`, matching "green
  means approved". Neutral pills are Cloud Card on white and white on Cloud Card.
- No `ColorScheme.fromSeed` (#65); every slot is set by hand.
- Exception kept: the video-call mockup's near-black stage `#15181A`.

## Type

**Alpino only**, from the single variable file `Alpino-Variable.ttf` (wght 100–900),
bundled unmodified with its `FFL.txt` (no subsetting or conversion, as the licence
requires). One exception, the lira sign: Alpino has no ₺ (U+20BA), so every text style
falls back per glyph to `Lira`, a one-glyph subset of Plus Jakarta Sans (OFL, chosen
by Can on 2 Oct 2026) whose vertical metrics were set to Alpino's so a price does not
grow its line (`fonts_and_icons_test.dart`). Checked on 1 Oct 2026:
- **Flutter maps `FontWeight` onto the wght axis** of the variable file: in a test,
  `FontWeight.w600` measured exactly like `FontVariation.weight(600)` (and the same for
  400, 500, 700, 900). So one file gives 400, 500 and 600 with no `fontVariations` code.
  The emulator and web checks happen in the theme slice.
- Alpino's own "Regular" instance is wght 422; we use 400, a hair lighter.
- **Gate for the theme slice:** the file's default instance is Black (900). The mapping
  above was measured in `flutter test`; if CanvasKit (web) or a device build ignores it,
  every weight renders Black. The theme slice checks web and the emulator first; if
  either fails, every style sets `fontVariations: [FontVariation.weight(n)]` as well.
- Turkish glyphs reach 0.88 em above the baseline (İ Ğ Ş Ç Ö Ü at 700) and 0.26 em
  below (ş ç g); the font's own line is 1.3 em (ascent 1.0, descent 0.3). Every line
  height below is at least 1.18 em, and Flutter's default proportional leading then
  leaves 0.91 em above the baseline and 0.27 em below, so nothing clips. Keep it
  proportional: `TextLeadingDistribution.even` would clip descenders by about 0.02 em.
- **No tabular figures** (no `tnum`). Numbers that must line up (agenda times, columns
  of kcal or kg in the panel) sit in a fixed-width, right-aligned slot sized to the
  widest value, e.g. "00:00" (#135, was C39).

Weights: headings and numbers **600**, buttons and navigation **500**, body **400**.
Nothing above 600 (Bevel's own rule). Tracking tightens with size, as Bevel's −0.03 em
does at display sizes; body text keeps 0.

### Touch scale (client app; panel on phones and tablets)

HIG iOS at the default text size (Large/default Dynamic Type). Text grows with the
system setting to at least 200 % (#135). Nothing under 11.

| HIG style | Flutter slot | Size / line | Weight | Tracking | Used for |
|---|---|---|---|---|---|
| Large Title | `displaySmall` | 34 / 41 | 600 | −0.7 | The hero number, a screen's big title |
| Title 1 | `headlineLarge` | 28 / 34 | 600 | −0.5 | Greeting, a screen heading |
| Title 2 | `headlineMedium` | 22 / 28 | 600 | −0.3 | App bar titles |
| Title 3 | `headlineSmall` | 20 / 25 | 600 | −0.2 | Section headings, dialog titles |
| Headline | `titleLarge` | 17 / 22 | 600 | 0 | Card titles, a row's name |
| Callout (emphasised) | `titleMedium` | 16 / 21 | 600 | 0 | Smaller titles, form section names |
| Subhead (emphasised) | `titleSmall` | 15 / 20 | 600 | 0 | Field labels, list subheads |
| Body | `bodyLarge` | 17 / 22 | 400 | 0 | Reading text, input text |
| Subhead | `bodyMedium` | 15 / 20 | 400 | 0 | Default `Text`: row second lines, supporting copy; reading text uses `bodyLarge` explicitly |
| Footnote | `bodySmall` | 13 / 18 | 400 | 0 | Helper text, captions under rows |
| Callout | `labelLarge` | 16 / 21 | 500 | 0 | Buttons, chips |
| Caption 1 | `labelMedium` | 12 / 16 | 500 | 0 | Bottom bar and rail labels |
| Caption 1 (emphasised) | `labelSmall` | 12 / 16 | 600 | +0.2 | Status pills, `Badge` |

Slots Flutter reads that need setting by hand in the theme: the app bar title (Flutter
defaults it to `titleLarge`; set `titleTextStyle` to `headlineMedium` with an explicit
colour), the `ListTile` title (defaults to `bodyLarge`; set it to `titleLarge`) and
`displayLarge` / `displayMedium`, which the date and time pickers read (fill them with
Large Title so nothing falls back to Material's font). Dialog titles read
`headlineSmall`, the rail and bottom bar `labelMedium`, buttons `labelLarge`.

### Compact scale (panel in a computer browser)

HIG's macOS styles, raised for readability. On 2 Oct 2026 Can judged the 11 px text
too small and pixelated in a browser, so the floor is now **12** and the slots above it
moved up one step (13 / 14), keeping the order small < medium < large.

| HIG macOS style | Flutter slot | Size / line | Weight |
|---|---|---|---|
| Large Title | `displaySmall` | 26 / 32 | 600 |
| Title 1 | `headlineLarge` | 22 / 26 | 600 |
| Title 2 | `headlineMedium` | 17 / 22 | 600 |
| Title 3 | `headlineSmall` | 15 / 20 | 600 |
| Headline | `titleLarge` | 14 / 18 | 600 |
| Callout (emphasised) | `titleMedium` | 13 / 16 | 600 |
| Subheadline (emphasised) | `titleSmall` | 12 / 15 | 600 |
| Body | `bodyLarge` | 14 / 18 | 400 |
| Callout | `bodyMedium` | 13 / 16 | 400 |
| Subheadline / Footnote | `bodySmall` | 12 / 15 | 400 |
| Body (buttons) | `labelLarge` | 14 / 18 | 500 |
| Caption 1 | `labelMedium` | 12 / 15 | 500 |
| Caption 1 (emphasised) | `labelSmall` | 12 / 15 | 600 |

The shortest line here is 22 / 26 (1.18 em), still above Alpino's 1.14 em of ink.

## Density

**By input, not width** (#135, Can 1 Oct 2026, was C44): the panel is compact when it
runs in a browser on Windows, macOS or Linux, and uses the touch profile on iOS, Android
and tablet browsers. Navigation still switches between rail and bottom bar by width at
600 dp. The client app is always touch. In Flutter: compact when `kIsWeb` and
`defaultTargetPlatform` is Windows, macOS or Linux. Flutter's web engine already reports
an iPad's Safari (which claims to be a Mac) as iOS when the browser has touch points
(`browser_detection.dart`). Known edge: a Windows touch laptop or a Chromebook (reports
Linux) gets compact; accepted, since both have a pointer too. This replaces
`panelThemeBuilder`'s width test and `isPanelPhone` stays only for layout (rail vs
bottom bar at 600 dp).

| Metric | Touch | Compact (draft) | Source |
|---|---|---|---|
| Minimum hit target | 48 × 48 | 28 × 28 | Android 48 / HIG iOS 44; HIG macOS 28 (compact is a draft) |
| Button height | 48 | 32 | The Görünüm control is the exception: never under 40 (a 32 px segmented control looked tiny on a roomy Profil page) |
| Input height | 52 | 32 | |
| Row minimum height | 72 | 40 | rows grow with their text |
| Avatar | 40 | 28 | |
| Page padding | 20 | 24 | |
| Card padding | 20 | 16 | Bevel's 32 at its 24 px body, scaled to 17 |
| Gap between cards | 12 | 12 | |
| Gap between sections | 32 | 24 | Chosen, not scaled: 80 × 17/24 would be 57, too airy for a phone screen |
| Card radius | 24 | 16 | Bevel's 24 |
| Input radius | 12 | 8 | |
| Buttons, chips, pills, bottom bar | full pill | full pill | Bevel's 128 / 9999 |
| Sheets and dialogs | 24 | 16 | |

Around controls: about 12 pt from a filled control to its neighbour and about 24 pt
around an unfilled one (HIG). Spacing scale: 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48,
Bevel's 8-pt base with the half steps an app needs. `VisualDensity` stays pinned to
standard; `AppDensity` is the only density system.

**Elevation:** two levels. Cards have no shadow and no border; Cloud Card on white is
the separation. Only floating things get a shadow: the bottom bar, menus, sheets and
snackbars, all with `rgba(0,0,0,0.15) 0 2 16` (the shadow of Bevel's elevated QR card;
Bevel's own nav has blur instead, which #135 rules out).

## Components

- **Filled button:** Charcoal pill, Cloud Card label (Callout 500), `charcoalHover`
  when pressed. One per screen region: the main action.
- **Secondary button:** a pale pill with an Ink label: Cloud Card on white, white on a
  Cloud Card. No outline.
- **Text action:** Ink, 500, no fill (a row's action at its right end, "Tümünü gör").
  Neutral actions (sign out, cancel) use the same; there is no separate grey quiet
  button any more, because green is no longer the action colour.
- **Destructive confirm:** red pill, white label, only inside a confirmation dialog.
- **Disabled:** a pale pill with a `textSecondary` label (Cloud Card on white, white on
  a Cloud Card), so it looks like a secondary button gone grey; a disabled control says
  why next to it (rule 4).
- **Chips (filters):** off: Cloud Card pill, Ink label (white on a Cloud Card); on:
  Charcoal pill, Cloud Card label, a tick. They only appear in a row of chips, which is
  what tells them apart from secondary buttons.
- **Status pills:** tint fill, coloured text, a word, no border. Neutral is Cloud Card.
  "Onaylı" is `accentStrong` + tick on `accentTint`; a draft is violet on `aiDraftTint`.
- **Inputs:** white fill, 1 px `borderStrong`, radius 12 (8 compact); focused: 2 px Ink.
  Always core's `LabeledField`: the label above the field in `titleSmall` (never
  `InputDecoration.labelText`, which floats inside and cuts the outline), helper in
  `bodySmall` grey and the error in red, both on the field's edge, and an optional
  show/hide for passwords.
- **Cards:** Cloud Card, radius 24, padding 20, no border, no shadow. Always core's
  `CloudCard`, never a bare `Card`: it re-themes its contents so the secondary pill, a
  disabled button, an off chip and `inset` turn white instead of
  vanishing into the card.
- **Lists:** rows on the canvas or inside a Cloud Card, dividers in `divider` only when
  rows touch. A person row: avatar, name (`titleLarge`), second line (`bodyMedium` grey),
  one text action at the right end.
- **Section heading:** `headlineSmall` (Title 3, 600) in Ink, left-aligned, an optional
  count in grey and a text link at the right end. No small capitals (Bevel's section
  label is a 600 heading, not a caps label).
- **App bar:** white, no elevation, title `headlineMedium` left-aligned (iOS large-title
  feel without the collapsing behaviour).
- **Bottom bar:** a solid white floating capsule, 16 from the screen edges and above the
  safe area, the floating shadow, no blur, no press ripple (as on iOS). Selected item Ink
  600, others `textSecondary` 500, no indicator pill. Labels always shown.
- **Navigation rail (wide panel):** white, selected Ink 600 with the heavy-stroke
  icon, others `textSecondary`, no pill. From a 900 px window the rail is extended
  (220 px): the mark on top, labels beside the icons, utilities and the signed-in name
  pinned to the bottom. Below 900 it is the narrow rail with labels under the icons.
- **Progress:** a 8 px rounded bar or a ring, green fill on the `track` grey (the same on the canvas
  and inside a card). It animates only when its value changes (rule 12).
- **Dialogs and sheets:** white, radius 24, title `headlineSmall`, actions right-aligned:
  cancel as a text action, confirm as a filled (or red) pill.
- **Empty states:** a heading that says what will appear here, one line of grey text,
  one action if there is one. No illustration yet. Core's `EmptyState`.
- **Loading and errors:** core's `AppLoading` (the mark over a spinner for a whole
  screen; `.card` reserves a card's height so the page doesn't jump) and `AppErrorView`
  (Turkish words, never a raw exception; "Tekrar dene" is the main action, with a second
  way out such as "Çıkış yap"; `.card` and one-line `.notice` for part of a screen). A
  button that waits shows `ButtonSpinner`.
- **Mark:** `WellkitMark`, a placeholder "W" on a Charcoal tile drawn in code, on the
  auth screens, `AppLoading` and the top of the extended rail. Callers only pass a
  size, so the real logo replaces its body alone.
- **Interview notes (panel demo only):** a question for the dietitian in an interview
  sits behind `InterviewNote`, one quiet "Görüşme notu" line that opens the paragraph.
  Never plain grey copy under a card: it read as leftover text.
- **AI draft container:** the card keeps its surface and gets a 1.5 px dashed violet
  border and the "Yapay zekâ taslağı" label (#57).
- **Star rating:** gold stars, always followed by the number in Ink ("4,8").
- **Numbers:** Alpino 600, the hero number in `displaySmall`; aligned columns use
  fixed-width right-aligned slots sized by core's `numberSlotWidth` to the widest
  value ("00:00", "000,0 kg") and, in a table, to the column's header if wider.
- **Dates:** one short form in lists, tables and chart axes, `formatDate` ("28 Eyl",
  the year only when not the current one); a time is `formatTime` ("08:00"). Long forms
  ("Pazartesi, 28 Eylül": weekday first, with a comma) only in agenda headings and
  sentences.

## Rules

Status of each numbered rule from `docs/design-system.md` (PLANNING #134), and the rule
as it stands in the new system.

| # | Rule | Status |
|---|---|---|
| 1 | **No gradients.** Flat fills; depth comes from Cloud Card on white. | Survives (C40 decided flat, 1 Oct 2026) |
| 2 | **No emoji as icons;** one icon set: Lucide, through `AppIcons` in core (a role name per icon, a heavier stroke `...Active` for the selected nav entry). Never `Icons.*`; a test enforces it. | Done (2 Oct 2026) |
| 3 | **No "✨ AI" badges.** Say what happened: "Yapay zekâ taslağı · onay bekliyor". | Survives, as part of the AI-draft safeguard |
| 4 | **Only what exists is drawn;** something unbuilt is named once with "Yakında". | Survives |
| 5 | **No invented numbers presented as real.** | Survives |
| 6 | **Left-aligned.** Centre only a single short message. | Replaced by #135 (HIG); same in practice |
| 7 | **One radius scale per density:** card 24/16, input 12/8, everything else a pill. | Replaced by #135 and the table above |
| 8 | **Two elevation levels;** shadow only on floating things. | Replaced by #135 (Bevel's floating shadow) |
| 9 | **No stock photos or illustrations.** A real person's photo or their initials. | Replaced; new wording (Can, 1 Oct 2026) |
| 10 | **Colour never carries meaning alone.** | Survives |
| 11 | **Numbering only for real sequences.** 01 / 02 / 03 only where order matters. | Kept as worded (Can, 1 Oct 2026) |
| 12 | **Motion only on a change of state,** none under Reduce Motion; native screen transitions stay. | Survives |
| 13 | **Label actions;** destructive ones get text and a confirmation. Icon-only only for universal icons, each with a Turkish tooltip. | Survives |
| 14 | **Money is off** while P6 holds (`kShowMoney`). | Survives |
| 15 | **It must not look AI-generated.** | Rewritten (checklist below) |

Rules carried by #134 beyond the numbered list: copy never praises or blames weight and
there is no streak (P7); "sen" in the client app, "siz" in the panel; no glass or blur.

### Rule 15 checklist (rewritten for Bevel)

Check every new screen:
- Every block shows something real from our data: a food, a person, a time, a number.
- Count the colours: black, white, Cloud Card and grey, plus green for progress or
  approval, plus at most one status colour. More needs a reason.
- No tinted icon tiles, no coloured shapes without a meaning, no grid of identical
  icon cards, no multicolour rings (Bevel's data rings are website art).
- Headings are 600 and stop at Large Title (34); Bevel's 40–80 px display sizes are for
  a website, not inside an app.
- Cards have no border and no shadow; a shadow means it floats.
- No gradient, glass or blur.
- Numbers are Alpino 600; columns of numbers sit in fixed slots, so they don't wobble.
- It must not read as "Bevel with our name": no sky gradient, no device renders, no
  laurels.
- Cover the logo: if the screen could belong to any wellness app, it fails.

## Language

Unchanged from Sade: Turkish UI; "sen" in the client app, "siz" in
the panel; "danışan", never "müşteri"; short button labels ("Kaydet", "Vazgeç");
`trUpper` and `formatDecimal` for Turkish casing and decimals; "Yapay zekâ taslağı".

## Open

- **Compact scale and sizes:** raised on 2 Oct 2026 (12 px floor); Can judges it again on the real panel.
- **Logo and app icon:** `WellkitMark` is a placeholder until a real logo exists.
