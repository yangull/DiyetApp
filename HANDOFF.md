# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 24 September 2026 (late evening).

## Where things stand

- Phase 0 is done: both apps have real Supabase auth, the client app has invites and
  Hedeflerim, the real panel has a client list, invites and a thin client detail
  (PLANNING §5). The **interview demo** (`lib/main_demo.dart`) runs on fake data; money
  UI is hidden (`kShowMoney = false`, P6).
- **Look:** "Sade" (#133) in both apps. On 24 Sep the panel took it screen by screen
  (slices 1–9), then an alignment pass (10–11b), and the client app its own (slice 12,
  `6fc7dfb`: one left edge, core `EdgeButton` for text buttons that sit on an edge).
- **Can's verdict the same evening:** aligned is not the same as premium. Randevular at
  1800 px had columns that lined up but actions spread across the window. Can wants a
  **UI revamp**: "more premium, good to the eye, not like someone without experience",
  starting with the panel, in a new session with Can's reference screenshots (prompt
  reviewed in chat, 24 Sep evening). Decided for Randevular and Genel Bakış (PLANNING
  #133): agenda by day, time first, actions grouped at the right end, readable width,
  rare actions in a labelled ⋯ menu.
- **Parked in `git stash`** ("Randevular agenda (WIP…)"): a first cut of that agenda.
  Wide layout done and tested; one phone test fails (the video-call test can't find
  "Görüşmeye başla" at 360 dp, 2×). Continue it inside the revamp or drop it once the
  revamp redraws Randevular: `git stash show -p stash@{0}`.
- **Review of slices 10–12** (Claude subagent, 24 Sep evening). Its button-padding point
  was verified and fixed in slice 12; these are still open and **not yet checked against
  the code**: the real panel's profile and client detail have no
  1100 px cap (`real_profile_screen.dart:21`, `real_client_detail_screen.dart:62`);
  Genel Bakış's "Danışanı aç" column is ~2 px too narrow just above its 1000 px
  breakpoint (estimate); stacked rows use `EdgeInsets.only(left:)` instead of
  directional; the demo's first appointment (now + 2 h) lands after midnight when the
  demo opens after 22:00. The revamp may redraw these screens anyway.
- **Tests:** core 14, client 18, panel 181.
- **Where to see it:** the emulator ("Wellkit" / "Wellkit Panel"), `flutter run -d
  web-server … -t lib/main_demo.dart` on localhost:8080 (restart it after pulling: a
  server started earlier keeps serving old code), captures in
  `C:\Users\jhana\Pictures\Wellkit Sade panel 24 Sep\` and `…\Wellkit slice 12\`.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Redesign canvas | The three directions, the before screens and the coded result ("Sonuç" row) | https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |
| Interview guide | Can and Kadir during interviews; notes are shared and tagged per dietitian | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN) | Understanding the whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y |
| Project overview (TR) | The same, for Kadir | https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | The 11 demo screens with one question each (**pre-Sade colours**) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |
| Design system (history) | The 28 Aug design decisions; the source is now `docs/design-system.md` | https://claude.ai/code/artifact/1d9436dc-cd7c-4639-a4ec-9459de2d8ea3 |

The interview guide mirrors QUESTIONS.md §2 (K) and §3 (DT) with the same numbers. After
an interview, ask Claude to "read the guide notes"; it moves the answers into QUESTIONS.md
and PLANNING.md.

## Next steps

1. **UI revamp (new session, Can's prompt + screenshots):** explore two rendered
   directions for Genel Bakış (before/after on an artifact page, since Can can't see chat
   images), Can picks, then Genel Bakış and Randevular become the reference screens.
   Time-box it: after those two, decide how far to roll out before data features.
2. **Refresh the panel tour artifact** after the revamp, not before (it still shows
   pre-Sade colours; Kadir and dietitians see it).
3. **Can answers C23** (what "more hooky" means for the client app) before the client
   app's turn in the revamp.
4. **The data features that bring Bugün to life**, each planned on its own before code.
   Claude recommends **weigh-ins first** (smallest complete feature, sets the
   relationship-keyed table + RLS + P9 pattern, needs no DT3), then `diet_plans` +
   Planım (needs C13, C21, DT3 or "örnek" values), meal logs, chat. Can hasn't chosen
   between that and plans-first.
5. **Before new health-data tables:** C17 (a separate Supabase dev project), CI
   (analyze + test on GitHub), RLS access tests.
6. **The real panel on the emulator:** sign up in the panel app, approve the account in
   the Supabase dashboard (#35), then check its screens at phone and wide size.
7. **Small follow-ups:** tablets (600 dp+) use the compact layout without touch padding;
   `Fraunces-SemiBold.ttf` can be deleted; launcher icons are still Flutter's; the
   Mesajlar context panel ends at its content while the list runs full height.
8. **Can + Kadir:** give Kadir edit access to the interview guide and ask K1–K3, K2 first.
9. **Can:** DT3 and C13 are the most blocking answers (plans); then C21, C17, DT7, C4.
   The full ranked list was given in chat on 24 Sep; QUESTIONS.md is the source.
10. **Unblocked any time:** custom SMTP, invite email delivery, ending a relationship.
