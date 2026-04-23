---
name: devflow-docs
description: Generate LLM and human-readable documentation for a feature. Reads source code and produces structured docs.
argument-hint: "[feature or area to document]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*) Edit(*)
---

Generate documentation for a feature or area.

Read `.claude/devflow.yaml → docs`. If `enabled` is false or missing,
tell user to enable it and stop.

## Flow

1. Read doc map (`devflow.yaml → docs.map_file`). Check existing coverage.
2. If `$ARGUMENTS` provided, use as target. Otherwise ask what to document.
3. Read relevant source files thoroughly. Extract: entry points, flows,
   config fields, API endpoints, data models, dependencies.
4. Create LLM doc at `<docs.llm_dir>/<name>.md`:
   - Full module/class paths, decision tables, field mappings
   - No prose — structured tables, code blocks, ASCII diagrams
   - Add `<!-- last-reviewed: YYYY-MM-DD -->` and `<!-- covers: path -->`
   - Keep under 15KB
5. Create human doc(s) at `<docs.human_dir>/<section>/<name>.md`:
   - No class names or code references
   - Mermaid diagram for every flow
   - Audience: product managers
   - For complex features, ask whether to split into multiple pages
6. Update doc map file with new entries.
7. If `docs.lint_command` is set, run it. Fix any failures.
