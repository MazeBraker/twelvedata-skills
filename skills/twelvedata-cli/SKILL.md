---
name: twelvedata-cli
description: Use when querying Twelve Data from the terminal via the twelvedata CLI - scripts, shells, CI/CD, or an agent running the binary as a subprocess. Covers install, auth through the TWELVEDATA_API_KEY env var the binary reads, machine mode, exit codes, twelvedata commands discovery, and ti subcommands for indicators. Use it whenever the user mentions the Twelve Data CLI, the twelvedata binary, or wants market data without writing HTTP/SDK code.
---

# Twelve Data CLI

Binary name is `twelvedata`. Source: https://github.com/twelvedata/twelvedata-cli. For REST rules see `twelvedata-api`; for IDE/MCP setup see `twelvedata-mcp`.

## How to answer

Always show the exact `twelvedata …` invocation. Authenticate through the environment, never with `--api-key` in a command an agent or CI runs. Discover flags with `twelvedata commands`, not by scraping `--help`. Indicators live under `twelvedata ti <name>`, not as top-level commands.

## Install

```bash
twelvedata --version || curl -fsSL https://raw.githubusercontent.com/twelvedata/twelvedata-cli/main/install.sh | bash
```

Also: `brew install twelvedata/cli/twelvedata`, or `go install github.com/twelvedata/twelvedata-cli/cmd/twelvedata@latest`.

## Authentication

Key resolution order: `--api-key` → `TWELVEDATA_API_KEY` → active profile from `twelvedata login` / `whoami`.

The binary reads **`TWELVEDATA_API_KEY`** (no underscore between Twelve and Data), while the other skills here use `TWELVE_DATA_API_KEY`. Keep one key and map it for the CLI:

```bash
export TWELVEDATA_API_KEY="$TWELVE_DATA_API_KEY"
twelvedata price --symbol AAPL
```

Do not pass `--api-key` in scripts, CI or agent subprocesses: the key lands in shell history, `ps` output and CI logs. Interactively, `printf '%s' "$TWELVE_DATA_API_KEY" | twelvedata login --key-stdin` stores it instead.

## Machine mode (agents and CI)

Non-TTY, piped stdout, `CI=true`, `TERM=dumb`, or `--raw` turns on machine mode: no prompts, no spinner. JSON (or CSV) on **stdout**; errors as a JSON envelope on **stderr**. Exit codes: `0` ok, `2` usage, `3` auth, `4` forbidden, `5` not found, `6` rate limit, `7` bad request, `8` server.

## Discover commands

```bash
twelvedata commands
```

That JSON tree (name, flags, enums, subcommands) is the source of truth. Alias: `twelvedata schema`.

## Common commands

```bash
twelvedata price --symbol AAPL
twelvedata quote --symbol AAPL
twelvedata time-series --symbol AAPL --interval 1day --outputsize 30
twelvedata ti rsi --symbol AAPL --interval 1day --time-period 14
twelvedata exchange-rate --symbol EUR/USD
twelvedata api-usage
twelvedata doctor --raw
```

`--output csv` streams CSV; default is JSON. For FX rates prefer `exchange-rate` / `currency-conversion`, not `quote`/`price` payloads.

## Gotchas

- Indicators: `twelvedata ti rsi …`, never `twelvedata rsi …`.
- Auth failures exit `3`, not `1`. Read stderr for the error envelope.
- `doctor` exits `1` on any `fail` check; `warn` does not fail the process.
- `docs` / `dashboard` in machine mode print a URL; they do not open a browser.
- One-off profile: `--profile` or `TWELVEDATA_PROFILE`. `auth switch` changes the persisted default.
- HTTP hangs in CI: set `TWELVEDATA_HTTP_TIMEOUT` (e.g. `30s`).

## Reference

Full command list and flags: run `twelvedata commands`. Upstream docs: https://github.com/twelvedata/twelvedata-cli.
