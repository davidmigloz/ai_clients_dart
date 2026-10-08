# Opt-in Responses WebSocket reconnection

Status: implemented, verified and independently reviewed; PR creation pending.
GitHub: [#343](https://github.com/davidmigloz/ai_clients_dart/issues/343).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-RECOVER-01–02.
Dependencies: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) and [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) (submitted-steer replay regression).

## Demonstrable outcome

Opt into socket recovery and bounded queuing of newly unsent frames without replaying submitted work.

## Acceptance criteria

- [x] Each SDK recoverable/nonrecoverable close category, required enabling callback, retry defaults/backoff/[0.75,1.0] jitter, hook preparation/abort/throw, auth refresh, exhaustion and explicit close during wait/handshake has deterministic coverage.
- [x] Default is disabled. Byte-boundary/overflow fixtures verify the strict 1 MiB unsent queue (including rejection of an oversized first frame, matches Python and deliberately differs from Node), immutable serialized UTF-8 enqueue snapshots, FIFO and observable final never-attempted message reporting. A fail-after-write fixture proves the unknown-delivery attempted frame is never retried.
- [x] Actual write counts prove already-sent create/steer/inject are never replayed, and explicit close never reconnects.
- [x] Offline example distinguishes socket reopening from caller-managed conversation/cache/steering reconciliation and states any deliberate SDK divergence.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Opt-in helper; HTTP retry policy and default WS behavior are unchanged. No automatic conversation or accepted-input recovery.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/18-websocket-recovery.md) records recovery
admission/timing, callback/auth/override semantics, prompt cancellation, strict
UTF-8 FIFO snapshots, no replay and explicit Node/Python divergences. All 104 new
cases pass on VM and real Chrome JavaScript/Wasm; 11,262 package unit tests pass
with two existing skips. All 508 Dart files format unchanged, fix applies nothing
and fatal-info analysis/diff checks pass. The literal README wrapper compiles
and the offline four-write example verifies rejection/final reporting for $0.
Full toolkit diagnostic sets remain exactly unchanged and visible;
exports/docs/README checks pass. Independent requirements and engineering peer
reviews approve the combined diff after findings are resolved. PR creation/CI
and merge remain pending; close #343 only after merge.
