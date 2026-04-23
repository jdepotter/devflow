---
name: context-awareness
description: >
  Before writing code in a module, read surrounding files to understand
  existing types, patterns, and architecture. Use this skill whenever
  creating new files in an existing directory, editing code in a module
  with other files, continuing work that someone else started, or picking
  up after a previous implementation pass — even for small edits, because
  context prevents inconsistencies.
user-invocable: false
paths:
  - "src/**"
  - "lib/**"
  - "app/**"
  - "packages/**"
  - "cmd/**"
  - "internal/**"
---

# Context Awareness

Before writing or editing code, understand what's already there.

## When creating a new file

1. Read the directory's index/barrel file if one exists
2. Read 2-3 existing files in the same directory to understand:
   - How modules are structured
   - What types/interfaces are already defined
   - Import patterns and dependencies
3. Read the parent directory's structure to understand how this
   module fits into the larger architecture

## When editing an existing file

1. Read the full file first — not just the area around the edit
2. Understand the imports to know what's available
3. Check for related test files to understand expected behavior
4. If the file imports from local modules, read those to understand
   the types and contracts

## When continuing work someone else started

1. Check `git log --oneline -5` to see recent changes
2. If a plan file exists (`.claude/tickets/<ID>.plan.md`), read it
   for context on what was already done and what remains
3. Read any `### What was done` sections to understand current state
4. Do NOT redo work that's already complete — build on it

## Rules

- Read BEFORE writing. Generating code in a directory you haven't
  looked at leads to inconsistencies with existing patterns.
- Match existing patterns. If the project uses factories, use factories.
  If it uses dependency injection, use DI. Introducing new patterns
  without reason creates confusion for the next developer.
- If you see something that looks wrong in existing code, mention it
  but don't fix it unless it's part of the current task.

## Examples

**Good:** Asked to add a new endpoint in `src/api/`, first reads
`src/api/users.ts` and `src/api/orders.ts` to see how routes are
structured, then creates `src/api/products.ts` matching the same pattern.

**Bad:** Asked to add a new endpoint, immediately writes
`src/api/products.ts` using a different framework style than the existing
routes because it didn't read them first.
