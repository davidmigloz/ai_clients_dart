# Mid-turn Responses steering

Status: specified; implementation pending.
GitHub: [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-STEER-01–03.
Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).

## Demonstrable outcome

Send a correction during a response and follow its accepted, pending or failed continuation safely.

## Acceptance criteria

- [ ] Exact user-only steer input contains type/previous_response_id/input, never lane/create settings/id/status/tool output; text/image/file variants and malformed input are covered.
- [ ] Accepted/pending/failed models preserve identity, optional lane/ID, original rejected raw input and future code/reason strings; all seven identifying required-input stubs round-trip.
- [ ] Fixtures cover steered-incomplete or normal original completion before successor creation/completion, tool-result pending, matching-create/no-pending races and repeated pending submissions for one parent.
- [ ] Actual write counts prove no create on acceptance, no accepted-input resend, no tool rerun and no replay on disconnect/missing ack; accepted-then-failed retains ID.
- [ ] Offline example demonstrates both automatic successor and saved-required-input continuation; scope/commit/unknown-outcome guidance is explicit.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive protocol. Follow restrictive operational guide where steering input schema is wider; preserve rejected input raw. Do not promise tool cancellation or rewriting prior output.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
