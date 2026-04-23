---
name: devflow-onboard
description: Generate a developer onboarding guide by analyzing the codebase structure, tech stack, and conventions.
argument-hint: "[output-path]"
disable-model-invocation: true
allowed-tools: Bash(*) Read(*) Write(*)
---

Generate an onboarding guide for this project.

## Flow

1. Scan:
   ```bash
   find . -maxdepth 3 -type f \( -name '*.md' -o -name '*.json' -o -name '*.yaml' \
     -o -name '*.toml' -o -name 'Makefile' -o -name 'Dockerfile' \) \
     | grep -v node_modules | grep -v .git | sort | head -50
   cat README.md 2>/dev/null | head -100
   ls .github/workflows/ 2>/dev/null
   ls package.json pyproject.toml go.mod Cargo.toml tsconfig.json 2>/dev/null
   git log --oneline -20
   git shortlog -sn --no-merges | head -10
   ```

2. Read: README.md, package.json (or equivalent), docs/ index files.

3. Generate:
   ```markdown
   # Developer Onboarding — <repo-name>

   ## What this project does
   ## Tech stack
   ## Getting started
   ## Project structure
   ## Key concepts
   ## Where to start reading
   ## Common tasks
   ```

4. If `$ARGUMENTS` provides a path, write there. Otherwise ask:
   - `Save as ONBOARDING.md`
   - `Save to docs/onboarding.md`
   - `Just show it`
