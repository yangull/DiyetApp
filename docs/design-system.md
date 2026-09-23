# Wellkit design system

The source of truth for how Wellkit looks. Written from the code in
`packages/core/lib/src/theme/` on 23 Sep 2026; if this file and the code disagree, the
code is right and this file gets fixed. The older design-system artifact on claude.ai
(28 Aug 2026) is history, not a source.

Short version of the locked decisions: PLANNING.md #54–#67, #131–#132.

## Direction

"Cool clinical": the reliability of health software without the category's pale
blue-grey. A neutral, cool, light ground; exactly one brand colour, a vivid emerald.
Every other colour means something. The client app is calm; the dietitian panel is
dense enough to replace Excel. One token set, two densities.

## Redesign "Sıcak" (decided and coded 23 Sep 2026)

Can saw the client app on a phone, called it dull and lifeless, and picked direction
**"Sıcak"** (option B on the mockup canvas,
https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn; copies and before-screenshots in
`docs/design/2026-09-23-redesign/`), closest to Lifesum: a green hero block with one
big number, colour for the exchange groups, a floating bottom bar. It applies to the
client app and the panel on phones; the panel on wide screens takes the same colours
and keeps its dense tables (PLANNING #131). The rule changes it needed were delegated
to Claude with one condition: **it must not look like an AI-coded frontend** (#132,
rule 15). Two outside reviews (Codex and a Claude subagent,
`docs/research/2026-09-23-sicak-redesign-review-*.md`) refined it the same day; the
values below include their verified corrections.

What makes it alive is mostly **daily data** (meals marked as eaten, P7; weigh-ins,
P8; the dietitian's messages), not decoration. The home screen stays honest until that
data exists (rules 4 and 5).

Slices 1–5 coded it the same day (PLANNING #131). The tables further down now hold the
coded values; this section keeps the reasoning and what differs from before.

**Token changes.** Contrast measured on 23 Sep (and re-measured by both reviewers)
against the new ground unless stated.

| Token | Now | Sıcak | Contrast |
|---|---|---|---|
| `ground` | `#F7F9F8` | `#F6F1E8` warm | textPrimary 14.70, textSecondary 7.17, textMuted 4.95, primary 4.75, warning 5.26, error 6.72, aiDraft 7.33, borderStrong 3.12 |
| `surfaceSubtle` | `#EBF1EE` | `#F1EADF` | textPrimary 13.84, textSecondary 6.75, primaryHover 6.37. **`primary` is 4.47 here: links and text on this fill use `primaryHover`.** `borderStrong` is 2.94 here: no essential boundary on this fill |
| `borderSubtle` | `#DAE4E0` | `#E8DDCB` | 1.19, decorative only |
| `hero` (new) | — | `#18795C` (= primary) | white 5.35; `onHeroSecondary` `#E4F2EC` 4.64 (also pending step numbers and borders) |
| `heroTrack` (new) | — | `#135F49` (= primaryHover) | the ring's and steps' unfilled track; highlight on it 4.53 |
| `highlight` (new) | — | `#F2C14E` | 3.19 on hero, 4.53 on heroTrack; text on it `#3B2A00` 8.25 |
| `warningTint` (new) | — | `#FBEFD5` | warning text 5.19 |

`highlight` (sun yellow) means **progress and achievement** only: the day's ring, a
finished step, the week count. It sits on the green hero. It never marks "needs
attention"; that stays `warning` with a label.

The mockups used a warmer text colour and extra greys (`#1F2A24`, `#4F5A52`,
`#5A5348`, `#6A6254`). They are **not** tokens: text keeps `textPrimary`,
`textSecondary` and `textMuted`.

**Exchange-group colours** (new, #132). They identify one of the eight groups in bars,
rings and chips, always next to the group's name (rule 10), and **nothing else**: never
avatars, icon tiles or statuses. Never violet. Bars are measured against white and
against their track, `surfaceSubtle` (3:1 needed for graphics); chip text against its
tint.

| Group | Colour | vs white | vs track | Chip text on tint |
|---|---|---|---|---|
| Süt | `#3E7BD6` | 4.19 | 3.51 | `#2B5EA8` on `#DCE8F7`, 5.18 |
| Et | `#C4552F` | 4.48 | 3.75 | `#8E3517` on `#F8E1D8`, 6.27 |
| Nişastalı | `#B07B12` | 3.69 | 3.09 | `#7A5406` on `#F7EBCB`, 5.71 |
| Kuru baklagil | `#8C6A3F` | 4.94 | 4.14 | `#624A2D` on `#EEE5D8`, 6.64 |
| A grubu sebze | `#478B37` | 4.19 | 3.50 | `#2F6A22` on `#E1EFDC`, 5.48 |
| B grubu sebze | `#2F8F8A` | 3.88 | 3.24 | `#1D6662` on `#DCF0EC`, 5.66 |
| Meyve | `#D2477B` | 4.26 | 3.57 | `#983055` on `#F8E0E9`, 5.83 |
| Yağ | `#6B7A8F` | 4.37 | 3.66 | `#46546A` on `#E7ECF2`, 6.46 |

Nişastalı sits near `warning` in hue; the label keeps them apart. For colour-blind
users some pairs collapse (Meyve/Yağ, Et/Kuru baklagil): the group name is what carries
the meaning.

Avatars and icon tiles are neutral: `surfaceSubtle` fill with `textSecondary` (6.75).

**Type.** Fraunces stays for greetings and screen titles only. **Every number** (the
hero count, kcal, kg, times, counts) is **Figtree 700 with tabular figures**: the
bundled Fraunces has no tabular digits, so "7/12" → "10/12" would shift sideways.
`Figtree-Bold.ttf` is added to the bundle; until slice 1 only 400 and 600 ship.

**Shape and depth (comfortable density).** Card radius 14 → 18, control radius
10 → 14, the hero block's bottom corners 28, pills and avatars fully round. The
floating bottom bar is the one shadowed element: `0 6 24` at 14 % of textPrimary; no
other card gets a shadow (rule 8).

**Touch and text size.** Every tappable thing is at least 48 × 48 (whole rows are one
target with a chevron, not a small text link). Rows have a **minimum** height (72) and
grow with their text. Nav labels may wrap to two lines. Layouts are tested at 360 and
412 dp wide with text scale 1.0, 1.3 and 2.0.

**Motion.** A ring or bar animates **only when its value changes**: when the client marks
a meal, or when something changed since the screen was last seen. Opening the app shows
the current value at once (Can, 23 Sep; #132). Marking a meal gives the check a short
pop (200 ms); value changes take 400 ms, ease-out. Everything is instant when
`MediaQuery.disableAnimationsOf` is true.

**Client home ("Bugün") order.** Hero (today's meals, "3/5 öğün", P7) → the next meal
with the one action "Öğünü yedim" → the dietitian's latest message → today's plan by
group ("Et · 4 değişim", planned amounts, not eaten fractions) → the week. The bottom
bar only navigates: no action button in it. Tabs are added when a feature ships for
everyone, not per user; a tab without data yet shows one true sentence ("Diyetisyenin
planı gelince burada görünür"). Profil stays the last tab.

**The week count, not a streak** (P7, was C22). "Bu hafta 5/7 gün", starting again each
Monday, never "you broke it". The client can hide it; the dietitian can turn it (and
the weight chart, and kcal) off for one client (P9). Kcal is not shown to clients unless
the dietitian turns it on. Copy never praises or blames weight or a missed meal.

**Panel on phones.** A slim green header, not the full hero block. Its counts are 48 dp
filters that open the matching list. The AI-draft card shows **what was checked, not a
verdict** ("Kayıtlı alerji: fıstık · planda yok", never "alerji kontrolü temiz") and
keeps "Taslağı incele".

## Colour

Light theme only (#59). Every value was measured; don't change one without
re-measuring. Ratios are also written next to each token in `app_colors.dart`.

| Token | Hex | Contrast | Means |
|---|---|---|---|
| `ground` | `#F6F1E8` | — | App background (warm since #131) |
| `surface` | `#FFFFFF` | — | Cards, sheets |
| `surfaceSubtle` | `#F1EADF` | — | Table headers, subtle fills, secondary buttons, bar tracks. Text and links on it use `primaryHover` |
| `borderSubtle` | `#E8DDCB` | 1.19:1 | Decorative hairline; never carries state |
| `borderStrong` | `#7E8C86` | 3.51:1 | Input and control boundaries |
| `textPrimary` | `#16211D` | 16.54:1 | Main text |
| `textSecondary` | `#46534D` | 7.62:1 | Supporting text |
| `textMuted` | `#5F6B64` | 5.56:1 | Captions, hints, quiet controls |
| `primary` | `#18795C` | 5.35:1 | **The brand.** Buttons, links, and "approved" |
| `primaryHover` | `#135F49` | 7.61:1 | Pressed / hovered primary |
| `warning` | `#8A5A0B` | 5.92:1 | Pending, waiting, needs attention |
| `error` | `#A32017` | 7.56:1 | Rejected, failed, destructive |
| `aiDraft` | `#514196` | 8.25:1 | **Only** AI-written content no dietitian has approved |
| `hero` | `#18795C` | white 5.35:1 | The one flat green block carrying a screen's main number |
| `onHeroSecondary` | `#E4F2EC` | 4.64:1 on hero | Secondary text and pending steps on the hero |
| `heroTrack` | `#135F49` | decorative | Unfilled ring or step line on the hero |
| `highlight` | `#F2C14E` | 3.19:1 on hero | **Only** progress and achievement |
| `onHighlight` | `#3B2A00` | 8.25:1 | Text and icons on `highlight` |
| `warningTint` | `#FBEFD5` | warning 5.19:1 | Fill behind warning text |

The eight exchange-group colours (`ExchangeGroupColors`) are in "Redesign Sıcak"
above. Contrast is measured against the surface the token sits on (white unless
stated) and checked by `packages/core/test/core_test.dart`.

Rules:
- **One brand hue.** No decorative second accent (#55). Since the "Sıcak" redesign
  (#132) two kinds of colour are added, each with a fixed meaning: `highlight` for
  progress and achievement, and one colour per exchange group.
- **No separate success colour.** A success green measured 1.19:1 against the brand
  green, so "approved" uses `primary` (#56).
- **Violet is reserved for unapproved AI drafts:** violet + a 1.5 px dashed border + a
  text label, together (#57). It appears nowhere else, so violet always means "a
  machine wrote this and nobody approved it". Other statuses (invites, appointments)
  must not reuse it.
- **`ColorScheme.fromSeed` is never used.** It would regenerate the palette (#65).
- **Exception:** the video-call mockup uses a near-black stage (`#15181A`), as every call
  app does. It is the only hard-coded colour.

Known tension, open for review: `primary` means both "you can press this" and
"approved"; `warning` means both "pending" and "needs attention".

## Type

Fraunces (headings only) + Figtree (everything else), bundled in `packages/core/fonts/`,
never fetched at runtime (#60, #63). All twelve Turkish glyphs are verified in the font
files. Serif never appears in body text, tables, buttons or numbers: every number is
`AppTypography.figures` (Figtree 700, tabular figures; `Figtree-Bold.ttf` is bundled
since #132).

| Slot | Face | Comfortable (client app, panel on phones) | Compact (panel on wide screens) |
|---|---|---|---|
| displaySmall | Fraunces 600 | 34 / 40 | 34 / 40 |
| headlineLarge | Fraunces 600 | 27 / 34 | 22 / 28 |
| headlineMedium | Fraunces 600 | 22 / 28 | 18 / 24 |
| titleLarge | Figtree 600 | 18 / 24 | 16 / 22 |
| titleMedium | Figtree 600 | 16 / 24 | 14 / 20 |
| bodyLarge | Figtree 400 | 16 / 24 | 14 / 20 |
| bodyMedium | Figtree 400 | 14 / 20 | 13 / 18 |
| bodySmall | Figtree 400 | 13 / 18 | 12 / 16 |
| labelLarge (buttons) | Figtree 600 | 15 / 20 | 13.5 / 18 |
| labelMedium (rail) | Figtree 600 | 13 / 18 | 12 / 16 |
| labelSmall | Figtree 600, +0.88 spacing | 11 / 16 | 11 / 16 |

Size / line height in logical pixels. Numbers that line up (kcal, g, kg, dates, ₺)
use tabular figures. Fill every `TextTheme` slot a widget reads; an empty slot falls
back to Material's font, not Figtree.

## Density and spacing

One token set, two profiles (`AppDensity`, #64). Colours, fonts and meanings never
change between them; only measurements do.

| Metric | Comfortable (client app, panel on phones) | Compact (panel on wide screens) |
|---|---|---|
| Page padding | 20 | 24 |
| Card radius | 18 | 10 |
| Control radius | 14 | 8 |
| Hero bottom radius | 28 | — |
| Button height | 48 | 36 |
| Input height | 52 | 38 |
| Row height | 72 | 44 |
| Avatar | 40 | 28 |

In the compact profile, buttons and chips are 36 tall and text fields and dropdowns 38, side by
side on one line. Flutter's own `VisualDensity` is pinned to standard in the theme:
`AppDensity` is the only density system.

Spacing scale (`AppSpacing`): 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48.
Navigation: the client app uses a bottom bar; the panel uses a `NavigationRail` with
labels on wide screens and a bottom bar on phones. The panel runs on web, phones and
tablets (PLANNING #38): wide screens use the compact density, phones the comfortable
one, so touch targets stay large. Cards and app bars have no elevation; separation comes from borders and surface
tone.

## Rules

What keeps Wellkit from looking generated, and honest. Each rule says what to do
instead.

1. **No gradients.** Flat fills; depth comes from borders and surface tone. A flat
   coloured block is allowed where it carries the screen's main number (the green
   hero, #132).
2. **No emoji as icons.** One icon set (Material outlined). Emoji only inside text a
   user wrote.
3. **No "✨ AI-powered" badges.** Say what happened: "Yapay zekâ taslağı · onay
   bekliyor", and what the dietitian must do.
4. **Only what exists is drawn.** Real data or a real action on every screen; something
   unbuilt is named once with "Yakında", never drawn as clickable UI (PLANNING #50).
   A control that does nothing is disabled and says why.
5. **No invented numbers presented as real.** Example values are labelled "örnek" or
   "tahminimiz"; no progress bar without a real target behind it.
6. **Left-aligned, one grid.** Centre only a single short message (e.g. the "under
   review" card) or one hero number per screen (#132).
7. **One radius scale per density.** Don't mix 4, 8, 16 and 24 on one screen.
8. **At most two elevation levels.** Borders and surface tone do the separating. Only
   floating elements (the bottom bar, sheets) get a shadow (#132).
9. **No stock photos.** A real dietitian's photo or none (QUESTIONS Q23 parked). One
   consistent illustration set for the eight exchange groups may come later
   (QUESTIONS C20); until then, group chips are text on a tint.
10. **Colour never carries meaning alone.** Every status has a label or icon too.
11. **Numbering only for real sequences.** 01 / 02 / 03 only where order matters.
12. **Motion only on a change of state,** and never when the OS asks for reduced
    motion. A ring or bar animates when its value changes (including a change since
    the screen was last seen), never just because a screen opened (#132). No fade-ins,
    staggered lists or parallax.
13. **Label actions.** In the panel, an action gets a visible text label, and every
    destructive action (cancel, delete, reset) gets text plus a confirmation step.
    Icon-only buttons are allowed only for universal icons (back, close a search,
    send, +/−, remove a row ×), and each must have a Turkish tooltip.
14. **Money is off.** No fee, price, commission or ₺ figure is shown while PLANNING P6
    holds; the demo gates them behind `kShowMoney`.
15. **It must not look AI-generated** (Can, 23 Sep 2026). Rules 1–3 and 12 already
    cover gradients, emoji, "✨ AI" badges and animate-everything. Check every new screen
    against this list:
    - Every block shows something real from our data: a food, a person, a time, a number.
    - No tinted icon tile or coloured shape without a meaning; no grid of identical
      icon cards.
    - No colour outside its token's meaning (group colours only for groups, violet only
      for AI drafts, yellow only for progress).
    - Numbers are in the sans (Figtree), not the serif.
    - No glass or blur, no oversized marketing headlines inside the app.
    - Cover the logo: if the screen could belong to any wellness app, it fails.

## Language

Turkish UI. "Sen" in the client app, "siz" in the panel; always "danışan", never
"müşteri" (#47–#49). Auth errors stay in English until l10n (#44).

- **Buttons use the short form:** "Kaydet", "Vazgeç", "İptal et", "Davet gönder", "Tekrar
  dene". Sentences, hints and dialog text use "siz" (#120).
- **Turkish casing and numbers.** Uppercase labels go through `trUpper` (so "tipi" becomes
  "TİPİ", not "TIPI") and decimals through `formatDecimal` (72,4 kg, not 72.4), both in
  the panel's `lib/util/turkish.dart`.
- "Yapay zekâ taslağı", not "AI taslağı". No English product words ("Marketplace") in
  UI text: the section is "Diyetisyen bul".
