# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 3 October 2026.

## Where things stand

- **Phase 0 is done**: monorepo, EU Supabase, real auth in both apps, invites, the real
  client list, and the interview demo on fake data (money UI hidden, P6).
- **The redesign is done** (PLANNING #134–#135, `docs/design-system.md`): Bevel adapted
  for an app, Alpino, a green accent, black pill buttons, Cloud Card cards, panel density
  by input, dark mode.
- **The A2 polish pass is done** (`docs/a2-polish-plan.md`): 118 of the 119 audit items
  fixed, 1 skipped by decision (C4.3, the bottom bar stays fixed at 200 % text). The audit
  page shows every screen before and after, with a status and a note per item. New
  shared pieces in core: `LabeledField`, `AppLoading` / `AppErrorView` / `EmptyState`,
  `WellkitMark` (placeholder), `AppIcons` (Lucide), the `Lira` fallback font for ₺,
  `numberSlotWidth`; in the panel: `InterviewNote`, the extended rail.
- **Tests**: core 54, client 26, panel 246 (+1 and +3 skipped capture files); analyze
  clean.
- **Not pushed.** Local commits on `main` since `origin/main`: `d411b24`, `75ab19f`,
  `65f65aa`, `ff4ad05`, `f868170`, `862cd25`, `e48d6fa` and the session-7 docs commit.
  The Codex worktree (`../dietician-app-codex`) is not fast-forwarded either:
  `git -C ../dietician-app-codex merge --ff-only main` after the push.
- Captures: `C:\Users\jhana\Pictures\Wellkit polish\` (`00 before`, one folder per
  slice with `before` / `after`, and `FINAL` with all 180 final screens).

## To-do, in order

Every slice: small; plan mode for anything bigger than one screen; analyze + test; a
subagent review; results shown to Can (artifact page or `C:\Users\jhana\Pictures\`);
commit on Can's word, push on "push".

### A. Close the polish (Can, small)

1. **Push and fast-forward Codex** once Can has looked.
2. **Pixel 8a check** (the test font is wider than Alpino, so a few layouts can only be
   judged on a device):
   - Lucide icons and the ₺ sign in a release build (Profil budget line, client record).
   - Mesajlar on the phone at 2× text: the "Gönder" label or its icon fallback, the
     thread page.
   - Takip's summary card at 1× and 2×; the Görüşme notice at 2× (it may touch the
     avatar).
   - Hatırlatma ayarları: "Açık / Kapalı" beside the switches, the app-bar title.
3. **Web check (Can).** The compact size (12 px floor since 2 Oct) in a Windows browser:
   `flutter run -d web-server … -t lib/main_demo.dart`, http://localhost:8080.
4. **Panel tour link.** The tour is updated (3 Oct screens), but link viewers see a
   pinned earlier version: move the pin in the page's Share menu.
5. Left from the pass, small and optional:
   - The plan PDF still uses Figtree (Alpino's static files would fix it).
   - `EdgeButton`'s outer 12 px is not tappable (from the S3 review).
   - The payments screen's ₺ columns need number slots before money is ever shown (P6).
   - A real logo and app icon replace `WellkitMark`.

### B. Phase 1 features: the next build (one slice each, plan mode first)

6. **Weigh-ins and measurements** (P8). The client logs weight, the dietitian adds
   measurements, both see a chart. P9 (hide numbers per client) applies. DT8 placeholder:
   weight, waist, hip.
7. **Plan editor + `diet_plans`** (P4, P10, #121–#123). Exchange list first, weekly,
   copied from last week, written by hand. **Needs DT3.**
8. **Meal ticks on Bugün** (P7). One tap per meal, time recorded, "Bu hafta 5/7 gün".
   Needs plans.
9. **Chat** (Supabase Realtime, P2).
10. **Dietitian verification upload and file attachments** (#125).
11. **Diyetisyen bul** (the marketplace listing). Needs C7 and C8.
12. **Video:** choose an SDK (Agora / 100ms / Daily), then embed it.
13. Later: AI drafts (P1, P10), then the AI-only tier (Phase 2).

New screens are built on the same system from the start: `LabeledField`, the shared
states, number slots, `formatDate`, `AppIcons`, `context.palette`.

### C. Foundation (#136): before launch, after the features

14. **Dev Supabase project (Can, dashboard).** Free tier, EU region. Claude writes a
    step-by-step wizard. Then push all migrations to it and copy the dashboard auth
    settings (email confirmation, #21).
15. **Two config files.** `env/dev.json` points at dev; a new gitignored `env/prod.json`
    points at today's project. Document which one `flutter run` and Codemagic use.
16. **CI.** A GitHub Actions workflow running `melos analyze` and `melos test` on every
    push (free minutes on the private repo).
17. **RLS tests.** Prove that a client can't read another client's data, a dietitian
    only sees their own clients, and the projections leak nothing (#90, #103). They run
    against the dev project; plan the approach first.

### D. Release prep (start early, it has waiting times)

18. **Google Play.** A developer account ($25). New personal accounts need a **14-day
    closed test with 12+ testers**, so start it as soon as one app is worth testing.
19. **Apple.** Developer Program ($99/yr), then Codemagic for iOS builds (not set up yet).
20. **Before any real user:**
    - Privacy policy, health-data disclosure and KVKK texts (legal help).
    - In-app account deletion (Q22), password reset and custom SMTP. Without SMTP,
      confirmation emails only reach Supabase org members.
    - Alpino's licence forbids a public repo: take `packages/core/fonts/Alpino-*` out of
      the repo and its history before `yangull/DiyetApp` ever goes public.

## Waiting on Can (and Kadir)

Most blocking first. Details in QUESTIONS.md.

- **DT3**: which exchange table and values. Blocks the plan editor (to-do 7).
- **C4**: when does B2B enter the roadmap? Does the pilot start with one company?
- **C23**: should clients choose things themselves (foods, dietitian, goals), and where
  first?
- **C21**: how much plan editing on a phone?
- **C14 / C15 / C16**: launch surfaces, what counts as a successful pilot, who runs
  operations (C16 also gives the rejected-application screen its real address).
- **C47**: tablets in "desktop site" mode; **C46**: the names rule; **C48**: "Açık"
  means both "on" and "light" on the demo's Ayarlar page.
- **C6–C12**: marketplace flow details.
- **§0**: inherited decisions to confirm or correct (I1, I3, I4, …).
- **§2**: Kadir's questions. **DT8**: which measurements. **DT7**: intake checkboxes.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Wellkit status report (TR/EN) | Can's general showcase. Update it when the state changes | https://claude.ai/artifact/8XtstTkUXxgnup4Q4Ywy5Z |
| Polish audit | Every screen before and after the A2 pass, 119 items with status | https://claude.ai/artifact/DPUhmDFvF1otcXXEa6VqMM |
| Wellkit Bevel system | The design system now in the code, dark theme included (private: Alpino's licence) | https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV |
| Panel tour | 11 demo screens with the interview questions (3 Oct screens; move the share pin) | https://claude.ai/artifact/12HiiqJV6Xyh8HbLoKhpQm |
| Interview guide | Can and Kadir during interviews | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN / TR) | The whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y · https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| History | Sade system, direction B canvas, 23 Sep directions | https://claude.ai/artifact/GKBbEfa4zHLzjQtQ6ZZpYh · https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4 · https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |

## Sources and how to read them

- Captures without the emulator: `test/audit_captures_test.dart` in each app (tagged
  `screenshots`; set `FLUTTER_ROOT` and `CAPTURE_DIR`, run with `--tags screenshots
  --run-skipped --update-goldens`). The tour's images come from the panel's
  `test/screenshots_test.dart` (`test/goldens/`).
- Apple's HIG pages come as exact text from
  `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`.
- Font checks: `uv run --with fonttools python …`. Alpino's zip:
  `/mnt/c/Users/jhana/Desktop/Alpino_Complete.zip`.
- refero.design: single pages with WebFetch only; values only from DESIGN.md files Can
  provides.
