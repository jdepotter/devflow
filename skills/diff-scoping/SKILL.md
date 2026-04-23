---
name: diff-scoping
description: >
  Rules for gathering branch diffs. Uses --first-parent --no-merges to
  exclude commits from merged branches. Use this skill whenever comparing
  branches, gathering PR context, listing changes, analyzing what changed,
  answering "what did I change," running git log or git diff against a
  base branch, or preparing content for a PR description.
user-invocable: false
---

# Diff Scoping

When gathering the diff for a branch, use this pattern:

```bash
git log --first-parent --no-merges --format='%h %s%n%b' origin/<base>..HEAD
git log --first-parent --no-merges -p origin/<base>..HEAD -- | head -c 30000
git log --first-parent --no-merges --stat origin/<base>..HEAD
```

Read `.claude/devflow.yaml → github.base_branch` for `<base>`. Default: `main`.

## Why

`--first-parent` follows only the direct line of the branch.
`--no-merges` drops merge commits themselves.

Together: excludes both merge commits and every commit that entered
through those merges. The result is only the author's work.

Do not second-guess this scoping. Everything in the output belongs
to the current branch.
