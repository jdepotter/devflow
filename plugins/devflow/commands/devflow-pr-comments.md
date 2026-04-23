---
name: devflow-pr-comments
description: Triage PR review comments — fix, decline, or defer each one, then post replies and a summary table to GitHub.
argument-hint: "[--manual] [--all] [--self]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*) Edit(*)
---

Handle review comments on the current branch's PR.

Be concise. Do not narrate filtering. Present results directly.
If nothing to do: "PR is clean — no unresolved comments." Stop.

Read `.claude/devflow.yaml`.

## Arguments

- (none): new + followup + deferred
- `--manual`: deferred items only
- `--all`: everything including resolved
- `--self`: include PR author's own comments

## Step 1 — Locate PR and load state

```bash
GH_HOST=<host> gh pr view --json number,title,url --jq '{number,title,url}'
GH_HOST=<host> gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

Read `.claude/review-state/PR-<number>.json` if exists.
Find existing summary comment (body starts with `## Review feedback`).

## Step 2 — Fetch comments

Inline threads via GraphQL (`reviewThreads` with `isResolved`, `comments`).
General comments via REST (`issues/<pr>/comments`).

## Step 3 — Filter

- Skip `author.login` ending with `[bot]`
- Skip body starting with `## Review feedback`
- Skip PR author's comments (unless `--self`)
- Determine: NEW, FOLLOWUP (reply after `[devflow-review]`), DEFERRED

Classify NEW: **FIX** (mechanical) / **DISCUSS** (judgment) / **PARTIAL** (needs confirmation).
General comments: **GENERAL-FIX** / **GENERAL-DISCUSS**.

## Step 4 — Present

Numbered list with `@reviewer`, file, summary, tag.

For FIX items ask (2 options for VS Code picker):
- `Fix all automatically (items ...)`
- `Let me review each one`

DEFERRED items: `Auto-fix` / `Done — I fixed it` / `Decline` / `Skip for now`
DISCUSS: `Reply (I'll type)` / `Decline` / `Handle offline`
PARTIAL: show before/after → `Apply` / `Decline` / `Handle manually`

## Step 5 — Implement fixes

Group by file, bottom-to-top. Run format command from config.
Show one-line summary per fix with reviewer name.

## Step 6 — Commit and push

```bash
git add <files>
git commit -m "fix: address review feedback on PR #<number>"
git push
```

## Step 7 — Post replies

Every decided item (not deferred) gets a reply:
- `[devflow-review] ✅ Fixed — <detail>`
- `[devflow-review] ❌ Won't fix — <reason>`
- `[devflow-review] 💬 <response>`

Inline: `pulls/<pr>/comments/<id>/replies`
General: `issues/<pr>/comments` with `> quote`

## Step 8 — Save state

Write `.claude/review-state/PR-<number>.json` via Write tool.
Ensure `.claude/review-state/` is gitignored.

## Step 9 — Update summary comment

Table with all decisions. Edit existing or create new.
General items show `PR comment` in File column.
Include `_Last updated_` timestamp.
Save comment ID to state.
