# Responses WebSocket transport and lane routing

Status: specified; implementation pending.
GitHub: pending issue creation after independent planning review.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-WS-01–04.
Dependencies: None. Shell 12/compaction 13 typed events join the shared codec when available.

## Demonstrable outcome

Run persistent Responses conversations on default/named lanes with complete event and error envelopes.

## Acceptance criteria

- [ ] Local upgraded-server fixtures assert base URL/path/query, auth/default/org/project/apiVersion header precedence, handshake failures/timeouts, close-during-connect cleanup and injected connector behavior.
- [ ] Exact create frames keep stream_id/generate WS-only, omit stream/background:false, reject background:true and invalid lanes; warm-up and previous-response chaining are demonstrated.
- [ ] Named/default lane interleaving and FIFO, request error then successful other lane, every currently supported shared event, lossless future raw frames and full WS errors (including the guide connection-limit error with omitted param and compatible absent code/param) parse without ending the connection at response completion.
- [ ] Early frame/close-before-listener, explicit buffer overflow, invalid frames, closed send, idempotent close, close metadata, close-code bounds, multi-byte UTF-8 reason byte limits and listener cancellation fixtures verify lifecycle ownership.
- [ ] Browser custom headers reject before dial with safe proxy guidance; headerless proxy route compiles/tests. No guessed ephemeral/WebRTC auth, cancel frame, or automatic replay.
- [ ] Offline two-lane example and recovery/fork/cache-limit guidance distinguish routing from ancestry. Helper/injection parity remains tracked in 18/19.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive caller-owned connection. Existing SSE and Realtime behavior stay compatible. Basic transport does not claim opt-in SDK recovery or typed steering/injection until their tickets complete.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
