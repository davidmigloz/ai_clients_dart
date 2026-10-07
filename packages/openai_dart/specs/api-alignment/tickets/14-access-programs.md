# Responses access-program selection

Status: specified; implementation pending.
GitHub: pending issue creation after independent planning review.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-ACCESS-01–02.
Dependencies: None.

## Demonstrable outcome

Select an access program explicitly and inspect the effective returned program.

## Acceptance criteria

- [ ] Distinct request shape accepts omitted or empty object and all three cyber values; supplied null/wrong types fail.
- [ ] Returned outer omission/null remains compatible; supplied response body requires nonnull cyber. Ordinary/SSE lifecycle responses retain it.
- [ ] Full CreateResponseRequest/Response field contracts preserve existing fields and new selection in copies, equality/hash and safe diagnostics.
- [ ] Offline example documents server-selected omission defaults and explicit selection/eligibility without model allowlists or Build/Launch/Grow client enums.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive request/response types with documented outer provider omission tolerance. No provisioned Daybreak calls.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
