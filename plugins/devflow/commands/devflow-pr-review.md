---
name: devflow-pr-review
description: AI self-review of your branch. Finds missing tests, null safety issues, code quality problems and lets you fix them before human review.
argument-hint: "[--severity high] [--category tests|security] [--fix-all]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*) Edit(*)
---

Self-review the current branch before requesting review.

Be concise. Present findings directly. No preamble.

Read `.claude/devflow.yaml`.

## Flow

1. Gather diff. Read each changed file in **full** (not just hunks).
2. Analyze across: missing tests, error handling, null safety, best practices,
   duplication, file structure, UI components, security, performance, naming.
   Language-specific checks from the code-quality skill apply automatically.
3. Classify: 🔴 HIGH, 🟡 MEDIUM, 🔵 LOW.
4. Filter by `--severity` or `--category` if provided.
5. Present numbered list with severity, file, issue, tag.
6. If `--fix-all` → fix everything. Otherwise ask:
   - `Fix all HIGH and MEDIUM automatically`
   - `Fix all automatically`
   - `Let me review each one`
7. Implement accepted fixes. Run format + test from config.
8. Commit: `fix: address self-review findings`. Push.
9. Print summary: Fixed N, Skipped M.

No issues found → "No issues found — ready for review." Stop.
