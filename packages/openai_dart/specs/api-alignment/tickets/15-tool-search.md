# Client-discovered tool definition and call fidelity

Status: specified; implementation pending.
GitHub: [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-SEARCH-01–02.
Dependencies: [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) (nested async definitions).

## Demonstrable outcome

Return client-discovered tools with complete definitions and the original search call ID.

## Acceptance criteria

- [ ] Request search arguments require an object; returned required arguments preserve arbitrary JSON including null/scalar/list. Returned execution/status/call_id retain contextual requiredness and null.
- [ ] Discovered namespace dotted names and all nested function/custom options survive request/output/conversation parse, copy and serialization with contextual requiredness.
- [ ] Public hosted/client search continuation fixtures retain original call_id, execution:client and complete tool lists, including empty optional request metadata and returned null call ID.
- [ ] Offline example returns discovered tools; sibling open_responses audit and migration for tightened contextual constructors are recorded.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Targeted request/output fidelity corrections. Do not impose ordinary function naming or top-level requiredness on discovered nested definitions.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
