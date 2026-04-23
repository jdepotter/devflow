---
name: devflow-init
description: Interactive setup wizard for devflow. Detects repo settings and generates .claude/devflow.yaml.
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Set up devflow for this project.

## Step 1 — Detect

```bash
git remote get-url origin 2>/dev/null
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
ls -1 package.json tsconfig.json pyproject.toml setup.py go.mod Cargo.toml 2>/dev/null
```

## Step 2 — Ask preferences

Each question separately, short selectable options:

> Commit format?
- `Conventional (feat: add login)`
- `Ticket prefix (feat: PROJ-123 add login)`
- `Freeform`

> Branch naming?
- `type/description`
- `type/ticket-description`
- `user/type/description`

> Ticket ID pattern? (e.g. JIRA-123, GH-42, or skip)

## Step 3 — Write .claude/devflow.yaml

Use detected + selected values. Base on the bundled `devflow.yaml.example`.

## Step 4 — Gitignore

```bash
grep -q 'review-state' .gitignore 2>/dev/null || echo '.claude/review-state/' >> .gitignore
grep -q '\.state\.json' .gitignore 2>/dev/null || echo '*.state.json' >> .gitignore
```

## Step 5 — Summary

One short paragraph of what was configured.
