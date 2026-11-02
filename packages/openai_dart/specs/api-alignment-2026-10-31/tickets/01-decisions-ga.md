# feat(openai_dart): align Decisions GA inputs and caching

## Outcome

Evaluate structured evidence and conversation/tool history with the generally available Decisions API, including up to 400 questions.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- DecisionRequest/Input/Question and their complete reachable input unions; no new HTTP operations.
- User/developer/system/assistant roles; function/custom calls and outputs; output text/refusals; JSON parts; multipart question instructions; request cache key/options and input breakpoints.

## Acceptance criteria

- [ ] Keep existing text, user-message and HTTP(S)/data-image calls working. Add role-specific content unions and tool-history items without sending unsupported fields.
- [ ] Support input_json as an object or array of objects, with finite JSON ownership and canonical depth/value/UTF-8 bounds. Question instructions accept text/image/JSON parts per the pinned spec and both SDKs; retain string constructors or document a migration.
- [ ] Update the question limit to 400, retain ordered mixed answers/refusals and usage, and cover all added variants through the public Decisions resource.
- [ ] Implement nullable cache key/options and input-part explicit boundaries. Decisions TTL remains 30m in the pinned contract; no Responses 12h option leaks into Decisions. Questions cannot contain cache breakpoints.
- [ ] Add a runnable JSON/multimodal/caching example, concise collapsible README topic and migration notes. Test legacy and GA serialization, copies, equality and malformed inputs.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/decision_create_params.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/decisions.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/decisions)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/01-decisions-ga.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
