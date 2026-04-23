---
name: devflow-pr-describe
description: Generate and set the PR description for an existing PR on the current branch.
argument-hint: "[pr-number]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Generate PR description for an existing PR.

Read `.claude/devflow.yaml`.

## Context

- Branch: !`git rev-parse --abbrev-ref HEAD`
- PR: !`gh pr list --head "$(git rev-parse --abbrev-ref HEAD)" --json number,url,body --jq '.[0]' 2>/dev/null`
- Commits: !`git log --first-parent --no-merges --oneline origin/main..HEAD 2>/dev/null | wc -l`

## Flow

1. Use `$ARGUMENTS` as PR number if provided, else context. No PR → suggest `/devflow-pr-create`.
2. Body has `<!-- auto-pr-desc` → regenerate. Blank → generate. Other → ask first.
3. Gather diff. 0 commits → stop.
4. Generate description.
5. Write to `/tmp/devflow-pr-body.md`, append marker.
6. `GH_HOST=<host> gh pr edit <number> --body-file /tmp/devflow-pr-body.md`
7. Clean up. Print URL.
