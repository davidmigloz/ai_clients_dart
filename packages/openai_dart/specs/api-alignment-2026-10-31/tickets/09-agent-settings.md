# feat(openai_dart): align Agent review and context settings

## Outcome

Configure current Agent/session context and review behavior, and use ultrafast requests successfully.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- Saved/session Agent compaction and experimental.time_awareness, session review, session metadata filter, session-agent tool updates, ultrafast request enum.
- Removed spend_control request/resource schemas and fields; preserve deliberate omitted/null update semantics.

## Acceptance criteria

- [ ] Add compaction.async and experimental.time_awareness across create/update/receive paths, including nullable override/default semantics.
- [ ] Replace removed spend_control contracts with current review values none/auto_review on session create/update/receive; publish a targeted migration and do not silently send removed fields.
- [ ] Permit ultrafast in every Agent request enum/validator; the current receive enum already supports it. Audit duplicated generated request validators, not just the enum declaration.
- [ ] Encode session metadata filters exactly as specified and allow session-agent tool updates with correct clear/omit behavior.
- [ ] Public HTTP/SSE fixtures, round-trip/ownership/equality and migration examples cover each changed path. Document hosted Artifact SDK availability/prewarming as server capabilities, adding no fictitious client endpoint.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/beta/agents/sessions/sessions.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/beta/agents/agents.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/agents-api/sessions)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/09-agent-settings.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
