---
name: devflow-pr-create
description: Push the current branch, generate a PR description, and open the PR.
argument-hint: "[base-branch]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Create a PR for the current branch.

Read `.claude/devflow.yaml`. If missing, tell user to run `/devflow-init`.

## Context

- Branch: !`git rev-parse --abbrev-ref HEAD`
- Open PR: !`gh pr list --head "$(git rev-parse --abbrev-ref HEAD)" --json number,url --jq '.[0]' 2>/dev/null`

## Flow

1. If PR exists → suggest `/devflow-pr-describe`. Stop.
2. Push: `git push --set-upstream origin <branch>`
3. Gather diff (the diff-scoping skill provides the rules)
4. Generate title (the commit-format skill provides the rules)
5. Generate description (the pr-description-format skill provides the rules)
6. Write description to `/tmp/devflow-pr-body.md`, append `<!-- auto-pr-desc: <timestamp> -->`
7. Create PR:
   ```bash
   GH_HOST=<host> gh pr create --title "<title>" --body-file /tmp/devflow-pr-body.md \
     --base "<base>" --head "<branch>"
   rm -f /tmp/devflow-pr-body.md
   ```
   Base: `$ARGUMENTS` if provided, else `devflow.yaml → github.base_branch`
8. Print PR URL.
