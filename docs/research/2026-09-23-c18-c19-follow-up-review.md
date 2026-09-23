# C18/C19 — follow-up UI review

23 September 2026 · Review mode · No application code edited

The intended fixes are substantially successful. The exchange totals are readable, the freeform macro summary is honest about its limitations, and the controls and Turkish copy are more consistent. The conversation list now works with 40 clients and drafts stay with their recipients. **Fix the new goal-filter reset regression before calling C18 complete.** A smaller, pre-existing reset issue is listed separately below.

## Scope and evidence

Reviewed Claude’s uncommitted changes in `/home/can/projects/dietician-app`, against base `ff4914b7c7081b6828ff3fd6c783a48a63dd8cf3`, including the untracked Turkish helper and its test. Read the repository instructions and required product/design references, the changed demo screens, real panel and shared theme. PLANNING #119 defines C18’s accepted scope; #120 settles C19’s short button verbs with “siz” in panel sentences.

All execution used a separate source snapshot at `/tmp/c18-c19-review`, preserving both working trees. Its 192 source-file hashes still matched Claude’s checkout at the final verification. Reviewed diff SHA-256: `7f50dfcf6268cc8285c4e1ddd1374b8d424a7e49626ce9eb4f50b059d86fd3db`.

- `dart run melos run analyze`: passed in all three packages.
- `dart run melos run test`: passed — core 4, client 7, panel 41; one screenshot test skipped by the normal run.
- Requested screenshot generation: passed separately; visually inspected all 11 generated PNGs, `01-genel-bakis.png` through `11-hatirlatmalar.png`. They are in the snapshot’s `apps/dietitian_panel/test/goldens/`.
- Additional temporary widget probes at 1600×900 with the Windows platform variant: the 40th conversation was reachable, its composer did not inherit Elif’s draft, and sending reached only the selected recipient. Two reset probes failed as described below.

These are Flutter widget/capture checks, not a live browser or backend session. Real-panel findings were assessed from code and the existing tests; no live accounts or data were touched. Temporary probes and their final output are `/tmp/c18-c19-review/apps/dietitian_panel/test/review_probes_test.dart` and `/tmp/c18-review-probes-final.log`.

## Ranked findings

### 1. Medium · bug/inconsistency — Reset can break the new goal dropdown

**New regression.** [clients_screen.dart:109](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/clients_screen.dart:109), with filtering at [line 40](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/clients_screen.dart:40). Screen: `02-danisanlar.png`; requires interaction beyond its initial state.

**Scenario:** Add a client with a goal not present in the seeded data, such as “Özel hedef” (the existing intake form allows free-text goals). Return to Danışanlar, select that goal, then confirm Sıfırla. Reset removes the added client and goal, but `_goal` survives in the mounted screen. `DropdownButtonFormField` receives an `initialValue` absent from its items and throws the “exactly one item” assertion. The temporary probe reproduced this. Independently of assertions, the retained filter also excludes every seeded client.

**Concrete fix:** Clear an unavailable goal when the data resets or changes, and synchronize the form field’s internal selection with that cleared state. Use the same validated selection for the list predicate and dropdown. Add a regression check that resets after choosing a newly introduced goal and verifies both “Tüm hedefler” and the seeded clients return without an exception. The old filter already retained stale state; replacing it with the stricter dropdown introduces the assertion failure.

### 2. Low · bug/inconsistency — Reset leaves unsent conversation text behind

**Pre-existing behavior retained by C18; not a new recipient-mixing defect.** [messages_screen.dart:38](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/messages_screen.dart:38), [panel_shell.dart:195](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel_shell.dart:195). Screen: `09-mesajlar.png`.

**Scenario:** Type a draft in Elif’s composer, confirm Sıfırla, then inspect the composer. The draft remains. The reset dialog promises that all changes from the interview are removed, but resetting the repository does not dispose the mounted screen or clear its controller map. The temporary probe reproduced the retained text. Before C18, the single controller also lived outside reset; C18 correctly isolates drafts by client but retains this lifecycle gap.

**Concrete fix:** Have confirmed demo reset also clear/dispose the conversation drafts and reset conversation selection, using a reset signal or a new session key for the stateful demo screens. Do not clear drafts on ordinary repository updates or conversation switches. Test that reset removes a draft while normal navigation preserves it. This is cleanup for repeated demo interviews, not evidence of real messages being sent incorrectly.

## Closure of the original review

| Original findings | Follow-up assessment |
|---|---|
| #1–2: drafts and conversation scrolling | Fixed for ordinary use. The additional 40-client interaction probe passes. Reset caveat above. |
| #3: exchange typography | Fixed in the regenerated capture; both headline numbers render. |
| #4: misleading macro summary | Fixed by explicit sample-target and energy-target labels. |
| #5: dirty intake cancellation | Guard now covers cancel/back with a discard confirmation. |
| #6–7: declined invites and real-panel errors | Status-specific fallback, readable errors and relevant retry actions are present, including name-fetch failure. |
| #8: task-oriented triage | Message links select the client; measurement links open the weight section. Appointment links open the appointments tab, without selecting/highlighting an exact appointment. Useful improvement; that last detail remains partial. |
| #11: weight chart spacing | X coordinates now use elapsed time between measurements. |
| #13: control consistency | Shared outlined/text-button, chip and input styling improves consistency. The client search/filter row now aligns. |
| #14 and C19: Turkish | Turkish casing and decimal formatting are corrected in the reviewed displays. Short button verbs follow the newly accepted rule; explanatory panel sentences retain “siz.” |
| #15: reminder navigation | Settings are now a named utility below the daily-work destinations. |
| #9, #10, #12 | Deliberately deferred by PLANNING #119: real-client search when needed, editor layout next, compact reports after interviews. Not blockers for this patch. |

Across the captures, the calm palette, heading hierarchy and compact client table remain effective. The detail/measurement screens are legible; the intake flow remains clearly grouped; appointment actions retain visible labels; the message workspace preserves useful client context. Reports are still tall and the editors still have different layouts, as the accepted sequence anticipates. The reminder screen now reads as settings in both its heading and navigation.

No demand is made for demo/real feature parity, money features, settled plan-model choices, or validated clinical demo values. No change to the known green/ochre semantics is proposed.

## Brainstorm

Opinion, not additional acceptance criteria: make “reset starts a fresh interview” one small interaction contract across the demo, covering filters, drafts and selected client as well as repository data. That would protect future demo screens from the same state-lifetime mismatch. When appointment triage is refined, briefly highlight the originating appointment so a dietitian with 40 clients can immediately see why the tab opened.
