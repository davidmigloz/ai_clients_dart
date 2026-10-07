# Persistent reasoning configuration updates

Status: implemented, verified, and independently reviewed; merge pending.
GitHub: [#335](https://github.com/davidmigloz/ai_clients_dart/issues/335).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-CONFIG-01–02.
Dependencies: None.

## Demonstrable outcome

Change subsequent reasoning effort through a conversation item without changing request-level effort or cached prefix.

## Acceptance criteria

- [x] Input configuration_update supports nullable optional id and optional nonnull reasoning with only nullable optional effort; returned item requires id.
- [x] Omitted, empty, nullable effort/id and malformed required/supplied objects have contextual fixtures.
- [x] Public Responses create/list-input and conversation create/list/retrieve parse and emit exact shapes. No invented OutputItem or dedicated streaming event.
- [x] Offline example reuses stable request-level effort and shows successive configuration updates; single-agent persistence is documented.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive contextual DTOs. Existing broad ReasoningConfig is not reused for a narrower wire object. Distinct from issue #316 runtime client updates.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/10-configuration-updates.md) records complete
contextual contracts, 3,269 passing unit tests, clean analysis, full toolkit
diagnostics, README/migration guidance, the offline example, and independent
requirements/engineering approvals. Close the issue only after implementation merge.

Implementation [PR #347](https://github.com/davidmigloz/ai_clients_dart/pull/347) is open for review; #335 closes only after merge.
