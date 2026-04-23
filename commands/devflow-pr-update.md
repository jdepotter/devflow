---
name: devflow-pr-update
description: Silently update the PR description to match current branch state. No changelogs or update annotations.
argument-hint: "[pr-number]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Update PR description to reflect current branch.

Read `.claude/devflow.yaml`.

## Context

- Branch: !`git rev-parse --abbrev-ref HEAD`
- PR: !`gh pr list --head "$(git rev-parse --abbrev-ref HEAD)" --json number,url,body --jq '.[0]' 2>/dev/null`
- Commits: !`git log --first-parent --no-merges --oneline origin/main..HEAD 2>/dev/null | wc -l`

## Flow

1. Locate PR. No PR → stop.
2. Body empty → suggest `/devflow-pr-describe`. Stop.
3. Strip `<!-- auto-pr-desc -->` marker.
4. Gather diff. 0 commits → stop.
5. Compare existing description against diff. Find stale/missing/inaccurate sections.
6. Produce a clean, complete description. Rules:
   - Reads as if written fresh — no "Updated:", no "Previously:"
   - Keep accurate sections as-is
   - Never mention the update process
7. Write to temp file, append marker, update PR via `--body-file`.
8. Print URL. Do NOT list what changed.
