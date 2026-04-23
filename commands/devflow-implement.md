---
name: devflow-implement
description: Implement a ticket end-to-end — plan, code, commit, PR. Use --auto to skip plan approval. Use when the user asks to implement, build, or work on a ticket.
argument-hint: "<ticket-id> [--auto] [--feedback \"text\"]"
disable-model-invocation: true
allowed-tools: Bash(*/scripts/implement.sh *) Bash(ls *) Read(*)
---

Implement ticket $ARGUMENTS.

If `$ARGUMENTS` is empty or contains only flags, list available tickets:
```bash
ls "$(git rev-parse --show-toplevel)/.claude/tickets/"*.md 2>/dev/null
```
Present filenames (without path or `.md`) as a selectable list.

Run:
```bash
SCRIPT="$(git rev-parse --show-toplevel)/scripts/implement.sh"
set +e
output=$($SCRIPT $ARGUMENTS 2>&1)
exit_code=$?
set -e
echo "$output"
echo "EXIT_CODE:$exit_code"
```

After:

- **EXIT_CODE:2** — plan ready. Extract path from `PLAN_READY:<path>`.
  Read the plan file. Present it. Ask:
  - `Implement`
  - `Give feedback — I'll type what to change`
  - `Cancel`

  If "Implement" → re-run: `$SCRIPT <ticket-id>`
  If "Give feedback" → ask for text, re-run: `$SCRIPT <ticket-id> --feedback "<text>"`

- **EXIT_CODE:0** — done. Show PR URL from output.

  Print handoff summary:
  ```
  === HANDOFF ===
  What was done: (extract from output)
  PR: (extract URL)
  To iterate: /devflow-implement <ticket-id> --feedback "what to change"
  ```

- **EXIT_CODE:1** — error. Show output.
