---
name: twelvedata-best-practices
description: Use when building something on Twelve Data rather than making a single call - budgeting API credits, deciding which errors are worth retrying, caching, choosing interval and outputsize, working with timezones and exchange sessions, aligning several instruments onto one timeline, and dealing with gaps, nulls, splits and holidays. Use it whenever a task involves repeated requests, a dashboard, a backtest, a scheduled job, or comparing instruments, and whenever data looks wrong rather than missing.
---

# Twelve Data best practices

Rules that apply across endpoints. For endpoint specifics see the `twelvedata-api` skill.

## Budget credits before writing the loop

Credits are consumed per symbol per request, and plans limit credits per minute and sometimes per day. A naive loop over a watchlist exhausts the quota within seconds of a page load.

1. Batch several requests into one `POST /batch` call.
2. Ask for what you will display. `outputsize` defaults to 30 but people often set 5000 out of habit.
3. Cache anything that does not change intraday: instrument metadata, exchange schedules, fundamentals, fund composition.
4. Read `/api_usage` in scheduled jobs and stop before hitting the ceiling instead of after.

## Retry only 429 and 500

`400`, `401`, `403` and `404` describe a wrong request, a wrong key, a plan restriction and an empty result. None of them change with a retry, and every attempt costs quota. Treating `403` as a rate limit is the most expensive mistake on this API.

## Timezones

Datetimes come back in the exchange timezone unless you pass `timezone`, whose value is a case-sensitive IANA name such as `America/New_York`, or `UTC`. Pass it explicitly on every request that will be compared with another one.

## Aligning several instruments

Exchanges have different holidays and sessions, so two series of the same length rarely cover the same dates. Request both with the same `interval` and an explicit date range, join on the datetime index rather than by position, and say whether missing rows were dropped or filled. Correlations computed on positionally zipped series are a common silent bug.

## Missing data

`null` means the metric is unavailable for that row, not that the request failed, and a missing bar usually means no trading rather than an outage. Substituting zero turns into a fake price move on the chart, so surface the gap instead.

## Corporate actions

A raw price series has discontinuities at splits. For returns over a long window, adjust using `/splits` and `/dividends` or state that the series is unadjusted.

## Reporting the result

State the interval, the timezone and the as-of timestamp, and say when a plan limit truncated the data instead of presenting a partial answer as complete.
