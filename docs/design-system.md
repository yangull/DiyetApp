# Wellkit design system

The source of truth for how Wellkit looks. Written from the code in
`packages/core/lib/src/theme/` on 23 Sep 2026; if this file and the code disagree, the
code is right and this file gets fixed. The older design-system artifact on claude.ai
(28 Aug 2026) is history, not a source.

Short version of the locked decisions: PLANNING.md #54–#67.

## Direction

"Cool clinical": the reliability of health software without the category's pale
blue-grey. A neutral, cool, light ground; exactly one brand colour, a vivid emerald.
Every other colour means something. The client app is calm; the dietitian panel is
dense enough to replace Excel. One token set, two densities.

## Colour

Light theme only (#59). Every value was measured; don't change one without
re-measuring. Ratios are also written next to each token in `app_colors.dart`.

| Token | Hex | Contrast | Means |
|---|---|---|---|
| `ground` | `#F7F9F8` | — | App background |
| `surface` | `#FFFFFF` | — | Cards, sheets |
| `surfaceSubtle` | `#EBF1EE` | — | Table headers, subtle fills, selected rows |
| `borderSubtle` | `#DAE4E0` | 1.36:1 | Decorative hairline; never carries state |
| `borderStrong` | `#7E8C86` | 3.51:1 | Input and control boundaries |
| `textPrimary` | `#16211D` | 16.54:1 | Main text |
| `textSecondary` | `#46534D` | 7.62:1 | Supporting text |
| `textMuted` | `#5F6B64` | 5.56:1 | Captions, hints, quiet controls |
| `primary` | `#18795C` | 5.35:1 | **The brand.** Buttons, links, and "approved" |
| `primaryHover` | `#135F49` | 7.61:1 | Pressed / hovered primary |
| `warning` | `#8A5A0B` | 5.92:1 | Pending, waiting, needs attention |
| `error` | `#A32017` | 7.56:1 | Rejected, failed, destructive |
| `aiDraft` | `#514196` | 8.25:1 | **Only** AI-written content no dietitian has approved |

Rules:
- **One brand hue.** No decorative second accent (#55).
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
files. Serif never appears in body text, tables or buttons.

| Slot | Face | Client app (comfortable) | Panel (compact) |
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

| Metric | Client app | Panel |
|---|---|---|
| Page padding | 20 | 24 |
| Card radius | 14 | 10 |
| Control radius | 10 | 8 |
| Button height | 48 | 36 |
| Input height | 52 | 38 |
| Row height | 72 | 44 |
| Avatar | 40 | 28 |

In the panel, buttons and chips are 36 tall and text fields and dropdowns 38, side by
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

1. **No gradients.** Flat fills; depth comes from borders and surface tone.
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
8. **At most two elevation levels.** Borders and surface tone do the separating.
9. **No stock photos.** A real dietitian's photo or none (QUESTIONS Q23 parked).
10. **Colour never carries meaning alone.** Every status has a label or icon too.
11. **Numbering only for real sequences.** 01 / 02 / 03 only where order matters.
12. **Motion only on a change of state,** and never when the OS asks for reduced
    motion.
13. **Label actions.** In the panel, an action gets a visible text label, and every
    destructive action (cancel, delete, reset) gets text plus a confirmation step.
    Icon-only buttons are allowed only for universal icons (back, close a search,
    send, +/−, remove a row ×), and each must have a Turkish tooltip.
14. **Money is off.** No fee, price, commission or ₺ figure is shown while PLANNING P6
    holds; the demo gates them behind `kShowMoney`.

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
