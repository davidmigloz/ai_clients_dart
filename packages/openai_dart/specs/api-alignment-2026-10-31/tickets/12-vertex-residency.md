# feat(openai_dart): support Vertex Responses and regional routing

## Outcome

Route Responses through Vertex using request-scoped Google credentials and current regional endpoints.

Parent: #413. Successor to completed #317.

Dependencies: #316

## Scope

- Pinned Python/Node Vertex provider behavior and regional processing/storage endpoint guidance.
- Responses create/retrieve/cancel/delete/input-items/compaction lifecycle routing; no claim that all OpenAI resources work through Vertex.

## Acceptance criteria

- [ ] Define an explicit provider/factory with project/location or a validated complete base URL and an injectable async token provider. Preserve the configured API root on all supported Responses lifecycle calls.
- [ ] Acquire credentials per request/attempt without shared mutable bearer state; no OpenAI organization/project/key headers or authenticated redirects leak to another origin.
- [ ] Make timeout/cancellation, credential refresh and transport ownership explicit. Coordinate dynamic configuration with #316; optional native credential discovery stays separate from portable browser/Wasm APIs.
- [ ] Document supported regional endpoints and processing versus storage-only residency. Project settings and credentials do not by themselves guarantee regional processing.
- [ ] Use concurrent local provider fixtures, token rotation, wrong-origin/header rejection and lifecycle URL assertions, plus a runnable injected-token example; no cloud credentials or paid calls are needed.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/providers/vertex.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/providers/vertex.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/your-data)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/12-vertex-residency.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
