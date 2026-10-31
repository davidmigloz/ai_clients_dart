# feat(openai_dart): align image safety identifiers and edit markup

## Outcome

Attach image safety identifiers, inspect tool moderation errors, and guide edits with markup overlays.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- Generation/edit request/response and streaming safety_identifier; deprecated user field guidance.
- JSON and multipart markup inputs, GA/beta image tool errors/moderation details and current model/input-fidelity documentation.

## Acceptance criteria

- [ ] Carry nullable safety_identifier through create/edit requests, ordinary responses and completed SSE events; update identifier limits and privacy-safe diagnostics.
- [ ] Support markup as transparent PNG binary or JSON image reference per the selected encoding. Validate documented mutual exclusion with mask and explain dimensions/orientation requirements.
- [ ] Preserve image-tool error/moderation payloads on GA/beta calls; keep token/tool accounting in ticket 02 as the shared owner.
- [ ] Preserve legacy user serialization while marking it deprecated where upstream does. Replace runnable gpt-image-1 examples after its October 23 shutdown and document supported explicit models/input_fidelity.
- [ ] Public JSON/multipart/SSE fixtures and an edit example cover exact bytes/fields, invalid combinations, optional details and nonstreaming compatibility.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/images.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/images.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/image-generation)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/11-image-contracts.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
