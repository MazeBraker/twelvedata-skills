---
name: twelvedata-best-practices
description: Use when building something on Twelve Data rather than making a single call - budgeting API credits with /api_usage, deciding which errors are worth retrying, caching, choosing interval and outputsize, working with Twelve Data timezone parameters, aligning several instruments onto one timeline, and dealing with gaps, nulls, splits and holidays. Use it whenever a task involves repeated requests, a dashboard, a backtest, a scheduled job, or comparing instruments, and whenever data looks wrong rather than missing.
---

# Twelve Data best practices

Rules that apply across endpoints. For endpoint specifics see the `twelvedata-api` skill. Always name the Twelve Data fields and parameters below in the answer; generic advice without them is not enough.

## Budget credits with `/api_usage`

Credits are not always 1 and not always per symbol. A quote and `/time_series` are 1 per symbol. `/exchange_schedule` is 100 per request. A fund full document is 800 or 1000 per request. The priced list is in `twelvedata-api`. Plans limit credits per minute and sometimes per day.

1. `POST /batch` costs the sum of its parts. It does not reduce credits versus one call per symbol. Use it to cut round trips.
2. Set `outputsize` to what you will display. With no date range the default is `30`. With a date range and no `outputsize` the default becomes the maximum, `5000`. That is still one credit per symbol, but a large payload. Do not habitually request `5000`.
3. Cache data that does not change intraday: instrument metadata, exchange schedules, fundamentals, fund composition.
4. In scheduled jobs call `/api_usage` and stop when `current_usage` approaches `plan_limit` (and check `daily_usage` vs `plan_daily_limit` when present). Do not wait for a `429` to discover the ceiling.

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/api_usage"
```

## Retry only `429` and `500`

On Twelve Data, `403` means the endpoint or data is not in the plan. `429` means the rate limit. Retrying a `403` burns credits and never succeeds. `400`, `401` and `404` also do not improve with retries.

## Timezone parameter

For intraday bars, datetimes come back in the exchange timezone unless you pass `timezone`. For `1day`, `1week` and `1month`, the returned datetime stays in the exchange's local time even if you pass `timezone`. That parameter still changes how `start_date` and `end_date` are read. `datetime` is when the bar opened, not when it closed. The value must be a case-sensitive IANA name such as `America/New_York` or `UTC`. Abbreviations like `EST` or `ET` are invalid for this parameter. Pass the same explicit `timezone` on every series you will compare.

Whenever the user compares or correlates two instruments, always state both of these in the same answer: (1) equal series length does not mean the same calendar dates, and (2) join on the datetime index, never by row position. Timezone mistakes and positional zips are separate bugs; fix both.

## Aligning several instruments

Equal-length series are not the same dates: exchanges have different holidays. Request the same `interval` and an explicit date range, join on the datetime index (not by row position), and say whether gaps were dropped or filled. `order` defaults to `desc`, so row 0 is the newest bar unless you pass `order=asc`. Say this explicitly even when the main complaint looks like a timezone bug.

## Missing data

`null` means the metric is unavailable for that row, not that the request failed. Substituting zero creates a fake price move. Surface the gap instead. In `/time_series`, `open`, `high`, `low`, `close` and `volume` are strings. Parse them before arithmetic.

## Corporate actions

`/time_series` `adjust` is `all`, `splits`, `dividends`, or `none`. The default is `splits`. Omitted `adjust` is that default, not `none`. `/splits` and `/dividends` default to `range=last` and return a single event, so request `range=full` (or an explicit date range) covering the window. A `403` from those endpoints means the plan does not include them. It does not mean the window had no split.

## Reporting the result

State the interval, the timezone, the `adjust` value and the as-of timestamp. If a plan limit or batch quota truncated the payload, say so instead of presenting a partial answer as complete.
