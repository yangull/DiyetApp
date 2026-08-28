# HANDOFF — pick up here

> Written 28 August 2026; updated same day after a second session that
> finished the panel prototype and bundled the fonts.
> Read `PLANNING.md` (Turkish, the full plan) and `CLAUDE.md` first, then this.
> Delete or rewrite this file once its contents have been acted on.

The product is now called **Wellkit**.

---

## 1. Where things actually stand

**Working and verified:**

- Supabase project `jpkvulcszsutacritttk` (eu-central-1, Frankfurt) with two migrations applied. `supabase migration list` shows local and remote in sync. Identity schema + RLS only — no other tables.
- Flutter 3.47.2 monorepo (pub workspace + Melos 8). `dart run melos run analyze` clean, `dart run melos run test` green (9 tests: core 4, client 1, dietitian_panel 4).
- Design system in `packages/core` — palette B, Fraunces + Figtree, two density profiles. Every color measured against WCAG. The two font faces now ship as **bundled assets** (`packages/core/fonts/`), not a runtime fetch — see §7 for what that changes.
- `apps/dietitian_panel` — a working discovery prototype, **now with real state**. Five rail destinations: Genel Bakış, Danışanlar, Randevular, Takip, Hatırlatmalar. Plus client detail and the plan editor. Every mutation persists to `localStorage` and survives a page reload; a reset button on the rail (with confirmation) returns to the seed data between interviews. Client detail's measurement-history card is finished — real weight chart, last four readings, honest "display only" note. Appointment dates are seeded relative to `DateTime.now()`, so the demo stays coherent whenever the interview actually happens.
- `apps/client` — still a themed placeholder. Nothing real.
- Everything pushed to `github.com/yangull/DiyetApp` (private), `main` branch.

**Run it:**

```bash
cd apps/dietitian_panel
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081 \
  --dart-define-from-file=../../env/dev.json
```

**What the prototype is for:** Can drives it live, on his own screen, in discovery
interviews with working Turkish dietitians. The goal is learning their workflow —
above all what is actually in a diet plan. It is not a sales demo. **It is now
resilient enough to actually run in front of someone** — it survives a refresh,
works offline (fonts bundled), and resets cleanly between interviews.

---

## 2. The finding that matters most

A research pass on real dietitian software came back with one load-bearing result,
and it invalidates part of our data model. **Still unconfirmed — nothing below
has changed this session, the model was deliberately left alone.**

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
**Note for whoever touches the model next:** if you do change `MealItem`, the demo
persistence layer added this session (`demo_codec.dart`) encodes it explicitly and
must be updated in lockstep, with `_schemaVersion` bumped — see §7.

Sources found: multiple Turkish dietitian sites plus the ADA "Exchange Lists for
Meal Planning" system.

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
the data. That was exactly the kind of prototype dishonesty a dietitian could
mistake for a real feature — it is gone now, see the commit
`c47532e`.

---

## 5. Next steps, in the order I would do them

1. **Run the dietitian interviews.** The prototype is ready and now reload-safe.
   This unblocks more open questions than any amount of building — Q3, Q4, Q10 and
   the exchange-list hypothesis all resolve here.
2. **Rewrite the plan model** on what you learn. Expect exchange groups. Remember
   to update `demo_codec.dart` and bump its schema version if you touch `MealItem`
   before the real Supabase schema exists.
3. **Decide the bundle id** (see §6) — needed before any store upload, and cheap now.
4. **Build `packages/core`'s domain layer** (PLANNING §12 step 2): models,
   repository interfaces, in-memory fakes. It is still empty — theme and config
   only. Everything after this step depends on it, and the panel's `demo/` layer
   is a dead end that gets replaced once this exists.
5. **Real auth** (PLANNING §12 steps 3–4) — the schema and RLS are ready and waiting.
6. **`apps/client` is still a placeholder.** If clients are ever shown the app, it
   needs the five screens designed in PLANNING §2.3 (decisions 50–53).

---

## 6. Open decisions that block work

| # | Decision | Why it blocks |
|---|---|---|
| **Bundle id** | `com.dietapp` is still the placeholder. Now that the name is Wellkit — `com.wellkit`? `com.wellkit.app`? A domain you own? | Must be final before the first TestFlight/Play upload; changing it after is painful. Touches `android/`, `ios/`, and both `build.gradle.kts` / `project.pbxproj`. |
| **Q10 — Kutay's Excel** | Nobody has seen a real diet plan | The plan editor is guesswork until then |
| **Q3 / Q4** | Doctor referral rules; which blood values | Regulatory; riskiest unknown in the product |
| **Q19** | Which dietitian fields are public in the marketplace | `dietitians.certificate_url` currently leaks to every signed-in user. **Must be fixed before the first dietitian is approved.** Still unresolved. |
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
- **Fonts are bundled now, not fetched.** `google_fonts` is gone from
  `packages/core/pubspec.yaml`; `app_typography.dart` builds `TextStyle`s against
  the asset families directly (`package: 'core'`). Don't reintroduce
  `google_fonts` — a core test asserts the resolved font family specifically to
  catch that.
- **The demo panel's persistence has a schema version.** `demo_codec.dart` encodes
  every field of `DemoState` by hand and checks `_schemaVersion` on decode; an
  unreadable or old-version stored state is discarded, not partially read. If you
  add or change a field on any demo model, update the codec and bump the version
  in the same change, or old browser storage will silently fall back to seed data
  (safe, but confusing to debug if you don't expect it).
- **`demo_store.dart` conditionally imports a web vs stub implementation** via
  `dart.library.js_interop` — this is what lets `flutter test` run on the VM
  without a browser. Don't collapse it into one file.
- **Melos config lives under the `melos:` key in the root `pubspec.yaml`**, not in a
  `melos.yaml`, and scripts must call `dart run melos`, not bare `melos`.
