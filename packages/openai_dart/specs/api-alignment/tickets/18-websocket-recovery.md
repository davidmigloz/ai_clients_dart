# Opt-in Responses WebSocket reconnection

Status: specified; implementation pending.
GitHub: pending issue creation after independent planning review.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-RECOVER-01–02.
Dependencies: WebSocket 16; steering 17 for submitted-steer replay regression.

## Demonstrable outcome

Opt into socket recovery and bounded queuing of newly unsent frames without replaying submitted work.

## Acceptance criteria

- [ ] Each SDK recoverable/nonrecoverable close category, required enabling callback, retry defaults/backoff/[0.75,1.0] jitter, hook preparation/abort/throw, auth refresh, exhaustion and explicit close during wait/handshake has deterministic coverage.
- [ ] Default is disabled. Byte-boundary/overflow fixtures verify the strict 1 MiB unsent queue (including rejection of an oversized first frame, matches Python and deliberately differs from Node), immutable serialized UTF-8 enqueue snapshots, FIFO and observable final never-attempted message reporting. A fail-after-write fixture proves the unknown-delivery attempted frame is never retried.
- [ ] Actual write counts prove already-sent create/steer/inject are never replayed, and explicit close never reconnects.
- [ ] Offline example distinguishes socket reopening from caller-managed conversation/cache/steering reconciliation and states any deliberate SDK divergence.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Opt-in helper; HTTP retry policy and default WS behavior are unchanged. No automatic conversation or accepted-input recovery.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
