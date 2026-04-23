---
name: devflow-split-pr
description: Split a large PR into smaller focused PRs based on logical groupings.
argument-hint: "[number-of-splits]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Split the current branch's changes into smaller PRs.

Read `.claude/devflow.yaml`.

## Flow

1. Gather full diff. Read changed files.
2. Identify logical groupings: independent vs dependent, refactor vs feature vs test.
3. Propose split plan with titles, file lists, dependencies.
4. Ask: `Split` / `Adjust — I'll describe` / `Cancel`
5. For each split: create branch, checkout files, commit, push, create PR.
6. Ask: `Close original PR` / `Keep it`
