# Eval results

Target `gpt-4o-mini`, judge `gpt-4.1`, both at `temperature: 0`, every case run with and without the skill. Settings live in `agent-skills-eval.yaml`, so the run is repeatable:

```bash
set -a; . ./.env; set +a
npx agent-skills-eval@0.1.1 --config agent-skills-eval.yaml
```

Artifacts land in `skills-eval-workspace/` (gitignored).

## Summary

| Skill | with | without | Δ | Cases |
| --- | ---: | ---: | ---: | --- |
| `twelvedata-mcp` | 100% | 17% | +83pp | 2 |
| `twelvedata-websocket` | 100% | 22% | +78pp | 3 |
| `twelvedata-funds` | 100% | 33% | +67pp | 3 |
| `twelvedata-cli` | 78% | 25% | +53pp | 3 |
| `twelvedata-indicators` | 92% | 42% | +50pp | 3 + 1 precision |
| `twelvedata-best-practices` | 93% | 43% | +50pp | 3 + 2 held-out |
| `twelvedata-api` | 92% | 52% | +40pp | 3 + 1 precision |

All seven beat the no-skill baseline. Pass rates are per assertion, not per case.

## Precision cases

Two cases check that a loaded skill does not take over a task that is not ours: an indicator computed from a broker CSV with no Twelve Data account, and a request for a vendor the user explicitly named. Both failed with the skill loaded — the agent pushed `/rsi` and asked for an API key — because the rules were written unconditionally. `twelvedata-api` and `twelvedata-indicators` now scope them to data that is meant to come from Twelve Data, and both cases pass. They are regression guards, not evidence of lift: the skills were changed to satisfy them.

## Held-out cases

`twelvedata-best-practices` was rewritten in an earlier iteration after seeing its own failures, so its old cases only measured recall of the rewrite. The two `held-out` cases were written afterwards, against sections no case covered (what to cache in a dashboard, what to state alongside the numbers), and were not used to change the skill. Its +50pp survives on them, with one miss: the model does not volunteer that a plan limit truncated the payload.

## Known misses

Left as they are rather than tuned against the judge: `twelvedata-api` skips `POST /batch` on the multi-symbol case, `twelvedata-indicators` does not say that `/macd` keeps fixed moving-average types, `twelvedata-cli` omits the `ti` explanation and the exit-code categories. These are instruction-following misses of a small target model against rules the skills do state.

## Limits

Two to five cases per skill, one run each, so a single assertion moves a skill by 8–17pp; treat the numbers as directional, not as SLAs. Only one target model was measured, and it is weaker than the models these skills run on in Cursor or Claude Code, where the lift may be smaller. HTML reports: `skills-eval-workspace/iteration-6/report/index.html` (cli, best-practices), `iteration-7` (api, indicators after the precision fix), `iteration-8` (funds, mcp, websocket).
