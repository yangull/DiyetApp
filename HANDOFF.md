# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 1 October 2026 (evening).

## Where things stand

- Phase 0 is done (auth, invites, real client list, interview demo on fake data; money UI
  hidden, P6).
- **Visual redesign from zero, decided and planned; no code yet** (PLANNING #134–#135).
  - Survives: the safeguards (AI-draft marking, approval gate, no money UI, Turkish copy
    with sen/siz, labelled actions) and the honesty, safety and access rules listed in
    #134, including how weight may be named in copy.
  - **Style: Bevel.** Its DESIGN.md is in `docs/design/2026-10-01-bevel/DESIGN.md`,
    verbatim. It describes a marketing website, so #135 adapts it: HIG type sizes and
    44/48 touch targets, Bevel's character (white canvas, pale borderless cards, 600
    headings, grey supporting text), black pill buttons with one accent, measured red,
    amber and AI-draft violet, a solid floating tab bar, panel density by input.
  - **Font: Alpino** (Fontshare). Turkish complete, licence allows apps, **no tabular
    figures**: numbers that must line up get fixed-width, right-aligned slots.
  - Still open: accent hue green vs blue (C36) and sky gradient vs flat (C40), both
    picked on the canvas; dark mode (C43); density details (C44); Alpino in artifacts
    (C45).
- The code still ships Sade/direction B. `docs/design-system.md` describes it until the
  theme slice; the target goes into `docs/design-system-next.md` first.
- Direction B's rollout is **paused**. B1 and B2 (Genel Bakış) are committed and pushed;
  their core widgets (`SectionLabel`, `ActionRow`, `PersonAvatar`) and screen states are
  code to reuse. The 24 Sep Randevular agenda is in `git stash` (`stash@{0}` today; find
  it by its message "Randevular agenda (WIP, 24 Sep)").
- Tests at the last code commit: core 21, client 18, panel 195.

## Next steps (the redesign plan, one slice per step)

Every slice: small; `dart run melos run analyze` and `… test` when code changes; a
subagent review; results shown to Can (an artifact page or `C:\Users\jhana\Pictures\`,
since chat images don't reach Can); commit only on Can's word; push only on "push".

1. **Design system target (docs, no code).** Write `docs/design-system-next.md` from
   the DESIGN.md and PLANNING #134–#135: the HIG type scale in Alpino (touch) plus a
   compact draft for the panel (C44), spacing, radii, the black pill button, the darker
   grey for text on Cloud Card, a new red and amber, the AI-draft violet (re-measure
   #514196 against Bevel's palette), both accent candidates (C36), every colour
   measured (WCAG AA and HIG, stricter wins), light only (C43). Rewrite rule 15's
   checklist and state each numbered rule's status as in #134. Then install it as a
   Design System artifact; ask C45 before uploading Alpino to it.
2. **Copy study (docs).** Hooks, empty states and buttons from Diyetkolik, Hiwell,
   NutriMobi, Diyetisyen Oflaz and YAZIO's Turkish version, quoted with sources, into
   `docs/research/`; client app only, filtered by #134's weight rule. Store listings are
   the first source; ask Can for screenshots of empty screens.
3. **Bugün canvas.** A Design artifact on that system: phone (iPhone and Android) and
   wide artboards; Bugün with a plan (main, labelled not built yet) and a new client's
   setup (today's flow, C23); green vs blue (C36), gradient vs flat (C40). Can picks;
   ask C43 again.
4. **Flutter theme.** Alpino into `packages/core/fonts/` with its `FFL.txt` (no
   subsetting or conversion). Source: `/mnt/c/Users/jhana/Desktop/Alpino_Complete.zip`,
   `Fonts/OTF/` statics and `Fonts/TTF/Alpino-Variable.ttf`. Note: the variable file's
   default instance is Black (900) and its named Regular is ~422, so check how Flutter's
   `FontWeight` maps onto it before choosing statics vs variable. New tokens in core's
   theme, font and contrast tests updated, Figtree and Fraunces removed,
   `design-system-next.md` replaces `design-system.md`. Check on the emulator.
5. **Flutter screens:** Bugün as drawn, then the client app's other screens, then the
   panel (density by input, C44), screen by screen.
6. Outside the redesign, unchanged: data features (weigh-ins first; until step 4 they
   use today's design-system.md), C17 dev project + CI + RLS tests; DT3 and C13 remain
   Can's most blocking product answers.

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
  read single pages with WebFetch only; values come only from the DESIGN.md file Can
  provides.
- Apple's HIG pages come as exact text from
  `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`
  (typography, accessibility, buttons, tab-bars, materials, color, dark-mode, layout).
- Font checks: `uv run --with fonttools python …` (cmap for Turkish glyphs, GSUB for
  `tnum`, `fvar` for axes, `hhea` and glyph bounds for line height).

## What Can needs to do

- Answer C44 (density details) and C45 (Alpino in a private artifact) before slice 1's
  artifact; C36, C40 and C43 come up on the canvas.
- Still open from before: C23 (interaction half), DT3, C13, C21, C17, DT7, C4, C46.
