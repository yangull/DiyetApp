# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 1 October 2026.

## Where things stand

- Phase 0 is done (auth, invites, real client list, interview demo on fake data; money UI
  hidden, P6).
- **Visual redesign from zero started** (PLANNING #134, 1 Oct 2026). Features and the
  safeguards stay (AI-draft marking, approval gate, no money UI, Turkish copy with
  sen/siz, labelled actions), plus the honesty, safety and access rules listed in #134.
  Colours, fonts, layout and shapes are open.
- **Style chosen: Bevel** from styles.refero.design. Its DESIGN.md is in
  `docs/design/2026-10-01-bevel/DESIGN.md`, verbatim. It describes a marketing website,
  so Can accepted proposals for its clashes with HIG and our rules (PLANNING #135):
  HIG sizes, black pill buttons with one accent, measured status colours, a solid
  floating tab bar, panel density by input. **Font: Alpino** (checked: Turkish complete,
  licence allows apps, no tabular figures: numbers that must line up get fixed-width
  slots).
- Decided for the first canvas: Bugün in two states (with a plan as the main artboard,
  labelled not built yet; a new client's setup), and one style for both apps.
- Direction B's rollout is **paused**. Slices B1 and B2 (Genel Bakış) are committed and
  **not pushed**; their core widgets (`SectionLabel`, `ActionRow`, `PersonAvatar`) and
  screen states are code to reuse. `stash@{1}` still holds the 24 Sep Randevular agenda.
- The code still ships Sade; `docs/design-system.md` describes it until the new system
  replaces it.

## Next steps (the redesign plan, one slice per step)

Every slice: small, `dart run melos run analyze` and `… test` when code changes, a
subagent review, results shown to Can (artifact page or `Pictures\`), commit only on
Can's word, push only on "push".

0. Alpino's files are in Can's `Desktop\Alpino_Complete.zip`; copy them from there
   when the theme slice needs them.
1. **Design system (docs, no code).** Rewrite `docs/design-system.md` from Bevel's
   DESIGN.md and PLANNING #134–#135: HIG type scale in Alpino, spacing, radii, the
   black pill button, the darker grey on Cloud Card, a new red and amber, the AI-draft
   violet, both accent candidates (C36), every colour measured; the rules checklist
   (rule 15) rewritten. Install it as a Design System artifact with Alpino uploaded as
   an asset.
2. **Copy study (docs).** Hooks, empty states and buttons from Diyetkolik, Hiwell,
   NutriMobi, Diyetisyen Oflaz and YAZIO's Turkish version, quoted with sources, into
   `docs/research/`; client app only, filtered by the weight rule in #134.
3. **Bugün canvas.** A Design artifact on that system: phone (iPhone and Android) and
   wide artboards; Bugün with a plan (main) and a new client's setup; green vs blue
   accent (C36), sky gradient vs flat (C40). Can picks.
4. **Flutter: theme.** Alpino bundled in `packages/core/fonts/` (variable file for 600),
   new tokens in core's theme, font and contrast tests updated, Figtree and Fraunces
   removed. Both apps restyle through the theme; check on the emulator.
5. **Flutter: Bugün** as drawn, then the client app's other screens, then the panel
   (density by input, #135), screen by screen.
6. Unchanged outside the redesign: data features (weigh-ins first), C17 dev project + CI
   + RLS tests; DT3 and C13 are still Can's most blocking product answers.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Genel Bakış revamp canvas | Direction B proposals and results (history now) | https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4 |
| Wellkit design system | Sade tokens (history once the new system lands) | https://claude.ai/artifact/GKBbEfa4zHLzjQtQ6ZZpYh |
| Redesign canvas (23 Sep) | The three older directions | https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |
| Interview guide | Can and Kadir during interviews | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN / TR) | The whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y · https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | 11 demo screens (**pre-Sade**, refresh after the redesign) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |

Captures: `C:\Users\jhana\Pictures\Wellkit revamp\`. Device captures:
`apps/dietitian_panel/test/device_captures_test.dart` (tagged, see its header comment).

## Sources and how to read them

- styles.refero.design's robots.txt disallows Claude agents and its API has a bot check:
  read single pages with WebFetch only, and take values only from Can's pasted or
  downloaded DESIGN.md.
- Apple's HIG pages come as exact text from
  `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`
  (typography, accessibility, buttons, tab-bars, materials, color, dark-mode, layout).

## What Can needs to do

- C36 and C40 are picked on the canvas; C43 (dark mode) after it.
- Still open from before: C23 (interaction half), DT3, C13, C21, C17, DT7, C4, and the
  narrowed names rule from direction B (moot if the redesign changes rows).
