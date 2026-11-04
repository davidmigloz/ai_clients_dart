# Optional idle-session run observation (#394)

Status at PR preparation: implementation and early independent engineering review complete; final-head review and CI remain merge gates. Reactivated under #413; #317 remains completed. This adds zero schemas or HTTP operations.

## Authority and actual surface

Frozen authority is OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, SHA-256 `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`, Python 3.42.0 `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f` and Node 7.47.0 `c717857c3151bde92e07e4d396301a9c67163e68`. [The scoped handoff](42-idle-run-helper-manifest.json) records exact SDK file hashes, fourteen unchanged real DTO bindings and the new client-only helper contexts. Global manifest/spec promotion remains #427-owned.

`AgentSessionsResource.stream` returns a lazy stateful `AgentSessionRun`. The existing typed initial string/message-array union is exactly reused, then normalized to the existing user-message input. Empty helper arrays/text reject locally while valid raw empty message/text shapes remain available. Inputs/options are immediately detached; constructor capture makes zero HTTP requests.

One application input writer is a local requirement, not a server lock. Setup retrieves idle state, awaits validated SSE headers, then submits one normalized input with a stable input-only key. Case-insensitive explicit request headers win, then the named key, then a generated 128-bit opaque key. Header values are nonnullable in Dart; no Node header-null tombstone API is invented. Input keys are removed from observation/retrieval request options. All per-request auth stays in the existing resource generation; no shared last-resolved credential field is introduced.

The helper does not widen package retry policy. Current Dart transport can retry transient 429 POSTs; 503/timeout/connection POSTs remain single-attempt even with a key. This differs from broader upstream SDK retry defaults and preserves established safe project behavior. After uncertain delivery, applications inspect current state before an explicit new decision; the helper never resubmits work on reconnect because it does not reconnect.

## Cursor, bounded state and lifecycle

`events` is a single-use Stream adapter; `nextEvent()` is a sequential controlled cursor. Both use one setup and one observation/input. Repeated driver selection, concurrent pulls and repeated external start reject locally. Explicit pulls pause the raw source between calls. Stream pause propagates backpressure, and break/take/cancel wakes a pending read before awaiting generator cancellation. A Stream break closes observation; callers needing continuation use the pull API. No second source exists for later draining.

Original event order is retained. Delivery-ID deduplication uses the SDK's exact insertion window of 1024, including deterministic oldest eviction without refreshing duplicates. The first root turn.created with null subagent_id selects the coordinator. Initial idle, child terminals and unrelated turn terminals cannot complete observation. Selected completed/failed/cancelled terminal followed by idle, or session.failed, establishes the boundary; this is observation completion, not a promise of backend success. Missing boundary at EOF is a local observation error.

Queued progress defaults to 256 events/1 MiB of encoded JSON, with positive finite configurable bounds. Overflow explicitly fails and releases the source; retained prior deliveries can drain before the error. Future opaque events remain opaque, with no fabricated event ID/dedup identity. Native session, selected turn, source boundary and local handle closure remain distinct.

A validated source boundary wins over late unrelated SSE error/EOF even when the input POST is still pending. Genuine setup/input/API failures remain fatal with their explicit causes; an input error is never hidden by already queued source events. The origin-specific regression uses a deliberately uncooperative local source that invokes a callback after cancellation, exercising the actual guard instead of relying on lower-layer suppression.

Abort/close cancels only local requests and observation, wakes readiness/pulls, releases captured inputs/options/queues and preserves borrowed HTTP ownership. Late opens are cleaned up. Original abort reasons and request errors remain explicitly accessible behind private diagnostics. No cancel input, delete, compute shutdown, tool callback or automatic replay is sent. Arbitrary application Futures still require cooperative cancellation.

## Validation and closure

- 39 deterministic public-resource/cursor fixtures passed on VM, actual Chrome JavaScript and Chrome Wasm.
- Cases cover lazy capture, readiness order/no first-event dependency, non-idle admission, raw-shape preservation, normalized input/key precedence, shared 429 retry with exact key/body, root/child/terminal selection, EOF, recent-ID eviction, exact UTF8 byte bounds, overflow, sequential/concurrent drivers, pause, setup/input aborts/late completion, borrowed/owned HTTP, closed-client admission, typed provider privacy and source-boundary/input-error races.
- Offline example passed in normal completion and explicit `--cancel-active` modes. Both use only synthetic HTTP/SSE. The optional raw cancellation is an explicit application flag, separate from local observer closure.
- Scoped formatting/fixes, read-only package analysis and toolkit docs/README checks passed; no unrelated formatter/fixer mutation was needed. README contains 64 collapsible usage topics after integrating merged main.
- Root reviewed the full engine/cursor/key/subscription design and requested the origin-specific boundary probes, which now pass. Final exact-head review/CI remain required before merge.

Local deep capture, bounded queues, controlled pull API and private wrapper errors are explicit Dart policies. Dispatch/streamed-creation callbacks (#395), result collection/parsing (#396) and file adapters (#397) retain separate ownership. No release/version/changelog or global source promotion is included.
