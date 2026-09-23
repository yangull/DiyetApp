# Wellkit: Codex review of the existing plan

Recorded: 21 September 2026. Status: discussion notes, not an approved replacement plan.

## Latest user answers

- **Confirmed by Can:** the main promise to the first dietitians is **bringing them new clients**, mostly. Managing existing clients is a supporting capability.
- **Unknown to Can:** whether the Miro notes labelled interview summaries are actual interview answers, and whether example Excel diet plans have been obtained. These remain evidence requests for the partner; do not treat them as completed interviews.
- Requested action: save this assessment separately and collect answered and unanswered questions. No implementation or edits to the existing product plan are authorized by these notes.

The detailed register is [Questions and recorded answers](2026-09-21-questions-and-answers.md).

## Sources and limits

- [PLANNING.md](../../PLANNING.md), last dated 30 August 2026.
- [HANDOFF.md](../../HANDOFF.md), [CLAUDE.md](../../CLAUDE.md), and [CONTEXT.md](../../CONTEXT.md).
- Saved Claude planning documents for panel hardening and real client management. These describe largely completed implementation slices, not a newly approved future plan.
- Claude's saved 21 September 2026 Miro report and subsequent comparison, from session `ba39f871-6def-428d-99ea-01993189ade6`.
- Target board: [diyetisyen.xl](https://miro.com/app/board/uXjVH1k8Rq8=/).
- Relevant local model, invitation UI, and migration code. This was a plan review, not a complete code/security audit; tests and live backend settings were not checked in this review.

**Miro access:** no callable Miro tools were available in Codex when this file was written. Plugin discovery found a Miro integration that was not installed; installation/connection was suggested. The live board has NOT been independently re-read by Codex. Board statements below are secondhand quotations from Claude's saved report, not verified interview testimony. The report did not expose author or date metadata for individual notes. Competitor prices and market claims from it are not adopted as current facts.

## Overall judgement

Keep the foundation. The main remaining problems are product scope, incomplete evidence, and an unclear first customer journey, rather than a demonstrated need to replace the stack.

The project has real authentication and client relationships, alongside a richer interview demo. Chat, payments, video, and plan drafting in the demo do not establish that their production services exist. A screen inventory is not an end-to-end launch assessment.

## Decisions I would retain

1. Flutter apps and shared core, Supabase backend, and versioned database migrations. No project-specific evidence from this review justifies replacing them.
2. Dietitian review before delivering an AI-generated plan on the human-service side. Enforce this in data access as well as UI.
3. One general dietitian panel, with appropriate fields for differing workflows, rather than an app per specialty.
4. Human dietitian service before the separate AI-only subscription.
5. Demo and real app as separate entry points, with unverified calculations and reference values clearly marked in the demo.
6. Small working slices, explicit access policies, and independent review of consequential changes.

## Recommendations, updated after Can's answer

### Make the marketplace promise the centre of the first release

My earlier suggestion was to start primarily with dietitians' existing clients. **That is not the agreed direction.** Can confirmed that bringing new clients is the main promise.

Revised recommendation: test a small but complete new-client journey with a few verified dietitians. A candidate journey is discovery -> selection/request -> dietitian acceptance -> agreed service/payment -> intake -> approved plan delivery -> follow-up. The exact order, first-plan promise, and payment timing are still decisions, not assumptions to implement.

The panel should support fulfilling that promise. Existing-client invitations remain useful, but panel convenience alone does not prove that the marketplace works. Acquisition channel, target audience, dietitian capacity, and the reason a client chooses Wellkit now need explicit answers. This changes priorities; it does not authorize new scope.

### Define what is sold before implementing money flows

The demo associates fees with appointments. Reported board notes lean toward monthly/multi-month packages. A package can contain appointments, messages, and plan revisions; an appointment is an event inside that service.

Decide included services, start/end dates, renewal, missed appointments, cancellation, partial refunds, and payout timing before coding real payments. The demo's 15% is a placeholder, not a confirmed rate. Also distinguish marketplace-acquired clients from clients the dietitian brings: their fee treatment is unresolved.

### Do not turn the plan-model question into a false either/or

Exchange calculations and a readable food-and-amount plan could be parts of one workflow. Weekly/monthly duration is a separate decision from how a meal is represented. Custom household units do not, by themselves, prove a particular exchange schema.

Ask for an anonymized example showing client input -> dietitian calculations -> delivered plan -> next revision. Use it to choose the smallest faithful representation. Do not build a universal nutrition system from shorthand notes.

### Preserve approved plan history

The reported board asks to retain previous plans and support weekly/monthly planning. Decide which plan is current, its applicable dates, and how revisions work. Recommended behaviour: a delivered version stays retrievable; an edit creates a draft that needs approval before replacing what the client sees. Changes to reference tables should not silently rewrite historical plans.

### Separate reviewed AI drafts from direct client chat

An AI draft that a dietitian approves and an immediate chatbot response have different supervision. Keep them as separate scope decisions. Before direct client chat, define allowed topics, access to personal data, escalation to the dietitian, response records, and whether the assistant may suggest changing an approved plan. "Fine-tune" on the board describes a desired kind of personalization, not an approved technical method.

### Resolve the order of the first customer journey

Reported notes mention a written program before a live conversation, a three-day food log after agreement, and monthly packages. These can coexist, but the timing is not defined: what does the client receive immediately, what waits for the log, when do they pay, and what happens if the dietitian declines or responds late?

### Measure the marketplace promise

Suggested pilot observations, with targets still to be agreed: qualified visitors -> requests -> accepted/paid clients; time to first approved plan; client return/renewal; dietitian workload and willingness to keep using the service. Do not substitute screen count or demo polish for this evidence. A reviewed cost estimate should cover the chosen acquisition and service model before setting sustainable prices.

## Corrections to earlier interpretations

| Topic | More careful interpretation |
|---|---|
| Interview status | Old docs say interviews have not happened. The newer report contains an interview-summary cluster. Can does not know its provenance. Record uncertainty; ask the partner. |
| Reviews | The quoted `yorum yapma olucak` reads as commenting will exist. Claude's report interpreted it as no reviews, apparently incorrectly. Another quoted note also favours reviews. Confirm policy and timing; do not claim a demonstrated contradiction. |
| Existing clients | Email invitations already provide a basic route for existing clients to join. Bulk import, manual records, and onboarding without an account are separate additional requirements. |
| Custom units | A request for dietitian-specific units supports investigation; it does not establish the final groups, calorie values, or calculation model. |
| Athlete support | Sports nutrition does not automatically mean exercise-coaching/PT is in scope. Clarify them separately. |
| Measurements | A request to record caliper measurements does not establish a validated path from those measurements to every proposed energy calculation. Required inputs and professional workflow remain to be verified. |
| First appointment | A proposed written-plan-first funnel is a new detail to reconcile, but the existing locked decisions do not prove that every client must begin with a paid live appointment. |
| Weekly plans | Exchange-based content can be scheduled across a week. Plan duration and meal representation should not be conflated. |
| WhatsApp | Importing leads, delivering notifications, and conducting the consultation are different functions. A lead-import note does not by itself overturn the in-app consultation decision. |
| Phase labels | Miro's older phase numbers differ from the repository's. Compare deliverables and dependencies, not phase numbers alone. |

## Gaps to address before appropriate release stages

- **Identity verification:** PLANNING §2.2 #21 says email verification is disabled for development, while migration 4's invitation policies trust the email claim. The live setting is unknown. Verify it before relying on real invitations. Supabase confirms that disabling Confirm Email implicitly confirms addresses: [official documentation](https://supabase.com/docs/guides/auth/general-configuration).
- **Operational onboarding:** verification, password recovery, real invitation email delivery, understandable errors, dietitian approval/rejection support, and who operates those processes.
- **Relationship lifecycle:** how a client or dietitian ends the relationship and what happens to future access, ongoing service, and past plans.
- **Testing environment:** worktrees isolate files, not the shared backend. Decide how migrations, test accounts, and real records are separated. Add appropriate automated access-policy checks, backup/recovery checks, and real-device checks as the release becomes concrete.
- **Privacy and scope:** data actually needed for the first service, who sees it, consent/information flows, retention/deletion, and what external providers receive. These are product and professional/legal review questions, not assumptions to resolve with an AI-generated checklist alone.
- **Hosting wording:** EU hosting alone does not establish KVKK compliance. Cross-border transfers have their own requirements. Have the actual proposed data flows reviewed; see [KVKK guidance](https://www.kvkk.gov.tr/Icerik/2053/Yurtdisina-Aktarim).
- **Payments/platform rules:** the existing provider choices and blanket statements about payment exemptions need checking against the exact service before release. This review did not validate current store/provider requirements or contractual eligibility.
- **Failure paths:** declined matches, no response, failed payment, disputed payment, unavailable AI, and a client unable to use the app need deliberate behaviour.

## What does not need reopening now

No basis here to redesign the theme, swap state management, implement catering/B2B/device integrations, or build every speculative board item. Continue to treat future ideas as future ideas unless Can explicitly changes their priority.

The question register distinguishes current product decisions from evidence requests and later work. It is not a demand that every open question be answered before any useful development can continue.

## Change record

- 21 September 2026: saved Codex's assessment separately at Can's request; incorporated the confirmed new-client acquisition priority; retained uncertainty about interview evidence and example Excel files.
- Existing `PLANNING.md`, `HANDOFF.md`, application code, database, and board were not edited by this documentation task.
