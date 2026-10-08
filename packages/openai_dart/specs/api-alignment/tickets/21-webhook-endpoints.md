# Manage project webhook endpoints and discover event types

Status: specified and independently reviewed; implementation pending.
GitHub: [#358](https://github.com/davidmigloz/ai_clients_dart/issues/358).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 4 Webhooks and safety](../webhooks-safety.md), WH-ENDPOINT-01–04.
Dependencies: None; endpoint management is useful independently of verification.

## Demonstrable outcome

Create, inspect, update, paginate, delete, rotate and test project endpoints, discover available event types and retain signing secrets securely.

## Acceptance criteria

- [ ] All eight exact operations use public client.webhooks methods and eventTypes.list through existing request/auth/abort/error/closed-client behavior, encoded IDs and conservative retry. Update is POST; no beta/admin endpoint is invented.
- [ ] Create/update/test writable enums include all 23 canonical choices, including video; returned/discovery strings preserve future values. Create constraints, optional nonnull update fields and an empty update are tested at serialization and public request boundaries.
- [ ] List has only limit/after, correct nullable cursors/has_more and no inferred IDs. Every returned DTO covers required nullable signing_secret_hint, optional updated_at, required with-secret fields, deletion shape and unpaginated event-type list.
- [ ] Rotation permits an omitted body or {}, distinguishes omitted/false/true and documents immediate invalidation versus 24-hour overlap without changing a configured local secret implicitly.
- [ ] Test fixtures retain success:true with both 2xx and 500 receiver statuses, verify required event_type and exact URI/body, and never send a live external test delivery.
- [ ] Built-in FINEST enabled response logging structurally redacts signing_secret before truncation, including short/raw-looking values; actual returned body/model/toJson keeps the secret. Default diagnostics/errors do not disclose it. No unrelated logging rewrite.
- [ ] Offline management example walks lifecycle and cursor/event discovery, explains secret storage/rotation and checks receiver status separately from completed test success, with MockClient and $0 cost.

- [ ] Changed models have contextual serialization, requiredness/null/absence, complete copy/clear/replacement, equality/hash, immutable parsed ownership and redacted diagnostics across all old/new fields. Known malformed variants fail and documented receive-only tolerance stays explicit.
- [ ] Public factories/resources/parsers, exports and real manifest mappings are verified; no fake components or exclusions. README/llms, a runnable offline example and any migration guidance are complete.
- [ ] Relevant focused VM/browser fixtures, format → fix → fatal-info analysis, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible and classified.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive project resource/model APIs; reuse existing transport and explicit authentication. Returning notification types does not widen project subscription admission or claim organization-admin endpoint management.

Use deterministic MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement, API key, endpoint test
delivery or paid API action. Any later live smoke uses the existing bounded-cost
authorization with explicit scope; never run the full integration suite. Package
publishing/version bumps and unrelated API families are outside this ticket.

## Completion evidence

Implementation, runtime verification and independent implementation review remain
pending. Link its acceptance evidence and PR when complete; close the issue only
after implementation merge. The planning review does not claim runtime acceptance. Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) merged October 8, 2026 at `886659c3c11cbee89335788ba918eeecd528fce0` after green CI.
