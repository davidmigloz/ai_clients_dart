# docs(openai_dart): close October alignment with verified coverage

## Outcome

Finish this fixed round with accurate API coverage, current examples, source receipts and explicit remaining limits.

Parent: #413. Successor to completed #317.

Dependencies: #414, #415, #416, #417, #418, #419, #420, #421, #422, #423, #424, #425, #426, #392, #393, #394, #395, #396, #397, #316, #246

## Scope

- Final canonical source promotion and toolkit coverage after the corresponding implementation slices, README/llms/example index and migration guidance.
- October model/voice/tier notices, API deprecations and documentation-only/platform announcements; no independent new API feature.

## Acceptance criteria

- [ ] Reconcile every changed schema and all 18 added operations in inventory.json with merged implementation evidence or a named intentional exclusion. Do not interpret toolkit resource-file presence as full method/field parity.
- [ ] Promote the reviewed pinned candidate into canonical specs only with truthful manifest mappings/exclusions and source metadata. Record fetch/review/verify results including baseline failures; never suppress unknown gaps to make checks green.
- [ ] Keep common Responses calls first and every Usage topic collapsible. Each implemented feature has a runnable example and matching concise README/llms links; preserve old anchors where practical.
- [ ] Update guidance for GPT-6.1 Terra/Rosalind access restrictions, server-managed service-tier controls and account credits, current image/audio/model sunsets, Assistants shutdown and Evals November 30 shutdown. String model IDs need no closed-enum feature implementation.
- [ ] Record compatible changes and targeted migrations (Decisions unions, Agent spend_control removal, Live DTMF and any shared open_responses change); release/version bump remains a later task.
- [ ] Run appropriate Dart formatting/analysis/unit tests and toolkit checks; validate README structure/links across managed packages when shared tooling changes. HTTP/2 #408 may remain explicitly gated without reopening this milestone.

## Compatibility and validation

Documentation and verification only; implementation tickets own actual API compatibility changes. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/CHANGELOG.md)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/CHANGELOG.md)
- [Official guide](https://developers.openai.com/api/docs/deprecations)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/14-docs-verification.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
