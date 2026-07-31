---
name: twelvedata-websocket
description: Use when streaming real-time prices from Twelve Data over WebSocket at wss://ws.twelvedata.com - subscribing and unsubscribing to symbols, handling price and status events, keeping the connection alive, or debugging dropped connections and missing ticks. Use it whenever a request mentions live prices, streaming, tick data, a price feed or a websocket connection to Twelve Data, because the connection limits and event protocol differ from the REST API.
---

# Twelve Data WebSocket

Real-time prices come from the Twelve Data Distributed WebSocket System, not from the REST API. Endpoint:

```
wss://ws.twelvedata.com/v1/quotes/price?apikey=your_api_key
```

The key can also travel in a header, which is preferable in server code:

```
wss://ws.twelvedata.com/v1/quotes/price
X-TD-APIKEY: your_api_key
```

## Protocol

Everything after connecting is driven by JSON events sent to the server.

```json
{"action": "subscribe", "params": {"symbols": "AAPL,RY:TSX,EUR/USD,BTC/USD"}}
```

- `unsubscribe` takes the same shape and removes symbols
- `reset` drops every subscription on the connection
- `heartbeat` should be sent roughly every 10 seconds to keep the connection stable

Two event types come back. `status` events confirm what was subscribed or rejected, `price` events carry the tick: `event`, `symbol`, `type`, `timestamp` as UNIX seconds, `price`, and `day_volume` for equities.

Disambiguate a ticker by appending the exchange after a colon, as in `RY:TSX`.

## Hard limits

- **Three connections per API key across the lifetime of the application.** Opening a fourth silently closes the oldest one. Use one connection per environment, typically production, stage and local, and never open a connection per user or per page.
- The server accepts up to 100 events from the client. This does not limit messages sent back to you.
- No limit on the number of symbols, but a single message cannot exceed 1 MB.
- Streaming costs WebSocket credits, 1 per symbol. These are separate from API credits.

## Plan gating

Full WebSocket access requires the Pro plan for individuals or Venture for business. On Basic and Grow you get one connection and up to 8 simultaneous symbols from the trial symbol list. A `403` or an empty subscription confirmation on a valid symbol usually means the plan, not the code.

## Gotchas

- Subscribe after the socket is open, not before. Events sent during connect are lost.
- Always read `status` events. A symbol that failed validation simply never produces ticks, with no error thrown.
- Missing heartbeats are the usual cause of a connection that dies after a few minutes with no error.
- Reconnect with backoff and resubscribe from your own list. The server does not restore subscriptions.
- `timestamp` is UNIX seconds in UTC. Convert before displaying, see the `twelvedata-best-practices` skill.
- Streaming does not backfill. Load history from `/time_series` and then attach the stream, otherwise the chart starts empty.

## Reference

The full event schema and the trial symbol rules are at https://twelvedata.com/docs/llms/websocket/ws-real-time-price.md. Fetch it if a subscription is rejected and the reason is not obvious.
