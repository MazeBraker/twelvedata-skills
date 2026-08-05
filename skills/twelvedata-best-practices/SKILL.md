---
name: twelvedata-best-practices
description: Use when building something on Twelve Data rather than making a single call - budgeting API credits with /api_usage, deciding which errors are worth retrying, caching, choosing interval and outputsize, working with Twelve Data timezone parameters, aligning several instruments onto one timeline, and dealing with gaps, nulls, splits and holidays. Use it whenever a task involves repeated requests, a dashboard, a backtest, a scheduled job, or comparing instruments, and whenever data looks wrong rather than missing.
---

# Twelve Data best practices

Rules that apply across endpoints. For endpoint specifics see the `twelvedata-api` skill. Always name the Twelve Data fields and parameters below in the answer; generic advice without them is not enough.

## Budget credits with `/api_usage`

Credits are consumed per symbol per request. Plans limit credits per minute and sometimes per day.

1. Prefer `POST /batch` over a per-symbol loop.
2. Set `outputsize` to what you will display. Default is `30`; do not habitually request `5000`.
3. Cache data that does not change intraday: instrument metadata, exchange schedules, fundamentals, fund composition.
4. In scheduled jobs call `/api_usage` and stop when `current_usage` approaches `plan_limit` (and check `daily_usage` vs `plan_daily_limit` when present). Do not wait for a `429` to discover the ceiling.

```bash
curl -H "Authorization: apikey $TWELVE_DATA_API_KEY" \
  "https://api.twelvedata.com/api_usage"
```

## Retry only `429` and `500`

On Twelve Data, `403` means the endpoint or data is not in the plan. `429` means the rate limit. Retrying a `403` burns credits and never succeeds. `400`, `401` and `404` also do not improve with retries.

## Timezone parameter

Datetimes come back in the exchange timezone unless you pass `timezone`. The value must be a case-sensitive IANA name such as `America/New_York` or `UTC`. Abbreviations like `EST` or `ET` are invalid for this parameter. Pass the same explicit `timezone` on every series you will compare.

Whenever the user compares or correlates two instruments, always state both of these in the same answer: (1) equal series length does not mean the same calendar dates, and (2) join on the datetime index, never by row position. Timezone mistakes and positional zips are separate bugs; fix both.

## Aligning several instruments

Equal-length series are not the same dates: exchanges have different holidays. Request the same `interval` and an explicit date range, join on the datetime index (not by row position), and say whether gaps were dropped or filled. Say this explicitly even when the main complaint looks like a timezone bug.

## Missing data

`null` means the metric is unavailable for that row, not that the request failed. Substituting zero creates a fake price move. Surface the gap instead.

## Corporate actions

A raw price series has discontinuities at splits. For long-window returns, adjust with `/splits` and `/dividends` or state that the series is unadjusted.

## Reporting the result

State the interval, the timezone and the as-of timestamp. If a plan limit or batch quota truncated the payload, say so instead of presenting a partial answer as complete.
