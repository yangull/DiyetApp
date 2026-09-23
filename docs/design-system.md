# Wellkit design system

The source of truth for how Wellkit looks. Written from the code in
`packages/core/lib/src/theme/` on 23 Sep 2026; if this file and the code disagree, the
code is right and this file gets fixed. The older design-system artifact on claude.ai
(28 Aug 2026) is history, not a source.

Short version of the locked decisions: PLANNING.md #54–#67, #131–#133.

## Direction

**"Sade"** (plain; Can, 23 Sep 2026, PLANNING #133), modelled on how MyFitnessPal's
current app reads, not copied from it: black type on a neutral light-grey ground, white
cards without borders or shadows, bold sans headings and numbers, and **one accent**, the
brand green, only where the user can act or sees progress. Everything else is black,
white and grey; the only other colours are status colours with a fixed meaning (waiting,
error, AI draft). The client app is calm; the dietitian panel is dense enough to replace
Excel. One token set, two densities.

Premium here means restraint: few colours, generous space, rows of equal rhythm, and
nothing drawn that is not data, a status or an action (rule 15).

## How we got here (23 Sep 2026)

Can found the first client app "dull, like a form". Three directions were mocked up
(https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn; copies in
`docs/design/2026-09-23-redesign/`) and he picked **"Sıcak"**: warm cream, a green hero
block, a colour per exchange group, a sun-yellow highlight (#131). Two outside reviews
(`docs/research/2026-09-23-sicak-redesign-review-*.md`) corrected it and it was coded in
slices 1–5b. Seeing it on the phone the same night, Can found it had **too many colours to
feel clean and premium**, and moved to "Sade" (#133): green only, neutral grey, all sans.
Dropped: the cream ground, the green hero block, the yellow highlight, the eight group
colours, Fraunces. Kept from Sıcak and the reviews:

- **Numbers** are `AppTypography.figures`: Figtree 700 with tabular figures.
- **Touch and text size.** Every tappable thing is at least 48 × 48; rows have a minimum
  height (72) and grow with their text; nav labels may wrap. Layouts are tested at 360
  and 412 dp with text scale 1.0, 1.3 and 2.0.
- **Motion** only when a value changes, never because a screen opened; instant under
  reduced motion (`AppMotion`).
- **The week count, not a streak** (P7): "Bu hafta 5/7 gün", starting again each Monday;
  the client can hide it, the dietitian can turn it (and weight and kcal) off per client
  (P9). Copy never praises or blames weight or a missed meal.
- **The bottom bar only navigates**; tabs arrive when a feature ships for everyone.
- **AI-draft cards show what was checked, not a verdict** (#126).
- The panel on phones has a slim header, not a hero.

**Client home ("Bugün") today:** the date and "Merhaba, <ad>" in large bold type, any
pending invite first, then one white "Başlangıç" card: the count ("1 / 3") and a thick
grey progress bar with a green fill, and three rows with a black tick when done or an
empty ring when not. A row's action is a pale-green pill ("Yaz", "Düzenle"). When plans
exist, the same card pattern carries today's meals ("3 / 5 öğün", P7).

## Colour

Light theme only (#59). Every value was measured; don't change one without
re-measuring. Ratios are also written next to each token in `app_colors.dart`.

| Token | Hex | Contrast | Means |
|---|---|---|---|
| `ground` | `#F2F4F3` | — | App background: neutral light grey |
| `surface` | `#FFFFFF` | — | Cards, sheets; no border, the ground separates them |
| `surfaceSubtle` | `#EBEEEC` | — | Table headers, secondary buttons, progress tracks |
| `borderSubtle` | `#E4E8E6` | 1.24:1 | Dividers inside a card; never carries state |
| `borderStrong` | `#7E8C86` | 3.51:1 | Input and control boundaries |
| `textPrimary` | `#16211D` | 16.54:1 | Main text |
| `textSecondary` | `#46534D` | 7.62:1 | Supporting text |
| `textMuted` | `#5F6B64` | 5.56:1 | Captions, hints, quiet controls |
| `primary` | `#18795C` | 5.35:1 | **The brand.** Buttons, links, and "approved" |
| `primaryHover` | `#135F49` | 7.61:1 | Pressed / hovered primary |
| `warning` | `#8A5A0B` | 5.92:1 | Pending, waiting, needs attention |
| `error` | `#A32017` | 7.56:1 | Rejected, failed, destructive |
| `aiDraft` | `#514196` | 8.25:1 | **Only** AI-written content no dietitian has approved |
| `primaryTint` | `#E3F1EA` | primaryHover 6.53:1 | Pale-green fill of a secondary action pill; the one place the accent is a background |
| `warningTint` | `#FBEFD5` | warning 5.19:1 | Fill behind warning text |

Contrast on the grey ground: textPrimary 14.98, textSecondary 7.30, textMuted 5.04,
primary 4.84, warning 5.36, error 6.85, aiDraft 7.47, borderStrong 3.18. Contrast is measured against the surface the token sits on (white unless
stated) and checked by `packages/core/test/core_test.dart`.

Rules:
- **One brand hue, used sparingly** (#55, #133). Green marks what you can press, what
  fills (progress) and "approved"; headings, ticks, selected navigation and body text are
  black or grey. No decorative second accent, no colour per category: groups and macros
  are told apart by name.
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

**One family, Figtree** (#60, changed by #133): headings bold (700, slightly tight),
body regular, labels and buttons semibold, every number `AppTypography.figures` (700,
tabular figures). Bundled in `packages/core/fonts/`, never fetched at runtime (#63); all
twelve Turkish glyphs verified in the font files. `Fraunces-SemiBold.ttf` is still
bundled but unused (remove it once Sade is settled).

| Slot | Face | Comfortable (client app, panel on phones) | Compact (panel on wide screens) |
|---|---|---|---|
| displaySmall | Figtree 700 | 32 / 38 | 32 / 38 |
| headlineLarge | Figtree 700 | 28 / 34 | 22 / 28 |
| headlineMedium | Figtree 700 | 22 / 28 | 18 / 24 |
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
| Card radius | 20 | 10 |
| Control radius | 14 | 8 |
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
one, so touch targets stay large. Cards and app bars have no elevation and no border; white on the grey ground does the
separating. The bottom bar is white; its selected item is black and bold, the rest grey,
with no coloured pill.

## Rules

What keeps Wellkit from looking generated, and honest. Each rule says what to do
instead.

1. **No gradients.** Flat fills; depth comes from white on grey, not shadows or washes.
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
   review" card).
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
    - No colour outside its token's meaning: green for action, progress and approval,
      amber and red for status, violet only for AI drafts. Count the colours on a
      screen; more than green plus one status colour needs a reason.
    - Numbers are `AppTypography.figures`.
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
