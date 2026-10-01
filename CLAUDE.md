# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start here

Read these files at the start of every session:

- **`HANDOFF.md`**: where things stand, next steps, and the most blocking questions.
- **`PLANNING.md`**: the product, locked decisions (stable IDs P1–P9 and #1–#135, which
  code comments cite), current state and roadmap. Edit it in place when a
  decision changes; never append session logs to it.
- **`CONTEXT.md`**: the domain glossary (değişim listesi, BMH, danışan, …).
- **`docs/design-system.md`**: colours, type, density and the design rules. Read it before touching UI.
- **`QUESTIONS.md`**: the only list of open questions. Add new ones there, never anywhere else.

## Project status

Phase 0 is done: monorepo, the Supabase identity schema, real auth in both apps
(`packages/core/lib/src/auth/`), and real client management: migration 4's
`dietitian_client_relationships`, `packages/core/lib/src/relationships/`, the panel's
`lib/panel/real_overview_screen.dart` and `real_client_detail_screen.dart`.

`apps/dietitian_panel` has two entry points: `lib/main.dart` (the real, auth-gated app)
and `lib/main_demo.dart` (the unauthenticated interview prototype on fake data, with both
plan editors side by side). Don't confuse them. Not built yet: the real plan editor,
`diet_plans` and anything marketplace. The plan model is decided (PLANNING P4, #121–#123):
exchange list by default with freeform kept, weekly plans, one shared exchange table.

**Wellkit** is a two-sided dietitian marketplace app for the Turkish market: dietitians get a
management panel + marketplace visibility; clients get affordable dietitian access or an
AI-only diet plan tier.

## Locked decisions (do not relitigate without asking Can)

- AI drafts diet plans, the dietitian approves; clients never see unapproved AI plans (on the human-service side).
- All communication stays in-app (chat + embedded video), for records, quality control, KVKK and B2B reporting (PLANNING P2); protecting a commission is no longer the reason.
- No money in the app at launch: clients pay dietitians directly; commission, packages and payouts are decided later (PLANNING P6).
- Build order: shared core → dietitian marketplace → AI-only tier.
- No per-dietitian-type screens; one general management panel.
- No Mac available: iOS builds go through Codemagic (cloud CI). Daily development is web-first via `flutter run -d web-server`, opened from the Windows browser; the Android emulator (on Windows) checks the mobile layout.

## Tech stack (decided)

- **Flutter** for the client app (iOS + Android) and for the dietitian panel (web, iOS and Android, a separate store app; PLANNING #38), sharing a `core` package in a single **Melos** monorepo.
- **Supabase (EU region)** for auth, Postgres, storage, realtime. EU region is deliberate: the app holds personal health data and must be **KVKK**-compliant.
- **Supabase Edge Functions** for all LLM calls — API keys never live in the client.
- Payments: **none for human dietitian services at launch** (clients pay dietitians directly, PLANNING P6; iyzico was the earlier plan). **RevenueCat + in-app purchase** for the later AI subscription tier (Apple/Google requirement).
- Video SDK not chosen yet (candidates: Agora / 100ms / Daily).

## Planned repo structure

```
apps/client/           Flutter customer app (iOS + Android)
apps/dietitian_panel/  Flutter panel (web + iOS + Android)
packages/core/         shared models, Supabase client, auth, theme
supabase/migrations/   SQL schema versions
supabase/functions/    Edge Functions (AI calls)
pubspec.yaml           pub workspace root; Melos config lives under its `melos:` key
```

## Flutter commands

Flutter 3.47.2 / Dart 3.13.2 lives at `~/development/flutter` (on PATH via `~/.bashrc`).
The repo is a **Dart pub workspace**: one `.dart_tool/` and one `pubspec.lock` at the root,
and every package declares `resolution: workspace`.

Melos 8 is a dev dependency rather than a global install, and its config lives under the
`melos:` key in the root `pubspec.yaml` — **not** in a `melos.yaml`, which Melos 8 ignores
when the root declares a pub workspace. Run scripts from the repo root:

```bash
dart run melos run analyze   # dart analyze --fatal-infos in every package
dart run melos run format    # dart format . (writes files)
dart run melos run test      # flutter test in every package that has test/
flutter pub get              # resolve the whole workspace at once
```

Run an app from its own directory; the config file is required or `AppConfig` comes up empty:

```bash
cd apps/client   # or apps/dietitian_panel
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
  --dart-define-from-file=../../env/dev.json
```

Then open `http://localhost:8080` from the Windows browser. Note that `flutter devices` does
**not** list the `web-server` device in this WSL setup even though `-d web-server` works —
don't chase that. There is no Chrome and no Linux desktop toolchain inside WSL, so
`flutter doctor` shows those two as expected failures, plus an "Android license status
unknown" that is cosmetic (the new `sdkmanager` output confuses it; licences are accepted).

**Android emulator (PLANNING #3).** Can starts the emulator on Windows (Android Studio →
Device Manager → ▶). WSL has its own JDK 21 (`~/development/jdk`) and Android SDK
(`~/Android/Sdk`), set in `~/.bashrc`, and sees the emulator through mirrored networking:

```bash
adb devices                  # should list emulator-5554
cd apps/client               # or apps/dietitian_panel
flutter run -d emulator-5554 --dart-define-from-file=../../env/dev.json
```

The first build after a WSL restart takes several minutes (Gradle starts cold). Screenshot
the emulator with `adb exec-out screencap -p > shot.png`. Bundle ids: `com.wellkit.client`
and `com.wellkit.panel`.

`apps/dietitian_panel` has a second entry point: add `-t lib/main_demo.dart` to the command
above to run the unauthenticated interview prototype (fake data, no login) instead of the
real auth-gated app.

## Supabase (working commands)

The repo is linked to the cloud project `jpkvulcszsutacritttk` (eu-central-1). CLI v2.116
lives at `~/.local/bin/supabase`. No local Docker stack — everything targets the cloud
project directly.

```bash
supabase migration new <name>   # create a new timestamped SQL file
supabase db push --dry-run      # show which migrations would apply
supabase db push                # apply them to the EU cloud project
supabase migration list         # compare local vs remote migration state
```

Never create or edit schema from the dashboard UI — every change is a versioned file in
`supabase/migrations/`. `supabase/config.toml` only configures the (unused) local stack;
remote auth settings are changed in the dashboard.

Real values for `--dart-define-from-file` are in `env/dev.json` (gitignored). The key
stored there is the **publishable** key (`sb_publishable_...`), not the legacy anon JWT.

## Working rules (from PLANNING.md §10)

- **Can is the source of truth for product decisions.** On a conflict or an unclear point, ask Can and record the question in `QUESTIONS.md`. The old Miro board is not a source: don't read or cite it, even though a Miro tool may be connected.
- When unsure, **ask — don't assume**.
- UI text in Turkish; code and commit messages in English.
- Work in small, working slices — no big-bang PRs.
- Update PLANNING.md when a decision changes or a question closes, in place. Rewrite
  HANDOFF.md at the end of a session. Session narratives go in commit messages.

## How a session runs

1. Can opens a new chat in this folder (no worktree). Read HANDOFF, then act on what Can
   brings: answers to QUESTIONS.md, or a task from HANDOFF "Next steps".
2. Work in one small slice. Run `dart run melos run analyze` and `… test`, show what
   changed, and ask before committing or pushing. Plan mode first for anything larger.
3. Codex (`../dietician-app-codex`, see AGENTS.md) gives second opinions in review mode
   and saves them to its own `docs/research/`, uncommitted. To use one: verify every
   claim against the code, copy the file into this repo's `docs/research/`, delete the
   uncommitted copy in the Codex folder, and commit here. Work-mode branches (`codex/*`)
   are reviewed with `git diff main...codex/<topic>` before merging.
4. When Can says "wrap up": record decisions in PLANNING.md, close or add questions in
   QUESTIONS.md, rewrite HANDOFF.md, update the artifact pages if screens or decisions
   changed, commit and push after Can's OK, then fast-forward the Codex branch
   (`git -C ../dietician-app-codex merge --ff-only main`).

## Gotchas

Traps that already cost time. Decisions with the same flavour (RLS projections, the PDF
approval gate, the 1919 energy constants) are in PLANNING §3 with their reasons.

**Supabase / SQL**
- Never add a SELECT policy on `profiles` or any client-data table to "just show a name".
  Use a `security definer` projection function (PLANNING #90, #103).
- `relationship_status` already has `declined`. To add `ended`, you cannot
  `alter type ... add value` and reference the new label in the same transaction. Split
  it into two migrations, or move the column to `text` + a check constraint.
- Invite accept/decline trusts the JWT `email` claim. It is only safe with email
  confirmation on (PLANNING #21, on since 23 Sep 2026), and that is a dashboard setting.
- With confirmation on and no custom SMTP, Supabase only emails members of the Supabase
  org. A test signup with a made-up address never gets confirmed.
- `Supabase.initialize` takes `publishableKey:`, not the deprecated `anonKey:`.
  `--fatal-infos` fails the build on the latter.
- There is one shared cloud project. Worktrees isolate files, not the database: only this
  `main` worktree is `supabase link`ed and runs `supabase db push`. The Codex worktree
  (`dietician-app-codex`, branches `codex/*`) is deliberately unlinked. Its rules are in
  `AGENTS.md`. Review a Codex branch before merging, e.g. `git diff main...codex/<topic>`.

**Theme and layout**
- `ColorScheme.fromSeed` silently discards the measured palette. Set every slot.
- Setting `AppBarTheme.titleTextStyle` cuts `foregroundColor` off from the title. Keep an
  explicit `color:` on that style.
- An unfilled `TextTheme` slot falls back to Material's default font, not Alpino. Fill
  any slot a new widget reads (NavigationRail uses `labelMedium`, pickers `display*`).
- Alpino is one variable file whose default instance is Black (900). Flutter maps
  `FontWeight` onto its wght axis (checked in tests and on the Pixel 8a, 1 Oct 2026); if a
  platform ever renders everything Black, add `fontVariations` in `AppTypography`. The
  `pdf` package can't read variable fonts, so the plan PDF keeps Figtree.
- Alpino's licence forbids sharing the font file through a public repository or server.
  `yangull/DiyetApp` is private; before it ever goes public, take
  `packages/core/fonts/Alpino-*` out of the repo and its history.
- Alpino has no tabular figures: `FontFeature.tabularFigures()` does nothing. Numbers
  that must line up go in fixed-width, right-aligned slots.
- A field helper that returns `Expanded` can only live in a `Row`. Put flex on the row
  builder.
- Flutter shrinks every control by 8 px on desktop (`VisualDensity.compact`), so a web
  build in a Windows browser differs from `flutter test` (Android defaults). The theme
  pins `VisualDensity.standard`; measure control sizes with
  `debugDefaultTargetPlatformOverride = TargetPlatform.windows`.
- `DropdownMenu` ignores the input theme's height (its arrow is a fixed 48 px button). Use
  `DropdownButtonFormField`.
- Dart's `toUpperCase()` turns "tipi" into "TIPI". Use `trUpper` / `formatDecimal` in
  core's `format/turkish_text.dart`.
- The panel's density follows the input, not the width (PLANNING #135): compact only in a
  browser on Windows, macOS or Linux (`panelDensity` in `lib/util/breakpoints.dart`).
  `flutter test` is never web, so `test/flutter_test_config.dart` sets
  `debugPanelDensity` to "wide window = computer, narrow = phone". The rail vs bottom bar
  switch is still width-based: branch phone layouts on `isPanelPhone(context)`; never
  hard-code `AppDensity.compact` in a screen. Card padding is `density.cardPadding`.
- Colours are checked by `packages/core/test/core_test.dart`, including on a Cloud Card
  under the 8 % press overlay: a new token needs its pairs added there. Keep overlays at
  `AppTheme.hoverOverlay` / `pressOverlay`; Material's defaults (10–12 %) break the grey.
- Cards are Cloud Card on the white canvas. Anything pale inside a card (a progress
  track, an avatar disc, a neutral pill) is `canvas`, not `cloudCard`, or it vanishes.
- Widgets read colours through `context.palette`, never `AppColors.*`: the constants
  are light-only, so a widget using them stays light in dark mode. Text on the filled
  pill (`charcoal`) is `onCharcoal`, which flips to near-black in dark.
- Black does the acting: `FilledButton` is the Charcoal pill, `OutlinedButton` the pale
  secondary pill (not an outline), `TextButton` Ink. Green is never an action colour. A
  destructive confirm uses `AppTheme.destructiveButton` (red).
- `Scrollable.ensureVisible` needs the target built. A lazy `ListView` doesn't build
  off-screen children, so a screen with a "jump to" link (Genel Bakış, the client
  record) is a `SingleChildScrollView`.

**Demo panel**
- All money UI (Ödemeler tab, "Tahsil edilmemiş" figures, payment reminder) is gated by
  `kShowMoney` in `lib/demo/demo_repository.dart`, off because of PLANNING P6. Gate any
  new fee or commission display the same way; `demo_widget_test.dart` checks nothing shows.
- Adding or changing a field on a demo model: update `demo_codec.dart` **and** bump
  `_schemaVersion` in the same change. `demo_codec_test.dart` catches a missing field but
  not a missing bump.
- `demo_store.dart` conditionally imports web vs stub via `dart.library.js_interop` so
  `flutter test` runs on the VM. Don't collapse it into one file.
- Seed data must be relative to `DateTime.now()`. The triage list reads dates as
  signals, so a pinned date is a bug, not cosmetics.
- The client app's "Hedeflerim" form is the only writer of `clients.goal`,
  `budget_range`, `health_notes`. Move the write if you replace it.

**Tests**
- The panel shells use an `IndexedStack`, so every tab stays built: scope test finders
  with `find.descendant(of: find.byType(SomeScreen), …)`, and scroll lazily built lists
  (`scrollUntilVisible`) before tapping at large text scales.
- `FakeAuthRepository.sessionChanges` replays the current session to new listeners, like
  Supabase's `onAuthStateChange`. Making it a bare broadcast stream breaks tests in
  non-obvious ways.
- Text clipped by a fixed-height box raises no overflow error. Use
  `test/text_fits.dart` (`expectTextNotClipped`), and give rows a `minHeight`, not a
  `height`.
- `scrollUntilVisible` / `ensureVisible` with a `.first` finder throws while nothing
  matches yet. Scroll to a unique heading, then drag.
- `find.byType` matches the exact class only: `OutlinedButton.icon` is a subclass. Use
  `find.byWidgetPredicate((w) => w is ButtonStyleButton)`.
- Seed times must be relative to now, not a time of day: "today 16:30" made an
  appointment past every evening and flipped a test.
- To see screens without the emulator, render them in a widget test with Alpino
  loaded (as `test/screenshots_test.dart` does) and `matchesGoldenFile` to a scratch
  path; that is how the 24 Sep alignment audit was done.
- The test font draws every glyph as a square, much wider than Alpino: a label that
  truncates at 2× in a test may fit on a device. Check real layouts on the emulator.
- `test/screenshots_test.dart` produces captures, not regression goldens. It is tagged and
  skipped by default. Regenerate with
  `flutter test test/screenshots_test.dart --tags screenshots --run-skipped --update-goldens`.
  It needs `FLUTTER_ROOT` and loads fonts under `packages/core/`-prefixed family names.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (yangull/DiyetApp), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one root `CONTEXT.md` + `docs/adr/`. See `docs/agents/domain.md`.
