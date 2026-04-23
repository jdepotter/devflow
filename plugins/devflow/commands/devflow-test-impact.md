---
name: devflow-test-impact
description: Analyze which tests to run based on changed files. Maps source changes to test files.
argument-hint: "[base-ref]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*)
---

Find tests affected by the current branch's changes.

Read `.claude/devflow.yaml`.

## Flow

1. Get changed files (diff-scoping skill provides the rules):
   ```bash
   git log --first-parent --no-merges --name-only --pretty=format: \
     origin/<base>..HEAD | sort -u | grep -v '^$'
   ```
   Use `$ARGUMENTS` as base ref if provided.

2. For each changed file, find test files:
   - By convention: `foo.ts` → `foo.test.ts`, `foo.spec.ts`; `foo.py` → `test_foo.py`; `foo.go` → `foo_test.go`
   - By imports: `grep -rl "from.*<module>" tests/ **/*.test.* 2>/dev/null`

3. Show:
   ```
   Direct tests: ...
   Indirect tests: ...
   No coverage: ⚠ ...
   ```

4. Ask:
   - `Run all identified tests`
   - `Run direct tests only`
   - `Show untested files`

5. Run using `devflow.yaml → languages.<primary>.test`.
