# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 23 September 2026.

## Where things stand

- Phase 0 is done: both apps have real Supabase auth. The **client app** has login, a
  two-tab home, invite accept/decline and the "Hedeflerim" form. The **real panel** has a
  client list, email invites and a thin client detail screen (PLANNING §5).
- The **interview demo** (`apps/dietitian_panel/lib/main_demo.dart`) runs on fake data;
  money UI is hidden (`kShowMoney = false`, P6).
- **23 Sep 2026, second session:**
  - **Android emulator works (#3).** Emulator on Windows, Flutter builds in WSL (own JDK
    21 + Android SDK), mirrored WSL networking. Can registered, confirmed by email and
    signed in to the client app on the emulator. Commands are in CLAUDE.md.
  - **The panel has `android/` and `ios/` runners**, bundle id `com.wellkit.panel`. Its
    debug APK builds; it has not been opened on the emulator yet.
  - **Email confirmation is on** (#21; X1 closed).
  - Can's verdict on the client app running on a phone: **it looks dull and lifeless**.
    The next session is a design plan, not code (step 1).
- Earlier the same day: docs restructured, Codex's UI review applied (#119, #120), Can's
  decisions and the interview answers recorded (P2, P4, P6, #38, #121–#130). Every answer
  from 23 Sep is listed in QUESTIONS.md "Answered on 23 Sep" as open to correction.
- Analyzer clean, all tests green (core 4, client 7, panel 47).

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Interview guide | Can and Kadir during interviews; notes are shared and tagged per dietitian | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN) | Understanding the whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y |
| Project overview (TR) | The same, for Kadir | https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | The 11 demo screens with one question each | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |
| Design system (history) | The 28 Aug design decisions; the source is now `docs/design-system.md` | https://claude.ai/code/artifact/1d9436dc-cd7c-4639-a4ec-9459de2d8ea3 |

The interview guide mirrors QUESTIONS.md §2 (K) and §3 (DT) with the same numbers. After
an interview, ask Claude to "read the guide notes"; it moves the answers into QUESTIONS.md
and PLANNING.md.

## Next steps

1. **Next session: plan the UI redesign (Can, 23 Sep).** On a real phone the client app
   reads as dull and not alive. Plan mode, no code until Can approves the plan. Inputs:
   `docs/design-system.md` (its 14 rules and palette are the current contract; change them
   only by Can's decision, recorded there and in PLANNING #54–#67), Can's design
   references (promised since 28 Aug; ask for them), and the emulator for looking at real
   screens. The plan should say which sections each app's screens need, what "alive"
   means within the rules, and the order of slices. The mobile panel layout (below)
   should follow the redesign, not precede it.
2. **The mobile panel layout** (#38): bottom bar and stacked screens below a width
   breakpoint, comfortable density on phones. Codex's inventory of what assumes desktop
   is in `docs/research/2026-09-23-decisions-review.md` (compact density hard-coded in the
   panel's `main.dart`, rail-only shells). Now checkable on the emulator.
3. **Small fix:** the client home's first card says "planınızı birlikte oluşturun"
   (`apps/client/lib/home/client_home_screen.dart:91`), the formal "siz"; the client app
   uses "sen" (#48). Fold it into the redesign.
4. **Can + Kadir:** give Kadir edit access to the interview guide (Share menu) and ask
   K1–K3, K2 first (is the intake form athletes-only?).
5. **Can:** the rest of the interview answers (DT1, DT7, DT8, DT10, DT15), then §0
   (I1–I16), C4 (B2B timing and bulk enrolment) and C8 (listing order).
6. **Can:** re-check QUESTIONS.md "Answered on 23 Sep" after the next talk with Kadir.
   The panel tour's shared link shows a pinned older version: re-pin it from its Share
   menu if viewers should see the update.
7. **Build later:** the "Diyetisyen bul" journey or the real plan editor on `diet_plans`,
   keyed off `dietitian_client_relationships`.
8. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), custom SMTP (for password reset and non-team signups), RLS access tests, invite
   email delivery, ending a relationship, Randevular rows overflowing below ~900 px.
