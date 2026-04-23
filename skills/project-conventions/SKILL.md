---
name: project-conventions
description: >
  Project coding standards and patterns. Reads existing files in the
  directory to match naming, structure, import organization, and error
  handling patterns. Use this skill whenever creating new files, writing
  new code, adding functions or classes, generating implementations,
  scaffolding modules, or when the user asks to "write a service" or
  "add a component" — even for simple additions.
user-invocable: false
paths:
  - "src/**"
  - "lib/**"
  - "app/**"
  - "packages/**"
  - "cmd/**"
  - "internal/**"
---

# Project Conventions

Before writing code in this project, understand its patterns.

## Step 1 — Read config

Read `.claude/devflow.yaml → languages.primary` to know the language.
If `auto`, detect from project files.

## Step 2 — Observe existing patterns

Before creating a new file or editing an existing one:
1. Read 2-3 existing files in the same directory
2. Note: naming conventions, file structure, import organization,
   error handling patterns, test patterns
3. Match these patterns in your code

## Step 3 — Follow conventions

- **Naming:** match existing casing (camelCase, snake_case, PascalCase)
  as used in surrounding files
- **File organization:** follow the directory's established pattern
  (one class per file, barrel exports, etc.)
- **Imports:** group and order imports like existing files
- **Error handling:** use the same patterns as adjacent code
- **Tests:** mirror the test style used in existing test files
  (describe/it, test(), table-driven, etc.)
- **Comments:** match the level and style of existing comments

## Step 4 — Check for project docs

Look for:
- `CONTRIBUTING.md` — team conventions
- `docs/` — architecture and design docs
- `.editorconfig` — formatting rules
- Linter configs (`.eslintrc`, `ruff.toml`, `.golangci.yml`)

Apply any conventions found there.

Do NOT impose conventions from other projects. Match THIS project.
