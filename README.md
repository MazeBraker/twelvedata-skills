# Twelve Data Skills

Agent Skills for working with the [Twelve Data](https://twelvedata.com) financial market data API. Follows the [Agent Skills](https://agentskills.io) format, so the skills work in Cursor, Claude Code, Codex and other compatible clients.

The repository is being built step by step, see [ROADMAP.md](./ROADMAP.md) for what is done and what comes next. Eval scores: [eval.md](./eval.md).

## Skills

| Skill | Description |
| --- | --- |
| [twelvedata-api](./skills/twelvedata-api) | Core REST API: authentication, credits, errors, batching, symbol resolution |
| [twelvedata-indicators](./skills/twelvedata-indicators) | 100+ ready-made technical indicators |
| [twelvedata-funds](./skills/twelvedata-funds) | ETFs, mutual funds and money market funds |
| [twelvedata-websocket](./skills/twelvedata-websocket) | Real-time price streaming |
| [twelvedata-mcp](./skills/twelvedata-mcp) | MCP server and SDK setup for agent clients |
| [twelvedata-cli](./skills/twelvedata-cli) | Official `twelvedata` CLI for shells, scripts and CI |
| [twelvedata-best-practices](./skills/twelvedata-best-practices) | Credit budgeting, timezones, gaps, retries, caching |

Skills are scoped so that a task loads only the context it needs. `twelvedata-api` holds the rules shared by every request and routes to the other skills.

## Prerequisites

1. Access to this GitLab project (it is private until published). Ask a maintainer for Reporter access or for a zip of the repo.
2. Node.js 18+ (for `npx skills`).
3. An agent client that loads Agent Skills (Cursor, Claude Code, Codex, or compatible).
4. A Twelve Data API key from [twelvedata.com/register](https://twelvedata.com/register).

```bash
export TWELVE_DATA_API_KEY='your-key'
```

All skills in this repo use that single name. The `twelvedata` CLI binary reads `TWELVEDATA_API_KEY`, so mirror it when you use the CLI: `export TWELVEDATA_API_KEY="$TWELVE_DATA_API_KEY"`.

## Install

### 1. Get the repository

```bash
git clone https://gitlab.atlasgroup.ai/twelvedata/skills.git
cd skills
```

If the latest work is still on a feature branch (for example `skills-v1`):

```bash
git fetch origin
git checkout skills-v1
```

Or unpack a zip from a maintainer and `cd` into that folder.

### 2. See what is available (no install yet)

From the **repository root**:

```bash
npx skills add . --list
```

You should see seven skills (`twelvedata-api`, `twelvedata-indicators`, …).

### 3. Install one skill

Example — only the REST core skill, into Cursor for this project:

```bash
npx skills add . --skill twelvedata-api --agent cursor -y
```

Other examples:

```bash
# CLI skill only
npx skills add . --skill twelvedata-cli --agent cursor -y

# Several skills
npx skills add . --skill twelvedata-api --skill twelvedata-indicators --agent cursor -y
```

Replace `cursor` with your client if needed (`claude-code`, etc.), or omit `--agent` and pick interactively.

### 4. Install every skill

```bash
npx skills add . --skill '*' --agent cursor -y
```

### 5. Confirm installation

```bash
npx skills list
```

In Cursor, open a chat in the same project and ask something that should trigger the skill, for example:

- `twelvedata-api`: “Get the last 30 daily bars for AAPL from Twelve Data; show the exact request.”
- `twelvedata-cli`: “Show the Twelve Data CLI command for 14-day RSI on AAPL.”
- `twelvedata-mcp`: “How do I wire Twelve Data MCP into Cursor?”

The agent should follow the skill (env key, concrete endpoints/flags). If it ignores Twelve Data rules, check that `npx skills list` shows the skill for that project and restart the client.

### Optional: MCP server

`mcp.json` in this repo is a template. Merge it into `~/.cursor/mcp.json` (or the project `.cursor/mcp.json`), keep the key in `TWELVE_DATA_API_KEY`, restart Cursor, and confirm the `twelvedata` server is connected. Details: `twelvedata-mcp` skill. Cursor interpolates `${env:TWELVE_DATA_API_KEY}` — a bare `${VAR}` will not resolve.

### Optional: install as a plugin

Claude Code copies the marketplace source as-is and does not skip `.gitignore`, so never add this working copy as a marketplace while `.env` is present. Export a clean tree first:

```bash
./scripts/export_plugin.sh
claude plugin marketplace add "$(pwd)/.plugin-export"
claude plugin install twelvedata@twelvedata-skills
claude plugin list   # twelvedata@twelvedata-skills, enabled
```

Cursor local plugin (after the same export):

```bash
mkdir -p ~/.cursor/plugins/local
ln -sfn "$(pwd)/.plugin-export" ~/.cursor/plugins/local/twelvedata
```

Then reload the window and check Customize → Skills / MCP for the seven skills and the `twelvedata` server. Requires `uv` (`brew install uv`) so `uvx` in `mcp.json` resolves.

### Remove a skill

```bash
npx skills remove twelvedata-api -y
```

## Links

- [API documentation](https://twelvedata.com/docs)
- [MCP server](https://github.com/twelvedata/mcp)
- [CLI](https://github.com/twelvedata/twelvedata-cli)
- [Python SDK](https://github.com/twelvedata/twelvedata-python)
- [Pricing](https://twelvedata.com/pricing)

## License

MIT, see [LICENSE](./LICENSE).
