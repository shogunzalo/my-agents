#!/usr/bin/env bash
# Sync this repo into ~/.claude/ so the agents, skills, and standards are available
# in every Claude Code session on this machine.
#
#   ./install.sh            copy agents/ + skills/ + standards/ into ~/.claude/
#   ./install.sh --symlink  symlink instead, so edits here take effect live
#   ./install.sh --dry-run  show what would happen, change nothing
#
# Targets (override with env vars):
#   CLAUDE_AGENTS_DIR    (default ~/.claude/agents)     <- agents/*.md
#   CLAUDE_SKILLS_DIR    (default ~/.claude/skills)     <- skills/**/SKILL.md (by folder)
#   CLAUDE_STANDARDS_DIR (default ~/.claude/standards)  <- standards/*.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="$ROOT/agents"
SKILLS_SRC="$ROOT/skills"
STANDARDS_SRC="$ROOT/standards"

AGENTS_DEST="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"
SKILLS_DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
STANDARDS_DEST="${CLAUDE_STANDARDS_DIR:-$HOME/.claude/standards}"

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

echo "root:      $ROOT"
[ "$DRY" -eq 1 ] && echo "mode:      $MODE (dry-run)" || echo "mode:      $MODE"
echo

place() { # place <src-file> <dest-file>
  local src="$1" dest="$2"
  [ "$DRY" -eq 1 ] || mkdir -p "$(dirname "$dest")"
  if [ "$MODE" = "symlink" ]; then
    echo "  symlink ${dest#$HOME/}"
    [ "$DRY" -eq 1 ] || ln -sf "$src" "$dest"
  else
    echo "  copy    ${dest#$HOME/}"
    [ "$DRY" -eq 1 ] || cp "$src" "$dest"
  fi
}

# --- agents: flat *.md -----------------------------------------------------------
echo "agents -> $AGENTS_DEST"
agent_n=0
if [ -d "$AGENTS_SRC" ]; then
  for f in "$AGENTS_SRC"/*.md; do
    [ -e "$f" ] || continue
    place "$f" "$AGENTS_DEST/$(basename "$f")"
    agent_n=$((agent_n + 1))
  done
fi
echo

# --- standards: flat *.md --------------------------------------------------------
echo "standards -> $STANDARDS_DEST"
std_n=0
if [ -d "$STANDARDS_SRC" ]; then
  for f in "$STANDARDS_SRC"/*.md; do
    [ -e "$f" ] || continue
    place "$f" "$STANDARDS_DEST/$(basename "$f")"
    std_n=$((std_n + 1))
  done
fi
echo

# --- skills: preserve folder-per-skill layout ------------------------------------
echo "skills -> $SKILLS_DEST"
skill_n=0
if [ -d "$SKILLS_SRC" ]; then
  while IFS= read -r skillmd; do
    rel="${skillmd#$SKILLS_SRC/}"          # e.g. engineering/tdd/SKILL.md
    place "$skillmd" "$SKILLS_DEST/$rel"
    skill_n=$((skill_n + 1))
  done < <(find "$SKILLS_SRC" -type f -name 'SKILL.md' | sort)
fi
echo

echo "done. ${MODE}d ${agent_n} agent(s), ${std_n} standard(s), ${skill_n} skill(s)."
