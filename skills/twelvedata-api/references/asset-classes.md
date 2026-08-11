# Asset classes

When to use which catalog and which skill. Price history for tradable symbols is almost always `/time_series` (or `/quote` / `/price`); catalogs only list what exists. Fund *product* data is different — see `twelvedata-funds`.

## Routing

| Class | Catalog (list / discover) | Typical data path | Notes |
| --- | --- | --- | --- |
| Stocks / equities | `/stocks`, `/symbol_search` | `/time_series`, `/quote`, `/price`, fundamentals under `/profile`, `/income_statement`, … | Disambiguate with `exchange` or `mic_code` when the ticker is shared across markets. |
| Forex | `/forex_pairs` | `/exchange_rate`, `/currency_conversion`, `/time_series` with pair symbols (`EUR/USD`) | Prefer FX endpoints over equity `quote`/`price` payloads for rates. |
| Crypto | `/cryptocurrencies`, `/cryptocurrency_exchanges` | `/time_series`, `/quote`, `/price` | Pair form like `BTC/USD`; exchange matters for some venues. |
| Commodities | `/commodities` | `/time_series`, `/quote`, `/price` | Same market-data path as equities once the symbol is known. |
| Bonds / fixed income | `/bonds` | `/time_series`, `/quote`, `/price` | Same pattern; do not invent bond-specific fund-style URLs. |
| ETF / mutual fund / MMF *as a product* (holdings, NAV meta, ratings, family) | `/etfs/list`, `/mutual_funds/list`, `/money_market_funds/list` (and family/type) | Fund views under `/etfs/world/…`, `/mutual_funds/world/…` | Switch to the `twelvedata-funds` skill. Directory first, then a narrow view. |
| ETF / fund *price chart* | `/etfs` or `/funds` catalog, or `/symbol_search` | `/time_series` | Price history stays on this skill; do not pull a series from `/etfs/world`. |

`/etfs` and `/funds` in the reference-data catalog are tradable-symbol lists. They are not the fund directory/composition API. Full endpoint URLs live in `endpoints.md`.

## When to leave this skill

- Holdings, expense ratio, fund risk/ratings, family listing → `twelvedata-funds`.
- RSI/MACD/SMA and other indicators by name → `twelvedata-indicators`.
- Live ticks / streaming → `twelvedata-websocket`.
- Shell/CI via the `twelvedata` binary → `twelvedata-cli`.
- Credit budgeting, timezones, aligning series → `twelvedata-best-practices`.
