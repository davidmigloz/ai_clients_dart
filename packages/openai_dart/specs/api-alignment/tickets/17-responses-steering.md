# Mid-turn Responses steering

Status: implemented, verified and independently reviewed; PR pending.
GitHub: [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-STEER-01–03.
Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).

## Demonstrable outcome

Send a correction during a response and follow its accepted, pending or failed continuation safely.

## Acceptance criteria

- [x] Exact user-only steer input contains type/previous_response_id/input, never lane/create settings/id/status/tool output; text/image/file variants and malformed input are covered.
- [x] Accepted/pending/failed models preserve identity, optional lane/ID, original rejected raw input and future code/reason strings; all seven identifying required-input stubs round-trip.
- [x] Fixtures cover steered-incomplete or normal original completion before successor creation/completion, tool-result pending, matching-create/no-pending races and repeated pending submissions for one parent.
- [x] Actual write counts prove no create on acceptance, no accepted-input resend, no tool rerun and no replay on disconnect/missing ack; accepted-then-failed retains ID.
- [x] Offline example demonstrates both automatic successor and saved-required-input continuation; scope/commit/unknown-outcome guidance is explicit.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Explicit steering methods preserve existing create/send signatures. New typed
acknowledgments extend the sealed ResponsesServerEvent hierarchy; document
exhaustive-switch/cast migration and contextual rejection of known malformed
frames. Follow the restrictive operational guide where the writable input schema
is wider. Require the failed input key but retain rejected arbitrary JSON as an
explicit compatibility inference. Do not promise tool cancellation or rewriting
prior output. Open Responses has no steering schema; this slice is OpenAI-only.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/17-responses-steering.md) records exact user-only
requests, all seven identifying stub types, complete acknowledgments, public
continuation/write-count fixtures and compatibility choices. The new model suite
passes 454 cases; new public/native coverage adds 31. Final package checks pass
11,158 tests with two existing skips, clean formatting/fix/fatal-info analysis.
The 484 new model/browser protocol cases pass in real Chrome JavaScript and Wasm.
Thirty serialized GA/beta fixtures validate independently against their schemas.
The exact README usage and migration After block compile; the six-frame offline
example and terminal-failure probes pass for $0. Full toolkit diagnostics remain
visible and independently classified. Requirements and engineering peer reviews
approve the final combined diff after all validated findings are resolved. The
implementation PR is pending; close #342 only after merge. Recovery #343 follows.
