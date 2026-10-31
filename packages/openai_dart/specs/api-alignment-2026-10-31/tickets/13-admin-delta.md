# feat(openai_dart): add bounded Admin key usage and storage APIs

## Outcome

Use the new Admin key/Decisions-usage operations and inspect current external-storage providers/statuses.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- Seven newly added operations: five organization external-key operations, project API-key update and organization Decisions usage.
- Five existing external-storage operations are explicit prerequisites for OCI and degraded status support. This is a 12-operation Admin slice, not full historical Admin parity.

## Acceptance criteria

- [ ] Specify a separate explicit Admin namespace/authentication configuration using official Admin credentials, preserving project-client defaults and redacting secret material.
- [ ] Implement external-key AWS/Azure/GCP parameter unions, purpose/resource/list/validation envelopes, path escaping and pagination; key material never appears in diagnostics.
- [ ] Update project API-key scopes/relative expiry with at least one supplied field, correct empty-scope meaning and documented retry effects on expiry. Preserve distinction from service-account keys.
- [ ] Implement Decisions usage time windows, buckets, group_by, model/source and pagination/error contracts; include new 30-minute cache-write completion-usage detail only where a supported response model exists.
- [ ] Implement the five bounded external-storage operations with complete pinned provider unions including OCI, and pending/validated/degraded/unhealthy statuses. Keep remaining historical Admin resources explicitly excluded.
- [ ] Public mock fixtures cover all 12 operations, auth separation, redaction, schemas and errors; examples use synthetic credentials and no real key registration or billing access.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/admin/organization/external_keys.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/admin/organization/external-storage.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/admin-apis)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/13-admin-delta.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
