# Devflow

AI-powered developer workflow automation for [Claude Code](https://code.claude.com). One config, 14 commands, 6 background skills — from ticket to merged PR.

## Install

```bash
# Add the marketplace and install
/plugin marketplace add jdepotter/devflow
/plugin install devflow@devflow

# Then run setup in your project
/devflow-init
```

## What it does

### Commands you invoke

| Command | What happens |
|---------|-------------|
| `/devflow-init` | Detect stack, generate config |
| `/devflow-pr-create` | Push + describe + create PR |
| `/devflow-pr-describe` | Generate description for existing PR |
| `/devflow-pr-update` | Silently fix stale description |
| `/devflow-pr-status` | Dashboard of open PRs |
| `/devflow-pr-comments` | Triage, fix, reply to review comments |
| `/devflow-pr-review` | AI self-review before human review |
| `/devflow-split-pr` | Split large PR into smaller ones |
| `/devflow-implement` | Plan → code → commit → PR |
| `/devflow-docs` | Generate LLM + human docs |
| `/devflow-onboard` | Generate onboarding guide |
| `/devflow-test-impact` | Find affected tests |
| `/devflow-security-scan` | Scan for secrets, injection, debug code |
| `/devflow-cleanup` | Clean merged branches, stale worktrees |

### Skills that auto-activate

These fire automatically when Claude detects the right context.
No command needed.

| Skill | Activates when |
|-------|---------------|
| `commit-format` | Claude writes a commit message |
| `code-quality` | Claude writes or edits code |
| `diff-scoping` | Claude gathers branch diff context |
| `pr-description-format` | Claude writes a PR description |
| `project-conventions` | Claude writes code in this project |
| `context-awareness` | Claude edits code in an existing module |

## Configuration

Everything reads from `.claude/devflow.yaml`. Run `/devflow-init` to generate it,
or copy `devflow.yaml.example` and edit.

```yaml
github:
  host: github.com
  base_branch: main

commits:
  preset: conventional       # conventional | ticket-prefix | freeform
  types: [feat, fix, docs, refactor, chore, test, perf]
  ticket_pattern: "[A-Z]+-[0-9]+"

branches:
  preset: type-ticket-description

languages:
  primary: auto              # auto-detect, or: javascript, typescript, python, go, rust
```

See `devflow.yaml.example` for all options including custom commit templates,
branch patterns, worktree settings, and documentation config.

## Ticket implementation

```bash
# Write a ticket
echo "Add user authentication with JWT" > .claude/tickets/PROJ-123.md

# Implement it
/devflow-implement PROJ-123

# Or without arguments — pick from available tickets
/devflow-implement

# Skip plan approval for simple tickets
/devflow-implement PROJ-123 --auto

# Give feedback without editing files
/devflow-implement PROJ-123 --feedback "use bcrypt not md5"
```

Three files per ticket:
- `PROJ-123.md` — your requirement (never modified)
- `PROJ-123.plan.md` — work plan + review cycles
- `PROJ-123.state.json` — machine state (gitignored)

## Review comments

```bash
/devflow-pr-comments           # new + followup + deferred
/devflow-pr-comments --manual  # deferred items only
/devflow-pr-comments --all     # everything including resolved
/devflow-pr-comments --self    # include your own comments
```

Each comment gets a decision: ✅ Fix, ❌ Decline, 🔧 Manual, 💬 Discuss.
Replies are posted to GitHub. A summary table is maintained as a single
PR comment (edited in place across runs).

## Self-review

```bash
/devflow-pr-review                    # full review
/devflow-pr-review --severity high    # critical issues only
/devflow-pr-review --category tests   # missing tests only
/devflow-pr-review --fix-all          # fix everything, no prompts
```

## Git hooks

For commits made outside Claude (directly via git):

```bash
# Install commit message validation hook
./scripts/setup-hooks.sh

# Remove
./scripts/setup-hooks.sh --remove
```

## Security

The implement script uses `--dangerously-skip-permissions` for `claude -p`
in worktrees. This is necessary because Claude Code's permission system
doesn't work reliably with `claude -p` in worktree directories.

Mitigations:
- Pre-flight scan (Haiku) checks ticket content for injection
- Safety preamble constrains Claude in every prompt
- Branch names are regex-validated
- Worktrees are isolated and disposable
- Push only targets the feature branch

## Project structure

```
devflow/
├── .claude-plugin/
│   └── plugin.json          # plugin manifest
├── skills/                  # 6 auto-triggering background skills
│   ├── commit-format/
│   ├── code-quality/
│   ├── diff-scoping/
│   ├── pr-description-format/
│   ├── project-conventions/
│   └── context-awareness/
├── commands/                # 14 user-invoked commands
│   └── devflow-*.md
├── scripts/
│   ├── implement.sh         # ticket implementation engine
│   └── setup-hooks.sh       # git hook installer
├── hooks/
│   └── commit-msg           # commit message validation
├── docs/
│   └── devflow-spec.md      # full specification
├── devflow.yaml.example
├── README.md
└── LICENSE
```

## License

MIT
