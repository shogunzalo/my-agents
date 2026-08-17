#!/usr/bin/env bash
# Sync this repo's agent definitions into ~/.claude/agents/ so they are available
# in every Claude Code session on this machine.
#
#   ./install.sh            copy agents/*.md -> ~/.claude/agents/
#   ./install.sh --symlink  symlink instead, so edits here take effect live
#   ./install.sh --dry-run  show what would happen, change nothing
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/agents"
DEST="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"

MODE="copy"
DRY=0
for arg in "$@"; do
  case "$arg" in
    --symlink) MODE="symlink" ;;
    --dry-run) DRY=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

echo "source: $SRC"
echo "dest:   $DEST"
[ "$DRY" -eq 1 ] && echo "mode:   $MODE (dry-run)" || echo "mode:   $MODE"
echo

[ "$DRY" -eq 1 ] || mkdir -p "$DEST"

for f in "$SRC"/*.md; do
  name="$(basename "$f")"
  target="$DEST/$name"
  if [ "$MODE" = "symlink" ]; then
    echo "symlink $name"
    [ "$DRY" -eq 1 ] || ln -sf "$f" "$target"
  else
    echo "copy    $name"
    [ "$DRY" -eq 1 ] || cp "$f" "$target"
  fi
done

echo
echo "done. ${MODE}d $(ls -1 "$SRC"/*.md | wc -l | tr -d ' ') agent(s) into $DEST"
