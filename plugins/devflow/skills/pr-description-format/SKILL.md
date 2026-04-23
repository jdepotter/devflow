---
name: pr-description-format
description: >
  PR description template and generation rules. Describes the final state
  of the branch, not commit history. Use this skill whenever writing,
  generating, or updating pull request descriptions, PR bodies, merge
  request descriptions, or when the user asks to "describe this PR" or
  "write a PR description."
user-invocable: false
---

# PR Description Format

When writing a PR description, follow this template and these rules.

## Template

```markdown
## Summary
<!-- 2-3 sentences. What changes after this PR? Mention ticket ID if in branch name. -->

## What was built
<!-- Break down by logical units — not by file or commit.
     Per unit: what it does, how it works, non-obvious decisions. -->

## Reviewer guide
<!-- Where to start reading. What needs attention vs what's boilerplate. -->

## Impact
<!-- API changes, DB migrations, config, dependencies, performance.
     If nothing: "Self-contained — no external impact." -->

## Testing
<!-- Tests added? Manual steps? Edge cases? If none, say so. -->
```

## Rules

1. **Final state, not journey.** Mentioning individual commits clutters the
   description — the reviewer sees commits in the diff already.
2. **Logical units, not files.** Organizing by feature helps reviewers
   understand what the PR does. Organizing by file just repeats the diff.
3. **Concrete.** "Adds `/api/users` endpoint" tells a reviewer where to
   look. "Introduces API infrastructure" doesn't.
4. **No invented context.** The ticket has the "why." Inventing motivation
   risks being wrong and confusing reviewers who know the actual context.
5. **Decisions inline.** Grouping non-obvious decisions with the code they
   affect saves reviewers from jumping between sections.
6. **No padding.** A 1-line Testing section ("Verified manually") is more
   honest and useful than filler.
7. **No diff reproduction.** The reviewer has the diff.

## Examples

**Good "What was built" entry:**
> Adds a `/api/products` endpoint that supports pagination and filtering
> by category. Uses cursor-based pagination (not offset) because the
> products table is large and offset pagination degrades at high page
> numbers. Route handler is in `src/api/products.ts`, query builder in
> `src/db/product-queries.ts`.

**Bad "What was built" entry:**
> Modified `src/api/products.ts`, `src/db/product-queries.ts`,
> `src/types/product.ts`, and `tests/api/products.test.ts` to add
> product listing functionality.
