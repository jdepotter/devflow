#!/bin/bash
# setup-hooks.sh — Install devflow git hooks
#
# Usage:
#   ./scripts/setup-hooks.sh          # Install
#   ./scripts/setup-hooks.sh --remove # Remove

set -e

ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$ROOT/.git/hooks"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Find the hooks source — could be in plugin cache or local
PLUGIN_HOOKS=""
for candidate in \
  "$ROOT/hooks" \
  "$SCRIPT_DIR/../hooks" \
  "$HOME/.claude/plugins/cache/devflow/hooks"; do
  if [ -d "$candidate" ]; then
    PLUGIN_HOOKS="$candidate"
    break
  fi
done

if [ -z "$PLUGIN_HOOKS" ] && [ "$1" != "--remove" ]; then
  echo "ERROR: Could not find devflow hooks directory."
  echo "Searched: $ROOT/hooks, $SCRIPT_DIR/../hooks, ~/.claude/plugins/cache/devflow/hooks"
  exit 1
fi

install() {
  mkdir -p "$HOOKS_DIR"

  # commit-msg hook
  if [ -f "$HOOKS_DIR/commit-msg" ] && ! grep -q 'devflow' "$HOOKS_DIR/commit-msg" 2>/dev/null; then
    echo "⚠  Existing commit-msg hook found. Back it up and re-run, or merge manually."
  elif [ ! -f "$HOOKS_DIR/commit-msg" ] || grep -q 'devflow' "$HOOKS_DIR/commit-msg" 2>/dev/null; then
    cp "$PLUGIN_HOOKS/commit-msg" "$HOOKS_DIR/commit-msg"
    chmod +x "$HOOKS_DIR/commit-msg"
    echo "✓ commit-msg hook installed"
  fi

  echo ""
  echo "Done. To remove: $0 --remove"
}

remove() {
  if [ -f "$HOOKS_DIR/commit-msg" ] && grep -q 'devflow' "$HOOKS_DIR/commit-msg" 2>/dev/null; then
    rm "$HOOKS_DIR/commit-msg"
    echo "✓ commit-msg hook removed"
  else
    echo "  No devflow hooks found"
  fi
}

case "${1:-}" in
  --remove) remove ;;
  *) install ;;
esac
