# Eval results

Target agent: `gpt-4o-mini`. Judge: `gpt-4.1`. Baseline: with skill vs without. Workspace artifacts under `skills-eval-workspace/` (gitignored).

## Summary

| Skill | with | without | Δ | Verdict |
| --- | ---: | ---: | ---: | --- |
| `twelvedata-websocket` | 100% | 11% | +89pp | keep |
| `twelvedata-mcp` | 100% | 17% | +83pp | keep |
| `twelvedata-indicators` | 89% | 22% | +67pp | keep |
| `twelvedata-api` | 100% | 36% | +64pp | keep |
| `twelvedata-cli` | 100% | 36% | +64pp | keep |
| `twelvedata-funds` | 100% | 44% | +56pp | keep |
| `twelvedata-best-practices` | 100% | 50% | +50pp | keep (rewritten; earlier Δ≈0) |

All seven beat the no-skill baseline.

## Notes

- First pass used judge `gpt-4o-mini`: `best-practices` had Δ≈0 (generic advice). Skill and its evals were rewritten around Twelve Data specifics (`/api_usage`, IANA `timezone`, join on datetime), then re-run.
- `twelvedata-cli` was added later and evaluated alone (iteration-5): machine-mode contract, `TWELVEDATA_API_KEY` vs `TWELVE_DATA_API_KEY`, and `ti <indicator>` are what the baseline misses.
- Sample sizes are small (2–3 cases per skill, one run). Treat percentages as directional, not publishable SLAs.
- HTML reports: `skills-eval-workspace/iteration-1/report/index.html` (core suite), `iteration-4` (best-practices + indicators re-run), `iteration-5` (cli).
