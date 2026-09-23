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
PLANNING.md; the rest are edited or removed there.

| # | Decision in force | Where it lives now | Your verdict |
|---|---|---|---|
| I1 | **AI drafts, the dietitian approves;** a client never sees an unapproved AI plan | PLANNING P1, #25, #98 | |
| I2 | **All communication stays in-app** (chat + embedded video) to protect the commission. External links (WhatsApp, Zoom) only as an emergency backup. | PLANNING P2; Mesajlar screen | |
| I3 | **Build order:** shared core → dietitian marketplace → AI-only tier | PLANNING P3, roadmap | |
| I4 | **One general panel,** no separate screens per dietitian type | PLANNING P5 | |
| I5 | **Revenue:** commission on dietitian–client matches + a monthly AI subscription + later B2B (catering, meal cards, corporate) | PLANNING §1, Ödemeler (15%) | |
| I6 | **Client flow:** sign up → choose the dietitian or AI path → enter blood values/tests → set a budget → dietitian (commission) or AI plan (subscription) | PLANNING §1 | |
| I7 | **Dietitian types to serve:** sports, lipedema, diabetes, GLP-1 injection users, bariatric | PLANNING §1 | |
| I8 | **Blood tests:** clients upload them; dietitians can't diagnose; some actions need a doctor-approved document | PLANNING §1, `blood_tests.doctor_approval_doc` in §7 | |
| I9 | **Kutay's Excel** is the reference for how plans are built today | PLANNING §1, HANDOFF | |
| I10 | **Meal-time notifications** matter to dietitians ("what time it was eaten") | PLANNING §1 | |
| I11 | **An AI chatbot** answers client questions without the dietitian (Phase 2) | PLANNING §1, roadmap | |
| I12 | **Diet styles** to learn and support: Mediterranean, intermittent fasting, low-carb | not in PLANNING, only here | |
| I13 | **Sports PT is suspended** | roadmap Phase 3+ | |
| I14 | **Later phases:** catering packages, meal-card integration, B2B corporate sales, WhatsApp/Instagram integration | PLANNING §1, roadmap Phase 3+ | |
| I15 | **Value to clients:** "cheap and accessible" dietitian service | PLANNING §1 | |
| I16 | **Tech stack:** Flutter + Flutter Web, Supabase EU, LLM calls via Edge Functions, iyzico for human services, IAP + RevenueCat for the AI tier, an embedded video SDK. Already built on, so only flag it if something is wrong. | PLANNING §4, the code | |

---

## 1. Can decides

Product decisions nobody else can make. The most blocking come first. Where you already
wrote a note in the interview guide, it is quoted, so you only confirm or correct.

### C1. Is there really no commission at launch?
Your note: **"şimdilik almıyoruz"**. If so: what does Wellkit earn at launch, and does I2
still stand? It exists to protect the commission. The demo's Ödemeler screen is built
around a 15% cut.
_Was: Q1, q11. Blocks: payments, Ödemeler, the pitch to dietitians._
>

### C2. Plan model: confirm "exchange list first, freeform kept as an option"
Your note: **"Değişim listesi (sonra değişebilir), iki seçenekte kalsın."** Is that a
decision (PLANNING P4 becomes "exchange list is the default, freeform is kept"), or still
waiting on dietitians and Kutay's Excel?
_Was: P4, Q10, q1. Blocks: `diet_plans`, the real plan editor._
>

### C3. Have any dietitian interviews happened? If not, by what date?
If that date passes without them, do we build on the current beliefs (§3) and mark them
reversible?
_Blocks: everything in §3._
>

### C4. Next real slice: the marketplace journey or the plan editor?
The promise is new clients, and no marketplace code exists (no public profile, listing,
request/accept flow or payment). If C2 is confirmed, the editor is unblocked too.
_Blocks: the next build session._
>

### C5. What does a new client's first week look like?
Your note: **"limitli iletişim"**. Fix the order, for example: request → dietitian
accepts → food log → first written plan → …? Is there a live first meeting? When does the
client pay? Is there a free sample? How fast is the first plan due?
_Was: q15. Blocks: onboarding, payment timing._
>

### C6. How does a client get a dietitian?
Pick directly from a list, send a request, or be matched by us? What happens if the
dietitian declines, is full, or doesn't answer?
_Blocks: the marketplace flow._
>

### C7. Ratings and reviews at launch
Your note: **"sadece puanlama olsun yorum yok, tartışılacak, sonradan eklenebilir yeterli
diyetisyen olunca."** Is it ratings only at launch and comments later, or nothing until
there are enough dietitians? What orders the listing?
_Was: q22._
>

### C8. WhatsApp
Your note: **"uygulama içi hatırlatmalar"**, so reminders stay in-app. Should the app
also import leads that arrive through a dietitian's WhatsApp, or is WhatsApp out
entirely?
_Was: Q7, q9._
>

### C9. Bringing over a dietitian's existing clients: "we'll do it"
Your note: **"entegresini biz yapıcaz."** Is that a white-glove service at launch (we
type in their clients / Excel templates by hand)? Who does the work, and is it free?
_Was: q20._
>

### C10. Sports clients: confirm "no PT, a short weekly summary"
Your note: **"tam olarak girilmiyor ama fikir edinecek kadar haftada ne yapıyor, kısa bir
özet."** So no PT and no device integration, just a weekly activity note on athlete
clients?
_Was: Q6, q10._
>

### C11. Blood tests: what does "mala yatıyoruz" mean?
That is your note on "when do you refer blood results to a doctor". I can't read it with
confidence. Does it mean "we skip this for now", or "the dietitian handles it"? This is
the regulatory risk in the product, so it needs a clear rule, and possibly legal advice
(§4). Related: I8.
_Was: Q3, Q4, q3–q4._
>

### C12. Is AI needed in the first release?
Must plan drafts be AI-generated at launch, or can dietitians write plans by hand while
the AI is validated? Your note calls AI drafts "gayet iyi, hatta iyi bir feature".
Related: I11.
_Was: q21._
>

### C13. Launch surfaces and addresses
Android, iOS, and/or client web? A domain? The dietitian panel's public URL?
_Was: Q13, Q21._
>

### C14. What result means the pilot worked?
New paying clients, time to first plan, renewals, dietitians who stay? With numbers and
a review date.
>

### C15. Who runs operations?
Who approves dietitians, handles complaints and refunds, and what support address does
a rejected dietitian see?
_Was: Q20._
>

### C16. Separate Supabase dev project?
Today every dev signup lands in the one live project. A second project is free on the
Supabase free tier.
>

---

## 2. Kadir (partner)

Business and market questions, plus everything you marked "kadire at". The same list
(K1–K9, in Turkish) is in the interview-guide artifact, where Kadir can answer directly:
https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB#kadir

- **K1. When do Kutay's Excel plans arrive?** Anonymized example plans plus the intake
  form. Who is Kutay, and what is his specialty? Your note: "bu gelecek". _Was: Q10, q2._
- **K2. What exactly is sold — what is in a package?** Appointments, messages,
  revisions; who sets the price; the minimum price; whether prices are public; rules for
  no-shows, cancellation and leaving halfway. Your note: "aylık ya da 3 aylık ancak sabit
  konulamaz, fiyat pazarlığı, min fiyat; şirketlerle anlaşma ayrı karar". _Was: Q28, q8._
- **K3. How will the first clients find us?** Channels, budget, owner, date; the first
  target audience. Your note: "dijital pazar". _Was: q12._
- **K4. Which dietitians for the pilot, and when are the interviews?** How many, which
  specialties, who runs them, when.
- **K5. Cost analysis and competitor prices.**
- **K6. When do dietitians get paid?** Does faster payout cost more? Installments, and who
  bears their cost?
- **K7. Can you send a real anamnez form?** Your note: "WP'den atıyor". _Was: Q26, q6._
- **K8. Do you already know these, or do we ask dietitians?** Measurements and device
  (DT13), falling-behind thresholds (DT15), the most painful admin task (DT4).
  _Was: Q25, Q27, q5, q7, q18._
- **K9. Logo and icon.** _Was: Q8, Q23._

---

## 3. Dietitians — interview questions

Asked in interview order. The Turkish wording, the reason for each, and Can's current
belief live in the interview-guide artifact, which records notes per interviewee:
https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB. **Critical** means the plan editor
or the payment flow can't be built without the answer.

**Before the demo: how do you work today**
- DT1. How do you find new clients, and what does one cost you? _(q12)_
- DT2. How many active clients at once, and what limits you? Belief: 30–40. _(q14)_
- DT3. Where do you talk to clients now; what would make you leave WhatsApp? _(q9)_
- DT4. Which tools besides Excel; which admin task takes the most time? Belief: payment by IBAN. _(q13, q18)_
- DT5. How does first contact happen: in person, video, no live meeting? Belief: limited contact. _(q15)_
- DT6. **Critical.** Sessions or packages; what's in a package; leavers; no-show fees? _(q8, Q28)_

**How a plan is built** (ask them to show a real one)
- DT7. **Critical.** Exchange list or food + amount? Belief: exchange list. _(q1)_
- DT8. **Critical.** Own group table and units, or a ready-made table? Where do kcal values come from?
- DT9. How long does a plan take; how much is copy-paste? Belief: mostly copy-paste. _(q16)_
- DT10. **Critical.** Daily, weekly or monthly; are old plans kept; should the client see them? Belief: weekly, ready-made plans, client can't see old ones. _(q17)_
- DT11. Which energy formula? (panel uses Harris-Benedict × activity factor)
- DT12. **Critical.** What does the anamnez really ask; which answers change the plan? _(q6, Q26)_
- DT13. Which measurements, device, frequency, BIA; who weighs the client? _(q7, Q27)_
- DT14. **Critical.** What happens with blood tests; which values; when is a doctor's referral required? _(q3–q4, Q3–Q4)_

**During the demo** (on the named screen)
- DT15. Genel Bakış: what do you check first on Monday; when is a client "falling behind"? _(q5, Q25)_
- DT16. Danışanlar: with 40 clients, which column is essential?
- DT17. **Critical.** AI taslağı: what must you see before signing an AI draft; what would make you never use it? Belief: a good feature. _(q21)_
- DT18. Hatırlatmalar: are app notifications enough, or is SMS required? _(Q15)_
- DT19. Ödemeler: reaction to payments going through the platform; what would you need to see? Ask the commission part after C1. _(q11)_
- DT20. Pazaryeri: ratings, disputes, who ranks first? _(q22)_

**After the demo**
- DT21. Which screen would make you switch, and what is still missing? _(q19)_
- DT22. Biggest objection to telling existing clients to install the app; would our importing your templates change it? _(q20)_

---

## 4. Checks — not questions

Facts to verify. Claude or Codex can do most of them; a few need Can's hands.

- **X1. Is email confirmation on in the live Supabase project?** (Can: Dashboard →
  Authentication → Sign In / Providers → Email, about 1 minute.) Invites (#102) depend
  on it. _Was: Q29._
- **X2.** Do iyzico and the app stores allow the chosen package, commission and payout
  flow? After C1 and K2.
- **X3.** Video SDK proof of concept, once the video scope is clear. _Was: Q5._
- **X4.** KVKK and legal review of the real data flows (consent, retention, deletion,
  AI provider), and the account-deletion flow. Before real health data. _Was: Q22._
- **X5.** Test/prod separation, backups, store accounts, signing. Before external beta.

---

## 5. Parked

Not asked now; reopen when their phase starts.

- AI-only tier price and contents. _Q2._
- l10n (Q12), SMS OTP login (Q15), photo source (Q23), client web preview width (Q24).
