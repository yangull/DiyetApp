# Wellkit — Plan and Locked Decisions

> What is true **now**: the product, the decisions that hold, what is built, what is
> open. Not a session log — history lives in git (`git log -p PLANNING.md`).
> Edit this file when a decision changes; rewrite a section rather than appending one.
>
> **Decision IDs are stable.** Product decisions are P1–P5; technical decisions keep
> their original numbers (#1–#130). Code comments cite them as `PLANNING.md #N` (older
> comments say `§2 #1` for P1). Never renumber; a retired ID stays unused.
>
> Last restructured: 23 September 2026.

---

## 1. Product

A two-sided dietitian marketplace for Turkey, named **Wellkit**.

- **Dietitians** get a management panel, marketplace visibility and new clients.
- **Clients (danışan)** get affordable dietitian access, or an AI-only diet plan tier.

**The main promise to the first dietitians is bringing them new clients** (confirmed by
Can, 21 Sep 2026). Managing existing clients is a supporting capability.

**How clients arrive** (Can, 23 Sep 2026; the general plan with Kadir, not final): mainly
**B2B corporate deals**, plus Wellkit's own digital ads. Dietitians can also bring their
existing clients. Clients find a dietitian in a **"Diyetisyen bul"** section of the
client app; first contact is online. There is no limit on clients per dietitian (the
usual load is 30–40). Where B2B sits in the roadmap is QUESTIONS.md C4.

**Money:** deferred, see P6. Commission, packages, pricing and payouts are all decided
later.

**Awaiting Can's confirmation** (QUESTIONS.md §0): the client flow (I6), the dietitian
types to serve (I7), blood-test handling (I8), meal-time notifications (I10), the AI
chatbot (I11) and "cheap and accessible" (I15).

---

## 2. Locked product decisions

P1, P2, P3 and P5 are awaiting re-confirmation (QUESTIONS.md §0, I1–I4).

Everything dated 23 Sep 2026 in this file is Can's first answer after speaking with
Kadir and is **open to correction**: QUESTIONS.md "Answered on 23 Sep" lists each one
with a way to reopen it.

- **P1** **AI drafts, the dietitian approves.** On the human-service side a client never sees
  an AI plan no dietitian has approved.
- **P2** **All communication stays in-app** (chat + embedded video). Confirmed by Can on
  23 Sep 2026 without the commission (was C5): the reasons now are one record of the
  client's care, quality control, KVKK (health data stays in the EU project, not on
  WhatsApp) and the reporting B2B needs. ⚠️ Every Turkish competitor uses WhatsApp for
  reminders — a real adoption friction to watch in interviews.
- **P3** **Build order:** shared core → dietitian marketplace → AI-only tier.
- **P4** **The exchange list is the default plan model; freeform stays as an option**
  (Can, 23 Sep 2026, was C1: "Değişim listesi (sonra değişebilir), iki seçenekte
  kalsın"). Both editors exist in the demo (#93, #97). Reversible if the interviews
  (DT2) disagree. `diet_plans` and the real plan editor are unblocked.
- **P5** **No per-dietitian-type screens.** One general management panel; fields may vary.
- **P6** **No money in the app at launch** (Can, 23 Sep 2026). Clients pay their dietitian
  directly, outside Wellkit (bank transfer or a Turkish payment app). Wellkit takes no
  commission and runs no payments until the money model is decided; every money question
  is parked (QUESTIONS.md §5). P2 was kept with new reasons.

### 2.1 What the dietitian interviews said

Interviews happened before 23 Sep 2026; Can relayed the answers that day (QUESTIONS.md
C2). Each ID names the interview question it came from.

- **#121** **Both plan models are used, depending on the client** (DT2), which confirms P4:
  the exchange list is the default and freeform stays.
- **#122** **One standard exchange table**, shipped by Wellkit, not one per dietitian (DT3).
  Which published table, and its values, is still to name; today's `kExchangeKcal` holds
  example ADA values (#97).
- **#123** **Plans are weekly and mostly copied** from a template or an earlier plan (DT4,
  DT5). Old plans are archived; the client sees only the current one. The real editor
  needs "start from a template / last week", not just a blank page.
- **#124** **Energy formulas in use:** Harris-Benedict (the default, #95), Mifflin-St Jeor,
  Cunningham (with a BIA device) and WHO/FAO for children (DT6). The last three are to
  be added as choices.
- **#125** **No blood-test section** (Can, for KVKK reasons). Instead, **the client and the
  dietitian can both attach any file** to the shared record (DT9). Files are health data:
  a private bucket in the EU project, readable only through the relationship.
- **#126** **Before approving an AI draft the dietitian sees** why it chose what it did,
  its totals against the client's target, and a check that allergies, illnesses and
  medications were respected (DT12). Extends P1.
- **#127** **Reminders are app push notifications only**, no SMS (DT13).
- **#128** **The client list needs** plan status, last contact or weigh-in, next
  appointment, and goal and weight (DT11).
- **#129** **Ratings: stars only, no comments at launch** (DT14; matches Can's note in C8).
- **#130** Dietitians use **Excel/Word and WhatsApp** today (DT1), have **no objection to
  moving existing clients** into the app (DT16), and are drawn by the plan editor with
  AI drafts, client tracking, and appointments with reminders (DT15). Company clients
  differ in **pricing and in how they register**: B2B needs bulk enrolment (DT17, C4).
- **Default until DT8 is answered:** measurements are weight, waist and hip, with fat %
  and muscle mass as optional BIA fields (today's demo card). Reversible.

---

## 3. Locked technical decisions

### 3.1 Environment and repo

- **#1** Flutter stable installed inside WSL2; no FVM yet (Codemagic pins its own version).
- **#2** Daily development is **web-first**: `flutter run -d web-server`, opened from the
  Windows browser.
- **#3** The Android emulator + adb bridge on Windows is an **early Phase 1 slice** — Chrome
  hides mobile-specific problems.
- **#4** Dart **pub workspace** + **Melos 8**. Melos config lives under the `melos:` key in the
  root `pubspec.yaml` (Melos 8 ignores `melos.yaml` in a pub workspace); scripts run as
  `dart run melos`.
- **#5** Melos scripts: `analyze` (`--fatal-infos`), `format` (writes files), `test`.
- **#6** Lints: `flutter_lints`, shared from the workspace root.
- **#7** `apps/client` targets android, ios, web. **Web is for development only**; whether it
  ships is Q13. RevenueCat/IAP and the video SDK may not work on web.
- **#8** `apps/dietitian_panel` targets **web, iOS and Android** (#38).
- **#9** `packages/core` is the shared package: models, auth, Supabase client, theme.
- **#11** Package names: `client`, `dietitian_panel`, `core`.
- **#14** Typed `AppConfig` reads compile-time values via `--dart-define-from-file`. Real values
  in gitignored `env/dev.json`; the template `env/dev.example.json` is committed.
- **#15** The publishable key is public by design; **Row Level Security** is what protects
  data; the `service_role` key never appears client-side.
- **#18** Both apps import theme and config from `core`.
- **#19** Private GitHub repo `yangull/DiyetApp`. It was public by mistake until 23 Sep 2026;
  no secrets were ever committed. Ask Can before pushing.
- **Bundle id:** `com.wellkit.client` (Android applicationId/namespace, Kotlin package,
  iOS `PRODUCT_BUNDLE_IDENTIFIER`). The panel has none yet; it needs its own before its
  first store build (#38).
- **No Mac:** iOS builds go through **Codemagic** (cloud CI).
- **Agent skills** (#85): mattpocock-skills configured. **GitHub Issues is the tracker**
  (confirmed 23 Sep 2026); triage and `wayfinder:*` labels exist on the repo. Domain
  docs are single-context (`CONTEXT.md`, `docs/adr/`).

### 3.2 Data and security

- **#20** **Email + password only.** Phone/SMS OTP needs a paid SMS provider — deferred (Q15).
- **#21** Email confirmation is **off in development**. ⚠️ Conflicts with #102 — see QUESTIONS.md X1.
- **#22** State management: **Riverpod**, hand-written providers, **no codegen** (#46).
- **#23** The `admin` role is never created in-app; it is assigned in the Supabase dashboard.
- **#24** SQL identifiers are **English**; Turkish only in UI text.
- **#25** P1 is enforced by an **RLS policy**, not only in app code — on `diet_plans` in Phase 1.
- **#26** Schema is managed with the **Supabase CLI** (`migration new` + `db push`) against the
  EU cloud project. No local Docker stack.
- **#27** Schema is **never** created from the dashboard UI — every change is a migration file.
- **#31** Role lives in `public.profiles.role` (`client|dietitian|admin`), created by a signup
  trigger on `auth.users`. No custom JWT claim; policies read it through
  `security definer` helpers.
- **#32** Role is **single and immutable**, enforced three ways: (a) `UPDATE` is granted only on
  harmless `profiles` columns; (b) `dietitians`/`clients` have a composite FK to
  `profiles(id, role)`; (c) the signup trigger accepts only `dietitian` from client
  metadata and turns everything else (a fake `admin` too) into `client`.
- **#34** **No dietitian reads client health data** except through an explicit relationship
  policy (#100). ⚠️ Never copy the `dietitians`-style "authenticated can read" policy
  onto a table holding client data.
- **#35** A dietitian **cannot approve themselves**: `verification_status` is not granted to
  `authenticated`. Approval happens in the dashboard or via `service_role`.
- **#90** **Publish through projection functions, not row policies.** RLS filters rows, not
  columns. Anything other users may see is returned by a `security definer` function
  whose return type lists exactly the public columns — `list_approved_dietitians()`
  (`user_id`, `specialties`, `bio`) and `list_my_clients()`. The base tables are
  owner-or-admin only. **Adding a column to such a function is a publication
  decision**, not a refactor.
- **Grants are explicit** (from the migration 1 security review, fixed in migration 2):
  no phone column (it could not be hidden per-column and contradicted P2); no
  `TRUNCATE` for `authenticated` (RLS does not apply to it); RLS helper functions are
  `EXECUTE`-able by `authenticated` only, never `PUBLIC`/`anon`; every
  `security definer` function sets `search_path = ''`; policies use
  `(select auth.uid())`.

### 3.3 Relationships (migration 4)

- **#100** A dietitian reads a `clients` row only with an **active relationship and while still
  approved** — a dietitian whose approval is revoked loses access to old matches.
- **#101** **Connection is by email invite** for now: the dietitian invites, the client accepts
  or declines in the client app. Marketplace matching replaces it; the `origin` column
  (`dietitian_invite`, later `client_request`) exists so old rows need no
  reinterpretation.
- **#102** Accept/decline policies compare `invited_email` to the **JWT `email` claim**. This is
  only safe while email confirmation is on (QUESTIONS.md X1).
- **#103** Client names reach the panel through `list_my_clients()`, not a SELECT policy on
  `profiles` (#90).
- **#104** The client app's "Hedeflerim" form (goal / budget / health note) is the **only
  writer** of those `clients` columns. Replace it, don't just remove it.
- **#105** The invite card names the **inviting dietitian** — the client is granting access to
  their health data and must see who asks (KVKK explicit-consent logic).
- **#106** Out of scope so far, deliberately: ending a relationship, structured health fields on
  `clients`, actually sending the invite email (Edge Function + `inviteUserByEmail`).

### 3.4 Auth and screens

- **#37** **No role-selection screen.** The role comes from the app used to sign up: the mobile
  app always creates `client`; the web panel sends `role: dietitian`.
- **#38** **The dietitian panel runs on web, phones and tablets** (Can, 23 Sep 2026; it was
  web only). One Flutter codebase with layouts by width: wide screens keep the rail and
  tables, phones get a bottom bar and stacked screens. Default: phones use the
  comfortable density (touch-sized controls), wide screens the compact one (#64).
  **Two store apps:** the client app and a separate dietitian app; the app you sign up
  in still sets your role (#37).
- **#39** Wrong-app sign-ins (dietitian in the client app, client in the panel) get a
  full-screen message + sign-out. No automatic logout.
- **#40** Admin sees a single card in MVP; approvals happen in the dashboard (a consequence of #35).
- **#41** Signup fields: email, password, full name.
- **#42** Password minimum **8 characters**, no complexity rules.
- **#43** **No password reset yet** — it needs custom SMTP, which arrives with email
  confirmation before launch.
- **#44** Auth error messages stay **English** (as Supabase returns them) until l10n (Q12).
- **#45** **`AuthGate`** in `core` routes on session + `profiles.role` + verification status,
  with real loading and error states.
- **#73** `core/lib/src/auth/`: `AuthRepository` + `ProfileRepository` interfaces, Supabase
  implementations, in-memory fakes for tests.
- **#74** `AuthGate` decides session / loading / error / wrong-app. It does **not** decide which
  screen a `pending` vs `approved` dietitian sees — that stays in each app's
  `authenticatedBuilder`.
- **#75** Riverpod providers default to the Supabase implementations; tests swap in fakes via
  `ProviderScope(overrides: …)`.
- **#47** **The app is in Turkish.** All UI text.
- **#48** Register: informal **"sen"** in the client app, formal **"siz"** in the panel.
- **#120** **Buttons use the short form** ("Kaydet", "Vazgeç", "İptal et", "Giriş yap"), as
  most Turkish apps do; sentences in the panel stay in "siz" (Can, 23 Sep 2026, was C19).
- **#49** The word is **"danışan"**, never "müşteri".
- **#50** **Everything visible is real data or a real action.** Unbuilt things are named once
  with a "Yakında" label, never drawn as clickable fake UI.
- **#51** Client home: 2 tabs (Ana Sayfa, Profil), greeting by name, two non-tappable path cards
  (dietitian / AI). In Phase 1 they become the marketplace and AI entry points.
- **#52** A pending dietitian sees one card **without the panel frame** ("Başvurunuz
  İnceleniyor" + a working "Durumu yenile"). `rejected` uses the same layout.
- **#53** An approved dietitian gets a **NavigationRail** with only destinations that have real
  content (today: Genel Bakış with the client list, and Profil). No empty rail
  destinations in advance.
- **#108** A screen that exists but cannot be reached in one click from the home screen is
  effectively missing — reachability is part of done.

### 3.5 Design system

Full reference, including type scale, density numbers and the design rules:
**`docs/design-system.md`** (the source; the 28 Aug artifact is history).

- **#54** Palette **B "Serin"**: background `#F7F9F8`, surface `#FFFFFF`, brand `#18795C`.
- **#55** **One brand hue.** Every non-green colour carries a meaning (waiting / error / AI
  draft); no decorative second accent.
- **#56** **No separate `success` colour** — it measured 1.19:1 against brand green. Approved
  states use brand green.
- **#57** **An AI draft has its own visual state:** violet `#514196` + 1.5px dashed border + a
  text label. Violet is used nowhere else. Colour never carries meaning alone.
- **#58** Every value is **measured**: WCAG AA 4.5:1 for text, 3:1 for interactive boundaries.
  Ratios are written next to each token in `app_colors.dart`. **Don't change a value
  without re-measuring.**
- **#59** **Light theme only** for now; the dark palette is measured and documented, not coded.
- **#60** **Fraunces** (headings only) + **Figtree** (body, UI, tables, buttons).
- **#61** Turkish glyph coverage verified from the font files' `cmap` tables.
- **#63** Fonts are **bundled assets** in `packages/core/fonts/`; no `google_fonts` runtime fetch.
  A core test asserts the resolved family.
- **#64** One token set, two density profiles: `AppDensity.comfortable` (client),
  `AppDensity.compact` (panel). Only spacing, radius, control and line height differ.
- **#65** **No `ColorScheme.fromSeed`** — it discards the measured palette. Every slot is set
  explicitly.
- **#66** Non-Material tokens travel as `AppPalette` / `AppDensity` ThemeExtensions
  (`context.palette`, `context.density`).
- **#67** The design rules in `docs/design-system.md` apply to every screen (14 since 23 Sep
  2026: no gradients, no emoji icons, no "✨ AI" badges, no mixed radii, labelled and
  confirmed actions, no money while P6 holds, …).

### 3.6 The interview demo

The panel has a second entry point, `lib/main_demo.dart`: an unauthenticated prototype
on fake data, which Can drives live in discovery interviews. **Not a sales demo** — it
is built to be corrected, not admired.

- **#78** **Two entry points that stay separate.** `lib/main.dart` is the real auth-gated app;
  `lib/main_demo.dart` is the demo. Don't merge them and don't wire real Supabase data
  into `PanelShell` — it must work offline mid-interview.
- **#68** Demo state persists to `localStorage` through `demo_codec.dart`, with a schema
  version inside the JSON (key `wellkit.demo`, no version in the key, #99). Unreadable
  or old-version state falls back to seed data rather than being partially read. A
  reset button sits under the rail; it also remounts the demo screens, so their own state
  (filters, message drafts, the open conversation) goes too.
- **#71** Seed data is anchored to `DateTime.now()`, never to a calendar date.
- **#89** Codec drift is caught by **tests, not codegen or colocated `toJson`**: a symmetry test
  and a completeness test that parses `demo_models.dart` at test time. (A review showed
  required constructor params already make decode drift a compile error; colocation
  would only spread the field list across more files.)
- **#93** The exchange-list editor exists for client c1 only, next to the untouched freeform
  editor, reached via "Değişim listesiyle dene". Counts are editable; kcal is derived.
- **#97** `kExchangeKcal` / `kExchangeFoods` are **example** ADA values, labelled "örnek" on
  screen. They are `const` outside `DemoState`; if dietitians may edit their own
  substitution list, they become state.
- **#95** Energy: **Harris-Benedict × activity factor is our default formula** (Can, 23 Sep
  2026: one of the main ones dietitians use; others can be added later, DT6). **Original 1919 Harris-Benedict** × activity factor 1.2–1.6 (five levels),
  reverse-engineered from a dietitian's spreadsheet and tested against its cells.
  WHO/FAO child brackets and Cunningham (`500 + 22 × lean mass`) are decoded but not
  implemented — no children in the demo, no lean-mass measurement.
- **#96** The calculated target sits **beside** the typed kcal field, not in place of it. A
  dietitian constantly overriding it is a signal the formula is wrong.
- **#98** **PDF export only for approved plans.** The PDF is the one artifact that leaves the
  panel for a client, so P1 is enforced there too.
- **#109** **No 7-day plan grid in the demo.** The grid assumed the food + amount model; the
  real editor is weekly and exchange-list first (P4, #123) and gets its own layout.
- **#110** Triage ("Dikkat gerekenler"): 7 days without a weigh-in, 24 h unanswered message, a
  no-show. Thresholds are named constants labelled on screen as our guess (Q25).
- **#111** The anamnez form's lower nine questions are **invented** and stored as text in
  `note` — made to be marked up by a dietitian (Q26).
- **#112** Progress direction comes from target weight vs starting weight; no target weight,
  no judgement.
- **#113** Body measurements (waist, hip, WHR, fat %, muscle mass) exist for three of five
  clients; which ones dietitians really take is Q27.
- **#114** `noShow` is distinct from `cancelled`; a no-show is currently not billed (Q28).
- **#118** The TR/EN panel walkthrough artifact is framed as a draft to argue with; invented,
  placeholder and example values are labelled as such.
- **#119** **The UI review (`docs/research/2026-09-23-ui-review.md`) is worked in order**
  (Can, 23 Sep 2026, was C18). Done 23 Sep: its nine bugs plus #8 (triage links open the
  task), #11 (weight chart spaced by date) and #15 (reminder settings moved off the
  rail). Next: #10, together with putting both plan editors in the same layout so
  dietitians compare the model, not the page. After the interviews: #12 (compact Takip).
  When the real client list grows: #9 (search and filter). Codex's follow-up
  (`docs/research/2026-09-23-c18-c19-follow-up-review.md`) found two reset gaps, fixed
  the same day (#68).

---

## 4. Tech stack

| Layer | Choice | Note |
|---|---|---|
| Client app | Flutter (iOS + Android) | |
| Dietitian panel | Flutter (web, iOS, Android) | Shared `core` package; its own store app |
| Backend | Supabase, EU (eu-central-1) | Auth, Postgres, Storage, Realtime. EU for KVKK — EU hosting alone is not KVKK compliance |
| AI calls | Supabase Edge Functions | LLM keys never in the client |
| Payment, human service | **None at launch (P6)** | Clients pay dietitians directly. iyzico was the earlier choice for a commission marketplace; revisit with the money model |
| Payment, AI tier | RevenueCat + in-app purchase | Apple/Google requirement |
| Video | Embedded SDK, not chosen | Agora / 100ms / Daily (Q5) |

---

## 5. Current state (23 Sep 2026)

| Area | State |
|---|---|
| Monorepo, tooling | Done. Analyzer clean, all tests green. No CI yet. |
| Supabase | Project `jpkvulcszsutacritttk`, 4 migrations applied: identity + RLS, grant tightening, dietitian public projection, relationships. One shared project — no dev/prod split. |
| Auth | Real in both apps: sign up / in / out, role routing, wrong-app screen, pending/approved dietitian. No password reset, no email sending. |
| Client app | Login → 2-tab home, pending-invite card (accept/decline), "Hedeflerim" form. |
| Real panel | Client list with pending invites, invite dialog, client detail (goal / budget / health note only). |
| Interview demo | 6 rail tabs on fake data (overview + triage, clients, appointments, messages, payments, tracking) and "Hatırlatma ayarları" at the bottom of the rail; both plan editors, energy card, PDF export, anamnez form, measurements. Every money screen (Ödemeler tab, "Tahsil edilmemiş" figures, payment reminder) is hidden behind `kShowMoney = false` (P6). |
| Marketplace | **Nothing real yet** — no public profile, "Diyetisyen bul" section or request/accept flow. |
| Brand | Name and palette settled. **Logo: placeholder "W" mark** until one is designed with Claude later. |
| Plan editor, `diet_plans` | Not built. Unblocked: exchange list first, weekly, from templates (P4, #121–#123). |
| Interviews | Held; most answers in §2.1, five questions still open (QUESTIONS.md §3). |

---

## 6. Roadmap

**Phase 0 — Shared core: done.** Monorepo, EU Supabase project, email/password auth, roles,
profile models, both apps at "login → first screen".

**Phase 1 — Dietitian marketplace (human service)**
- [ ] Dietitian onboarding + verification (diploma/document upload)
- [~] Client onboarding: goal, health info, optional blood values, budget — goal/budget/
      health-note form exists; structured health fields and blood values don't
- [ ] "Diyetisyen bul": dietitian listing + filtering + selection — email invite stands in for now (#101)
- [ ] In-app chat (Supabase Realtime)
- [ ] Diet plan: AI draft (Edge Function) → dietitian edits/approves → client sees it
- [ ] ~~iyzico payment + commission~~ — deferred (P6); clients pay dietitians directly
- [ ] Embedded video call

**Phase 2 — AI-only tier:** subscription (RevenueCat + IAP), AI plan generation + follow-up,
AI chatbot.

**Phase 3+ — later, don't touch (awaiting confirmation, QUESTIONS.md §0 I13–I14):** catering, meal cards, sports PT, WhatsApp/Instagram
integration. **B2B is now the main acquisition plan** and may move earlier (QUESTIONS.md C4).

**Release prerequisites** (not scheduled yet): Apple Developer ($99/yr) and Google Play
($25; new personal accounts need a 14-day closed test with 12+ testers — start early);
signing keys backed up; privacy policy and health-data disclosure for store review;
in-app account deletion (Q22); KVKK texts with legal support.

---

## 7. Data model sketch

Built: `profiles`, `dietitians`, `clients`, `dietitian_client_relationships`. The rest is a
sketch to be designed when its slice arrives:

```
blood_tests    (client_id, file_url, values_json, doctor_approval_doc?)
diet_plans     (relationship_id, source: ai|dietitian, state: draft|approved, content)
meal_logs      (plan_id, meal, time, eaten)
conversations  (client_id, dietitian_id | ai)
messages       (conversation_id, sender, body)
appointments   (client_id, dietitian_id, time, video_room_id, status)
payments       (deferred, P6)
subscriptions  (client_id, revenuecat_ref, status)
```

`diet_plans` should key off `dietitian_client_relationships`, not a second pairing.

---

## 8. Open questions

All open questions live in **`QUESTIONS.md`**, grouped by who answers them (Can,
Kadir, dietitians, checks, parked). The `Q<n>` numbers cited in this file appear there
as "Was: Q<n>" tags. When a question is answered, its decision is recorded in this file
and the question is removed from QUESTIONS.md.

---

## 9. Repo structure

```
apps/client/           Flutter client app (android + ios + web*)  *web for development
apps/dietitian_panel/  Flutter panel (web + iOS + Android) — lib/main.dart (real), lib/main_demo.dart (demo)
packages/core/         shared models, Supabase client, auth, theme, fonts
supabase/migrations/   SQL schema versions
supabase/functions/    Edge Functions (AI calls) — empty so far
env/                   dev.example.json committed; dev.json gitignored
docs/agents/           mattpocock-skills config
pubspec.yaml           pub workspace root; Melos config under `melos:`
```

---

## 10. Working rules

- **Can is the source of truth for product decisions.** On a conflict or an unclear point,
  ask Can and record the question in `QUESTIONS.md`. The old Miro board is not a source:
  don't read or cite it.
- When unsure, **ask — don't assume.**
- UI text in Turkish; code, commit messages and docs in English.
- Update this file **when a decision changes or a question closes** — edit the relevant
  section in place. Session narratives go in commit messages, not here.
- Small, working slices — no big-bang PRs.
