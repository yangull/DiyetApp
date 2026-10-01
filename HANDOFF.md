# HANDOFF — pick up here

> Where the project stands and what is waiting on whom. Rewrite this file (don't append)
> at the end of a session. Decisions live in `PLANNING.md`; open questions in
> `QUESTIONS.md`; traps in `CLAUDE.md` ("Gotchas"); vocabulary in `CONTEXT.md`.
> Updated 1 October 2026 (late night).

## Where things stand

- **Phase 0 is done**: monorepo, EU Supabase, real auth in both apps, invites, the real
  client list, and the interview demo on fake data (money UI hidden, P6).
- **The redesign is done and pushed** (PLANNING #134–#135, `docs/design-system.md`):
  - Bevel adapted for an app, Alpino, and a green accent.
  - Black pill buttons, Cloud Card cards (core `CloudCard`) and a floating bottom bar.
  - Panel density by input.
  - **Dark mode** (Sistem / Açık / Koyu).
  - Seen on the Pixel 8a, light and dark, with the real client app logged in.
  - Commits `ff89fbe`, `3134b9b`, `2f67827`.
- **Decided tonight**:
  - A dev Supabase project, CI and RLS tests come **before launch, not now** (#136, was
    C17). Until then no real client data in the project, test accounts only.
  - Plans written by hand at launch, AI drafts later (P10, was C13).
- **Tests**: core 28, client 18, panel 197; analyze clean.
- The Codex worktree (`../dietician-app-codex`) has not been fast-forwarded to these
  commits yet: `git -C ../dietician-app-codex merge --ff-only main`.

## To-do, in order

Every slice: small; plan mode for anything bigger than one screen; analyze + test; a
subagent review; results shown to Can (artifact page or `C:\Users\jhana\Pictures\`);
commit on Can's word, push on "push".

### A. Close the redesign (small)

1. **Web check (Can).** Panel demo at http://localhost:8080 (`flutter run -d web-server
   … -t lib/main_demo.dart`). Do headings look right (not Black)? Is the compact size (13 px
   text, 32 px buttons) too small? Does dark mode look right?
2. **Artifacts.** Add dark mode, `CloudCard` and `inset` to the private Design System
   artifact (https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV); refresh the panel tour
   (pre-Sade screenshots).
3. **Screen polish.**
   - Field labels above the field: a core wrapper, starting with the Danışanlar filter.
   - Fixed-width number slots (`numberSlotWidth`) for kg, kcal and the measurement
     columns.
   - The plan PDF still uses Figtree (Alpino's static files would fix it).

### B. Phase 1 features: the next build (one slice each, plan mode first)

4. **Weigh-ins and measurements** (P8). The client logs weight, the dietitian adds
   measurements, both see a chart. P9 (hide numbers per client) applies. DT8 placeholder:
   weight, waist, hip.
5. **Plan editor + `diet_plans`** (P4, P10, #121–#123). Exchange list first, weekly,
   copied from last week, written by hand. **Needs DT3.**
6. **Meal ticks on Bugün** (P7). One tap per meal, time recorded, "Bu hafta 5/7 gün".
    Needs plans.
7. **Chat** (Supabase Realtime, P2).
8. **Dietitian verification upload and file attachments** (#125).
9. **Diyetisyen bul** (the marketplace listing). Needs C7 and C8.
10. **Video:** choose an SDK (Agora / 100ms / Daily), then embed it.
11. Later: AI drafts (P1, P10), then the AI-only tier (Phase 2).

### C. Foundation (#136): before launch, after the features

12. **Dev Supabase project (Can, dashboard).** Free tier, EU region. Claude writes a
   step-by-step wizard. Then push all migrations to it and copy the dashboard auth settings
   (email confirmation, #21).
13. **Two config files.** `env/dev.json` points at dev; a new gitignored `env/prod.json`
   points at today's project. Document which one `flutter run` and Codemagic use.
14. **CI.** A GitHub Actions workflow running `melos analyze` and `melos test` on every
   push. On the private repo it uses free Actions minutes (2,000 a month).
15. **RLS tests.** Prove that a client can't read another client's data, a dietitian
   only sees their own clients, and the projections leak nothing (#90, #103). There is no
   local Docker, so they run against the dev project; plan the approach first.

### D. Release prep (start early, it has waiting times)

16. **Google Play.** A developer account ($25). New personal accounts need a **14-day
    closed test with 12+ testers**, so start it as soon as one app is worth testing.
17. **Apple.** Developer Program ($99/yr), then Codemagic for iOS builds (not set up yet).
18. **Before any real user:**
    - Privacy policy, health-data disclosure and KVKK texts (legal help).
    - In-app account deletion (Q22), password reset and custom SMTP. Without SMTP,
      confirmation emails only reach Supabase org members.

## Waiting on Can (and Kadir)

Most blocking first. Details in QUESTIONS.md.

- **DT3**: which exchange table and values. Blocks the plan editor (to-do 5).
- **C4**: when does B2B enter the roadmap? Does the pilot start with one company?
- **C23**: should clients choose things themselves (foods, dietitian, goals), and where
  first?
- **C21**: how much plan editing on a phone?
- **C14 / C15 / C16**: launch surfaces, what counts as a successful pilot, who runs
  operations.
- **C47**: tablets in "desktop site" mode; **C46**: the names rule.
- **C6–C12**: marketplace flow details.
- **§0**: inherited decisions to confirm or correct (I1, I3, I4, …).
- **§2**: Kadir's questions. **DT8**: which measurements.

## Pages (Claude artifacts)

| Page | For | Link |
|---|---|---|
| Wellkit Bevel system | The design system now in the code (private: Alpino's licence) | https://claude.ai/artifact/HCeGviNk93ac9jDJB7t7QV |
| Interview guide | Can and Kadir during interviews | https://claude.ai/artifact/8YW5uFvqQpWEBaG3ahBrgB |
| Project overview (EN / TR) | The whole project | https://claude.ai/artifact/AoDqhG54mg7jngZ3Ensj6y · https://claude.ai/artifact/La1Na7aVy1weCr9VpTRLad |
| Panel tour | 11 demo screens (**pre-Sade**, refresh: to-do 2) | https://claude.ai/code/artifact/002e0c24-01e2-4d49-a693-6261bcb414de |
| History | Sade system, direction B canvas, 23 Sep directions | https://claude.ai/artifact/GKBbEfa4zHLzjQtQ6ZZpYh · https://claude.ai/artifact/UUMWcZotJ72TkxgpabCHo4 · https://claude.ai/artifact/GZU5DJaeaECPpMUM32MDTn |

Captures: `C:\Users\jhana\Pictures\Wellkit revamp\` (Bevel theme, review fixes, dark mode).

## Sources and how to read them

- Apple's HIG pages come as exact text from
  `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/<page>.json`.
- Font checks: `uv run --with fonttools python …`. Alpino's zip:
  `/mnt/c/Users/jhana/Desktop/Alpino_Complete.zip`.
- refero.design: single pages with WebFetch only; values only from DESIGN.md files Can
  provides.
