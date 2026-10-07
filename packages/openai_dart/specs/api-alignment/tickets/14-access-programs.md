# Responses access-program selection

Status: implemented, verified and independently reviewed; PR creation pending.
GitHub: [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-ACCESS-01–02.
Dependencies: None.

## Demonstrable outcome

Select an access program explicitly and inspect the effective returned program.

## Acceptance criteria

- [x] Distinct request shape accepts omitted or empty object and all three cyber values; supplied null/wrong types fail.
- [x] Returned outer omission/null remains compatible; supplied response body requires nonnull cyber. Ordinary/SSE lifecycle responses retain it.
- [x] Full CreateResponseRequest/Response field contracts preserve existing fields and new selection in copies, equality/hash and safe diagnostics.
- [x] Offline example documents server-selected omission defaults and explicit selection/eligibility without model allowlists or Build/Launch/Grow client enums.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive request/response types with documented outer provider omission tolerance. No provisioned Daybreak calls.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/14-access-programs.md) records 168 model cases,
616 public HTTP/SSE fixtures (784 new tests), 6,152 passing package unit tests,
two existing skips, clean fatal-info analysis, compiled README usage and the
five-request offline example. Full toolkit diagnostics expose older parent gaps
and the nullable-enum scanner limitation without new exclusions. Independent requirements/engineering
reviews approve the final combined diff; PR creation remains pending; close #339 only after merge.
Tool search #340 follows this slice.
