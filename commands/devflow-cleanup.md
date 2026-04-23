---
name: devflow-cleanup
description: Clean up merged branches, stale worktrees, and old state files.
argument-hint: "[--dry-run]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*)
---

Clean up merged branches, orphaned worktrees, and stale state files.

Read `.claude/devflow.yaml`.

## Flow

1. Find merged branches: `git branch --merged origin/<base> | grep -v <base>`
2. Find orphaned worktrees: `git worktree list --porcelain` — check if branch merged/deleted
3. Find stale state files: `.claude/review-state/PR-*.json` and `tickets/*.state.json`
   for PRs that are merged/closed
4. Present summary.
5. If `--dry-run` → show and stop.
6. Ask: `Clean all` / `Let me pick` / `Cancel`
7. Delete branches (`git branch -d`), remove worktrees (`git worktree remove`),
   delete state files.
8. Ask: `Also delete remote branches` / `Keep remote`
