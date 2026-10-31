# fix(openai_dart): align WebSocket recovery and delivery reporting

## Outcome

Recover supported WebSocket connections explicitly and report uncertain or unsent delivery without replaying attempted work.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- Audit the pinned SDK recovery/queue fixes against current Responses recovery and missing Live/Realtime/Translation opt-in equivalents.
- Connection URL/query/header/options propagation, binary/text queues, disposal, observer failures and request-scoped credential refresh.

## Acceptance criteria

- [ ] Document which SDK fixes are already satisfied, then implement only demonstrated gaps. Keep reconnect opt-in and defaults bounded; application state reconciliation remains explicit.
- [ ] Queue only frames never attempted, snapshot bytes and account for the first frame, preserve binary frames and queue order, and expose detached unsent reports after terminal failure. Never automatically replay uncertain sends.
- [ ] Refresh credentials/URL factories per attempt, preserve base/per-call queries and caller native options, default compression appropriately and support legitimate large frames.
- [ ] Cancellation/setup failure/close during delay, dial, send or receive frees sockets, readers and timers; observer exceptions cannot strand state. Preserve original close/cancellation facts.
- [ ] Use fake clocks and real local WebSocket peers where useful. Cover Chrome/Wasm browser header rejection and document WebRTC/proxy alternatives; no live API is required.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/_websocket_connection.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/live/ws-base.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/voice-websockets)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/04-websocket-recovery.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
