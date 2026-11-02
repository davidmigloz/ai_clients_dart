# feat(openai_dart): preserve cache TTLs and hosted tool usage

## Outcome

Control each Responses cache breakpoint lifetime and inspect billable hosted-tool usage and error diagnostics.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- GA and beta Responses request/response cache boundaries, tool_usage, errors and web-search find results; shared fields also checked in open_responses.
- PromptCacheBreakpointConfig/Param ttl, ResponseToolUsage/WebSearchUsage/ImageGenToolUsage, ResponseError and Error-2; no new operations.

## Acceptance criteria

- [ ] Add optional 30m/12h breakpoint TTL with omission inheriting the request. The pinned top-level PromptCacheTTLEnum still permits only 30m: explicitly record the guide/spec/SDK discrepancy; implement documented 12h breakpoint support without claiming top-level parity or silently widening Decisions.
- [ ] Preserve tool_usage separately from base-model usage, including image input/output details, optional cached counts and web-search request counts. Unknown/missing counts stay unknown rather than becoming zero.
- [ ] Preserve nullable error type/param and existing code/message/details for HTTP, terminal Responses and stream error paths. Handle WebSearchActionFind.url omission/null on GA and beta paths.
- [ ] Audit affected shared models in open_responses and make matching corrections where applicable, with that package’s own fixtures and compatibility notes.
- [ ] Public mock HTTP/SSE fixtures, round-trip/immutability/equality tests and a concise usage example cover old responses and new fields.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/responses/responses.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/prompt-caching)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/02-responses-cache-usage.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
