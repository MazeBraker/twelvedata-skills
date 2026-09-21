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

python3 - "$OUT" <<'PY'
import json
import sys
from pathlib import Path

out = Path(sys.argv[1])
if (out / ".env").exists():
    sys.exit("export contains .env")

required = [
    ".cursor-plugin/plugin.json",
    ".cursor-plugin/mcp.json",
    "assets/twelvedata-logo.png",
    "LICENSE",
    "skills/twelvedata-api/SKILL.md",
    "skills/twelvedata-indicators/SKILL.md",
    "skills/twelvedata-funds/SKILL.md",
    "skills/twelvedata-websocket/SKILL.md",
    "skills/twelvedata-mcp/SKILL.md",
    "skills/twelvedata-cli/SKILL.md",
    "skills/twelvedata-best-practices/SKILL.md",
]
for rel in required:
    if not (out / rel).is_file():
        sys.exit(f"export missing {rel}")

plugin = json.loads((out / ".cursor-plugin/plugin.json").read_text())
hosted = json.loads((out / ".cursor-plugin/mcp.json").read_text())
root_mcp = json.loads((out / "mcp.json").read_text())
url = hosted["mcpServers"]["twelvedata"]["url"]
if url != "https://mcp.twelvedata.com/mcp":
    sys.exit(f"hosted MCP url is {url}")
if plugin.get("mcpServers") != "./.cursor-plugin/mcp.json":
    sys.exit("Cursor plugin must point at ./.cursor-plugin/mcp.json")
if plugin.get("logo") != "assets/twelvedata-logo.png":
    sys.exit("Cursor plugin logo path is missing")
if "uvx" not in json.dumps(root_mcp):
    sys.exit("root mcp.json must stay the local uvx template")
print("cursor export ok")
PY

echo "exported $OUT"
