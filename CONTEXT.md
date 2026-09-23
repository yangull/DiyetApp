# Wellkit — Domain Glossary

The words this product is built out of. Turkish terms keep their Turkish names in
code and conversation; there is no English translation layer, because the users
are Turkish dietitians and their clients.

Terms marked ⚠️ are **not settled**. They come from desk research, not from a
dietitian, and the first interviews exist to confirm or kill them. Do not treat a
⚠️ term as a decision.

Product and technical decisions live in `PLANNING.md`. State of play and open
questions live in `HANDOFF.md`; traps in `CLAUDE.md`. This file only defines vocabulary.

---

## The two sides

**Diyetisyen (dietitian).** The paying professional. Gets a management panel plus
marketplace visibility. Verified before they can be found: a `verification_status`
of `pending` / `approved` / `rejected`, approved only by an admin.

**Danışan (client).** The person following a plan. Reaches a dietitian through the
marketplace, or takes the AI-only tier without one. Addressed informally ("sen");
the dietitian is addressed formally ("siz").

**Komisyon (commission).** A platform cut of a paid session. **None at launch:** clients
pay their dietitian directly, outside Wellkit (PLANNING P6). Whether and how Wellkit
earns from sessions is decided later.

**Diyetisyen bul.** The client app section where a client finds and picks a dietitian;
the marketplace's front door. Not built yet.

---

## Diet plans

**Diyet planı (diet plan).** What a dietitian gives a client to eat: in the real
product a **week**, usually started from a template or last week's plan (PLANNING
#123); the demo shows a single day. The central artifact of the product, and the
screen that decides whether dietitians abandon Excel.

There are **two models of what a plan is**, both in the interview demo. The
interviews said dietitians use both, depending on the client: the exchange list is
the default and freeform stays as an option (PLANNING P4, #121).

**Serbest plan (freeform plan)** — `DietPlan` / `Meal` / `MealItem`. Each meal
lists foods and amounts as text: "yulaf ezmesi, 3 yemek kaşığı". The option kept
alongside the default.

⚠️ **Değişim listesi (exchange list)** — `ExchangePlan` / `ExchangeMeal` /
`ExchangeLine`. The Turkish form of the ADA exchange system. Instead of naming
foods, the plan says *how many exchanges from which group at which meal*; the
client picks the actual food from a substitution list. The default plan model,
confirmed in the interviews.

⚠️ **Değişim grubu (exchange group).** One of eight food groups: süt, et,
nişastalı yiyecekler, kuru baklagil, A grubu sebze, B grubu sebze, meyve, yağ.
Every food inside a group is calorie- and macro-equivalent — that equivalence is
the whole point, because it's what lets a client swap without asking.

⚠️ **Değişim (exchange).** One unit from a group, measured in **household
measures** — yemek kaşığı, çay bardağı, kibrit kutusu, "1 köfte kadar" — never in
grams. A plan line is a group plus a count: "öğle: et 2, nişastalı 2".

⚠️ **Değişim listesi tablosu (substitution table).** The group → example foods
mapping, at household measures. **One standard table shared by every dietitian**
(PLANNING #122), not per-dietitian data. Which published table and values is still
open (QUESTIONS DT3); the demo's values are labelled examples.

---

## Intake

**Anamnez.** The intake form a dietitian fills in with a new client: history, habits,
medication, allergies, and so on. The only real example we have is sports-oriented
(`docs/reference/anamnez-ornek.md`); the demo's form is invented.

## AI and approval

**AI taslağı (AI draft).** A plan the model wrote and no human has approved. Has
its own visual state — violet `#514196`, dashed border, text label — used nowhere
else in the app, so violet always and only means "machine wrote this, nobody
approved it". Colour never carries the meaning alone.

**Onay (approval).** The dietitian's act of accepting a draft. The gate the whole
human-service side turns on: **a client never sees an unapproved AI plan**,
enforced in row-level security, not just in the UI. `PlanState` is `aiDraft` or
`approved`, and both plan models above reuse it, so the mechanic is identical in
either editor.

---

## Energy

**BMH — bazal metabolizma hızı (basal metabolic rate).** What a client burns at
rest. Derived from age, sex, height and weight; nothing about it is stored.

**Harris-Benedict.** The formula used to get BMH from those four facts. The
original 1919 constants, because that's what the dietitian's spreadsheet uses.

**Cunningham.** An alternative BMH formula, `500 + 22 × lean body mass`. Not
implemented: lean mass needs a body-fat or bioimpedance reading the app doesn't
collect. Dietitians use it alongside Harris-Benedict, Mifflin-St Jeor and WHO/FAO
(PLANNING #124); the three are to be added as choices.

**FA — fiziksel aktivite faktörü (physical activity factor).** A multiplier from
1.2 (hareketsiz) to 1.6 (çok hareketli), one per `ActivityLevel`. BMH × FA is the
client's daily calorie target.

**Hedef vs planda (target vs planned).** The target is what the client *should*
eat, derived above. The planned total is what the plan actually adds up to. Seeing
both at once is the loop the dietitian currently runs by hand in a spreadsheet —
and the freeform editor can't close it, because its meals carry no calorie data.

## Tracking

**Ölçüm (measurement).** What gets recorded at a check-in. Today only weight.
⚠️ Real practice also takes bel/kalça çevresi (waist/hip circumference) and
bioimpedance — which measurements a given dietitian actually takes is an open
question, and likely per-dietitian configuration rather than a fixed set.

**Makro (macro).** Protein, carbohydrate, fat targets. Currently decorative in the
freeform editor — hand-set, unconnected to the meals below. Under an exchange
model they fall out of the group counts almost for free.
