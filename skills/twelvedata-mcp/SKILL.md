---
name: twelvedata-mcp
description: Use when setting up access to Twelve Data for an AI agent or IDE - installing and running the official Twelve Data MCP server, configuring it in Cursor, Claude Code or another MCP client, storing the API key, or deciding between MCP tools, the official SDKs and raw REST calls. Use it whenever a request is about connecting an agent, assistant or editor to Twelve Data rather than about a specific piece of market data.
---

# Twelve Data MCP setup

The official MCP server exposes the Twelve Data API as agent tools, so the model does not have to hand-write HTTP requests. Prefer it over direct REST whenever it is available.

## Run the server

The package needs Python 3.13 (3.12 is too old, 3.14 currently fails to build deps). Pin it with `uvx`:

```bash
uvx --python 3.13 mcp-server-twelve-data --twelve-data-apikey "$TWELVE_DATA_API_KEY"
```

Or install it first:

```bash
python3.13 -m pip install mcp-server-twelve-data
mcp-server-twelve-data --twelve-data-apikey "$TWELVE_DATA_API_KEY"
```

The flag is `--twelve-data-apikey` (short `-k`). There is no `--apikey`. Get a key at [twelvedata.com/register](https://twelvedata.com/register).

## Configure a client

Codex can use the hosted MCP server with per-user OAuth, without a local Python server or API key in configuration:

```bash
codex mcp add twelvedata --url https://mcp.twelvedata.com/mcp
```

The `add` command starts OAuth in the browser. Use `codex mcp login twelvedata` later to authorize again if needed, and `codex mcp remove twelvedata` to disconnect. After login, ask for an AAPL quote and AAPL RSI.

The MCP host does not issue tokens. Connect only to `https://mcp.twelvedata.com/mcp` and follow its protected-resource metadata to `https://auth.twelvedata.com`. Do not point a connector at the host root (it answers 404), or at this host's `/register` or `/.well-known/oauth-authorization-server`.

For the seven skills and the hosted MCP connection together, install the Codex plugin from the clean local export as described in this repository's README.

Cursor, in `~/.cursor/mcp.json` for every project or `.cursor/mcp.json` for one:

```json
{
  "mcpServers": {
    "twelvedata": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "--python",
        "3.13",
        "mcp-server-twelve-data",
        "--twelve-data-apikey",
        "${env:TWELVE_DATA_API_KEY}"
      ]
    }
  }
}
```

Claude Code and other MCP clients take the same command and arguments in their own config file. After editing, restart the client and confirm the server is listed as connected before assuming a tool call failed for another reason.

## Choosing an access path

Use MCP tools when the client supports MCP. The schemas keep parameter names correct and avoid a round trip through the docs.

Use an official SDK when writing application code that has to run without an agent: `twelvedata` for Python, `@twelvedata/twelvedata-node` for Node, plus Go, Java and R. Use the `twelvedata` CLI (see `twelvedata-cli`) from shells, scripts and CI.

Use raw REST when neither is available, or for a one-off `curl`. Follow the rules in the `twelvedata-api` skill.

## Gotchas

- The key is passed as a command argument, so it can leak into process lists and shell history. Keep it in `TWELVE_DATA_API_KEY` and interpolate, never paste the literal key into a config file that gets committed.
- The interpolation syntax is `${env:VAR}`. A bare `${VAR}` is not an environment variable in Cursor `mcp.json`, so the server starts with an unusable key. Inside a Cursor plugin `${VAR}` means a plugin variable that has to be declared in `variables` first.
- `uvx` needs `uv` installed. If the client reports that the command was not found, that is the cause, not the API key.
- Pin `--python 3.13`. Default `python3` on Homebrew may be 3.14, and `mcp-server-twelve-data` requires `>=3.13`.
- MCP does not change plan limits or credit prices. A tool call can still fail with `403` because the endpoint is not in the plan, or `429` because credits ran out. `/key_executives` is still 1000 credits per symbol, and a fund full document is still 800 or 1000 per request. See `twelvedata-api`.
- The server requests `format=CSV` and does not set `delimiter`. When the API returns CSV, the tool result is that text, not a JSON object. The default separator is a semicolon, not a comma. A JSON object means that endpoint did not return CSV.
- Streaming still goes through WebSocket, see the `twelvedata-websocket` skill.
- Twelve Data also ships integrations for ChatGPT, OpenClaw and NEAR AI. They are separate products, not alternatives to this server for IDE work.

## Reference

Server capabilities and transport options are at https://twelvedata.com/docs/llms/ai/mcp-server.md. Fetch it only if the setup above does not cover the client at hand.
