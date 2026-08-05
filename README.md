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

## Install

Until the repository is published, install from a local clone:

```bash
git clone https://gitlab.atlasgroup.ai/twelvedata/skills.git
npx skills add ./skills
```

Add `--list` to see the available skills without installing them.

## Prerequisites

- A Twelve Data account and API key, available at [twelvedata.com/register](https://twelvedata.com/register)
- REST / MCP: `TWELVE_DATA_API_KEY`
- CLI: `TWELVEDATA_API_KEY` (different name — see `twelvedata-cli`)



## Links

- [API documentation](https://twelvedata.com/docs)
- [MCP server](https://github.com/twelvedata/mcp)
- [Python SDK](https://github.com/twelvedata/twelvedata-python)
- [Pricing](https://twelvedata.com/pricing)

