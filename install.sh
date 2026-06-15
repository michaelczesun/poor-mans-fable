#!/usr/bin/env bash
set -euo pipefail

# Installs the /fable skill into your Claude Code skills directory.
SRC="$(cd "$(dirname "$0")" && pwd)/skills/fable/SKILL.md"
DEST="${HOME}/.claude/skills/fable"

if [ ! -f "$SRC" ]; then
  echo "error: $SRC not found (run this from inside the cloned repo)" >&2
  exit 1
fi

mkdir -p "$DEST"
cp "$SRC" "$DEST/SKILL.md"

echo "Installed /fable -> $DEST/SKILL.md"
echo "Restart Claude Code, then run:  /fable <your task>"
