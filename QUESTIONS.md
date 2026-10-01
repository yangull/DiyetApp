# QUESTIONS — the one list

Every open question for Wellkit lives here and nowhere else. Answer under a question
(or tell Claude, who writes it in). Once a question is answered, its decision moves into
`PLANNING.md` and the question is deleted from this file.

**Can is the only source for product decisions.** Nothing from the old Miro board counts,
and agents must not read or cite it. When something is unclear, it becomes a question
here.

**Who answers:** §0 and §1 Can · §2 Kadir (partner) · §3 dietitians, in interviews ·
§4 checks, not questions · §5 parked.

Tags: `Q<n>` is an old PLANNING question number, `q<n>` a question in the interview-guide
artifact, where Can wrote notes on 23 Sep 2026.

---

## Answered on 23 Sep 2026 — open to correction

Can answered these after speaking with Kadir. They are recorded as decisions so work can
move, but none is final: if one turns out wrong, tell Claude or Codex which row. The row
then moves back to its section as an open question, and the PLANNING entry is reverted.
Delete this section once Can has looked at it again (after the next talk with Kadir).

| Was | Question | Can's answer | Recorded in |
|---|---|---|---|
| I5 | Money in the app at launch? | No: clients pay dietitians directly, no commission | PLANNING P6 |
| I9 | Keep Kutay's Excel as a source? | Dropped | — |
| — | Default energy formula | Harris-Benedict × activity factor | PLANNING #95 |
| — | Where do clients come from? | Mainly B2B deals, plus Wellkit's ads and dietitians' own clients | PLANNING §1 |
| — | Clients per dietitian | No limit; usually 30–40 | PLANNING §1 |
| — | How clients find a dietitian | A "Diyetisyen bul" section in the app | PLANNING §1, roadmap |
| — | Logo | Placeholder "W" until designed | PLANNING §5 |
| C1 | Plan model | Exchange list by default, freeform kept ("sonra değişebilir") | PLANNING P4 |
| C5 | In-app only without a commission? | Keep it, for records, quality control, KVKK and B2B | PLANNING P2 |
| C3 | Next slice | The mobile panel layout, after UI review #10 | HANDOFF |
| new | Where does the panel run? | Web, phones and tablets | PLANNING #38 |
| new | One store app or two? | Two: client app and dietitian app | PLANNING #38 |
| C2 | Interviews held? | Yes; answers relayed the same day | PLANNING §2.1 |
| DT2 | Exchange list or food + amount? | Both, depending on the client | #121 |
| DT3 | Group table | One standard table (which table and values is still open, §3) | #122 |
| DT4, DT5 | Plan rhythm | Weekly, mostly copied; old plans hidden from the client | #123 |
| DT6 | Energy formulas | Harris-Benedict, Mifflin-St Jeor, Cunningham, WHO/FAO (Can ticked "Harris-Benedict only" together with the other three; read as "all four in use") | #124 |
| DT9 | Blood tests | No blood-test section (KVKK); client and dietitian can both attach any file | #125 |
| DT12 | Before approving an AI draft | Its reasoning, totals vs target, a health-flag check | #126 |
| DT13 | Reminders | App notifications only, no SMS | #127 |
| DT11 | Essential list columns | Plan status, last contact or weigh-in, next appointment, goal and weight | #128 |
| DT14 | Ratings | Stars only, no comments at launch | #129 |
| DT1, DT15, DT16, DT17 | Tools, pull, objections, company clients | Excel/Word + WhatsApp; editor + AI, tracking, appointments all pull; no objection to moving clients; company clients differ in pricing and bulk registration | #130 |
| DT8 | Measurements | Not answered; placeholder default (weight, waist, hip; fat % and muscle optional) so work isn't blocked | PLANNING §2.1 |
| C18, C19 | UI review fixes, button wording | As recommended; short button labels | #119, #120 |
| new | Panel bundle id | `com.wellkit.panel` | PLANNING §3.1 |
| new | WSL ↔ emulator bridge | Mirrored WSL networking | PLANNING #3 |
| new | Redesign direction | "Sıcak" (option B, Lifesum-like) | PLANNING #131, design-system.md |
| new | Design rule changes for it | Delegated to Claude: "must not look AI-coded" | PLANNING #132, design-system.md rule 15 |
| new | Do clients mark meals as eaten? | Yes, one tap per meal, time recorded | PLANNING P7 |
| new | Who enters weigh-ins? | Both: the client in the app, the dietitian adds measurements | PLANNING P8 |
| C22 | Streak rule | No consecutive streak: "Bu hafta 5/7 gün", resets weekly, client can hide it | PLANNING P7 |
| new | Hero number | Meals ("3/5 öğün"), not inferred exchanges | PLANNING P7 |
| new | Hide numbers for a client? | Yes: the dietitian turns off week count, weight chart, kcal per client | PLANNING P9 |
| new | When do rings animate? | Only when the value changes, not on every open | PLANNING #132, design-system rule 12 |
| new | Too many colours? | Yes: direction "Sade" (MyFitnessPal-like), keep our green, all sans, grey + white cards, no group colours | PLANNING #133 |
| C20 | Illustrations for the food groups | Dropped with the group colours in Sade; reopen if food imagery is wanted | PLANNING #133 |

---

## 0. Inherited decisions — confirm or correct

These came from the old board, not from a conversation with Can, and still shape the
plan. Mark each one ✅ (keep), ✏️ (change, and how) or ❌ (drop). Confirmed items stay in
PLANNING.md; the rest are edited or removed there. Already answered on 23 Sep: I5 (money
is deferred, now PLANNING P6) and I9 (Kutay's Excel dropped).

| # | Decision in force | Where it lives now | Your verdict |
|---|---|---|---|
| I1 | **AI drafts, the dietitian approves;** a client never sees an unapproved AI plan | PLANNING P1, #25, #98 | |
| I2 | **All communication stays in-app** (chat + embedded video); external links only as an emergency backup. Confirmed 23 Sep 2026 with new reasons (records, quality control, KVKK, B2B). | PLANNING P2; Mesajlar screen | ✅ |
| I3 | **Build order:** shared core → dietitian marketplace → AI-only tier | PLANNING P3, roadmap | |
| I4 | **One general panel,** no separate screens per dietitian type | PLANNING P5 | |
| I6 | **Client flow:** sign up → choose the dietitian or AI path → ~~enter blood values/tests~~ (superseded 23 Sep: no blood-test section, files can be attached, #125) → set a budget → dietitian or AI plan | PLANNING §1 | |
| I7 | **Dietitian types to serve:** sports, lipedema, diabetes, GLP-1 injection users, bariatric | PLANNING §1 | |
| I8 | **Blood tests:** ~~clients upload them~~ superseded 23 Sep: no blood-test section, any file can be attached (#125). Still open: dietitians can't diagnose; do some actions need a doctor-approved document? (C12) | PLANNING #125 | |
| I10 | **Meal-time notifications** matter to dietitians ("what time it was eaten"). 23 Sep: clients now log each meal with its time (P7); notifications still unconfirmed. | PLANNING §1, P7 | |
| I11 | **An AI chatbot** answers client questions without the dietitian (Phase 2) | PLANNING §1, roadmap | |
| I12 | **Diet styles** to learn and support: Mediterranean, intermittent fasting, low-carb | not in PLANNING, only here | |
| I13 | **Sports PT is suspended** | roadmap Phase 3+ | |
| I14 | **Later phases:** catering packages, meal-card integration, B2B corporate sales, WhatsApp/Instagram integration. B2B is now the main acquisition plan, see C4. | PLANNING §1, roadmap Phase 3+ | |
| I15 | **Value to clients:** "cheap and accessible" dietitian service | PLANNING §1 | |
| I16 | **Tech stack:** Flutter (client app on iOS/Android; panel on web, iOS and Android since 23 Sep, #38), Supabase EU, LLM calls via Edge Functions, IAP + RevenueCat for the AI tier, an embedded video SDK. Already built on, so only flag it if something is wrong. | PLANNING §4, the code | |

---

## 1. Can decides

Product decisions nobody else can make. The most blocking come first. Money questions
(commission, packages, pricing, payouts) are parked until later (§5, PLANNING P6).

**Redesign: what is still open (PLANNING #134, #135).** Bevel's DESIGN.md
(`docs/design/2026-10-01-bevel/DESIGN.md`) describes a website; C31–C42, C44 and C45 were
asked and answered on 1 Oct 2026 (now PLANNING #134–#135 and
`docs/design-system.md`). Still open:

### C43. Light only, or dark mode too?
Bevel is light only. HIG asks for contrast checks in both modes if an app supports dark.
Can (1 Oct 2026): decide after the DESIGN.md is adapted and the font is chosen. The font
is chosen; the adaptation (`docs/design-system.md`) measures light only, and the
canvas was skipped. Ask again once the redesigned client app runs on the phone.
>

### C47. Tablets in "desktop site" mode get the compact panel
The panel is compact in a browser on Windows, macOS or Linux (#135). Chrome and Samsung
Internet on Android tablets default to "desktop site", which reports Linux, so such a
tablet gets the 28 px computer sizes. Options: (a) accept it like touch laptops and
Chromebooks; (b) also ask the browser whether its pointer is a mouse
(`(pointer: fine)`), which needs the small `web` package in core. Proposal: (b) before
the panel ships to dietitians on tablets.
_Blocks: nothing today; the panel on tablet browsers._
>

### C46. Direction B's narrowed names rule
Under direction B a name opened the person's record only in lists of people. Moot until
the redesign draws rows; Can agreed (1 Oct 2026) to decide when the first list is
redesigned.
>

### C4. B2B is the main plan: when does it enter the roadmap?
You said clients will come mainly through corporate deals, plus our own digital ads.
Today B2B sits in Phase 3+ (I14), after the marketplace and the AI tier. If it is the
main channel, the first release may need company accounts, a way to enrol employees,
and a rule for what the employer may see (health data is KVKK special-category data, so
likely nothing per person). Does the pilot start with one company, or with individual
clients first?
_Blocks: roadmap order (P3), the first release's scope._
Interviews (DT17): company clients differ in pricing and in how they register; B2B needs
bulk enrolment of employees.
>

### C6. What does a new client's first week look like?
Known: first contact is online, the client finds a dietitian in the app's "Diyetisyen
bul" section, and payment happens outside the app. Still open: is there a live first
meeting, is there a food log before the first plan, how fast is the first plan due?
_Was: q15. Blocks: onboarding._
>

### C7. After a client picks a dietitian in "Diyetisyen bul"
Does the client send a request that the dietitian accepts? What happens if the dietitian
declines, is full, or doesn't answer? (There is no limit on clients per dietitian; the
usual load is 30–40.)
_Blocks: the marketplace flow._
>

### C8. What orders the "Diyetisyen bul" listing?
Ratings are stars only, no comments, at launch (PLANNING #129). What decides who is
listed first: rating, distance, specialty, availability, a random rotation?
_Was: q22._
>

### C9. Leads from a dietitian's WhatsApp
Reminders stay in-app (your note). Should the app import leads that reach a dietitian
through WhatsApp, or is WhatsApp out entirely?
_Was: Q7, q9._
>

### C10. Dietitians bring their existing clients: who does the work?
Decided: dietitians can bring their previous clients into Wellkit. Today they invite
each one by email. Your earlier note said **"entegresini biz yapıcaz"**. Do we also
import them for the dietitian (from their files), or is the invite enough?
_Was: q20._
>

### C11. Sports clients: confirm "no PT, a short weekly summary"
Your note: **"tam olarak girilmiyor ama fikir edinecek kadar haftada ne yapıyor, kısa bir
özet."** So no PT and no device integration, just a weekly activity note on athlete
clients?
_Was: Q6, q10._
>

### C12. Blood tests: what does "mala yatıyoruz" mean?
That is your note on "when do you refer blood results to a doctor". Does it mean "we skip
this for now", or "the dietitian handles it"? It is the product's regulatory risk, so it
needs a clear rule. Related: I8, DT9.
_Was: Q3, Q4, q3–q4._
>

### C13. Is AI needed in the first release?
Must plan drafts be AI-generated at launch, or can dietitians write plans by hand while
the AI is validated? Your note calls AI drafts "gayet iyi, hatta iyi bir feature".
Related: I11.
_Was: q21._
>

### C14. Launch surfaces and addresses
Android, iOS, and/or client web? A domain? The dietitian panel's public URL?
_Was: Q13, Q21._
>

### C15. What result means the pilot worked?
For example: clients who got a first plan, time to first plan, clients still active after
a month, dietitians who stay. With numbers and a review date.
>

### C16. Who runs operations?
Who approves dietitians, handles complaints, and what support address does a rejected
dietitian see?
_Was: Q20._
>

### C17. Separate Supabase dev project?
Today every dev signup lands in the one live project. A second project is free on the
Supabase free tier.
>

### C21. How much plan editing on a phone?
The panel runs on phones (#38). Editing a full weekly exchange plan on a small screen is
hard. Proposal: on phones the dietitian reviews, approves and makes small edits (a count,
a note); full weekly editing stays on tablet and web. Agree?
_Blocks: the mobile plan screen (the panel's plan editor)._
>

### C23. How should clients choose things themselves?
Can (24 Sep 2026): the client app should feel modern, "hooky", the client choosing
everything simply and openly. The look is being redesigned from zero (PLANNING #134,
1 Oct 2026). Still open, the interaction half: should clients pick
things themselves (foods from the exchange list, the dietitian, goals) with simple
choices instead of forms, and where first?
_Blocks: the client app's feature design, not its look. Bugün's new-client state on the
canvas draws today's flow until this is answered._
>

---

## 2. Kadir (partner)

Can asks these, or Kadir answers them in the interview guide's Kadir tab:
https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB#kadir

- **K1. Which dietitians for the pilot, and when are the interviews?** How many, which
  specialties, who runs them, when.
- **K2. The intake form you sent: is it for athletes only, or for every client?** If
  athletes only, is there a general form too? (Can is asking; see
  `docs/reference/anamnez-ornek.md`.)
- **K3. Which companies are we talking to for B2B, and what would they expect from
  Wellkit?** Feeds C4.

---

## 3. Dietitians — interview questions

Asked in interview order. The Turkish wording, the reason for each, and Can's current
belief live in the interview guide, which records notes per interviewee:
https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB. **Critical** means the plan editor
can't be built without the answer.

Answered by Can on 23 Sep and removed from the interview: how dietitians find clients
(Wellkit brings them: mainly B2B, plus ads and their own existing clients), client
capacity (no limit, usually 30–40), where they chat today (not needed), first contact
(online), and sessions vs packages (a money question, parked).

Answered on 23 Sep 2026 (Can relayed the interviews; now PLANNING §2.1): DT2, DT4–DT6, DT9,
DT11–DT14, DT16, DT17, part of DT3 and most of DT1 and DT15. Still open, same numbers:

- DT3. **Critical.** Which published exchange table (source, edition) and which kcal values per group? One shared table is decided (#122); today's values are ADA examples.
- DT1. Which admin task takes the most time? (Tools today: Excel/Word and WhatsApp.)
- DT7. **Critical.** Looking at an intake form: which questions really change the plan, what is missing, what is useless? (Show `docs/reference/anamnez-ornek-2021.jpg`.)
- DT8. Which measurements, device, frequency, BIA; who weighs the client? (Default in use: weight, waist, hip; fat % and muscle optional.)
- DT10. Genel Bakış: what do you check first on Monday; when is a client "falling behind"?
- DT15. What is still missing?

---

## 4. Checks — not questions

- **X2.** Video SDK proof of concept, once the video scope is clear. _Was: Q5._
- **X3.** KVKK and legal review of the real data flows (consent, retention, deletion, AI
  provider, and what an employer may see under B2B), and the account-deletion flow. Before
  real health data. _Was: Q22._
- **X4.** Test/prod separation, backups, store accounts, signing. Before external beta.

---

## 5. Parked

Not asked now; reopen when their phase starts.

- **Money, all of it** (Can, 23 Sep 2026: "later"): commission rate and whether there is
  one, sessions vs packages and what a package contains, pricing and minimum price,
  whether prices are public, no-show and cancellation fees, payouts and installments,
  in-app payment provider (iyzico) and its store rules, ad budget, cost analysis and
  competitor prices. _Was: Q1, Q28, q8, q11, old C1, K2, K5, K6, DT6, DT19, X2._
- AI-only tier price and contents. _Q2._
- l10n (Q12), SMS OTP login (Q15), photo source (Q23), client web preview width (Q24).
