# Wellkit — Plan and Locked Decisions

> What is true **now**: the product, the decisions that hold, what is built, what is
> open. Not a session log — history lives in git (`git log -p PLANNING.md`).
> Edit this file when a decision changes; rewrite a section rather than appending one.
>
> **Decision IDs are stable.** Product decisions are P1–P9; technical decisions keep
> their original numbers (#1–#133). Code comments cite them as `PLANNING.md #N` (older
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

P1, P3 and P5 are awaiting re-confirmation (QUESTIONS.md §0, I1, I3, I4); P2 was confirmed on 23 Sep.

Everything dated 23 Sep 2026 in this file is Can's first answer after speaking with
Kadir and is **open to correction**: QUESTIONS.md "Answered on 23 Sep" lists each one
with a way to reopen it.

- **P1** **AI drafts, the dietitian approves.** On the human-service side a client never sees
  an AI plan no dietitian has approved.
- **P2** **All communication stays in-app** (chat + embedded video). Confirmed by Can on
  23 Sep 2026 without the commission (was C5): the reasons now are one record of the
  client's care, quality control, KVKK (health data stays in the EU project, not on
  WhatsApp) and the reporting B2B needs. External links only as an emergency backup
  (inherited with I2; Can confirmed I2 as a whole). ⚠️ Every Turkish competitor uses WhatsApp for
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
- **P7** **Clients mark meals as eaten, one tap per meal** (Can, 23 Sep 2026, while
  planning the redesign). The time is recorded, which is what dietitians asked for (I10).
  It feeds the client's day (progress ring, week strip, streak) and the dietitian's
  view. Per exchange group was the more detailed option, rejected as too much tapping.
  Table sketch: `meal_logs` (§7). The client's hero therefore counts **meals** ("3/5
  öğün"), never inferred exchanges. There is **no consecutive-day streak**: a weekly count
  ("Bu hafta 5/7 gün") that starts again each Monday, which the client can hide (Can,
  23 Sep 2026, was C22; both design reviews cited eating-disorder risk from streaks).
- **P8** **Weigh-ins are entered by both sides** (Can, 23 Sep 2026): the client logs their
  weight in the app, and the dietitian can add measurements. Which measurements is still
  DT8.
- **P9** **The dietitian can hide numbers from one client** (Can, 23 Sep 2026): the week
  count, the weight chart and kcal can be turned off per client, e.g. for an
  eating-disorder history. Kcal is off for clients by default.

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
- **#3** **Android emulator: done (23 Sep 2026).** Chrome hides mobile-specific problems, so
  apps are also checked on an emulator. The emulator runs on **Windows** (Android Studio,
  Pixel 8a, API 37, 16 KB pages); Flutter builds in **WSL** with its own JDK 21 and Android
  SDK. WSL uses **mirrored networking** (`networkingMode=mirrored` in the Windows
  `.wslconfig`), so WSL's `adb` reaches the emulator on `localhost` with no manual bridge.
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
  iOS `PRODUCT_BUNDLE_IDENTIFIER`). The panel is **`com.wellkit.panel`** (Can,
  23 Sep 2026; its `android/` and `ios/` runners were generated with it, #38).
- **No Mac:** iOS builds go through **Codemagic** (cloud CI).
- **Agent skills** (#85): mattpocock-skills configured. **GitHub Issues is the tracker**
  (confirmed 23 Sep 2026); triage and `wayfinder:*` labels exist on the repo. Domain
  docs are single-context (`CONTEXT.md`, `docs/adr/`).

### 3.2 Data and security

- **#20** **Email + password only.** Phone/SMS OTP needs a paid SMS provider — deferred (Q15).
- **#21** **Email confirmation is on** (Can, 23 Sep 2026; it was off in development). #102
  depends on it. Without custom SMTP, Supabase only emails members of the Supabase org, so
  test signups need a real team address; custom SMTP arrives with password reset (#43).
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
  only safe while email confirmation is on (#21).
- **#103** Client names reach the panel through `list_my_clients()`, not a SELECT policy on
  `profiles` (#90).
- **#104** The client app's "Hedeflerim" form (goal / budget / health note) is the **only
  writer** of those `clients` columns. Replace it, don't just remove it.
- **#105** The invite card names the **inviting dietitian** — the client is granting access to
  their health data and must see who asks (KVKK explicit-consent logic).
- **#106** Out of scope so far, deliberately: ending a relationship, structured health fields on
  `clients`, actually sending the invite email (Edge Function + `inviteUserByEmail`).

### 3.4 Auth and screens

- **#37** **No role-selection screen.** The role comes from the app used to sign up: the
  client app always creates `client`; the dietitian app sends `role: dietitian` on every
  platform (web, iOS, Android; #38).
- **#38** **The dietitian panel runs on web, phones and tablets** (Can, 23 Sep 2026; it was
  web only). One Flutter codebase with layouts by width: wide screens keep the rail and
  tables, phones get a bottom bar and stacked screens. Default: phones use the
  comfortable density (touch-sized controls), wide screens the compact one (#64).
  **Two store apps:** the client app and a separate dietitian app; the app you sign up
  in still sets your role (#37).
  **Built 23 Sep 2026 (redesign slice 4):** below **600 dp** wide both entry points use a
  bottom bar and the comfortable density; from 600 dp up, the rail and compact density
  (`lib/util/breakpoints.dart`, `lib/widgets/adaptive_nav_scaffold.dart`). The demo's reminder
  settings and reset sit behind a labelled "Demo" button on phones. Tablets (600 dp+) get
  the compact layout for now. Slice 5a (same day) stacked the real client list and the demo's
  triage rows on phones; slice 5b did the demo's other screens: stacked Danışanlar rows,
  Randevular rows that stack below 720 px (this also fixed their overflow below ~900 px on
  the web), Mesajlar as list → thread page, wrapping headers in Takip and the client
  record, and a sideways-scrolling measurement table. Every demo tab, a client record and
  a thread are tested at 360 and 412 dp with text scale 1.0, 1.3 and 2.0
  (`test/phone_layout_test.dart`).
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
- **#51** Client home: 2 tabs (**Bugün**, Profil). Since the "Sıcak" redesign (#131, slice 2,
  23 Sep 2026) Bugün opens on a green hero with the greeting and three real steps (goals →
  dietitian → first plan, derived from saved data; the plan step says "yakında"), then a
  pending invite, the goal row (one tap target into Profil), the connected dietitian, and
  one quiet "Yakında" note for Diyetisyen bul and the AI tier. **Profil** (slice 3) is a
  summary, not a form: the name, the three Hedeflerim answers, the connected dietitian, a
  "Yakında" note for files (#125), and a quiet "Çıkış yap" at the bottom. Hedeflerim is
  edited on its own screen (`goals_edit_screen.dart`, still the only writer, #104). More
  tabs arrive when their features ship for everyone.
- **#52** A pending dietitian sees one card **without the panel frame** ("Başvurunuz
  İnceleniyor" + a working "Durumu yenile"). `rejected` uses the same layout.
- **#53** An approved dietitian gets a **NavigationRail** on wide screens (a bottom bar on
  phones, #38) with only destinations that have real content (today: Genel Bakış with the client list, and Profil). No empty rail
  destinations in advance.
- **#108** A screen that exists but cannot be reached in one click from the home screen is
  effectively missing — reachability is part of done.

### 3.5 Design system

Full reference, including type scale, density numbers and the design rules:
**`docs/design-system.md`** (the source; the 28 Aug artifact is history).

- **#134** **Visual redesign from zero** (Can, 1 Oct 2026). Features stay; the look of
  Sade and direction B (#131–#133) is replaced. **Only the safeguards survive:** AI
  drafts clearly marked and never shown to clients unapproved (P1; #57's own visual
  state and text label, not necessarily its violet), the approval gate (#98, #126), no
  money UI (P6), Turkish copy with "sen" in the client app and "siz" in the panel
  (#47–#49, #120), and labelled actions (design rule 13). **Open:** every colour (the
  brand green too), fonts, layout and shapes. Until a new value is decided and coded,
  the entries below (#54–#57, #60, #64, #131–#133) describe the code, not the target.
  **Rules that also survive** (Can, 1 Oct 2026, was C32), because they are about
  honesty, safety or access rather than looks:
  - Only real data or a "Yakında" label (#50); no invented numbers shown as real.
  - Copy never praises or blames weight, and there is no streak (P7). Naming the
    client's own goal is fine ("Hedefin: 68 kg"); judging a result is not ("Harika, 2
    kilo verdin!"). Wellkit's own hooks lead with the dietitian and the plan, not kilos.
  - Colour never carries meaning alone; contrast is measured (WCAG AA and HIG).
  - Motion only on a change and none under Reduce Motion; native screen transitions
    are platform habits and stay.
  - "It must not look AI-generated" (rule 15); its checklist is rewritten once the
    DESIGN.md is adapted, because parts of it were Sade-specific.
  - No glass or blur on content. Whether bars (tab bar, toolbars) may use it is decided
    with the DESIGN.md (QUESTIONS C41).
  - Light only or dark mode too: decided after the DESIGN.md and the font (C43).

  How the work runs:
  - **Style: Bevel** (Can, 1 Oct 2026, was C31), after a shortlist and Can's own search:
    https://styles.refero.design/style/c0717d1a-b446-4166-a445-6497fe287fea. Its
    Extended DESIGN.md is copied verbatim to `docs/design/2026-10-01-bevel/DESIGN.md`;
    values come only from that file, never from a web summary. It describes Bevel's
    **marketing website**, not an app, so its clashes with HIG and with these rules are
    QUESTIONS C35–C43. A second style may still supply type or colour if Can says so.
  - **Fonts:** Can picks from Fontshare and uploads the TTF/OTF files. A script checks
    Turkish glyphs (ı İ ğ ş ç ö ü â), the licence, tabular figures and weights before
    use. Bundled, never fetched at runtime (#63).
  - **Apple HIG** is the rulebook for measurable things (tap targets, type sizes and
    line height, spacing, contrast, large-text support) in both apps on iOS, Android and
    the wide panel. Platform habits stay native: Android keeps its back button and
    system behaviours, iOS its own. Every place HIG's numbers conflict with
    `docs/design-system.md` goes to Can before anything changes.
  - **Copy:** how five Turkish diet or dietitian apps or coaches write hooks, empty
    states and buttons shapes the **client app's** texts only, with sources shown.
    Picked by Claude (1 Oct 2026): Diyetkolik, Hiwell, NutriMobi, Diyetisyen Oflaz and
    YAZIO's Turkish version (not Turkish-made; the quality bar). Their App Store
    listings are the first source.
  - **Graphics:** any generated graphic or icon is SVG. The icon pack and a tone-of-voice
    document come later.
  - **Order:** the client app first, starting with one reference screen (Bugün) on a
    Design canvas with phone and wide artboards and the DESIGN.md installed as the
    design system, before any Flutter. Bugün is drawn in two states (was C33): with a
    plan (today's meals with one-tap ticks, the week count, weigh-ins; the main
    artboard, labelled as not built yet) and a new client's setup. Flutter builds only
    what exists (#50).
  - **One system for both apps** (was C34): the panel takes the same style later,
    denser on wide screens (#64), so the style must also work for a work tool.
  - **Working:** small slices, ask instead of assuming, `melos analyze` and `test`, a
    subagent review per slice, commit only when Can says so, push only on "push".
  - Direction B's rollout is **paused**. Its structure (core `SectionLabel`,
    `ActionRow`, `PersonAvatar`, the screen states and their tests) is code to reuse,
    not a look to keep.
- **#135** **Bevel adapted for an app** (Can, 1 Oct 2026, accepting Claude's proposals
  in C35–C38, C41, C42). Bevel's DESIGN.md describes a website, so:
  - **Sizes come from HIG** (iOS, default text size): Large Title 34/41, Title 1 28/34,
    Title 2 22/28, Title 3 20/25, Headline 17/22 semibold, Body 17/22, Callout 16/21,
    Subhead 15/20, Footnote 13/18, Caption 1 12/16; no text under 11; text grows to at
    least 200 %. Touch targets 48 (meets HIG's 44 and Android's 48), with about 12 pt
    around filled controls and 24 pt around unfilled ones. Screens are left-aligned.
    Line heights never go below HIG's, so Turkish marks (İ Ğ Ş Ç Ö Ü) don't clip.
  - **Bevel's character stays:** one sans family, 600-weight headings with slightly
    tight tracking, grey supporting text, a white canvas, borderless pale (Cloud Card)
    cards at radius 24 without shadow, full pill buttons, shadows only on floating
    things. What Bevel lacks (inputs, lists, tab bar, dialogs, sheets, chips, progress,
    empty states) is built from HIG's patterns in Bevel's tone.
  - **Colour:** buttons are black (Charcoal) pills. One accent marks progress and
    "approved" and is also the one data colour (meals ring, week count, weight chart);
    its hue is C36. Bevel's per-category data colours are not used: on white they
    measure 1.5–2.1:1. Star ratings are gold and always show the number. Text on Cloud
    Card uses a darker grey (Body Gray measures 3.98:1 there). A new red and amber are
    measured in Bevel's tone. Violet stays for AI drafts only, darkened to pass 4.5:1;
    Sleep Lilac is dropped.
  - **Bottom bar:** a solid floating white capsule on both platforms, no blur; Android's
    back button and gestures stay native.
  - **Panel density by input, not width:** the compact profile only for pointer use
    (web on a computer); tablets and phones get the touch sizes. This replaces the
    width rule in #38 and #64 when the panel is redesigned.
  - Bevel's sky gradient is drawn both ways on the canvas (C40).
  - **Font: Alpino** (Can, 1 Oct 2026, from Fontshare; files in Can's
    `Alpino_Complete.zip`). Checked by script: all Turkish letters (ı İ ğ ş ç ö ü â î û)
    in every weight; ITF Free Font License allows embedding in apps but not modifying
    the files; static Thin, Light, Regular, Medium, Bold, Black plus one variable file
    (wght 100–900), so 600 needs the variable file or becomes 500/700. **No tabular
    figures**, so (Can, 1 Oct 2026, was C39) Alpino is used everywhere and numbers that
    must line up (agenda times, panel tables) sit in fixed-width, right-aligned slots;
    revisited when the panel's tables are redesigned.

- **#54** Brand green `#18795C`, surface `#FFFFFF`. Ground since #133: neutral light grey
  `#F2F4F3` (was cool `#F7F9F8` in palette "Serin", then warm `#F6F1E8` in "Sıcak").
- **#55** **One brand hue.** Every non-green colour carries a meaning (waiting / error / AI
  draft); no decorative second accent, no colour per category (#133 removed the group
  colours and the yellow highlight Sıcak had added). The one tinted fill is `primaryTint`
  behind a secondary action. "Onaylı" is a grey pill with a black tick (Can, 24 Sep
  2026), so a green pill always means a button. Buttons are pills; destructive confirms
  are red.
- **#56** **No separate `success` colour** — it measured 1.19:1 against brand green. Approved
  states use brand green.
- **#57** **An AI draft has its own visual state:** violet `#514196` + 1.5px dashed border + a
  text label on a draft container; a draft status pill is violet text on `aiDraftTint`
  with its label and no border (Can, 24 Sep 2026). Violet is used nowhere else. Colour
  never carries meaning alone.
- **#58** Every value is **measured**: WCAG AA 4.5:1 for text, 3:1 for interactive boundaries.
  Ratios are written next to each token in `app_colors.dart`. **Don't change a value
  without re-measuring.**
- **#59** **Light theme only** for now; the dark palette is measured and documented, not coded.
- **#60** **Figtree only** since #133 (Can, 23 Sep 2026): bold headings, regular body, every
  number Figtree 700 with tabular figures. Fraunces (the old heading serif) is still
  bundled but unused.
- **#61** Turkish glyph coverage verified from the font files' `cmap` tables.
- **#63** Fonts are **bundled assets** in `packages/core/fonts/`; no `google_fonts` runtime fetch.
  A core test asserts the resolved family.
- **#64** One token set, two density profiles: `AppDensity.comfortable` (the client app, and
  the panel on phones) and `AppDensity.compact` (the panel on wide screens; #38). Only
  spacing, radius, control and line height differ.
- **#65** **No `ColorScheme.fromSeed`** — it discards the measured palette. Every slot is set
  explicitly.
- **#66** Non-Material tokens travel as `AppPalette` / `AppDensity` ThemeExtensions
  (`context.palette`, `context.density`).
- **#67** The design rules in `docs/design-system.md` apply to every screen (15 since 23 Sep
  2026: no gradients, no emoji icons, no "✨ AI" badges, no mixed radii, labelled and
  confirmed actions, no money while P6 holds, nothing that looks AI-generated, …).
- **#133** **Direction "Sade" replaces Sıcak's colour** (Can, late 23 Sep 2026, after seeing
  Sıcak on the phone: "too many variations of colour, doesn't look clean and premium";
  reference: MyFitnessPal's current app). Neutral light-grey ground, white borderless
  cards, Figtree only (bold headings), black ticks and selected navigation, and the brand
  green only for actions, progress and "approved". Dropped: the cream ground, the green
  hero block, the yellow highlight, the eight group colours. Can chose each point: keep
  our green (not MyFitnessPal's blue), all sans, grey + white cards, no group colours.
  Everything else from #131/#132 (numbers, touch targets, motion, week count, P9, tab bar
  only navigates) stands. Spec: `docs/design-system.md`.
  **The panel follows Sade screen by screen** (24 Sep 2026, slices 1–9, each checked on
  the emulator at phone and wide size, reviewed by a subagent and by Codex:
  `docs/research/2026-09-24-panel-sade-review*.md`). Can decided along the way: every
  button is a pill; `OutlinedButton` is the pale-green secondary pill; "Onaylı" is a grey
  pill with a black tick, so a green pill always means a button (C24–C25); destructive
  confirms are red (C26); **one green action per row**, the rest grey quiet buttons
  (Genel Bakış; Randevular keeps "Görüşmeye başla", C29); grey triage and draft icons
  and amber only on the reason (C30; its counts line and no-violet rule were replaced by
  direction B below); Danışanlar on phones keeps search in
  view and puts goal and plan status behind one "Filtrele" sheet (C28); the Mesajlar
  thread sits on the grey ground with white client bubbles and pale-green dietitian
  bubbles (C27). Filter chips are borderless (white off, pale green on).
  **Alignment pass** (24 Sep 2026, slices 10–11b, after Can spotted drifting columns in
  Randevular): rows of related cards share one column grid, every action has a fixed
  column; forms and text pages stop at 1100 px and centre (lists and tables stay full
  width); wide plan editors centre, the status pill next to the title; cancel buttons
  ("Vazgeç") are grey. The client app got the same pass (slice 12): one left edge, and a
  text button that must sit on an edge uses core's `EdgeButton` (the pill hangs into the
  margin; zero padding put the hover fill against the text).
  **Stretched grids are not tidy** (Can, 24 Sep 2026 evening, on Randevular at 1800 px):
  columns that line up but spread actions across the window look scattered, not
  premium. Can chose, for Randevular and then Genel Bakış: an **agenda by day** (day
  headings, time first, name with the kind under it), **actions grouped at the right
  end**, capped at the readable width, and rarer actions ("Randevuyu iptal et",
  "Gelmedi olarak işaretle") in a labelled **⋯ menu** that still confirms. A first cut is
  in `git stash` ("Randevular agenda (WIP…)"), to be carried into the UI revamp (HANDOFF).
  **Direction B, everywhere** (Can, 25 Sep 2026, after two proposals on
  https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4; references: five Lifesum screens in
  `docs/design/references/2026-09-25-lifesum/`). Sade's colour stays; the hierarchy comes
  from Lifesum. For every panel screen and the client app (which also closes the visual
  half of C23): one focal card per screen with the screen's one big number; small-capital
  section labels on the ground; rows with an initials avatar or time first and their one
  green action as text at the right end (no column of pale pills); a person's name in a list of people opens
  their record; one client once per section; dashboards stop at 1200 px with a second
  column for secondary content; wide-screen cards radius 16. Genel Bakış (first reference
  screen): the drafts card leads ("3 plan onayınızı bekliyor", oldest first), with the
  violet "Yapay zekâ taslağı" label (Can chose it over C30's no-violet); today's agenda
  beside it (a column on wide screens, today plus one line on phones); triage grouped by
  client; the counts line and the greeting's size are gone (C30 revised). Spec:
  `docs/design-system.md` "Direction B".
- **#131** **Redesign direction "Sıcak"**, colour superseded by #133 the same night (Can, 23 Sep 2026, after calling the client app
  dull on a phone; option B of three on the mockup canvas
  https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn). Close to Lifesum: warm ground, a
  flat green hero block carrying the day's number, colour per exchange group, a floating
  bottom bar. Applies to the client app and the panel on phones; the panel on wide
  screens takes the same colours and keeps its tables. Target values:
  `docs/design-system.md` "Redesign Sıcak", not coded yet.
- **#132** **Design rules relaxed for "Sıcak"**, delegated by Can to Claude on 23 Sep 2026
  with one condition: it must not look like an AI-coded frontend (new rule 15). Changed:
  flat hero blocks (rule 1), one centred hero number (6), a shadow on floating elements
  only (8), rings and bars animate when their value changes, not on every open (12, Can's
  choice), `highlight` and group colours (#55), and rule 15 as a checklist. Kept: no
  gradients, no stock photos (illustrations are C20), only real data (4, 5). Corrected
  the same day by two outside reviews (`docs/research/2026-09-23-sicak-redesign-review-*.md`):
  numbers in Figtree Bold with tabular figures (Fraunces only for greetings and titles),
  group colours only for groups, touch targets 48+, no action button in the tab bar, a
  slim header on the panel's phone layout, and AI-draft cards that show what was checked
  rather than a verdict (#126).

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
  rail). Also done 23 Sep: #10, both plan editors share `PlanEditorLayout`
  (`lib/widgets/plan_editor_layout.dart`): meals in a column capped at 760 px, status,
  energy, approve and PDF in a side panel from 1100 px up, and a pinned bottom bar with
  the approve button below that. After the interviews: #12 (compact Takip).
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

## 5. Current state (24 Sep 2026)

| Area | State |
|---|---|
| Monorepo, tooling | Done. Analyzer clean, all tests green (core 14, client 18, panel 181). No CI yet. Both apps build and run on the Android emulator (#3) and show as "Wellkit" and "Wellkit Panel". |
| Supabase | Project `jpkvulcszsutacritttk`, 4 migrations applied: identity + RLS, grant tightening, dietitian public projection, relationships. One shared project — no dev/prod split. |
| Auth | Real in both apps: sign up / in / out, role routing, wrong-app screen, pending/approved dietitian. Email confirmation on (#21). No password reset, no custom SMTP. |
| Client app | "Sade" design (#133). Login → Bugün (date and greeting, any invite first, a white Başlangıç card with a progress bar and three real steps, one Yakında note) and Profil (a summary; Hedeflerim edited on its own screen). All copy in "sen". No plan, meal log, weigh-in or chat yet, so Bugün is honestly sparse. |
| Real panel | Client list with pending invites, invite dialog, client detail (goal / budget / health note only). Phone layout below 600 dp: bottom bar, comfortable density, stacked client rows (#38). Takes Sade through the shared theme; not yet checked on the emulator (needs an approved dietitian account, #35). |
| Interview demo | Fully Sade screen by screen (24 Sep 2026, #133); below 600 dp a bottom bar, stacked screens and a "Demo" button for reminder settings and reset. 6 rail tabs on fake data (overview + triage, clients, appointments, messages, payments, tracking) and "Hatırlatma ayarları" at the bottom of the rail; both plan editors, energy card, PDF export, anamnez form, measurements. Every money screen (Ödemeler tab, "Tahsil edilmemiş" figures, payment reminder) is hidden behind `kShowMoney = false` (P6). |
| Marketplace | **Nothing real yet** — no public profile, "Diyetisyen bul" section or request/accept flow. |
| Brand | Name settled. Palette, type and layout are being redesigned from zero (#134; the code still ships "Sade"). **Logo: placeholder "W" mark** until one is designed with Claude later. |
| Plan editor, `diet_plans` | Not built. Unblocked: exchange list first, weekly, from templates (P4, #121–#123). |
| Interviews | Held; most answers in §2.1, five questions still open (QUESTIONS.md §3). |

---

## 6. Roadmap

**Phase 0 — Shared core: done.** Monorepo, EU Supabase project, email/password auth, roles,
profile models, both apps at "login → first screen".

**Phase 1 — Dietitian marketplace (human service)**
- [ ] Dietitian onboarding + verification (diploma/document upload)
- [~] Client onboarding: goal, health info, budget — goal/budget/health-note form exists;
      structured health fields don't. No blood-test section (#125)
- [ ] File attachments on the shared record, from client and dietitian (#125)
- [ ] "Diyetisyen bul": dietitian listing + filtering + selection — email invite stands in for now (#101)
- [ ] Client marks meals as eaten (P7) and logs weight; dietitian adds measurements (P8)
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
attachments    (relationship_id, uploaded_by, file_url, created_at)  -- any file, no blood-test fields (#125)
diet_plans     (relationship_id, source: ai|dietitian, state: draft|approved, content)
meal_logs      (plan_id, meal, time, eaten)                          -- P7, one tap per meal
measurements   (client_id, taken_by: client|dietitian, kind, value, taken_at)  -- P8
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
