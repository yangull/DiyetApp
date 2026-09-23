# Decision fixes — verification of 7aeff0c

23 September 2026 · Review mode · No code edits or commit

**Verdict: the six previous findings are addressed in substance. No blocking code defect found in this commit. One minor documentation inconsistency remains.**

## Scope

Reviewed `a23ff1b..7aeff0c` after reading AGENTS.md and its required references. Both local branches remain at `7aeff0cfe7553ce27c704f26ce0e5cd65a0cead2`; the main checkout has no uncommitted application changes. The shared plan-editor layout from original UI finding #10 is still listed as the next build and has no new implementation to review. This report verifies the decision fixes, not that future layout.

## Previous findings

| Finding | Result |
|---|---|
| Plan-model guidance | CLAUDE, the glossary prose and model comment now say exchange by default, freeform retained, weekly real plans and a shared table. Formula choices are recorded. Minor marker issue below. |
| Retired blood-test feature | Roadmap and schema sketch now use generic relationship attachments; I6/I8 mark the superseded parts and retain the unanswered handling question. |
| Platform contracts | Role is now tied to app identity on every platform. Rail and compact density are scoped to wide screens; the design tables include comfortable panel phones. |
| Missing DT3 follow-up | The published table/source/edition and values question is restored; the answered row explicitly distinguishes it from settled table ownership. |
| SMS option | Removed from settings, repository mutation, model and codec; appointments consistently describe app notifications. No remaining `setChannel` or `reminders.channel` references found. |
| P2 confirmation | Removed from the awaiting-confirmation list; the emergency-backup qualification is present. Decision-ID headers are updated. |

The reminder model change correctly bumps the codec schema from 5 to 6. Under the existing #68 policy, old stored demo sessions fall back to seeds; this is a full demo-state reset, not a migration preserving prior edits. It prevents an old SMS selection surviving and is consistent with the documented prototype policy.

## Remaining finding

### 1. Low · bug/inconsistency — The confirmed model still carries an “unsettled” marker

**Evidence:** [CONTEXT.md:7](/home/can/projects/dietician-app/CONTEXT.md:7) defines every warning-marked term as not settled and says not to treat it as a decision. [CONTEXT.md:50](/home/can/projects/dietician-app/CONTEXT.md:50) still marks “Değişim listesi” that way while its revised text explicitly calls it the confirmed default.

**Scenario:** A new session following the glossary legend still receives conflicting instructions about whether the exchange model is approved, despite the corrected prose and P4.

**Concrete fix:** Remove the marker from the confirmed model entry, or attach an explicit uncertainty note only to the still-unresolved published table, units and values. Preserve that real uncertainty under DT3. This does not block the next editor-layout slice.

## Verification

Used an isolated archive at `/tmp/decisions-closure-7aeff0c`:

- `dart run melos run analyze`: passed in all three packages.
- `dart run melos run test`: **54 passed** — core 4, client 7, panel 43; the normal screenshot test remained skipped. Both reset regression tests passed.
- Regenerated and visually inspected `11-hatirlatmalar.png`: readable push-only explanation, no SMS selector, reminder switches retained. Capture test passed.

Logs: `/tmp/closure-analyze.log`, `/tmp/closure-test.log`, `/tmp/closure-screen.log`. No backend requests or native builds were performed. The already-documented mobile layout and native-runner gaps remain scheduled work, not regressions introduced here.
