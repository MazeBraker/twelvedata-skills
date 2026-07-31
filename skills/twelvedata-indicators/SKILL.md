---
name: twelvedata-indicators
description: Use when computing or plotting technical indicators with Twelve Data - RSI, MACD, SMA, EMA, Bollinger Bands, ADX, Stochastic, ATR, VWAP, Ichimoku, Supertrend and 100+ others, including overlap studies, momentum, volume, volatility, price transforms, cycle indicators and statistical functions. Use it whenever a request mentions an indicator by name or asks for trend, momentum, overbought or oversold signals on Twelve Data symbols, so the agent calls the ready-made endpoint instead of recomputing values from candles.
---

# Twelve Data technical indicators

Every indicator is its own endpoint on `https://api.twelvedata.com`, named after the indicator itself, and takes the same core parameters as `/time_series`.

Read the `twelvedata-api` skill first for authentication, credits and error handling.

## Call the endpoint, do not recompute

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/rsi?symbol=AAPL&interval=1day&time_period=14&outputsize=30"
```

Fetching candles and recomputing RSI in pandas costs the same credits, adds a dependency, and produces values that disagree with the rest of the platform because of different warm-up handling. Use the endpoint.

## Common parameters

- `symbol` and `interval` behave exactly as in `/time_series`
- `series_type` selects the input price, usually `close`, also `open`, `high`, `low`
- `time_period` is the lookback where the indicator has one
- `outputsize` defaults to `30`, maximum `5000`
- date filtering with `start_date` and `end_date` works the same way

## Endpoint names

The endpoint is the indicator name in lowercase: `/rsi`, `/macd`, `/bbands`, `/atr`, `/supertrend`, `/ichimoku`. Statistical and arithmetic helpers follow the same rule, `/stddev`, `/correl`, `/linearreg`, `/sub`.

The naming is not always guessable, so check `references/endpoints.md` before assuming an indicator does not exist. `/technical_indicators` returns the same catalog from the API itself.

## Gotchas

- MACD comes in three flavours. `/macd` uses fixed EMA types, `/macdext` lets you choose them, `/macd_slope` returns the slope. Picking the wrong one changes the output shape.
- `/stoch`, `/stochf` and `/stochrsi` are different indicators, not aliases.
- `/percent_b` needs the same band parameters as `/bbands` to be comparable with it.
- Indicators are computed per symbol, so a multi-symbol request costs credits per symbol. Batch them through `/batch`, see the `twelvedata-api` skill.
- An indicator with a long `time_period` needs enough history. Increase `outputsize` or set `start_date`, otherwise the first values are missing rather than wrong.
- Values depend on the `interval`. Never mix intervals when comparing signals across instruments.

## Reference

`references/endpoints.md` lists every indicator with a link to its documentation page. Read it when the indicator is not one of the common ones above, or when you need its exact parameters and defaults.
