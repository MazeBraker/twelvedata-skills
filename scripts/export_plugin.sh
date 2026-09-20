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
    ".codex-plugin/plugin.json",
    ".mcp.json",
    ".agents/plugins/marketplace.json",
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

plugin = json.loads((out / ".codex-plugin/plugin.json").read_text())
mcp = json.loads((out / ".mcp.json").read_text())
marketplace = json.loads((out / ".agents/plugins/marketplace.json").read_text())
root_mcp = json.loads((out / "mcp.json").read_text())
hosted = mcp["mcpServers"]["twelvedata"]["url"]
if hosted != "https://mcp.twelvedata.com/mcp":
    sys.exit(f"hosted MCP url is {hosted}")
if plugin.get("mcpServers") != "./.mcp.json":
    sys.exit("Codex plugin must point at ./.mcp.json")
if "uvx" not in json.dumps(root_mcp):
    sys.exit("root mcp.json must stay the local uvx template")
if marketplace.get("name") != "twelvedata-skills":
    sys.exit("marketplace name must be twelvedata-skills")
print("codex export ok")
PY

echo "exported $OUT"
