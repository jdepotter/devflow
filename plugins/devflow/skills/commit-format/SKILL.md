---
name: commit-format
description: >
  Enforces commit message format when writing git commits. Reads the
  project's devflow.yaml for the active preset (conventional, ticket-prefix,
  or freeform) and applies it automatically. Use this skill whenever
  committing code, staging changes, writing commit messages, running
  git commit, or when the user asks to "commit this" or "save my changes."
user-invocable: false
---

# Commit Message Format

When writing a commit message, follow these rules.

## Step 1 — Read config

Read `.claude/devflow.yaml → commits`. Extract:
- `preset` (conventional | ticket-prefix | freeform)
- `types` (allowed prefixes)
- `ticket_pattern` (regex to extract ticket ID from branch name)
- `template` (custom template, overrides preset)
- `lowercase_description` (boolean)
- `max_length` (default 72)

If no config exists, default to conventional with `[feat, fix]`.

## Step 2 — Determine type

Look at the changes being committed:
- New functionality → `feat`
- Bug fix → `fix`
- Documentation only → `docs`
- Refactoring (no behavior change) → `refactor`
- Tests only → `test`

## Step 3 — Extract ticket ID

Get the current branch name. Apply `ticket_pattern` regex. If a match
is found and the preset uses ticket IDs, include it.

## Step 4 — Format the message

### Preset: `conventional`
```
<type>(<optional-scope>): <description>
```

### Preset: `ticket-prefix`
```
<type>: <TICKET-ID> <description>
```

### Preset: `freeform`
Clear imperative summary, no enforced structure.

### Custom template
Replace `{type}`, `{ticket}`, `{scope}`, `{description}` in the template.

## Rules

- If `lowercase_description` is true, description must be all lowercase
- Use imperative mood: "add", "fix", "remove" — not "added", "fixed"
- Keep total length under `max_length`
- No period at the end
