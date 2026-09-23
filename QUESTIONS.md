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

Business and market questions, plus everything you marked "kadire at". Candidate for one
`/to-questionnaire` document to send him.

### K1. Kutay's Excel plans: when do they arrive?
Your note: **"bu gelecek."** Anonymized example plans plus the intake form. Also: who is
Kutay, and what is his specialty?
_Was: Q10, q2._
>

### K2. Package pricing: what exactly is sold?
Your note: **"aylık ya da 3 aylık ancak sabit konulamaz, fiyat pazarlığı, min fiyat;
şirketlerle anlaşma ayrı karar"**. What is in a package (appointments, messages,
revisions)? Who sets the price? What is the minimum price? Are prices public? What are
the rules for no-shows, cancellation and leaving halfway?
_Was: Q28, q8._
>

### K3. How will the first clients find us?
Your note: **"dijital pazar."** Which channels, what budget, who owns it, by when? Who is
the first target audience?
_Was: q12._
>

### K4. Which dietitians for the pilot, and when are the interviews?
How many, their capacity, and who talks to them. Your belief: **"kaliteliyse 30–40
sınır, ama bizim sıkımızda çok değil."**
_Was: q14._
>

### K5. Cost analysis and competitor prices
What launch and running costs to expect, and what competitors charge.
>

### K6. Payouts and installments
When do dietitians get paid, and does faster payout cost more? Are installments offered,
and who bears their cost?
>

### K7. Anamnez form: get a real one
Your note: **"bunu WP'den atıyor, Kadir'e at"** — dietitians send it over WhatsApp.
_Was: Q26, q6._
>

### K8. Measurements, device, frequency, BIA
_Was: Q27, q7. (You marked it "Kadir'e at".)_
>

### K9. Triage thresholds: days without a weigh-in, hours unanswered
_Was: Q25, q5. (You marked it "Kadir'e at".)_
>

### K10. The most painful admin task
_Was: q18. (You marked it "Kadir'e at".)_
>

### K11. Logo and icon
The name and palette are settled; the visual identity is not.
_Was: Q8, Q23._
>

---

## 3. Dietitians — interview questions

Merged from the interview-guide artifact (q1–q22). Asked in Turkish, so written in
Turkish. **Belief:** marks what Can currently thinks, for the interview to confirm or
correct.

**Must ask**

- **DT1.** Planı nasıl kuruyorsunuz — değişim listesiyle mi, besin + miktar yazarak mı?
  Ekranınızda gerçek bir planı gösterebilir misiniz? _Belief: değişim listesi. Was: q1._
- **DT2.** Kendi grup tablonuz, kendi ölçü birimleriniz var mı? Kalori değerleriniz
  bizimkilerle uyuşuyor mu?
- **DT3.** Planlar günlük mü, haftalık mı, aylık mı? Eski planlar saklanıyor mu, danışan
  eskisine bakabilmeli mi? _Belief: haftalık, hazır planlar var, danışan eskiyi göremiyor.
  Was: q17._
- **DT4.** Bir plan ne kadar sürede hazırlanıyor, ne kadarı önceki planlardan
  kopyala-yapıştır? _Belief: kopyala-yapıştır. Was: q16._
- **DT5.** Anamnezde gerçekte neler soruluyor, hangi cevap planı değiştiriyor?
  _Was: q6, Q26._
- **DT6.** Kilo dışında hangi ölçümler, hangi cihazla, ne sıklıkla? BİA var mı?
  _Was: q7, Q27._
- **DT7.** Kan tahlili geldiğinde ne yapıyorsunuz, hangi değerlere bakıyorsunuz, ne zaman
  hekim yönlendirmesi şart? _Was: q3–q4, Q3–Q4._
- **DT8.** Pazartesi sabahı ilk neye bakıyorsunuz? Geride kalan danışanı nasıl
  anlıyorsunuz, kaç gün / kaç saat? Proaktif bir "bu danışanı kaybediyorsunuz" uyarısı
  işe yarar mı? _Was: q5, Q25._
- **DT9.** Bir AI taslak hazırlasa, adınızı koymadan önce ne görmeniz gerekir? Neyi
  görürseniz hiç kullanmazsınız? _Belief: iyi bir özellik. Was: q21._
- **DT10.** Tek seans mı, paket mi satıyorsunuz? Pakette ne var, yarıda bırakan danışanla
  ne oluyor, gelmeyenden ücret alınıyor mu? _Was: q8, Q28._

**Ask if there is time**

- **DT11.** Yeni danışanı şu an nasıl buluyorsunuz, bir danışan size neye mal oluyor?
  _Was: q12._
- **DT12.** Danışanlarla şu an nerede konuşuyorsunuz? WhatsApp'ı bırakmanız için ne
  olmalı? _Was: q9._
- **DT13.** Excel dışında hangi araçları kullanıyorsunuz (randevu, ödeme, yazışma)?
  _Belief: ödeme IBAN ile. Was: q13._
- **DT14.** İlk görüşme yüz yüze mi, görüntülü mü, canlı görüşme olmadan mı başlıyor?
  _Belief: limitli iletişim. Was: q15._
- **DT15.** Aynı anda kaç aktif danışan, sizi ne sınırlıyor? _Belief: 30–40. Was: q14._
- **DT16.** En çok vaktinizi alan idari iş hangisi? _Was: q18._
- **DT17.** Mevcut danışanlarınıza "bu uygulamayı indirin" demenin en büyük çekincesi ne?
  Excel/Word şablonlarınızı biz aktarsak kararınız değişir mi? _Was: q20._
- **DT18.** Platform ödemeyi alıp komisyonu kesip size aktarsa ilk tepkiniz ne? Komisyon
  mu, sabit abonelik mi daha adil? _Rephrase after C1. Was: q11._
- **DT19.** Puanlamaya sıcak bakıyor musunuz? Haksız puana itiraz nasıl olmalı? Listede
  kim üstte çıkmalı? _Was: q22._

**After the demo**

- **DT20.** Gösterdiğim ekranlardan hangisi sizi mevcut düzeninizden vazgeçirir, hangisi
  eksik? _Your note: ask after the demo. Was: q19._

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
