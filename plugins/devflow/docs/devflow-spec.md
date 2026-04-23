# Devflow — AI-Powered Developer Workflow Suite for Claude Code

An open-source suite of Claude Code skills and commands that automate the PR lifecycle, ticket implementation, code review, and documentation — configurable for any team, language, or Git hosting provider.

---

## Architecture

### Configuration-driven

Every tool reads from `.claude/devflow.yaml` — no hardcoded hosts, commit formats, or build commands. The config supports presets for common patterns and custom templates for teams with unique conventions.

### File structure

```
.claude/
├── devflow.yaml                    # project config (committed)
├── prompts/                        # shared prompt templates (committed)
│   ├── diff-scoping.md
│   ├── pr-description.md
│   └── title-format.md
├── commands/                       # user-invoked slash commands (committed)
│   ├── devflow-init.md
│   ├── devflow-pr-create.md
│   ├── devflow-pr-describe.md
│   ├── devflow-pr-update.md
│   ├── devflow-pr-status.md
│   ├── devflow-pr-comments.md
│   ├── devflow-pr-review.md
│   ├── devflow-split-pr.md
│   ├── devflow-implement.md
│   ├── devflow-cleanup.md
│   ├── devflow-onboard.md
│   ├── devflow-test-impact.md
│   └── devflow-security-scan.md
├── tickets/                        # ticket files + state (gitignored state)
│   ├── PROJ-123.md                 # engineer's requirement (committed or local)
│   ├── PROJ-123.plan.md            # work plan + review cycles
│   └── PROJ-123.state.json         # machine state (gitignored)
└── review-state/                   # review-comments state (gitignored)
    └── PR-42.json
```

### Three shared prompt files

All PR-related tools reference the same prompt files to guarantee consistency:

| File | Purpose | Used by |
|------|---------|---------|
| `diff-scoping.md` | `--first-parent --no-merges` scoping rules | all PR commands, implement script |
| `pr-description.md` | Description template + generation rules | pr-create, pr-describe, pr-update, implement |
| `title-format.md` | Commit/PR title format (reads from devflow.yaml) | pr-create, implement |

---

## Configuration: `devflow.yaml`

```yaml
github:
  host: github.com                     # github.com, gitlab.com, or GHE hostname
  base_branch: main                    # default PR target branch

commits:
  preset: conventional                 # conventional | ticket-prefix | freeform
  types: [feat, fix, docs, refactor, chore, test, perf, ci, build]
  ticket_pattern: "[A-Z]+-[0-9]+"     # regex to extract ticket ID from branch
  template: null                       # custom: "{type}: {ticket} {description}"
  lowercase_description: true
  max_length: 72

branches:
  preset: type-ticket-description      # type-description | type-ticket-description
                                       # user-type-description | user-ticket-description
  template: null                       # custom: "{user}/{ticket}_{slug}"
  separator: hyphen                    # hyphen | underscore
  types:
    feature: feat
    fix: fix
    hotfix: fix
    docs: docs
    chore: chore

pr:
  draft: false                         # create PRs as draft by default
  description_marker: "auto-pr-desc"
  review_comments_marker: "review-comments"

tickets:
  dir: ".claude/tickets"
  state_gitignored: true

worktrees:
  dir: "~/worktrees"
  repo_mode: current                   # current | bare | /path/to/bare/clone
  bare_clone_dir: "~/devflow-repos"

languages:
  primary: auto                        # auto-detect or: javascript, typescript,
                                       # python, go, rust
  javascript:
    format: "npm run format"
    test: "npm test"
    build: "npm run build"
  typescript:
    format: "npm run format"
    test: "npm test"
    build: "npm run build"
  python:
    format: "ruff format ."
    test: "pytest"
    build: null
  go:
    format: "gofmt -w ."
    test: "go test ./..."
    build: "go build ./..."
  rust:
    format: "cargo fmt"
    test: "cargo test"
    build: "cargo build"

docs:
  enabled: false
  llm_dir: "docs/llm"
  human_dir: "docs"
  map_file: "tools/doc/doc-map.yaml"
  lint_command: null
```

### Auto-detection

When `languages.primary` is `auto`, detect from repo root:

| File | Language |
|------|----------|
| `package.json` | javascript/typescript |
| `pyproject.toml` / `setup.py` | python |
| `go.mod` | go |
| `Cargo.toml` | rust |

---

## Tool Reference

### Tier 0 — Setup

#### `/devflow-init`

Interactive setup wizard that generates `devflow.yaml`.

**Flow:**

1. Detect GitHub host from `git remote -v` (github.com, gitlab, GHE)
2. Detect default branch (`main` or `master`)
3. Auto-detect language from repo files
4. Ask with selectable options:

   > Commit message format?
   - `Conventional (feat: add login flow)`
   - `Ticket prefix (feat: PROJ-123 add login flow)`
   - `Freeform (no enforced format)`

5. Ask:

   > Branch naming pattern?
   - `type/description (feature/add-login)`
   - `type/ticket-description (feature/PROJ-123-add-login)`
   - `user/type/description (jsmith/feature/add-login)`

6. Ask:

   > Ticket ID pattern? (e.g. JIRA-123, GH-42, or leave blank)

7. Write `.claude/devflow.yaml`
8. Create `.claude/prompts/` directory with shared prompt files
9. Add gitignore entries for state files
10. Print summary of what was configured

**Arguments:** none

---

### Tier 1 — PR Lifecycle

#### `/devflow-pr-create`

Push the current branch, generate a description from the diff, and open a PR.

**Flow:**

1. Check no PR already exists on the current branch
2. Push the branch to remote
3. Gather diff context using `--first-parent --no-merges` (see `diff-scoping.md`)
4. Generate PR title from `title-format.md` rules (reads format from `devflow.yaml`)
5. Generate description from `pr-description.md` rules
6. Write description to temp file, create PR via `--body-file`
7. Print PR URL

**Arguments:** `[base-branch]` (optional, defaults to `devflow.yaml → github.base_branch`)

---

#### `/devflow-pr-describe`

Generate and set the PR description for an existing PR. Works regardless of how the PR was created.

**Flow:**

1. Find the PR (from current branch or argument)
2. Check existing description — if manually written (no auto-marker), ask before overwriting
3. Gather diff context
4. Generate description
5. Write to temp file, update PR via `--body-file`

**Arguments:** `[pr-number]` (optional, defaults to current branch PR)

---

#### `/devflow-pr-update`

Compare the current description against the latest diff and silently correct stale sections. No changelogs, no "Updated:" annotations — the result reads as if written fresh.

**Flow:**

1. Find the PR and get current description
2. Gather current diff context
3. Compare description against diff — find stale, missing, or inaccurate sections
4. Produce a clean, complete updated description
5. Write to temp file, update PR

**Rules:**
- Output reads as if written fresh — no trace of the update
- Preserve sections that are still accurate
- Never mention the update process

**Arguments:** `[pr-number]` (optional)

---

#### `/devflow-pr-status`

Dashboard view of PRs that need attention.

**Flow:**

1. Fetch open PRs authored by the current user:
   ```
   gh pr list --author @me --json number,title,url,reviewDecision,
     updatedAt,isDraft,reviews,comments
   ```
2. Categorize each PR:

   | Status | Criteria |
   |--------|----------|
   | 🟢 Approved | `reviewDecision == APPROVED` |
   | 🔴 Changes requested | `reviewDecision == CHANGES_REQUESTED` |
   | 🟡 Waiting for review | Not draft, no review decision yet |
   | ⚪ Draft | `isDraft == true` |
   | 🔵 Stale | No updates in 7+ days |

3. Display as a concise table:

   ```
   Your open PRs:

   🔴 #1775  feat: ZDP-4577 add sce processing     Changes requested (2 unresolved)
   🟡 #1780  fix: ZDP-4601 fix null pointer          Waiting for review (2 days)
   🟢 #1782  feat: ZDP-4612 add retry logic          Approved — ready to merge
   ⚪ #1785  feat: ZDP-4620 refactor pipeline         Draft
   ```

4. Ask:

   > What would you like to do?
   - `Address review comments on #1775`
   - `Merge #1782`
   - `Done`

   "Address review comments" runs `/devflow-pr-comments` on that PR.
   "Merge" runs `gh pr merge --squash`.

**Arguments:** none

---

#### `/devflow-pr-comments`

Fetch review comments, help the engineer triage them (fix/decline/manual/discuss), implement fixes, and post all decisions back to GitHub with individual replies and a summary table.

**Flow:**

1. Find the PR, fetch owner/repo
2. Load local state from `.claude/review-state/PR-<number>.json`
3. Find existing summary comment on the PR (for editing in place)
4. Fetch inline review threads (GraphQL for resolution status) AND general PR comments (REST API)
5. Filter:
   - Skip bots (`author.login` ends with `[bot]`)
   - Skip own summary comments (`## Review feedback`)
   - Skip PR author's comments (unless `--self`)
   - Determine thread status: NEW, FOLLOWUP (someone replied after `[review-comments]`), DEFERRED
6. Classify NEW items as FIX / DISCUSS / PARTIAL; general comments as GENERAL-FIX / GENERAL-DISCUSS
7. Present numbered list with reviewer names:
   ```
   1. [auth.ts:23] @alice — Use try-catch instead of bare throw [FIX]
   2. [PR comment] @bob — Add a README [GENERAL-FIX]
   3. [api.ts:15] @bob — Why not strategy pattern? [DISCUSS]
   4. [utils.ts:8] @alice — Extract helper (deferred) [DEFERRED]
   ```
8. Ask for FIX items:
   - `Fix all automatically (items 1, 2)`
   - `Let me review each one`
9. For DISCUSS/PARTIAL/DEFERRED/FOLLOWUP: triage individually
10. Implement fixes, run format/test commands from `devflow.yaml`
11. Commit and push
12. Post individual replies to every decided comment:
    - ✅ Fixed — `[review-comments] ✅ Fixed — <what changed>`
    - ❌ Declined — `[review-comments] ❌ Won't fix — <reason>`
    - 🔧 Manual — no reply posted (stays deferred, shows next run)
    - 💬 Discuss — `[review-comments] 💬 <engineer's response>`
13. Update summary comment (edit in place):
    ```
    ## Review feedback
    | # | Reviewer | File | Comment | Decision | Details |
    |---|----------|------|---------|----------|---------|
    | 1 | @alice | auth.ts:23 | try-catch | ✅ Fixed | wrapped |
    | 2 | @bob | PR comment | Add README | ❌ Won't fix | out of scope |
    ```
14. Save state to `.claude/review-state/PR-<number>.json`

**Arguments:**
- `--manual` — show only deferred items
- `--all` — show everything including resolved
- `--self` — include PR author's own comments

**State:**
- Local: `.claude/review-state/PR-<number>.json` (gitignored)
- GitHub: summary comment edited in place (visible to reviewer)

**Deferred item lifecycle:**
- First pass: engineer picks "I'll handle manually" → no reply posted, saved as `deferred`
- Second pass: deferred items return with options: `Auto-fix` / `Done — I fixed it` / `Decline` / `Skip for now`
- FOLLOWUP: if reviewer replies after a `[review-comments]` reply, thread resurfaces

---

#### `/devflow-pr-review`

AI self-review of the current branch before requesting human review. Analyzes the diff for quality issues, missing tests, potential bugs, and code structure problems — then lets the engineer fix them interactively.

**When to use:** Before requesting review. Run this after implementation to catch issues a human reviewer would flag, so the PR arrives clean.

**Flow:**

1. Gather diff context using `--first-parent --no-merges` (see `diff-scoping.md`)
2. Read each changed file in full (not just the diff hunks — Claude needs surrounding context)
3. Analyze across these categories:

   | Category | What it checks |
   |----------|----------------|
   | **Missing tests** | New functions/methods/endpoints without corresponding test files or test cases |
   | **Error handling** | Uncaught exceptions, missing try-catch, unhandled promise rejections, missing error boundaries |
   | **Null safety** | Null/undefined dereferences, missing null checks, optional chaining opportunities (language-dependent) |
   | **Best practices** | Hardcoded values that should be config, magic numbers, deprecated API usage, anti-patterns for the detected language |
   | **Code duplication** | Repeated logic that should be extracted into a shared function/utility |
   | **File structure** | Files that are too large (>300 lines), functions that are too long (>50 lines), god classes/modules |
   | **UI components** | (if frontend code detected) Missing accessibility attributes, inline styles that should be classes, missing error/loading states, missing key props in lists |
   | **Security** | SQL injection, XSS vectors, secrets in code, unsafe deserialization |
   | **Performance** | N+1 queries, unbounded loops, missing pagination, unnecessary re-renders (React) |
   | **Naming** | Unclear variable/function names, inconsistent naming conventions |

4. Present findings as a numbered list, classified by severity:

   ```
   Found 8 issues in 4 files:

   🔴 HIGH
   1. [auth/service.ts:45] No error handling on API call — unhandled rejection [FIX]
   2. [api/users.ts:23] SQL query built with string concatenation — injection risk [FIX]

   🟡 MEDIUM
   3. [auth/service.ts] No test file found — auth logic is untested [FIX]
   4. [components/UserList.tsx:30] Missing key prop in .map() [FIX]
   5. [utils/parser.ts:12-89] Function is 77 lines — consider splitting [PARTIAL]

   🔵 LOW
   6. [config.ts:5] API URL hardcoded — should use env variable [FIX]
   7. [components/UserList.tsx] Missing loading and error states [PARTIAL]
   8. [utils/helpers.ts:20] Duplicates logic from utils/format.ts:15 [PARTIAL]
   ```

5. Ask with exactly these options:

   > How do you want to handle these?
   - `Fix all HIGH and MEDIUM automatically`
   - `Fix all automatically`
   - `Let me review each one`

6. For each item, same decision flow as `/devflow-pr-comments`:
   - **FIX**: Claude implements the fix
   - **PARTIAL**: Claude proposes a fix, shows before/after, asks for confirmation
   - **Decline**: Engineer says "this is intentional" with a reason
   - **Skip**: Leave for later

7. After fixes:
   - Run format and test commands from `devflow.yaml`
   - Commit: `fix: address self-review findings`
   - Push

8. Print summary:
   ```
   Self-review complete:
     Fixed: 5
     Declined: 1 (intentional)
     Skipped: 2

   Ready to request review.
   ```

**What it does NOT do:**
- Does not post comments on GitHub (this is local, pre-review)
- Does not replace human review — it catches mechanical issues so the human reviewer can focus on design and logic
- Does not review code outside the current branch's diff

**Language-aware checks:**

The tool adapts its analysis based on `devflow.yaml → languages.primary`:

| Language | Extra checks |
|----------|-------------|
| TypeScript/JavaScript | Missing `async/await`, unhandled promise rejections, missing React keys, prop type issues, `any` type usage |
| Python | Missing type hints, bare `except:` clauses, mutable default arguments, missing `__init__` |
| Go | Unchecked errors (`_` on error return), missing `defer` for cleanup, exported functions without doc comments |
| Rust | Unnecessary `.unwrap()`, missing error propagation with `?`, unused `Result` |

**Arguments:**
- `--severity high` — only show HIGH severity issues
- `--category tests` — only check for missing tests
- `--category security` — only run security checks
- `--fix-all` — skip the interactive menu, fix everything automatically

---

#### `/devflow-split-pr`

Help split a large PR into smaller, focused PRs.

**Flow:**

1. Gather the full diff for the current branch
2. Analyze the changes and identify logical groupings:
   - Changes that are independent of each other
   - Changes that have dependencies (must go in order)
   - Refactoring vs feature vs test changes
3. Propose a split plan:
   ```
   This PR has 47 files changed across 3 concerns:

   PR 1: "refactor: extract auth service" (12 files)
     - auth/service.ts, auth/config.ts, tests...
     - No dependencies, can merge first

   PR 2: "feat: PROJ-123 add oauth login" (28 files)
     - Depends on PR 1 (uses new auth service)
     - oauth/controller.ts, oauth/flow.ts, tests...

   PR 3: "chore: update auth documentation" (7 files)
     - Depends on PR 2
     - docs/auth.md, docs/api/auth.md...
   ```
4. Ask:
   - `Split into these PRs`
   - `Adjust the split — I'll describe what to change`
   - `Cancel`
5. If splitting:
   - Create branches for each split
   - Cherry-pick or checkout relevant files into each branch
   - Create PRs with generated descriptions
   - Print URLs for all created PRs

**Arguments:** `[number-of-splits]` (optional hint)

---

### Tier 2 — Ticket Implementation

#### `/devflow-implement`

Single command for the full ticket lifecycle: plan → implement → iterate on feedback. No separate review command needed.

**When run without arguments**, lists available ticket files and lets the engineer pick:
```
Available tickets:
1. PROJ-123
2. PROJ-456
3. ZDP-4577
```
The engineer selects one, and it becomes the ticket ID for the run.

**Three-file structure per ticket:**

| File | Purpose | Modified by |
|------|---------|-------------|
| `<ID>.md` | Engineer's original requirement | Engineer only (never modified by script) |
| `<ID>.plan.md` | Work plan + review cycles | Claude (appends reviews), Engineer (writes feedback) |
| `<ID>.state.json` | Branch, PR number, run count, status | Script only (gitignored) |

**State machine:**

```
[no state] → planning → (exit code 2, waiting for approval)
                ↓ (re-run)
           implementation → review
                ↓ (engineer adds feedback + re-run)
           implementation → review → ...
                ↓ (engineer approves / no more feedback)
           done (PR ready)
```

**Exit codes:**
- `0` — implementation complete
- `1` — error
- `2` — plan written, waiting for engineer approval

**Flow — first run (no plan file):**

1. Security pre-flight: scan ticket content for injection (Haiku, fast/cheap)
2. Generate branch name from ticket content (validated against regex)
3. Create worktree:
   - If `worktrees.repo_mode: bare` in config, create/reuse a bare clone first
   - Write scoped permissions into worktree
4. Claude reads ticket + technical docs, writes `<ID>.plan.md`:
   ```markdown
   # PROJ-123 — Work Plan

   ## Original requirement
   > (quoted verbatim from ticket)

   ## Plan
   1. Create FooService in src/services/...
   2. Add event handler for bar.events
   3. Write unit tests
   4. Run format

   ## Review 0
   ### Feedback
   (engineer will write feedback here before next run)
   ```
5. Exit with code 2 — command wrapper reads the plan and presents it

**Command wrapper behavior on exit code 2:**

The `.md` command file reads the plan and asks:
- `Implement` — re-run the script (plan exists, skips planning)
- `Give feedback — I'll type what to change` — ask for text, re-run with `--feedback "text"`
- `Cancel`

**Flow — subsequent runs (plan file exists):**

1. Read ticket + plan (including any `### Feedback` content)
2. Implement the work, run format/test commands from `devflow.yaml`
3. Commit following `devflow.yaml` commit format
4. Append `## Review N` section to plan file with summary + blank `### Feedback`
5. Push branch
6. Create or update PR with generated title and description (not draft)
7. Exit with code 0

**Flow — re-run after implementation (status = review):**

If no `--feedback` argument and no new feedback in the plan file, the script
prints the current status and PR URL, then exits 0. No wasted Claude calls.

If `--feedback "text"` is passed or the engineer edited `### Feedback` in
the plan file, the script picks up the feedback and runs another implementation
pass.

**Arguments:**
- `<ticket-id>` — optional (if omitted, lists available tickets)
- `[ticket-file-path]` — optional, defaults to `<tickets-dir>/<ticket-id>.md`
- `--auto` — skip plan approval, go straight to implementation
- `--feedback "text"` — inject feedback without editing the plan file

**Worktree from separate clone:**

When `worktrees.repo_mode` is `bare` in config:
1. First run checks for `~/devflow-repos/<repo-name>.git`
2. If not found: `git clone --bare <remote> ~/devflow-repos/<repo-name>.git`
3. All worktrees created from the bare clone (faster for large repos, no IDE conflicts)
4. Bare clone is reused across tickets

**`--dangerously-skip-permissions`:**

The implement script runs `claude -p` in a worktree. Claude Code's permission
system doesn't work well in worktrees (the worktree's `.claude/settings.json`
may not be picked up by `claude -p`). The script therefore uses
`--dangerously-skip-permissions` for all `claude -p` calls.

This is safe because:
- The worktree is isolated (outside the main repo)
- The worktree is disposable (can be deleted and recreated)
- The security pre-flight scans ticket content before the agent runs
- The safety preamble in the prompt tells Claude what not to touch
- Push access is limited to the feature branch by the `gh` host config

Document this in the README so users understand the tradeoff.

---

### Tier 3 — Documentation

#### `/devflow-docs`

Generate LLM and human-readable documentation for a new or undocumented feature.

**Flow:**

1. Read `devflow.yaml → docs` config for paths and settings
2. Read the doc map file to understand existing coverage
3. Identify what is new or undocumented (from recent git changes + user context)
4. Read relevant source files
5. Create LLM reference doc:
   - Full module/class paths, API endpoints, config fields
   - Decision tables with exact boolean logic
   - Field mapping tables
   - Freshness markers (`<!-- last-reviewed: YYYY-MM-DD -->`)
6. Create human-readable doc(s):
   - No class names or code references
   - Mermaid diagrams for every processing flow
   - Audience: product managers
7. Update doc map file
8. Run lint command if configured

**Arguments:** `[feature or area to document]`

**Requires:** `docs.enabled: true` in `devflow.yaml`

---

### Tier 4 — Quality & Maintenance

#### `/devflow-onboard`

Read a codebase and generate a developer onboarding guide.

**Flow:**

1. Scan the repo structure:
   - Directory layout, key files (README, CONTRIBUTING, CI config)
   - Package manager and language detection
   - Entry points (main files, route definitions, command handlers)
2. Read existing documentation (README, docs/, CONTRIBUTING.md)
3. Analyze recent git activity:
   - Most active directories (where development is happening)
   - Key contributors
   - Common commit patterns
4. Generate an onboarding document:

   ```markdown
   # Developer Onboarding — <repo-name>

   ## What this project does
   (2-3 sentence summary inferred from README + code structure)

   ## Tech stack
   - Language: TypeScript
   - Framework: Next.js 15
   - Database: PostgreSQL (via Prisma)
   - CI: GitHub Actions

   ## Getting started
   1. Clone: `git clone ...`
   2. Install: `npm install`
   3. Environment: copy `.env.example` to `.env`
   4. Database: `npx prisma migrate dev`
   5. Run: `npm run dev`

   ## Project structure
   src/
   ├── app/          — Next.js app router pages
   ├── components/   — React components
   ├── lib/          — Shared utilities
   └── server/       — API routes and server logic

   ## Key concepts
   (3-5 concepts a new developer needs to understand)

   ## Where to start reading
   (ordered list of files/dirs to read first)

   ## Common tasks
   - Adding a new page: ...
   - Adding an API endpoint: ...
   - Running tests: ...
   ```

5. Ask if the engineer wants to save it as `ONBOARDING.md` or `docs/onboarding.md`

**Arguments:** `[output-path]` (optional)

---

#### `/devflow-test-impact`

Analyze which tests to run based on changed files.

**Flow:**

1. Gather changed files using diff-scoping rules
2. For each changed file, find related test files:
   - Convention-based: `foo.ts` → `foo.test.ts` or `foo.spec.ts`
   - Import analysis: files that import the changed module
   - Config-based: if `devflow.yaml` defines test mappings
3. Categorize:

   ```
   Changes affect 5 files → 12 test files identified:

   Direct tests (test file matches source file):
     auth/service.test.ts
     api/controller.test.ts

   Indirect tests (imports changed code):
     integration.test.ts
     e2e/auth.test.ts

   No test coverage:
     ⚠ utils/helpers.ts — no test file found
   ```

4. Ask:
   - `Run all identified tests`
   - `Run direct tests only`
   - `Show me the untested files`

5. Run selected tests using `devflow.yaml → languages.<lang>.test` command

**Arguments:** `[base-ref]` (optional, defaults to `github.base_branch`)

---

#### `/devflow-security-scan`

Pre-push security check for common issues.

**Flow:**

1. Gather changed files using diff-scoping rules
2. Scan for:

   | Check | What it looks for |
   |-------|-------------------|
   | Secrets | API keys, tokens, passwords, private keys in code or config |
   | .env exposure | `.env` files added to git, secrets in committed config |
   | Dependency issues | Known vulnerable dependencies (reads lock files) |
   | Permissions | Overly broad file permissions (chmod 777, world-readable) |
   | Debug code | `console.log`, `print()`, `System.out.println` in production paths |
   | SQL injection | Raw SQL string concatenation |
   | Hardcoded URLs | Production URLs/IPs hardcoded in source |

3. Report:

   ```
   Security scan — 2 issues found:

   🔴 HIGH: Possible API key in src/config.ts:15
      OPENAI_API_KEY = "sk-..."
      → Move to environment variable

   🟡 LOW: Debug console.log in src/auth/login.ts:42
      console.log("user data:", userData)
      → Remove before merging

   ✅ No vulnerable dependencies found
   ✅ No .env files staged
   ```

4. Ask:
   - `Fix the issues automatically`
   - `Show me details`
   - `Ignore and continue`

**Arguments:** `[base-ref]` (optional)

---

#### `/devflow-cleanup`

Clean up merged branches, stale worktrees, and old state files.

**Flow:**

1. Find merged branches:
   ```bash
   git branch --merged <base_branch> | grep -v <base_branch>
   ```
2. Find orphaned worktrees:
   ```bash
   git worktree list --porcelain
   ```
   Check if the branch for each worktree has been merged or deleted on remote.
3. Find stale state files:
   - `.claude/review-state/PR-*.json` for PRs that are merged/closed
   - `.claude/tickets/*.state.json` for tickets whose PRs are merged
4. Present summary:
   ```
   Cleanup candidates:

   Merged branches (5):
     feature/PROJ-100-add-login
     fix/PROJ-105-null-check
     ...

   Orphaned worktrees (2):
     ~/worktrees/feature_PROJ-100_add_login (branch merged)
     ~/worktrees/fix_PROJ-105_null_check (branch deleted)

   Stale state files (3):
     .claude/review-state/PR-42.json (PR merged)
     .claude/tickets/PROJ-100.state.json (PR merged)
     ...
   ```
5. Ask:
   - `Clean all`
   - `Let me pick`
   - `Cancel`
6. If cleaning:
   - Delete local branches: `git branch -d <branch>`
   - Remove worktrees: `git worktree remove <path>`
   - Delete state files
   - Optionally delete remote branches: `git push origin --delete <branch>`

**Arguments:** `--dry-run` (show what would be cleaned without doing it)

---

## Cross-cutting concerns

### Config reader

Every tool's first action is to read `.claude/devflow.yaml`. If the file doesn't exist, tell the user to run `/devflow-init`. The config is loaded once and values are referenced throughout the command.

Commands reference config values like:
- `devflow.yaml → github.host` for all `gh` commands
- `devflow.yaml → github.base_branch` for diff base
- `devflow.yaml → commits` for title/message generation
- `devflow.yaml → languages.<primary>` for format/test/build commands

### Security model for `/devflow-implement`

The implement script uses `--dangerously-skip-permissions` for `claude -p` calls in worktrees. This is necessary because Claude Code's permission system doesn't reliably work with `claude -p` in worktree directories.

**Mitigations:**
- Security pre-flight: Haiku scans ticket content for prompt injection before the main agent runs
- Safety preamble: every prompt tells Claude not to touch CI/CD files, not to push to main, not to install global packages
- Branch name validation: regex check against `[a-z0-9][a-z0-9/_-]*`, max 100 chars
- Worktree isolation: the worktree is outside the main repo, disposable
- Push scope: `git push` only targets the feature branch

### Output rules

All tools follow these verbosity rules:
- Filter/classify phases are silent — no narrating what's being skipped
- Results are presented directly
- "Nothing to do" states are one line, not a paragraph
- No intermediate API response logging unless `--verbose` is passed

### State management

| State | Storage | Shared? |
|-------|---------|---------|
| Review comment decisions | `.claude/review-state/PR-<n>.json` | Local (gitignored) |
| Review summary table | GitHub PR comment (edited in place) | Yes (visible to reviewer) |
| Ticket progress | `.claude/tickets/<ID>.state.json` | Local (gitignored) |
| Ticket plan + reviews | `.claude/tickets/<ID>.plan.md` | Local (can be committed) |
| PR description state | `<!-- auto-pr-desc -->` marker in PR body | Yes |

No tool writes state into the PR description body except the `auto-pr-desc` marker.

---

## Tier summary

| Tier | Tools | Use case |
|------|-------|----------|
| 0 — Setup | `devflow-init` | First-time configuration |
| 1 — PR Lifecycle | `pr-create`, `pr-describe`, `pr-update`, `pr-status`, `pr-comments`, `pr-review`, `split-pr` | Day-to-day PR workflow |
| 2 — Ticket Implementation | `implement` (plan, code, feedback, iterate — one command) | AI-assisted coding |
| 3 — Documentation | `docs` | Doc generation and maintenance |
| 4 — Quality & Maintenance | `onboard`, `test-impact`, `security-scan`, `cleanup` | Code quality and repo hygiene |

Ship Tier 0 + 1 first. They're the smallest useful unit with the broadest appeal.
