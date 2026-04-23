---
name: devflow-pr-status
description: Dashboard of your open PRs — status, review state, quick actions.
disable-model-invocation: true
allowed-tools: Bash(*) Read(*)
---

Show status of your open PRs.

Read `.claude/devflow.yaml`.

## Flow

1. Fetch:
   ```bash
   GH_HOST=<host> gh pr list --author @me \
     --json number,title,url,reviewDecision,updatedAt,isDraft,headRefName
   ```

2. Categorize:
   - 🟢 Approved (`APPROVED`)
   - 🔴 Changes requested (`CHANGES_REQUESTED`)
   - 🟡 Waiting (not draft, no decision)
   - ⚪ Draft (`isDraft`)
   - 🔵 Stale (no updates 7+ days)

3. Display concise table. No extra commentary.

4. Ask:
   - `Address comments on #<number>` → suggest `/devflow-pr-comments`
   - `Merge #<number>` → `GH_HOST=<host> gh pr merge <number> --squash`
   - `Done`
