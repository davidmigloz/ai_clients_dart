# feat(openai_dart): add Responses WebSocket warmup and sessions

## Outcome

Warm up a Responses connection, change output formats mid-session, and consume bounded per-lane final results.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- ResponseConfigurationUpdate.text.format, response.create.generate, GA/beta unions and opt-in local session/lane accumulation.
- Compare current low-level Dart connection with the SDK session/lane helpers; preserve direct sends and avoid implementing an automatic tool runner.

## Acceptance criteria

- [ ] Expose typed generate:false warmup and preserve its terminal response ID for later continuation. Exclude HTTP-only stream/background fields from WebSocket messages.
- [ ] Support text format changes in configuration_update items/events, including JSON schema, omission/null semantics and beta variants; local parser/output-type metadata never enters API JSON.
- [ ] Add bounded opt-in lane routing/final-response collection, or reuse equivalent existing helpers with public evidence. Preserve event order, stream IDs, refusal/tool output and failed/incomplete terminal states.
- [ ] Budget events/bytes and release readers on close, cancellation, lane detach, malformed events and unexpected EOF. A failed lane must not corrupt another lane.
- [ ] Demonstrate warmup, tool-turn continuation, fork barrier and compacted-history replay rules in an offline runnable example; test terminal output omitted/null/empty distinctions.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/lib/responses_websocket/_session.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/lib/responses/responses-websocket-session.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/websocket-mode)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/03-responses-websocket-workflows.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
