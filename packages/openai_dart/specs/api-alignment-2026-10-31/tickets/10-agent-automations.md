# feat(openai_dart): add Agent automations and invocations

## Outcome

Create, pause, resume and inspect scheduled Agent work and its invocations.

Parent: #413. Successor to completed #317.

Dependencies: #422

## Scope

- All 10 /agents/automations operations: list/create/get/update/delete, pause/resume, invocation list/create/get.
- Once/periodic schedules, existing/new-session targets, resource status/environment/creator unions, metadata and automations tool variants.

## Acceptance criteria

- [ ] Expose all 10 operations through the existing beta Agents client with correct paths, headers, query serialization, pagination and raw HTTP status handling.
- [ ] Model once/periodic schedules and target unions completely, preserving omission/null, required fields and immutable ownership.
- [ ] Add automations tool variants to persisted and session tool request/response unions, including validators and exports.
- [ ] Create/update/pause/resume never imply immediate invocation. Invocation creation is explicit; status/error/source payloads and nonadvancing cursors are handled.
- [ ] Public mock lifecycle tests and an offline schedule/invoke example cover every operation and variant. Do not create real recurring jobs during automated tests.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/beta/agents/automations/automations.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/beta/agents/automations/automations.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/agents)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/10-agent-automations.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
