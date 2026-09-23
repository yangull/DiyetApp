# Main: reset fixes and decision consistency

23 September 2026 · Review mode · No tracked files edited; no commit

**Both previous reset findings are fixed. The decision update still needs a consistency pass:** active instructions retain the old plan-model blocker, blood-test roadmap, and platform assumptions. The new entries generally match the “Answered on 23 Sep” table; the contradictions are mostly elsewhere in the same documents or in required companion files.

## Reviewed and verified

Read AGENTS.md and all six required references first. Reviewed `git log ff4914b..main` and the cumulative diff, with the preceding C18/C19 review as context. The three commits are:

- `97aa3ed` — Fix the panel UI review findings and use short button labels
- `78f2e82` — Record Can's decisions and the dietitian interview answers
- `a23ff1b` — Mark today's answers as open to correction and follow the new decisions

Reviewed tip: `a23ff1b5157bad2d4647e9dd76e1bc6766b7cecd`. Execution used a clean archive of that commit at `/tmp/decisions-review-20260923`, not either working tree. Analysis passed in all three packages. Existing tests passed: core **4**, client **7**, panel **43**, with the screenshot capture test skipped as configured. No native build, live backend or new visual capture was performed.

The reset handler now resets repository data, invalidates conversation selection, and changes the key of the screen stack ([panel_shell.dart:208](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel_shell.dart:208), [stack key:109](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel_shell.dart:109)). That disposes local filter/draft state and returns to the overview. The added tests explicitly return to the affected screen after reset ([demo_widget_test.dart:170](/home/can/projects/dietician-app/apps/dietitian_panel/test/demo_widget_test.dart:170), [draft test:222](/home/can/projects/dietician-app/apps/dietitian_panel/test/demo_widget_test.dart:222)).

I also reran the independent probes from the preceding review, adjusted to reopen the screen after reset. **All three pass** with the Windows platform variant: custom-goal reset, draft reset, and reaching/sending to the 40th conversation without inheriting another recipient's draft. Logs: `/tmp/decisions-analyze.log`, `/tmp/decisions-test.log`, `/tmp/decisions-probes.log`. Temporary probes were added only to the archive.

## Ranked findings

### 1. Medium · bug/inconsistency — Required startup guidance still blocks the now-approved plan model

**Evidence:** [CLAUDE.md:27](/home/can/projects/dietician-app/CLAUDE.md:27), [CONTEXT.md:37](/home/can/projects/dietician-app/CONTEXT.md:37), [CONTEXT.md:63](/home/can/projects/dietician-app/CONTEXT.md:63), [demo_models.dart:228](/home/can/projects/dietician-app/apps/dietitian_panel/lib/demo/demo_models.dart:228).

CLAUDE says the real editor waits on the plan-model question, although P4 explicitly unblocks it. CONTEXT still defines a plan as one day, calls the model unconfirmed, suggests per-dietitian exchange tables, and says “whichever model wins.” Its Cunningham entry also leaves formula choice open ([line 99](/home/can/projects/dietician-app/CONTEXT.md:99)), despite #124. The model comment falsely attributes the old hypothesis to current P4. A new implementation session could stop unnecessarily or design daily plans and individually owned tables.

**Fix:** Synchronize these passages with P4/#121–124: exchange default plus freeform, weekly real plans, one shared table, and the recorded formula choices. Keep the demo's daily representation and invented exchange values explicitly labelled as implementation limitations; the published table/values remain unresolved. Do not remove the second editor.

### 2. Medium · bug/inconsistency — The roadmap and schema still prescribe the retired blood-test feature

**Evidence:** [PLANNING.md:359](/home/can/projects/dietician-app/PLANNING.md:359), [schema sketch:386](/home/can/projects/dietician-app/PLANNING.md:386), [QUESTIONS.md:69](/home/can/projects/dietician-app/QUESTIONS.md:69).

#125 and the answered DT9 row agree: no dedicated blood-test section; both parties attach files to the shared record. But Phase 1 still schedules blood values, the sketch still contains `blood_tests(values_json, doctor_approval_doc)`, and I6/I8 retain blood-test onboarding and document requirements as decisions in force. An agent following the roadmap could build the feature that the new decision removed.

**Fix:** Replace the roadmap/sketch with the generic attachment direction from #125 and mark the superseded parts of I6/I8 accordingly. Keep genuinely unanswered handling/referral questions in C12/X3 without presenting a structured blood-test feature as approved. This is an internal consistency finding, not an assessment of the legal rationale.

### 3. Medium · bug/inconsistency — #38 conflicts with the older role and density contracts

**Evidence:** [PLANNING.md:192](/home/can/projects/dietician-app/PLANNING.md:192), [#53:228](/home/can/projects/dietician-app/PLANNING.md:228), [#64:254](/home/can/projects/dietician-app/PLANNING.md:254), [design-system.md:59](/home/can/projects/dietician-app/docs/design-system.md:59), [unqualified control sizes:92](/home/can/projects/dietician-app/docs/design-system.md:92).

#38 and the answered rows correctly specify two store apps and width-based layouts. #37 still says “the mobile app always creates client”; #53 mandates a rail without a width qualification; #64 and the design tables equate the entire panel with compact density. Following those older rules for the new dietitian phone app would produce the wrong role contract or undersized controls.

**Fix:** Name roles by app identity, not platform: client app → client; dietitian app → dietitian on every target. Qualify rail/compact rules as wide-layout rules and label the density tables by profile, including comfortable for panel phones. Existing signup code already uses `asDietitian: true` independently of platform ([signup_screen.dart:46](/home/can/projects/dietician-app/apps/dietitian_panel/lib/auth/signup_screen.dart:46)); no role-routing bug was found.

### 4. Medium · bug/inconsistency — The unresolved exchange-table source disappeared from the question list

**Evidence:** [PLANNING.md:73](/home/can/projects/dietician-app/PLANNING.md:73), [QUESTIONS.md:42](/home/can/projects/dietician-app/QUESTIONS.md:42), [remaining interview questions:203](/home/can/projects/dietician-app/QUESTIONS.md:203).

#122 explicitly says the published table and values are still to be named. The answered row closes DT3 after answering only shared versus per-dietitian ownership, and the remaining questions omit its original source/value question. Someone preparing the next interview from QUESTIONS alone will miss an input needed to replace the example constants.

**Fix:** Retain the answered ownership decision and restore the unresolved source/version/values portion under DT3 in QUESTIONS. Continue labelling the current constants as examples until that answer arrives; do not invent a standard table.

### 5. Low · bug/inconsistency — The demo still offers SMS despite push-only #127

**Evidence:** [settings_screen.dart:65](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/settings_screen.dart:65), [appointments_screen.dart:30](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/appointments_screen.dart:30), [demo_codec_test.dart:20](/home/can/projects/dietician-app/apps/dietitian_panel/test/demo_codec_test.dart:20).

The decision and answered DT13 row match, but the interview screen still lets the dietitian select SMS and changes the appointment heading to advertise it. The codec test preserves that choice. This is existing demo behavior left behind by the new decision, not evidence that real SMS is sent. It can still mislead the next interview.

**Fix:** Present push as the sole supported channel, normalize previously stored SMS selections, and update the persistence expectation. This does not require implementing push delivery now. If the old selector is deliberately retained for research, explicitly label it as an alternative to the current decision.

### 6. Low · bug/inconsistency — P2 is simultaneously confirmed and awaiting confirmation

**Evidence:** [PLANNING.md:42](/home/can/projects/dietician-app/PLANNING.md:42), [P2:50](/home/can/projects/dietician-app/PLANNING.md:50), [QUESTIONS.md:66](/home/can/projects/dietician-app/QUESTIONS.md:66).

The section preamble still puts P2 among decisions awaiting re-confirmation, although P2, the answered C5 row and checked I2 say it was confirmed. A new session can reopen a settled question unnecessarily. I2 also retains an emergency external-link exception that the current P2 wording does not mention.

**Fix:** Remove P2 from the outstanding confirmation list while preserving the general “open to correction” rule. Carry the recorded emergency-backup qualification consistently into P2, or explicitly identify that qualification as unresolved rather than silently dropping it. Minor related index cleanup: CLAUDE's opening reference still ends at #118/P5, and PLANNING's header still ends at P5 rather than P6.

## Remaining web/desktop assumptions

These are an implementation inventory for the explicitly scheduled mobile slice, not a demand to complete it in these commits. HANDOFF already schedules mobile after editor layout and acknowledges appointment overflow.

| Location | Current assumption and concrete next action |
|---|---|
| [pubspec.yaml:2](/home/can/projects/dietician-app/apps/dietitian_panel/pubspec.yaml:2), [dependency comment:18](/home/can/projects/dietician-app/apps/dietitian_panel/pubspec.yaml:18) | Explicitly says “Flutter Web only” and cites #38 as justification. Update both descriptions. Keep the conditionally used `web` dependency for browser demo storage. |
| [app_density.dart:23](/home/can/projects/dietician-app/packages/core/lib/src/theme/tokens/app_density.dart:23), [app_theme.dart:45](/home/can/projects/dietician-app/packages/core/lib/src/theme/app_theme.dart:45), [screenshots_test.dart:86](/home/can/projects/dietician-app/apps/dietitian_panel/test/screenshots_test.dart:86), [export_plan_button.dart:42](/home/can/projects/dietician-app/apps/dietitian_panel/lib/widgets/export_plan_button.dart:42) | Comments tie comfortable to the client app, compact to the web panel, the panel to a mouse, and printing to a browser. Scope comments to layout/density or the particular desktop capture. The printing call itself uses `Printing.layoutPdf`, not a direct browser API. |
| [main.dart:39](/home/can/projects/dietician-app/apps/dietitian_panel/lib/main.dart:39), [main_demo.dart:31](/home/can/projects/dietician-app/apps/dietitian_panel/lib/main_demo.dart:31) | Both apps unconditionally select compact density; the missing-config screen does too. Add width-based profile selection during mobile work. Theme code already supports the comfortable profile and padded targets. |
| [real_panel_shell.dart:38](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel/real_panel_shell.dart:38), [panel_shell.dart:38](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel_shell.dart:38), [real_overview_screen.dart:242](/home/can/projects/dietician-app/apps/dietitian_panel/lib/panel/real_overview_screen.dart:242) | Both shells always use a rail; the real client list remains a multi-column table. Add the specified phone navigation and stacked rows. Demo messages hide the context column at narrower widths but still retain a 240px conversation list beside the thread ([messages_screen.dart:63](/home/can/projects/dietician-app/apps/dietitian_panel/lib/screens/messages_screen.dart:63)); phones need list-to-thread navigation. Fixed appointment/editor rows also await the scheduled responsive work. |
| [.metadata:14](/home/can/projects/dietician-app/apps/dietitian_panel/.metadata:14) and tracked platform directories | Only the web runner exists; no panel `android/` or `ios/` runner is tracked. Generate native scaffolding and assign separate bundle IDs before native builds. PLANNING already acknowledges the missing panel bundle ID; changing target wording alone does not make store builds available. |
| [demo_store.dart:8](/home/can/projects/dietician-app/apps/dietitian_panel/lib/demo/demo_store.dart:8), [demo_store_stub.dart:1](/home/can/projects/dietician-app/apps/dietitian_panel/lib/demo/demo_store_stub.dart:1) | Browser demo persistence is conditional; native uses a no-op store and starts from seeds on restart. This is now explicitly documented as a demo limitation, not a production-web restriction. Real auth/data do not depend on that store. |

No unconditional browser import was found in the real-panel path. Web-first development commands and a laptop-sized interview capture remain valid; neither contradicts mobile shipment. Earlier dated research reviews describe their reviewed state and should not be rewritten as current specifications.

## Decision cross-check

| Entries | Match to the answered table |
|---|---|
| #119–120 | Match C18/C19: accepted fix sequence and short button verbs. Both reset follow-ups now pass. |
| P2, P4, #38 | Main entries match C5, C1 and the two platform rows. Remaining conflicting guidance is listed above. |
| #121–123 | Match both models, one table and weekly/copied plans with prior plans hidden. Table-source question remains open. |
| #124 | Matches all four formulas. QUESTIONS transparently records the interpretation of conflicting ticks; this review does not independently verify the interview notes. |
| #125–129 | Match attachments, AI approval information, push-only reminders, list columns and stars-only ratings. Blood-test remnants and SMS UI are the inconsistencies above. |
| #130 | Matches current tools, reasons to switch, client migration and B2B bulk enrolment. DT1's time sink and DT15's missing features remain open appropriately. |
| DT8 and next slice | The reversible measurement default matches; editor layout → mobile panel ordering agrees across QUESTIONS and HANDOFF's numbered next steps. |

No new product rule is proposed. The outstanding work is to make the existing accepted direction unambiguous and keep the scheduled implementation gaps distinct from completed behavior.
