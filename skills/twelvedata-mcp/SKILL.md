---
name: twelvedata-mcp
description: Use when setting up access to Twelve Data for an AI agent or IDE - installing and running the official Twelve Data MCP server, configuring it in Cursor, Claude Code or another MCP client, storing the API key, or deciding between MCP tools, the official SDKs and raw REST calls. Use it whenever a request is about connecting an agent, assistant or editor to Twelve Data rather than about a specific piece of market data.
---

# Twelve Data MCP setup

The official MCP server exposes the Twelve Data API as agent tools, so the model does not have to hand-write HTTP requests. Prefer it over direct REST whenever it is available.

## Run the server

```bash
uvx mcp-server-twelve-data --apikey $TWELVE_DATA_API_KEY
```

Or install it first:

```bash
pip install mcp-server-twelve-data
mcp-server-twelve-data --apikey $TWELVE_DATA_API_KEY
```

Get a key at [twelvedata.com/register](https://twelvedata.com/register).

## Configure a client

Cursor, in `~/.cursor/mcp.json` for every project or `.cursor/mcp.json` for one:

```json
{
  "mcpServers": {
    "twelvedata": {
      "command": "uvx",
      "args": ["mcp-server-twelve-data", "--apikey", "${TWELVE_DATA_API_KEY}"]
    }
  }
}
```

Claude Code and other MCP clients take the same command and arguments in their own config file. After editing, restart the client and confirm the server is listed as connected before assuming a tool call failed for another reason.

## Choosing an access path

Use MCP tools when the client supports MCP. The schemas keep parameter names correct and avoid a round trip through the docs.

Use an official SDK when writing application code that has to run without an agent: `twelvedata` for Python, `@twelvedata/twelvedata-node` for Node, plus Go, Java, R and a CLI.

Use raw REST when neither is available, or for a one-off `curl`. Follow the rules in the `twelvedata-api` skill.

## Gotchas

- The key is passed as a command argument, so it can leak into process lists and shell history. Keep it in `TWELVE_DATA_API_KEY` and interpolate, never paste the literal key into a config file that gets committed.
- `uvx` needs `uv` installed. If the client reports that the command was not found, that is the cause, not the API key.
- MCP does not change plan limits. A tool call can still fail with `403` because the endpoint is not in the plan, or `429` because credits ran out.
- Streaming still goes through WebSocket, see the `twelvedata-websocket` skill.
- Twelve Data also ships integrations for ChatGPT, OpenClaw and NEAR AI. They are separate products, not alternatives to this server for IDE work.

## Reference

Server capabilities and transport options are at https://twelvedata.com/docs/llms/ai/mcp-server.md. Fetch it only if the setup above does not cover the client at hand.
