# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 24 September 2026.

## Where things stand

- Phase 0 is done: both apps have real Supabase auth, the client app has invites and
  Hedeflerim, the real panel has a client list, invites and a thin client detail
  (PLANNING §5). The **interview demo** (`lib/main_demo.dart`) runs on fake data; money
  UI is hidden (`kShowMoney = false`, P6).
- **Look:** "Sade" (#133): one green accent, grey ground, white borderless cards,
  Figtree only. The client app got it on 23 Sep; **the panel got it screen by screen on
  24 Sep** in nine committed slices (plus 4a–4c), each checked on the emulator at phone
  and wide size:
  1. plan editors fit on phones; 2. shell (white rail, no grey band); 3. pills: every
  button a pill, `OutlinedButton` = pale-green secondary, borderless status pills,
  "Onaylı" grey with a black tick, red destructive confirms; 4a–c. Genel Bakış in green
  and amber, date + greeting + tappable counts line, fixes from Codex; 5. Danışanlar:
  search + "Filtrele" sheet on phones, borderless chips, rows that grow; 6. Randevular:
  one green action per row; 7. Mesajlar: title, unread without colour, thread on the
  ground; 8. app names "Wellkit" / "Wellkit Panel"; 9. sweep (intake form on phones,
  video mockup, settings, AI banner tint).
  Can's taste calls (C24–C30, C27–C29) are recorded in PLANNING #133.
- **Reviews:** a Claude subagent reviewed slices 1–3 and Codex slices 1–4b
  (`docs/research/2026-09-24-panel-sade-review.md`, `…-review-codex.md`). Every finding
  was checked against the code; the valid ones are fixed.
- **Tests:** core 14, client 14, panel 159 (98 this morning). New: phone tests for the
  plan editors, intake form, filters, past appointments, the keyboard-open thread and
  the video mockup; a clipping check (`test/text_fits.dart`); colour guards for Genel
  Bakış and Randevular.
- **Where to see it:** the emulator ("Wellkit Panel" in the app list), `flutter run -d
  web-server … -t lib/main_demo.dart` on localhost:8080, or before/after screenshots in
  `C:\Users\jhana\Pictures\Wellkit Sade panel 24 Sep\` (`once`, `sonra\1…9`).

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

1. **Refresh the panel tour artifact** with the Sade screens (it shows the old colours
   and is what Kadir and dietitians see). Also the canvas's "Sonuç" row.
2. **Can answers C23:** what "more hooky" means for the client app (visual, interaction,
   or both). It shapes the next client-app design session.
3. **The data features that bring Bugün to life**, each planned on its own before code:
   `diet_plans` + the client's Planım tab and a meal count on Bugün; meal logs (P7) with
   the weekly count; weigh-ins (P8); chat. Keyed off `dietitian_client_relationships`.
   P9 (hide numbers per client) lands with the first of them.
4. **Can answers C21** (how much plan editing on a phone); it blocks the panel's phone
   plan screen.
5. **The real panel on the emulator:** sign up in the panel app, approve the account in
   the Supabase dashboard (#35), then check its screens at phone and wide size.
6. **Small follow-ups:** tablets (600 dp+) use the compact layout without touch padding;
   `Fraunces-SemiBold.ttf` can be deleted now that Sade is settled; launcher icons are
   still Flutter's (logo placeholder, PLANNING §5); on phones the first client row draws
   its top divider against the card edge.
7. **Can + Kadir:** give Kadir edit access to the interview guide and ask K1–K3, K2 first.
8. **Can:** the rest of the interview answers (DT1, DT7, DT8, DT10, DT15), then §0
   (I1–I16), C4 and C8.
9. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), custom SMTP, RLS access tests, invite email delivery, ending a relationship.
