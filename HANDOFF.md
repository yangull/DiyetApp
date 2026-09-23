# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 24 September 2026 (just after midnight).

## Where things stand

- Phase 0 is done: both apps have real Supabase auth, the client app has invites and
  Hedeflerim, the real panel has a client list, invites and a thin client detail
  (PLANNING §5). The **interview demo** (`lib/main_demo.dart`) runs on fake data; money
  UI is hidden (`kShowMoney = false`, P6).
- **23 Sep 2026, third session: the "Sıcak" redesign, planned and coded.**
  - Can found the client app dull on a phone. Claude compared it against Lifesum and
    MyFitnessPal (App Store screenshots; Can has no reference images of his own) and
    built three directions as mockups. Can picked **B, "Sıcak"** (#131): warm ground, a
    flat green hero carrying the day's number, colour per exchange group.
  - Two outside reviews (Codex and an Opus subagent,
    `docs/research/2026-09-23-sicak-redesign-review-*.md`) corrected it before coding.
    Can decided: clients mark **meals** as eaten (P7; the hero counts meals), a **weekly,
    forgiving count** instead of a streak (was C22), **weigh-ins from both sides** (P8),
    the dietitian can **hide numbers per client** (P9), rings animate **only when their
    value changes**. Rule changes were delegated to Claude with one condition, now
    design rule 15: it must not look AI-coded (#132).
  - **Coded in six slices, each committed:** theme tokens (warm palette, hero,
    highlight, group colours, Figtree Bold for numbers, motion that honours reduced
    motion, a test that re-measures every colour pair); client **Bugün**; client
    **Profil** as a summary with Hedeflerim on its own screen; the **panel phone shell**
    (below 600 dp: bottom bar, comfortable density, both entry points); phone layouts
    for the real client list and every demo screen (5a, 5b).
  - Every client and panel screen is tested at 360 and 412 dp with text scale 1.0, 1.3
    and 2.0. Analyzer clean; tests: core 9, client 14, panel 98.
  - **Where to see it:** the emulator, or the before/after screenshots in
    `docs/design/2026-09-23-redesign/` (`screenshots/` = before, `after/` = now), also
    copied to `C:\Users\jhana\Pictures\Wellkit redesign 23 Sep\` (`once`, `sonra`), and
    the top row ("Sonuç") of the mockup canvas.
  - Can's own test account now has the goal "Kilo vermek" (saved while testing on the
    emulator); clear it in Profil if unwanted.
- **Same night, "Sade" (#133), the current look:** on the phone Sıcak had too many colours to feel premium.
  Using a MyFitnessPal screenshot as the reference, Can chose: keep our green as the only
  accent, all bold sans (no Fraunces), light-grey ground with white borderless cards, no
  group colours, no green hero or yellow highlight. Coded in one slice: tokens, theme
  (neutral bottom bar with a black selected item), and Bugün rebuilt as a greeting + one
  "Başlangıç" card (progress bar, black ticks, pale-green "Yaz/Düzenle" pills). The panel
  follows through the theme. Screenshots: `docs/design/2026-09-23-redesign/sade/` and
  `C:\Users\jhana\Pictures\Wellkit redesign 23 Sep\sade\`. Tests: core 8, client 14,
  panel 98. On the emulator both apps are installed as "client" and "panel" (swipe up
  for the app list); both are the Sade build.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Redesign canvas | The three directions, the before screens and the coded result ("Sonuç" row) | https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |
| Interview guide | Can and Kadir during interviews; notes are shared and tagged per dietitian | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN) | Understanding the whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y |
| Project overview (TR) | The same, for Kadir | https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | The 11 demo screens with one question each (pre-redesign colours) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |
| Design system (history) | The 28 Aug design decisions; the source is now `docs/design-system.md` | https://claude.ai/code/artifact/1d9436dc-cd7c-4639-a4ec-9459de2d8ea3 |

The interview guide mirrors QUESTIONS.md §2 (K) and §3 (DT) with the same numbers. After
an interview, ask Claude to "read the guide notes"; it moves the answers into QUESTIONS.md
and PLANNING.md.

## Next steps

1. **Next session: bring the panel fully into "Sade" (Can, 24 Sep).** The panel only
   took Sade through the theme; its screens still carry Serin/Sıcak-era details. Plan it
   as small slices, checked on the emulator (`-t lib/main_demo.dart`) at phone and wide
   sizes:
   - Genel Bakış: the triage task buttons become the pale-green pills Bugün uses
     ("Düzenle"); the header gets the same "date + bold greeting" pattern; consider the
     slim header with tappable counts from the Sıcak spec.
   - Danışanlar: one "Filtrele" button instead of four filter controls on a phone; status
     pills in the Sade style (text + tint, fewest colours).
   - Client detail, plan editors, Randevular, Mesajlar, Takip: remove leftover borders and
     extra colours; check every screen against rule 15's checklist ("count the colours").
   - The real panel (`lib/main.dart`) on the emulator: needs an approved dietitian
     account (sign up in the panel app, approve in the Supabase dashboard; #35).
   - App names on the phone are the Flutter defaults "client" and "panel": set
     `android:label` (and the iOS display name) to e.g. "Wellkit" and "Wellkit Panel".
2. **The data features that bring Bugün to life**, each planned on its own before code:
   `diet_plans` + the client's Planım tab and a meal count on Bugün; meal logs (P7) with
   the weekly count; weigh-ins (P8); chat. Keyed off `dietitian_client_relationships`.
   P9 (hide numbers per client) lands with the first of them.
3. **Can answers** C21 (how much plan editing on a phone); it blocks the panel's phone
   plan screen.
4. **Small follow-ups:** tablets (600 dp+) use the compact layout without touch padding;
   the panel tour artifact and the canvas's "Sonuç" row show older colours;
   `Fraunces-SemiBold.ttf` can be deleted once Sade is settled; Codex's code review of
   the redesign was cut short by its usage limit: rerun it (prompt in the 23 Sep chat,
   scope `git diff b0776e8..HEAD`).
5. **Can + Kadir:** give Kadir edit access to the interview guide (Share menu) and ask
   K1–K3, K2 first (is the intake form athletes-only?).
6. **Can:** the rest of the interview answers (DT1, DT7, DT8, DT10, DT15), then §0
   (I1–I16), C4 (B2B timing and bulk enrolment) and C8 (listing order). Re-check
   QUESTIONS.md "Answered on 23 Sep" after the next talk with Kadir.
7. **Unblocked any time:** CI (analyze + test on GitHub), a separate Supabase dev project
   (C17), custom SMTP (for password reset and non-team signups), RLS access tests, invite
   email delivery, ending a relationship.
