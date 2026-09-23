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
| I6 | **Client flow:** sign up → choose the dietitian or AI path → enter blood values/tests → set a budget → dietitian or AI plan | PLANNING §1 | |
| I7 | **Dietitian types to serve:** sports, lipedema, diabetes, GLP-1 injection users, bariatric | PLANNING §1 | |
| I8 | **Blood tests:** clients upload them; dietitians can't diagnose; some actions need a doctor-approved document | PLANNING §1, `blood_tests.doctor_approval_doc` in §7 | |
| I10 | **Meal-time notifications** matter to dietitians ("what time it was eaten") | PLANNING §1 | |
| I11 | **An AI chatbot** answers client questions without the dietitian (Phase 2) | PLANNING §1, roadmap | |
| I12 | **Diet styles** to learn and support: Mediterranean, intermittent fasting, low-carb | not in PLANNING, only here | |
| I13 | **Sports PT is suspended** | roadmap Phase 3+ | |
| I14 | **Later phases:** catering packages, meal-card integration, B2B corporate sales, WhatsApp/Instagram integration. B2B is now the main acquisition plan, see C4. | PLANNING §1, roadmap Phase 3+ | |
| I15 | **Value to clients:** "cheap and accessible" dietitian service | PLANNING §1 | |
| I16 | **Tech stack:** Flutter + Flutter Web, Supabase EU, LLM calls via Edge Functions, IAP + RevenueCat for the AI tier, an embedded video SDK. Already built on, so only flag it if something is wrong. | PLANNING §4, the code | |

---

## 1. Can decides

Product decisions nobody else can make. The most blocking come first. Money questions
(commission, packages, pricing, payouts) are parked until later (§5, PLANNING P6).

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

Answered on 23 Sep 2026 (Can relayed the interviews; now PLANNING §2.1): DT2–DT6, DT9,
DT11–DT14, DT16, DT17 and most of DT1 and DT15. Still open, same numbers:

- DT1. Which admin task takes the most time? (Tools today: Excel/Word and WhatsApp.)
- DT7. **Critical.** Looking at an intake form: which questions really change the plan, what is missing, what is useless? (Show `docs/reference/anamnez-ornek-2021.jpg`.)
- DT8. Which measurements, device, frequency, BIA; who weighs the client? (Default in use: weight, waist, hip; fat % and muscle optional.)
- DT10. Genel Bakış: what do you check first on Monday; when is a client "falling behind"?
- DT15. What is still missing?

---

## 4. Checks — not questions

- **X1. Is email confirmation on in the live Supabase project?** (Can: Dashboard →
  Authentication → Sign In / Providers → Email, about 1 minute.) Invites (#102) depend
  on it. _Was: Q29._
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
