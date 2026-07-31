---
name: twelvedata-api
description: Use when calling the Twelve Data REST API for market and company data - latest price, quotes, time series, symbol search, exchanges, fundamentals such as income statement or balance sheet, analyst estimates, batch requests, or API usage. Covers authentication, API credits, error handling and symbol resolution. Use this skill whenever the user mentions Twelve Data, twelvedata.com or api.twelvedata.com, even for a single price lookup, because it carries the rules the other Twelve Data skills rely on.
---

# Twelve Data API

Base URL is `https://api.twelvedata.com`. Every endpoint returns JSON unless `format=CSV` is requested.

If the Twelve Data MCP server is available, call it instead of building HTTP requests by hand. See the `twelvedata-mcp` skill for setup.

## Authentication

Prefer the header, it keeps the key out of URLs and logs:

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/price?symbol=AAPL"
```

The query parameter form `?apikey=...` also works and is what the public docs use. `apikey=demo` only returns a small set of demo symbols, never use it in real code.

## Quick start

```python
import os

from twelvedata import TDClient

td = TDClient(apikey=os.environ["TWELVE_DATA_API_KEY"])
df = td.time_series(symbol="AAPL", interval="1day", outputsize=100).as_pandas()
```

In Node use `@twelvedata/twelvedata-node`, which exposes the same endpoints as typed methods.

Supported `interval` values: `1min`, `5min`, `15min`, `30min`, `45min`, `1h`, `2h`, `4h`, `8h`, `1day`, `1week`, `1month`.

## Resolve the symbol before requesting data

If the user gives a company name, an ambiguous ticker, or a non-US instrument, resolve it first with `/symbol_search`, then pass the exact `symbol` plus `exchange` or `mic_code` to the data endpoint. Skipping this step is the most common cause of silently wrong results, because the same ticker exists on several exchanges.

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/symbol_search?symbol=apple"
```

## Credits and limits

Each endpoint costs API credits, usually 1 per symbol per request, and the plan defines credits per minute and sometimes per day. Check the current state with `/api_usage`, which returns `current_usage`, `plan_limit`, `daily_usage`, `plan_daily_limit` and `plan_category`.

Before writing a loop over symbols, use `/batch` instead.

## Errors

The body is always `{"code": ..., "message": ..., "status": "error"}`.

| Code | Meaning | What to do |
|---|---|---|
| 400 | Invalid parameter | Read `message`, it names the parameter and lists valid values |
| 401 | Bad API key | Check the key, not the plan |
| 403 | Endpoint or data not in the plan | Upgrade, retrying will not help |
| 404 | No data for these filters | Loosen the filters, often too narrow a date range |
| 414 | Parameter array too long | Split the request |
| 429 | Rate limit hit | Back off and retry, see `twelvedata-best-practices` |
| 500 | Server side | Retry later |

`403` and `429` are different problems. Retrying a `403` in a loop burns credits and never succeeds.

## Batch requests

`POST /batch` takes a map of request ids to relative URLs and returns a map keyed the same way. Errors are isolated per sub-request, and credits are the sum of the parts.

```bash
curl -X POST "https://api.twelvedata.com/batch" \
  -H "Content-Type: application/json" \
  -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  -d '{
    "aapl": {"url": "/time_series?symbol=AAPL&interval=1min&outputsize=2"},
    "fx":   {"url": "/exchange_rate?symbol=USD/JPY"}
  }'
```

If the batch exceeds the remaining quota, only part of the data comes back. Check each entry's `status` rather than assuming the whole response succeeded.

## Gotchas

- `outputsize` defaults to `30` for time series and indicators, with a maximum of `5000`. Set it explicitly or the chart silently covers 30 points.
- Financial statement endpoints default to `6` records, `/earnings` to `10`, `/dividends` and `/splits` to `100`. These are different defaults, do not assume one number.
- `null` in a response field means the metric is unavailable, not an error. Handle it instead of failing.
- Statements have consolidated variants at `/income_statement/consolidated`, `/balance_sheet/consolidated` and `/cash_flow/consolidated`. Pick deliberately.
- Historical data and calendars are separate endpoints. `/earnings` is what a company reported, `/earnings_calendar` is what is scheduled. Same split for `/dividends` and `/splits`.
- Parameter names are case-insensitive, and endpoints that accept several values take them comma separated.
- Do not compute an indicator from raw candles when Twelve Data exposes it directly, see the `twelvedata-indicators` skill.

## Where to look next

`references/endpoints.md` lists every endpoint of the REST API, grouped by section, with a link to the page documenting its parameters and response. Read it when you need an endpoint you do not know by name, or before guessing a parameter. Market data, reference data, currencies, fundamentals, analyst estimates and regulatory filings are all in there.

Switch skills when the task moves on: `twelvedata-indicators` for technical indicators, `twelvedata-funds` for ETFs and mutual funds, `twelvedata-websocket` for streaming, `twelvedata-best-practices` for credit budgeting, timezones and retries.
