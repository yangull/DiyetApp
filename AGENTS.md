# AGENTS.md

Instructions for Codex (and any agent that reads `AGENTS.md`). Claude Code reads
`CLAUDE.md`; both agents work on this repo, so the project rules live in one place.

## Read first

Before anything else, read these files in the repo root:

1. `CLAUDE.md`: commands, conventions, locked decisions, **Gotchas**. Its rules apply
   to you too, except the Claude-specific tooling (skills, artifacts).
2. `HANDOFF.md`: current state, next steps, open questions for Can.
3. `PLANNING.md`: the product, locked decisions (stable IDs P1–P5, #1–#118), roadmap.
4. `CONTEXT.md`: the domain glossary. Use its terms.

Locked decisions are not reopened without asking Can. If you disagree with one, say
so in your answer; don't change code or docs to route around it.

## Where you work

Two git worktrees share one repository:

| Path | Branch | Who |
|---|---|---|
| `~/projects/dietician-app` | `main` | Claude Code and Can. Only place that runs `supabase db push`. |
| `~/projects/dietician-app-codex` | `codex/*` | Codex |

- Work on a `codex/<topic>` branch in `dietician-app-codex`. Never commit to or push
  `main`; Can merges after review.
- **Never run `supabase db push`, `supabase link` or anything that changes the live
  database.** The Codex worktree is deliberately not linked. You may write a new
  migration file (`supabase migration new <name>`); it is applied from the main worktree
  after review.
- Worktrees isolate files, not the backend: apps run from either worktree talk to the
  same live Supabase project. Don't create test accounts or data there unless asked.
- Don't push or commit unless Can asks.

## Two modes

Can tells you which one. If it's unclear, ask.

### Review mode: read, don't edit

Used for a second opinion on Claude's work, a branch, a plan or the docs.

- Don't modify tracked files. Answer in the conversation.
- Only if Can asks to save it: write `docs/research/YYYY-MM-DD-<topic>.md`.
- Check every claim against the code before reporting it. Say what already exists
  before calling something missing. A reviewer without the plan tends to demand
  features that already exist or that the plan defers on purpose.
- Rank findings by severity. For each: file and line, what goes wrong, and a
  concrete scenario. Separate "bug" from "I'd do it differently".
- Keep it short. A list of 10 verified findings beats a register of 100 open
  questions.

### Work mode: implement a slice

- One small, working slice per branch. Don't expand scope beyond the request.
- Follow the surrounding code's style, comment density and naming.
- Before saying you're done, run from the repo root and report the results:

  ```bash
  dart run melos run analyze
  dart run melos run test
  ```

- If you change a demo model, update `demo_codec.dart` and bump `_schemaVersion`
  (see CLAUDE.md Gotchas).
- If a decision changes, edit the relevant PLANNING.md section in place. Don't
  append session logs. Update HANDOFF.md only if Can asks.
- UI text in Turkish ("sen" in the client app, "siz" in the panel); code, commits
  and docs in English.
