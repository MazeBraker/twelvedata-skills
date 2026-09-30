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

1. A clone of this repository: https://github.com/MazeBraker/twelvedata-skills
2. Node.js 18+ if installing individual skills with `npx skills`.
3. An agent client that loads Agent Skills (Cursor, Claude Code, Codex, or compatible).
4. A Twelve Data account from [twelvedata.com/register](https://twelvedata.com/register). Local API key setups also need your API key. Hosted Cursor and Codex plugins use browser login instead.

For local API and stdio MCP setups, set the key in your environment:

```bash
export TWELVE_DATA_API_KEY='your-key'
```

All skills in this repo use that single name for local key-based access. The hosted Codex MCP server uses OAuth instead. The `twelvedata` CLI binary reads `TWELVEDATA_API_KEY`, so mirror it when you use the CLI: `export TWELVEDATA_API_KEY="$TWELVE_DATA_API_KEY"`.

## Install

### 1. Get the repository

```bash
git clone https://github.com/MazeBraker/twelvedata-skills.git
cd twelvedata-skills
```

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

The root `mcp.json` is a template for local clients. Merge it into `~/.cursor/mcp.json` (or the project `.cursor/mcp.json`), keep the key in `TWELVE_DATA_API_KEY`, restart Cursor, and confirm the `twelvedata` server is connected. Details: `twelvedata-mcp` skill. Cursor interpolates `${env:TWELVE_DATA_API_KEY}` — a bare `${VAR}` will not resolve.

The Cursor plugin instead uses `.cursor-plugin/mcp.json` to connect to our [hosted MCP server](https://mcp.twelvedata.com/mcp). Cursor should prompt for Twelve Data OAuth login in your browser; no API key or `uv` is needed for this path. The MCP host does not issue tokens. Connect only to `https://mcp.twelvedata.com/mcp` and follow its protected-resource metadata to `https://auth.twelvedata.com`. The host root answers 404. For help, use [Twelve Data support](https://twelvedata.com/contact); see our [privacy policy](https://twelvedata.com/privacy).

### Codex: hosted MCP server

For MCP tools without the bundled skills, connect Codex to the hosted Twelve Data server:

```bash
codex mcp add twelvedata --url https://mcp.twelvedata.com/mcp
codex mcp list
```

The `add` command starts OAuth; sign in with your own Twelve Data account in the browser. The MCP host does not issue tokens. Connect only to `https://mcp.twelvedata.com/mcp` and follow its protected-resource metadata to `https://auth.twelvedata.com`. The host root answers 404. Run `codex mcp login twelvedata` if you need to authorize again later. The hosted server uses per-user OAuth; you do not need to put an API key in Codex configuration. Codex desktop, CLI, and IDE extension share the same MCP configuration. In Codex, use `/mcp` to check that `twelvedata` is connected, then ask for an AAPL quote and AAPL RSI. To disconnect, run `codex mcp remove twelvedata`.

### Codex: skills and hosted MCP as a plugin

To install all seven skills and the hosted MCP connection together from this checkout, export a clean package and add it as a local Codex marketplace:

```bash
./scripts/export_plugin.sh
codex plugin marketplace add "$(pwd)/.plugin-export"
codex plugin add twelvedata@twelvedata-skills
```

Open Codex, authenticate the Twelve Data MCP server when prompted, and confirm the seven plugin skills and `twelvedata` MCP tools are available. Then ask for an AAPL quote and AAPL RSI. To remove the plugin or the MCP-only server: `codex plugin remove twelvedata@twelvedata-skills` and `codex mcp remove twelvedata`.

This local export is for a checkout on this machine. The public plugin repository is https://github.com/MazeBraker/twelvedata-skills. Install from that URL:

```bash
codex plugin marketplace add https://github.com/MazeBraker/twelvedata-skills
codex plugin add twelvedata@twelvedata-skills
```

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
if [ -L ~/.cursor/plugins/local/twelvedata ]; then rm ~/.cursor/plugins/local/twelvedata; fi
mkdir -p ~/.cursor/plugins/local/twelvedata
cp -R .plugin-export/. ~/.cursor/plugins/local/twelvedata/
```

Then reload the window and check Customize → Skills / MCP for the seven skills and the `twelvedata` server. If it is missing on a managed team account, ask an admin to enable local plugin imports. Sign in with a Twelve Data account and ask for an AAPL quote and 30 daily AAPL bars. Confirm that both tools return data. Disconnect the server, reconnect, and repeat the quote.

The public Cursor plugin repository is https://github.com/MazeBraker/twelvedata-skills. Submit that repository at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish). The community [cursor.directory](https://cursor.directory/plugins/mcp-twelve-data-mcp-server) card is a separate directory.

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
