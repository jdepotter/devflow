---
name: code-quality
description: >
  Code quality checks applied while writing or editing code. Catches
  missing error handling, null safety issues, test gaps, naming problems,
  and language-specific anti-patterns. Use this skill whenever writing
  new code, editing existing code, generating implementations, fixing
  bugs, writing tests, or refactoring — even if the user doesn't
  explicitly ask for a review.
user-invocable: false
---

# Code Quality

When writing or editing code, check for these issues inline. Do not run
a separate review pass — apply these during generation.

## Checks

### Error handling
- Every external call (API, DB, file I/O) has error handling
- No bare catch/except that swallows errors silently
- Async operations have rejection handling

### Null safety
- No dereference without a guard or optional chaining
- Function parameters that could be null/undefined are checked
- Return values from external calls are validated

### Test coverage
- New public functions should have tests (or note that they don't)
- Edge cases (empty input, null, error path) are considered

### Naming
- Variables and functions have descriptive names
- Consistent with surrounding code conventions
- No single-letter variables outside loop indices

### Structure
- Functions under 50 lines where possible
- No deeply nested conditionals (3+ levels)
- Repeated logic extracted into helpers

## Language-specific

Read `.claude/devflow.yaml → languages.primary`. Apply extra checks:

**TypeScript/JavaScript:**
- No `any` type without justification
- Async functions have `await` or return the promise
- React components have `key` props in lists
- No `console.log` in production paths

**Python:**
- Type hints on function signatures
- No bare `except:` — catch specific exceptions
- No mutable default arguments

**Go:**
- Error returns are checked (no `_ = err`)
- Resources have `defer` cleanup
- Exported functions have doc comments

**Rust:**
- `.unwrap()` only with a comment explaining why it's safe
- Errors propagated with `?` where possible

## How to apply

Do NOT list issues separately. Fix them as you write. If you spot a
problem in existing code adjacent to your changes, mention it but don't
fix it unless asked — avoid scope creep.
