---
name: twelvedata-funds
description: Use when working with funds through Twelve Data - ETFs, mutual funds and money market funds. Covers fund directories and search, full fund data, performance, risk metrics, ratings, portfolio composition and holdings, sustainability, purchase information, and fund families and types. Use it whenever a request mentions an ETF, mutual fund, money market fund, expense ratio, NAV, fund holdings or fund performance on Twelve Data.
---

# Twelve Data funds

Funds have their own endpoint families, separate from equity endpoints. Read the `twelvedata-api` skill first for authentication, credits and errors.

## How to answer

Always paste the concrete endpoints in the reply. For holdings use `/etfs/world/composition` (or the mutual-fund twin), not the full `/etfs/world` document. Start from a directory or family lookup, then the narrow data call. Say that composition lags the market. Do not invent ETF ratings URLs.

## Two steps, always

Fund endpoints are split into a directory that finds the fund and a data endpoint that describes it.

```bash
# 1. find the fund
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/etfs/list?symbol=QQQ"

# 2. holdings only (not the full document)
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/etfs/world/composition?symbol=QQQ"
```

Going straight to the data endpoint with a name the user typed usually returns `404`, because fund tickers are ambiguous across markets and share classes.

## Endpoints

ETFs: `/etfs/list` directory, `/etfs/world` full data, and the focused views `/etfs/world/summary`, `/etfs/world/performance`, `/etfs/world/risk`, `/etfs/world/composition`. Grouping lives in `/etfs/family` and `/etfs/type`. The asset catalogs `/etfs` and `/funds` list tradable symbols, but they are reference data, so they are indexed in the `twelvedata-api` skill rather than here.

Mutual funds: `/mutual_funds/list` directory, `/mutual_funds/world` full data, and the views `/mutual_funds/world/summary`, `/mutual_funds/world/performance`, `/mutual_funds/world/risk`, `/mutual_funds/world/ratings`, `/mutual_funds/world/composition`, `/mutual_funds/world/purchase_info`, `/mutual_funds/world/sustainability`. Grouping lives in `/mutual_funds/family` and `/mutual_funds/type`.

Money market funds: `/money_market_funds/list` and `/money_market_funds/world`. The full document costs 1000 credits and is on the Ultra plan for individuals and the Enterprise plan for business, and above.

## Vanguard (or any family) without tickers

Resolve the family first, then list funds. Do not switch to ETF endpoints for mutual funds.

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/mutual_funds/family"
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/mutual_funds/list?outputsize=500"
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/mutual_funds/world/risk?symbol=VFIAX"
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/mutual_funds/world/ratings?symbol=VFIAX"
```

## Pick the narrow endpoint

`/etfs/world` costs 800 credits and `/mutual_funds/world` costs 1000. Both return the full document and are on the Ultra plan for individuals and the Enterprise plan for business, and above. If the user asks only about returns or holdings, call the performance or composition view: `/etfs/world/performance` and `/etfs/world/composition` cost 200 each, and so do `/mutual_funds/world/performance` and `/mutual_funds/world/composition`.

## Gotchas

- Fund families and types are separate lookup endpoints, not fields you can filter by on the directory. Resolve the family first if the user asks for "all Vanguard funds".
- `/mutual_funds/world/ratings`, `/purchase_info` and `/sustainability` exist only for mutual funds. There is no ETF equivalent, so do not guess the URL.
- Directory endpoints truncate by default: `/etfs/list` returns `50` records, `/mutual_funds/list` and `/money_market_funds/list` return `100`. Raise `outputsize` before concluding that a fund does not exist.
- Money market funds are the newest family and expose fewer views than ETFs, only the directory and full data.
- Funds report on their own schedule, so composition and holdings lag the market by weeks. Say so when presenting the data instead of implying it is live.
- Price history for a fund still comes from `/time_series` in the `twelvedata-api` skill, these endpoints describe the fund rather than quote it.

## Reference

`references/endpoints.md` lists the fund endpoints with a link to each documentation page. Read it before composing a request whose parameters or response fields you are not sure about.
