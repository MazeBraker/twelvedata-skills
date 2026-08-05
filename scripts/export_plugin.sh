#!/usr/bin/env bash
# Clean tree for local marketplace / plugin installs.
# Claude Code copies the marketplace source as-is and does not honour .gitignore,
# so a working copy with .env would leak into ~/.claude/plugins/cache.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-"$ROOT/.plugin-export"}"
rm -rf "$OUT"
mkdir -p "$OUT"
rsync -a \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='.plugin-export' \
  --exclude='*-workspace/' \
  --exclude='.venv' \
  --exclude='node_modules' \
  --exclude='__pycache__' \
  --exclude='.DS_Store' \
  "$ROOT"/ "$OUT"/
echo "exported $OUT"
