# Multi-agent WebSocket tool-output injection

Status: implemented, verified and independently reviewed; merge pending in [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356).
GitHub: [#344](https://github.com/davidmigloz/ai_clients_dart/issues/344).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-INJECT-01–02.
Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).

## Demonstrable outcome

Return client-owned multi-agent tool results to an active beta response and observe every injection acknowledgment.

## Acceptance criteria

- [x] Local handshake fixture proves explicit beta header on plain Responses URL with correct precedence; HTTP beta query conventions do not leak into WS.
- [x] Exact response.inject sends target response ID and client-owned results with no stream_id; existing beta fields/agent metadata and lane envelopes retain fidelity.
- [x] Created/failed acknowledgment fixtures preserve full fields and uncommitted raw input, including acknowledgment after response completion and multiple outstanding injections.
- [x] Malformed injection generic 400 and socket close remain observable; no submitted injection or tool execution automatically repeats.
- [x] Offline multi-agent injection example waits for response terminal and all acknowledgments with explicit cleanup; browser proxy limitations remain explicit.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Explicit beta opt-in; application owns developer tool execution. Existing DTO
names/imports/const constructors remain available. New sealed acknowledgment
variants, the failed-input getter widening and contextual malformed-frame
validation require migration guidance. Nested steering/injection child copies
also correct stale metadata resurrection. Distinct from Agents API transport.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/19-websocket-injection.md) records exact beta
handshake/request projection, complete acknowledgments and raw reporting,
late-ack/continuation races, no automatic replay/tool execution, value/copy
contracts and preserved legacy request-codec boundaries. All 11,448 package unit
tests pass with two existing skips; 656 focused cases pass on VM and real Chrome
JavaScript/Wasm. Formatting/fix/fatal-info analysis and offline example pass.
Independent requirements and engineering reviews approve the combined diff.
The full toolkit delta is classified; unrelated diagnostics remain visible.
Implementation [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) is open for review. Close #344 only after merge.
