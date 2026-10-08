# Retrieve project safety alerts and organization cases

Status: specified and independently reviewed; implementation pending.
GitHub: [#359](https://github.com/davidmigloz/ai_clients_dart/issues/359).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 4 Webhooks and safety](../webhooks-safety.md), SAFETY-READ-01–03.
Dependencies: [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357) for the verified-notification example; HTTP methods themselves do not require a verifier.

## Demonstrable outcome

Receive a verified safety notice, retrieve its referenced project alert or organization case explicitly and preserve all details with the correct credential scope.

## Acceptance criteria

- [ ] Public safety.alerts.retrieve and safety.cases.retrieve implement only the two canonical GET operations, encoded IDs/maxima 38 and 128, no list/query/body or invented ID grammar, and existing auth/abort/status/request-ID/retry/closed-client behavior.
- [ ] All five real alert/case/notice/enum components preserve every required field, including reason:null and request_paused:false; missing required nullable reasons fail rather than silently adopting Python defaults. Unknown received enum strings retain raw values as documented tolerance.
- [ ] Project api.safety.alerts.read and same-organization api.safety.read examples use separately scoped MockClient credentials. Event.id, data.id and entity_identifier are never confused; no parser automatic GET or credential escalation.
- [ ] Workspace safety.org_alert.created is typed by ticket 20, but its documented api.chatgpt.com administrator/enterprise-permission lookup remains in Phase 7 inventory. No silent project-key routing or unsupported workspace-response guarantee.
- [ ] Fixture-backed signed-notice example explicitly retrieves both relevant detail types, explains request_paused as successful block registration rather than confirmed stop/reversal, redacts sensitive reason/identifiers and performs no enforcement-changing action.

- [ ] Changed models have contextual serialization, requiredness/null/absence, complete copy/clear/replacement, equality/hash, immutable parsed ownership and redacted diagnostics across all old/new fields. Known malformed variants fail and documented receive-only tolerance stays explicit.
- [ ] Public factories/resources/parsers, exports and real manifest mappings are verified; no fake components or exclusions. README/llms, a runnable offline example and any migration guidance are complete.
- [ ] Relevant focused VM/browser fixtures, format → fix → fatal-info analysis, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible and classified.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive read-only Safety namespace. Strict new DTO requiredness follows canonical/Node; Python missing reason behavior and receive-only future enum tolerance are recorded explicitly.

Use deterministic MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement, API key, endpoint test
delivery or paid API action. Any later live smoke uses the existing bounded-cost
authorization with explicit scope; never run the full integration suite. Package
publishing/version bumps and unrelated API families are outside this ticket.

## Completion evidence

Implementation, runtime verification and independent implementation review remain
pending. Link its acceptance evidence and PR when complete; close the issue only
after implementation merge. The planning review does not claim runtime acceptance. Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) merged October 8, 2026 at `886659c3c11cbee89335788ba918eeecd528fce0` after green CI.
