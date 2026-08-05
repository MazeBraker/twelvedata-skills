# Roadmap

Working plan for the first version.

## 1. Research

Done, no commit of its own.

Inventory of [twelvedata.com/docs](https://twelvedata.com/docs) and the machine-readable [llms.txt](https://twelvedata.com/docs/llms.txt), the [Agent Skills](https://agentskills.io) format, and how existing skill repositories are built. The suggested set was discussed, and the research points at starting with these skills:

- `twelvedata-api`
- `twelvedata-indicators`
- `twelvedata-websocket`
- `twelvedata-mcp`
- `twelvedata-cli`
- `twelvedata-funds`
- `twelvedata-best-practices`

## 2. Skills

One `SKILL.md` per skill, holding the rules an agent would otherwise get wrong: authentication, credits, error semantics, symbol resolution, endpoint names, and the gotchas per domain. `twelvedata-api` carries the shared rules and routes to the rest.

Done when every skill is discovered by `npx skills add <path> --list` with a description that triggers on the right prompts.

## 3. Endpoint index

One generated `references/endpoints.md` per skill: endpoint, what it returns, and the URL of its documentation page. The documentation itself stays upstream, mirroring it into the repository would duplicate `llms.txt` and go stale.

Done when the sync is repeatable, produces no diff on a second run, and the index stays small enough to read in one go.

## 4. Evals

Two to five cases per skill in `skills/<skill>/evals/evals.json`, run with and without the skill and graded against assertions. Settings are pinned in `agent-skills-eval.yaml` so a run can be repeated. Besides the cases that measure lift, a skill that risks taking over neighbouring tasks gets a precision case where it must stay out of the way.

Done when every skill beats its no-skill baseline on cases it was not tuned against. A skill that does not gets reworked or dropped.

## 5. Distribution

Plugin manifests for the supported clients, the Twelve Data MCP server registration, and the license.

Done when the repository installs as a plugin, not only as loose skills.

## 6. Publishing on opensource?

Not decided yet, and nothing in the repository claims otherwise until it is. For now this is a private GitLab project installed from a local clone.

What has to be in place before it can be opened:

- Sign-off from the owner on publishing the content, and agreement with the owner of [twelvedata-clawhub](https://github.com/twelvedata/twelvedata-clawhub) so there are not two diverging official skill sets.
- A public GitHub mirror with publish access to the `twelvedata` organisation, because `npx skills update` has historically been GitHub-only and skills.sh discovery needs a public repository.
- `metadata` in the frontmatter with author, version and repository, once those URLs actually exist.
- README rewritten around `npx skills add twelvedata/skills` instead of the local clone.
- A smoke test on a clean machine: install from the public URL into an empty project and confirm the skills activate.

Done when a fresh install works end to end without anything from this working copy.