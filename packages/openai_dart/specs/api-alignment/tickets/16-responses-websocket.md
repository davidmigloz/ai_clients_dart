# Responses WebSocket transport and lane routing

Status: merged in PR #353; #341 closed.
GitHub: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-WS-01–04.
Dependencies: None. Shell [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337) and compaction [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338) typed events join the shared codec when available.

## Demonstrable outcome

Run persistent Responses conversations on default/named lanes with complete event and error envelopes.

## Acceptance criteria

- [x] Local upgraded-server fixtures assert base URL/path/query, auth/default/org/project/apiVersion header precedence, handshake failures/timeouts, close-during-connect cleanup and injected connector behavior.
- [x] Exact create frames keep stream_id/generate WS-only, omit stream/background:false, reject background:true and invalid lanes; warm-up and previous-response chaining are demonstrated.
- [x] Named/default lane interleaving and FIFO, request error then successful other lane, every currently supported shared event, lossless future raw frames and full WS errors (including the guide connection-limit error with omitted param and compatible absent code/param) parse without ending the connection at response completion.
- [x] Early frame/close-before-listener, explicit buffer overflow, invalid frames, closed send, idempotent close, close metadata, close-code bounds, multi-byte UTF-8 reason byte limits and listener cancellation fixtures verify lifecycle ownership.
- [x] Browser custom headers reject before dial with safe proxy guidance; headerless proxy route compiles/tests. No guessed ephemeral/WebRTC auth, cancel frame, or automatic replay.
- [x] Offline two-lane example and recovery/fork/cache-limit guidance distinguish routing from ancestry. Helper/injection parity remains tracked in 18/19.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive caller-owned connection. Existing HTTP/SSE/Realtime entry points stay
available. The directly encountered shared annotation event now accepts its
required nullable payload; widening that getter requires the documented nullable
guard migration. Nonnull event behavior remains compatible. Basic transport does
not claim opt-in SDK recovery or typed steering/injection until their tickets
complete.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/16-responses-websocket.md) records the new
connection, native/browser/stub transports, lane/error models, public local
fixtures, browser verification and reviewed fixes. Package checks pass: OpenAI 10,676 tests/two existing skips; sibling 506/three
existing skips, clean analysis and formatting. Both JS/Wasm Chrome matrices and
the offline example pass for $0. Full toolkit diagnostics remain classified and
visible. Independent requirements and engineering peer reviews approve the final combined
change. Implementation [PR #353](https://github.com/davidmigloz/ai_clients_dart/pull/353)
merged after green CI on October 8, 2026 at 05:04:30 UTC, commit
`b1c7b0238921b25be1f3592f5f4b1cd9cc2479d6`, closing #341. Steering
#342 follows. The directly encountered shared nullable annotation correction
is included in both client packages with migration guidance.
