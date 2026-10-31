# feat(openai_dart): integrate Decisions with Live sessions

## Outcome

Delegate from Live to Decisions, evaluate transcript triggers, and manage shared decision items.

Parent: #413. Successor to completed #317.

Dependencies: #414

## Scope

- Live decisions delegation/settings, acknowledgement_delay_ms, input/output transcript triggers (maximum two), decision.create and decision item create/delete.
- Native decision.event/completed payloads and full current item/question unions across primary, sideband and fork protocols.

## Acceptance criteria

- [ ] Model delegation target decisions and optional acknowledgement delay consistently with client/responses delegation. Preserve required/optional/null fields and direction-specific event unions.
- [ ] Support shared decision items, role-specific messages and function/custom-tool history, question string/parts, trigger source IDs and typed native Decision responses.
- [ ] Respect separate Live limits: trigger/native question groups use the canonical 64-question bound, not the standalone Decisions 400-question bound.
- [ ] Correlate trigger versus delegation events without inventing missing IDs; emit current input/output transcript event names and preserve ordering/unknown event behavior.
- [ ] Public HTTP/WebSocket fixtures exercise configure/update/send/receive across all allowed channels, and a runnable offline example demonstrates delegation plus one transcript trigger.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/live/decision_event.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/live/sessions.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/decisions-voice)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/06-live-decisions.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
