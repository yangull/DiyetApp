# HANDOFF — pick up here

> Written 28 August 2026; updated across six sessions — panel prototype +
> fonts (2nd), real Supabase auth for both apps (3rd), Mesajlar/Ödemeler/
> video-call mockup in the interview demo (4th), agent-skill setup + a
> drift-detection hardening pass on the demo persistence layer (5th), and the
> certificate_url RLS fix + structured health fields + client filtering +
> the exchange-list editor + energy calculation + PDF export (6th, this one).
> Read `PLANNING.md` (Turkish, the full plan) and `CLAUDE.md` first, then this.
> Delete or rewrite this file once its contents have been acted on.

The product is now called **Wellkit**.

---

## 1. Where things actually stand

**Working and verified:**

- Supabase project `jpkvulcszsutacritttk` (eu-central-1, Frankfurt) with **three** migrations applied. `supabase migration list` shows local and remote in sync. Identity schema + RLS only — no other tables. Migration 3 closed the `certificate_url` leak (Q19): the `dietitians` table is owner-or-admin only, and `list_approved_dietitians()` is the marketplace projection.
- Flutter 3.47.2 monorepo (pub workspace + Melos 8). `dart run melos run analyze` clean, `dart run melos run test` green (**28** tests: core 4, client 3, dietitian_panel 21).
- **`docs/agents/*.md` + a `## Agent skills` block in `CLAUDE.md`** now exist (`mattpocock-skills` plugin's `setup-matt-pocock-skills`, 5th session): GitHub as the issue tracker, default triage labels, single-context domain docs. **`CONTEXT.md` now exists** (6th session) with the domain glossary — değişim listesi, the eight groups, BMH and activity factors, target vs planned — and marks every term that is still a hypothesis. No `docs/adr/` yet.
- **`demo_codec.dart`'s silent-drift risk is now partly test-enforced.** Two tests in `apps/dietitian_panel/test/demo_codec_test.dart` — an encode/decode symmetry check, and one that parses `demo_models.dart`'s actual field declarations at test time and asserts every field reaches the encoded JSON. Both were verified to actually fail on injected drift. See §7's updated trap entry — this doesn't remove the "update the codec by hand" step, it just makes forgetting loud instead of silent.
- Design system in `packages/core` — palette B, Fraunces + Figtree, two density profiles. Every color measured against WCAG. The two font faces ship as bundled assets (`packages/core/fonts/`), not a runtime fetch.
- **Both apps have real Supabase auth now** (PLANNING §12 steps 2–5, the whole first milestone). `packages/core/lib/src/auth/` holds the domain layer: `AuthRepository` + `ProfileRepository` interfaces, Supabase-backed implementations, in-memory fakes for tests, and `AuthGate` — the shared session/profile router. Sign up, sign in, sign out, role routing, and the reverse-app mismatch screen (§2.3 #39) all work end to end.
- `apps/client` is no longer a placeholder: login/signup ("sen" register) → a real 2-tab home (Ana Sayfa greets by name, two non-tappable "Yakında" cards; Profil has sign-out).
- `apps/dietitian_panel` now has **two separate entry points** — see "Run it" below. `lib/main.dart` is the real app: login/signup ("siz" register) → pending/rejected status card (no panel frame, §2.3 #52) or the approved shell (2-destination rail, honest "Henüz danışanınız yok" empty state, §2.3 #53). `lib/main_demo.dart` is the interview prototype — now **seven** tabs (Genel Bakış, Danışanlar, Randevular, **Mesajlar**, **Ödemeler**, Takip, Hatırlatmalar), fake data, `localStorage` persistence, reset button, no login. Mesajlar (in-app chat) and Ödemeler (commission ledger, rate is a placeholder — Open Question #1) were added in a fourth session so Can has something concrete to show and click through beyond auth; a "Görüşmeye başla" button on online appointments also opens a video-call mockup (no real SDK — §3 hasn't picked one). **The demo and the real panel still don't share screens** — the real approved panel is deliberately not the demo's rail.
- **Sixth session added to the demo:** structured health fields on the client record (allergies, conditions, medications, diet type, sex, activity level — displayed, not yet editable); search + goal/status filtering on the client list; a **second plan editor built on the exchange-list model** for c1 only, with editable counts and the substitution sheet; an **energy calculation** (`demo/energy.dart`) reproducing a dietitian's own spreadsheet, shown as a card on the client page and as a target line in both editors; and **PDF export** of an approved plan from either editor.
- Bundle id resolved: `com.wellkit.client` (Android `applicationId`/namespace, Kotlin package, iOS `PRODUCT_BUNDLE_IDENTIFIER`). The panel has no bundle id — it's web-only (§2.3 #38).
- Everything pushed to `github.com/yangull/DiyetApp` (private), `main` branch.

**Run it:**

```bash
# The real app, either one:
cd apps/client && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
  --dart-define-from-file=../../env/dev.json
cd apps/dietitian_panel && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081 \
  --dart-define-from-file=../../env/dev.json

# The interview demo (fake data, no login) — note the -t flag:
cd apps/dietitian_panel && flutter run -t lib/main_demo.dart -d web-server \
  --web-hostname 0.0.0.0 --web-port 8081 --dart-define-from-file=../../env/dev.json
```

Signing up for real creates a live Supabase user against the `jpkvulcszsutacritttk`
project — there is no local/staging split yet. A dietitian signup lands in
`verification_status = 'pending'` and stays on the status card until someone
flips it to `approved` from the Supabase dashboard (§2.2 #23, #35 — no in-app
admin panel yet, and the `authenticated` JWT structurally cannot approve itself).

**What the demo prototype is for** (`main_demo.dart`, unchanged from session 2):
Can drives it live, on his own screen, in discovery interviews with working
Turkish dietitians. Not a sales demo. Reload-safe, works offline, resets
cleanly between interviews.

---

## 2. The finding that matters most

A research pass on real dietitian software came back with one load-bearing result,
and it invalidates part of our data model. **Still unconfirmed — nothing in any
session since has changed this, the model was deliberately left alone.**

**Turkish dietitians do not write plans as "food + amount".** They use a
**değişim listesi** (exchange list) — the Turkish form of the ADA exchange system.
Foods are grouped into roughly eight groups:

> süt · et · nişastalı yiyecekler · kuru baklagil · A grubu sebze · B grubu sebze · meyve · yağ

Every food inside a group is calorie- and macro-equivalent **at its standard
household measure** — yemek kaşığı, çay bardağı, kibrit kutusu — not grams. A plan
specifies *how many exchanges from which group at which meal*; the specific food is
then chosen from a substitution list.

**What this breaks:** `MealItem { food, amount }` in
`apps/dietitian_panel/lib/demo/demo_models.dart` cannot represent it. The real
primitive is closer to `(exchangeGroup, exchangeCount)` per meal, plus a **separate,
reusable substitution table** shared across every plan rather than retyped per client.

**Do not rewrite the model on this alone.** It is research, not a dietitian's word.
Take it into the first interview as a hypothesis to confirm — "planı değişim
listesiyle mi kuruyorsunuz?" — and let the answer drive the schema. But expect it.
If you do change it, `demo_codec.dart` (the interview demo's persistence layer)
encodes `MealItem` explicitly and must be updated in lockstep, with
`_schemaVersion` bumped.

**Since 28 Aug 2026 the hypothesis is testable rather than askable.** The demo has
a second editor, `screens/exchange_plan_editor_screen.dart`, that builds Elif's day
(c1 only) as exchange counts per group with a live kcal total and a substitution
sheet in household measures. Reached from her client detail screen via "Değişim
listesiyle dene", next to the untouched freeform editor. Show both and let the
dietitian point at one.

Two things this does **not** mean: the model is not decided — `DietPlan` and
`ExchangePlan` both exist, deliberately, and the real one is still an open
question. And the numbers in `kExchangeKcal` / `kExchangeFoods`
(`demo/demo_models.dart`) are placeholders off the published ADA tables, labelled
"örnek" on screen so a dietitian corrects them instead of trusting them. Their
table is one of the things to collect.

Sources found: multiple Turkish dietitian sites plus the ADA "Exchange Lists for
Meal Planning" system.

**A second artifact, and this one is stronger evidence.** Can was shown a
dietitian's own energy-requirement spreadsheet: BMH per client (Harris-Benedict
for adults, WHO/FAO brackets for children, Cunningham where lean mass is known)
× a physical-activity factor of 1.2–1.6 = the daily calorie target. Every formula
was reverse-engineered from the cell values and now lives in `demo/energy.dart`,
verified against those cells in `test/energy_test.dart`.

Why this matters beyond the arithmetic: **the plan's calorie target used to be a
number the dietitian typed in, with no derivation and no relationship to the
meals below it.** Now the target is derived from the client, and the exchange
editor shows it next to what the plan actually adds up to. The freeform editor
cannot do that — its rows carry no calorie data — which is the sharpest concrete
difference between the two models, and worth watching for in the interview.

⚠️ Ask where this sheet came from before treating it as settled practice. If it
is one dietitian's, it is one dietitian's.

---

## 3. The other research finding — and it conflicts with a locked decision

**Every Turkish dietitian tool surveyed routes reminders and confirmations through
WhatsApp.** DiyetBulut advertises WhatsApp integration directly, alongside e-Nabız
(national health record) transmission, digital consent forms, and commission
calculation.

Our locked decision §2 #2 says **all communication stays in-app**, to protect
commission revenue. That decision is sound for the business model, but the entire
competitive set does the opposite because that is where danışans already are.

**This is a real adoption friction point, not a hypothetical.** Ask dietitians about
it directly in the interviews. Do not relitigate the decision without Can.

Other market context: international tools (Nutrium, Practice Better, Healthie,
Kahunas) treat client portal + mobile app, scheduling, billing, secure messaging and
intake forms as table stakes. Notably, **none of them treats the meal-plan builder as
solved** — Practice Better users bolt on a separate tool, Healthie de-prioritises it.
That is a signal that the plan editor is where a product can still win.

⚠️ The research agent could **not** confirm "NippyOS" as a findable product, though
Can has seen it directly. Treat that name as unverified in writing.

---

## 4. What was in flight when the first session ended

A **critique of the panel prototype** was commissioned and died to a session limit
before producing anything. Still not re-run. It was to cover:

1. Screen-by-screen critique, judged both as a dietitian with 40 clients and as
   software that has to ship
2. Competitor feature comparison (partially delivered — see §3 above)
3. What a diet plan really contains (partially delivered — see §2 above)
4. Information architecture: what belongs in the rail at launch, and how it survives
   chat, video, payments and the marketplace profile arriving
5. Ranked add / remove / defer lists — including an honest assessment of whether
   appointments and payment tracking belong in a commission marketplace at all, or
   quietly turn this into practice-management SaaS with a different revenue model
6. Pre-deployment gaps under KVKK
7. Which screens to lead interviews with, and where the prototype might mislead a
   dietitian into agreeing with something that is not built

**Items 1, 4, 5, 6 and 7 were never delivered.** Re-run that critique next session if
still wanted — but the interviews themselves may answer more of it than an agent can.

The second session did fix one thing item 7 would have flagged: `MacroSummary`
was drawing progress bars from hardcoded fill constants (identical for every
client) under a caption claiming a percentage of a target that did not exist in
the data. That was prototype dishonesty a dietitian could mistake for a real
feature — gone now (commit `c47532e`).

---

## 5. Next steps, in the order I would do them

1. **Run the dietitian interviews.** Nothing built since changes this — Q3, Q4,
   Q10 and the exchange-list hypothesis all resolve here, and the plan editor
   and real client management are guesswork until they do.
2. **Rewrite the plan model** on what you learn. Expect exchange groups.
3. **Build Faz 1's schema and screens** once the model is known: a
   dietitian-client relationship table, `diet_plans`, and the real plan editor
   in `apps/dietitian_panel`'s approved shell (`lib/panel/real_panel_shell.dart`
   currently just shows an empty state on Genel Bakış — that's where the
   client list goes).
4. **`apps/client`'s two path cards are still "Yakında".** Faz 1 turns them
   into real marketplace/AI entry points (§2.3 #51).

> **Note (3rd session, 28 Aug 2026):** Can chose to build real auth (steps
> 2–5 of PLANNING §12) now rather than wait for the interviews, since that
> work doesn't depend on the plan-model question. It's done — see PLANNING
> §2.8. What's still genuinely gated on the interviews is everything Faz 1:
> the plan editor, client management, and the schema that supports them.

---

## 6. Open decisions that block work

| # | Decision | Why it blocks |
|---|---|---|
| **Q10 — Kutay's Excel** | Nobody has seen a real diet plan | The plan editor is guesswork until then |
| **Q3 / Q4** | Doctor referral rules; which blood values | Regulatory; riskiest unknown in the product |
| ~~**Q19**~~ | ~~Which dietitian fields are public in the marketplace~~ | **Closed 28 Aug 2026, migration 3.** The base table is owner-or-admin only now; `list_approved_dietitians()` returns `user_id`, `specialties`, `bio` and nothing else. Adding a column to that function is a publication decision — treat it as one. |
| **Q15 / SMS** | Reminders over push (free, needs app installed) vs SMS (paid, works for everyone) | The reminder features are built but the channel is unresolved. Ask dietitians. |
| **Logo / icon** | Name is settled, visual identity is not | Store listing, app icon, favicon |

---

## 7. Traps for whoever picks this up

- **Don't design the plan editor from imagination.** See §2. It is the screen that
  decides whether dietitians abandon Excel.
- **Don't copy the `dietitians` RLS policy shape onto any table holding client health
  data.** PLANNING §2.2 #34 explains why; a review already caught one leak of this
  exact kind.
- **`ColorScheme.fromSeed` will silently discard the measured palette.** The theme
  sets every slot explicitly on purpose — see `packages/core/lib/src/theme/app_theme.dart`.
- **`flutter devices` never lists the `web-server` device in this WSL setup**, but
  `-d web-server` works. Don't waste time on it.
- **Fonts are bundled, not fetched.** `google_fonts` is gone from
  `packages/core/pubspec.yaml`; `app_typography.dart` builds `TextStyle`s against
  the asset families directly (`package: 'core'`). A core test asserts the
  resolved font family to catch a regression.
- **`apps/dietitian_panel` has two entry points that must stay separate.**
  `lib/main.dart` (real, auth-gated) and `lib/main_demo.dart` (interview demo,
  fake data, no login). Don't merge them, and don't wire real Supabase data
  into `PanelShell` — that widget exists specifically to be safe to drive live
  in front of a dietitian without a network dependency mid-conversation.
- **`AuthGate` (in `packages/core`) decides session/loading/error/role-mismatch;
  it deliberately does not decide which screen a `pending` vs `approved`
  dietitian sees** — that branch lives in each app's own `authenticatedBuilder`.
  Don't push app-specific screen logic into `AuthGate` itself.
- **`FakeAuthRepository.sessionChanges` replays the current session to every
  new listener** (`yield _session; yield* _controller.stream;`), matching what
  Supabase's real `onAuthStateChange` does on subscribe. If you write a test
  that calls `signIn()` before building the widget tree, this is why the
  session isn't just silently lost — but if you ever "simplify" it to a bare
  broadcast stream, every such test will start failing for a non-obvious reason.
- **The demo panel's persistence has a schema version.** `demo_codec.dart` encodes
  every field of `DemoState` by hand and checks `_schemaVersion` on decode; an
  unreadable or old-version stored state is discarded, not partially read. If you
  add or change a field on any demo model, update the codec and bump the version
  in the same change, or old browser storage will silently fall back to seed data
  (safe, but confusing to debug if you don't expect it). **This is now caught by a
  test, not just this paragraph**: `demo_codec_test.dart`'s "every demo model field
  reaches the encoded JSON" test parses `demo_models.dart` at test time and fails
  loudly, naming the exact missing field, if you add one and forget the codec.
  It does not catch a forgotten `_schemaVersion` bump on its own — that's still on
  you. (Also don't bother colocating `toJson`/`fromJson` on the models to "fix"
  this — a 5th-session review already checked: Dart's required constructor params
  already make the compiler catch most decode-side drift, so colocation buys
  proximity, not enforcement, while spreading the field list across three files
  instead of two. The two tests above close the actual gap — optional fields and
  the encode side — for less code.)
- **PDF export is gated on approval, and that gate is load-bearing.** The
  button in `widgets/export_plan_button.dart` is disabled while a plan is an
  AI draft. A PDF is the one artifact that leaves the panel and reaches a
  client, so locked decision §2 #1 is enforced there as well as in the UI that
  renders the draft. Don't "simplify" it to always-enabled.
- **The energy formulas are pinned to a real dietitian's spreadsheet, not to a
  textbook.** `demo/energy.dart` uses the *original 1919* Harris-Benedict
  constants because that is what the sheet Can was given uses; the published
  "revised" variant gives a different answer and `test/energy_test.dart` will
  fail if someone swaps it in. That failure is the point. The sheet also had
  WHO/FAO child brackets and the Cunningham formula, both decoded and recorded
  in PLANNING §2.11 #95 but deliberately not implemented — children because the
  demo has none, Cunningham because it needs lean body mass we don't measure.
- **The exchange reference tables are `const`, not state.** `kExchangeKcal`,
  `kExchangeFoods` and `kExchangeGroupLabels` in `demo/demo_models.dart` sit
  outside `DemoState` on purpose: nothing edits them, so they stay out of the
  codec and out of the completeness test. The moment a dietitian is allowed to
  edit their own substitution list — which is a plausible interview outcome, it's
  their professional signature — they become state and need all three.
- **`demo_store.dart` conditionally imports a web vs stub implementation** via
  `dart.library.js_interop` — this is what lets `flutter test` run on the VM
  without a browser. Don't collapse it into one file.
- **`Supabase.initialize` takes `publishableKey:`, not `anonKey:`** — the
  latter is deprecated in `supabase_flutter` 2.17 and `dart analyze
  --fatal-infos` will fail the build on it.
- **Melos config lives under the `melos:` key in the root `pubspec.yaml`**, not in a
  `melos.yaml`, and scripts must call `dart run melos`, not bare `melos`.
- **`docs/agents/*.md` is now real config, not boilerplate.** `setup-matt-pocock-skills`
  already ran (5th session) — don't re-run it unless you actually want to switch issue
  trackers or reset it; re-running is safe but pointless otherwise. If a `mattpocock-skills`
  command asks where issues/domain docs live, the answer is already written down there.
