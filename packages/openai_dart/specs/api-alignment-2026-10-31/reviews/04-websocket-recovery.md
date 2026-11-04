# Issue #417 frozen WebSocket contract audit

Issue #417; parent #413. Source audit and implementation review dated November 4, 2026.

## Authority

- Python 3.42.0, commit `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, commit `c717857c3151bde92e07e4d396301a9c67163e68`.
- Plan ticket `specs/api-alignment-2026-10-31/tickets/04-websocket-recovery.md`.
- These are helper/lifecycle contracts, not additional OpenAPI wire schemas. Do not promote the canonical source manifest or expand the frozen cutoff.

## Required source disagreements

| Concern | Python | Node | Recommended Dart decision |
| --- | --- | --- | --- |
| Translation recovery | Public `on_reconnecting` on sync and async connect; shared base + send queue | Specialized Translation WS has no reconnect; explicitly never buffers/replays events | An additive explicit-callback Translation recovery path can follow Python. Do not claim both SDKs prohibit or support it. Preserve existing default no-retry behavior. |
| Realtime queue | Shared automatic recovery queue, default 1 MiB | Explicit boolean recovery, manual pending queue, default 0 bytes; `flushPending` and `takePending` | A dedicated Realtime manual queue policy is safest and closest to current Node. Alternatively choose Python callback policy deliberately and document. Do not inherit automatic flush accidentally. |
| Retry budget | Shared counter cumulative until valid non-error application progress resets it | Live counter per interruption; Realtime counter lifetime and never reset | State chosen policy explicitly and test. Existing Responses per-interruption default matches Node generic, but not Python progress-reset semantics. |
| Oversized first queued frame | Strict queue budget including first frame | Generic queue allows one oversized first frame; Realtime manual queue strict | Ticket explicitly requires strict accounting including first; retain strict Dart behavior. Record deliberate Node generic difference. |
| Compression | Defaults disabled when receive max_size unlimited; finite max_size can leave library default | Disabled even when finite maxPayload; caller can override | Set Dart native connector compression disabled by default while retaining explicit/custom-connector override. |

## Exact contracts and receipts

### Python shared controller and queue

`src/openai/_websocket_connection.py`:

- `send_raw` admits only while recovering or behind an active batch. Direct writes are not queued before being attempted.
- Sync `_reconnect` lines100–200 and async `_attempt_reconnect` lines322–397: callback first, abort decision/override maps, jittered exponential delay, fresh `_make_ws` invocation, late-close socket disposal, flush, successful return. Five attempts, .5s initial and8s cap.
- Recovery requires both callback and socket factory. Normal/nonrecoverable closures do not reconnect. Actual peer close code governs policy; absent code uses1006.
- Flush lines399–422 uses `requeue_failed=False`; attempted failed frame is removed, while never-attempted remainder stays available. Close marks pending frames unsent and prevents new admission.
- Shared queue supports `str|bytes`; Python bytes immutable. `_send_queue.py` lines78–89 enforces total byte budget without oversized-first exemption; lines201+ retains pending batch and queue accounting during active flush; lines236+ drains and detaches unsent remainder.

### Python Live and Translation public surfaces

`resources/live/live.py`:

- Public sync/async connect lines142+ and251+: explicit callback, retry/delay/queue defaults.
- AsyncLiveConnection iterator lines372+ retries through shared base. `recv` and `recv_bytes` lines408–438 reset retry count only on a valid non-error event, not merely upgrade success.
- Manager `_connect_ws` lines674–739 rebuilds URL, query and request-scoped authorization per attempt; native options preserved, unlimited receive max_size default and compression None default in that case.
- No startup tracking or automatic `session.start` replay is performed by the generic SDK wrapper.

`resources/realtime/translations/translations.py`:

- Public `connect` lines76–105 and130–159 exposes explicit callback with5/.5s/8s/1MiB defaults.
- AsyncTranslationsConnection lines196+ derives from shared base; iterator lines236+ retries and reports pending remainder when terminal.
- `_connect_ws` lines547–612 preserves base query, merges model and per-call overrides, freshly prepares auth/options on each attempt, preserves custom native options; manager cleanup closes a socket if wrapper construction or initial flush fails.

### Node generic Live/Forks/Sideband

`resources/live/ws-base.ts` lines15–55: callback opt-in,5 retries per interruption,500ms/8000ms defaults,1MiB queue. The queue's oversized-first behavior is documented but should not override this ticket's strict byte requirement.

`resources/live/ws-base.ts` lines80–113 and equivalent forks/sideband ws-base: shared connection controller, `requeueFailed:false`, refresh socket factory each attempt, raw send support; no automatic startup generation or session state tracker.

`internal/ws-connection-controller.ts`:

- `_notifyReconnecting` lines594–650 invokes callback, applies parameters override, emits reconnecting; throwing callback terminates recovery while emitting permanent close.
- `_reconnect` lines663–814: backoff uses min(initial*2^attempt,max) then .75–1 jitter; callback before delay; URL rebuilt after delay and before asynchronous credential refresh; refreshed socket is opened, backlog flushed, then reconnecting becomes false and reconnected is emitted.
- Generic Live flush is automatic; no `session.start` injection or state restore happens.
- Stale-socket handlers ignore superseded events. Cancel refresh/delay on explicit close. Permanent-close lines848+ drains unsent before public observers, guaranteeing internal iterator termination.

`internal/ws.ts`:

- lines330–344 defensively snapshot binary views/buffers, respecting view offsets; fragment arrays flattened.
- SendQueue lines412+ serializes JSON immediately; queue flush lines465+ removes attempted frame before write, preserves unattempted tail with `requeueFailed:false`, prevents reentrant flush, detaches drain.

### Node Realtime and Translation

`internal/realtime-recovery.ts`:

- Options lines10–23: reconnect false default, five attempts over whole lifetime,500/8000ms,0-byte default queue.
- Validation lines27+ rejects intent/call_id reconnection; only model sessions supported. Nonnegative safe integers; timer maximum2147483647ms.
- Controller hooks lines102+ use `manualQueue:true`, `lifetimeRetries:true`, `requeueFailed:false`, excludes1015 even though generic close policy includes it. No automatic history/audio/session replay.

`realtime/ws.ts`:

- Fresh credentials and snapshotted native options per recovery attempt lines198–223.
- Public explicit pending flush/take lines333–343; callers reconcile state first.
- Defaults maxPayload0, compression false; explicit caller options retained.

`realtime/translations/ws.ts`:

- Class docs lines215–218 explicitly say events never buffered/replayed; API has no reconnect option.
- create lines253–295 freshly resolves auth, case-insensitive default/per-call headers, native options, maxPayload0/compression false defaults; redirects always disabled.
- This specialized finish/drain API is not equivalent to Python's context-manager Translation connection.

## Current Dart already satisfies

The existing Responses helper already supplies:

- Explicit callback opt-in, bounded retry defaults, strict first-frame budget and zero disables queue.
- Immutable serialized-text capture, FIFO, removal before write attempt, separate unknown-delivery and terminal detached unsent reports.
- Actual close policy, handling transport error separately from close; stale socket generation guard.
- Cancelable default retry Timer; close races preparation/delay/dial; late sockets disposed and late failures consumed.
- Lifecycle observer notification asynchronous through broadcast controller, final report available independently from paused/absent listeners.
- Fresh resource auth/header merge per handshake and rebuilt URL; RequestBuilder preserves repeated base query keys.
- Existing Responses tests cover retry close codes, close during prepare/dial, callback map snapshotting, strict UTF8 accounting, queue flush reentrancy, original close facts, detached report and paused lifecycle listeners. Do not duplicate these as new feature work without a demonstrated gap.

## Demonstrated Dart gaps / bounded implementation recommendation

1. **Add a reusable binary-capable recovery core/payload report without weakening existing Responses contracts.** Current `ResponsesUnsentMessage` and helper explicitly support text only. Preserve text-vs-binary identity, defensive byte snapshots and immutable/detached final remainder. Keep strict budget and uncertain-send exclusion.
2. **Expose opt-in recovery on native Live and Realtime, and callback-based Translation if using Python as authority.** Keep defaults unchanged. Do not recreate all SDK helper layers or add new API wire schemas.
3. **Protect Live startup generations.** Current Dart primary/fork wrapper tracks `_startupSent`, `_started`, final `_startedSignal`, current session/startup config and usage/final state. Simply putting a swapping socket under it retains stale state and can send ordinary commands to a fresh unstarted session. Reset generation-specific startup/session state before swap/reconnected exposure, require explicit new startup, and ensure queued application commands cannot auto-flush before the new session.started barrier. No implicit startup/audio/external action replay. The safest adaptation is a documented manual pending flush policy for guarded Live connections; generic SDKs have no Dart-style startup guard to preserve.
4. **Retain Realtime manual pending policy if following Node.** Default0bytes, explicit restore/update, then flush; lifetime retry budget bounded. No transcript, audio, tool output or server event reconstruction.
5. **Fix native transport defaults.** All current `dart:io.WebSocket.connect` calls omit compression, retaining compressionDefault. Explicitly disable by default. Dart IO already has no Node-style small maxPayload default; validate large real local frames rather than inventing an unnecessary cap. Caller custom connectors are the native option seam; preserve them every attempt.
6. **Bring Realtime setup/lifecycle up to current Live/Responses standard.** Current Realtime `_openSocket` lacks timeout/abort/custom connector, validation/case-insensitive header merge, late-handshake disposal and wrapper/setup failure disposal. IO wrapper drops no reader reference, validates close reason by code-unit length instead of UTF8, closes controller before peer close facts arrive, and nonredacted diagnostics can retain auth/URL data. These are concrete scoped lifecycle gaps shared by Translation.
7. **Browser tests/docs stay explicit.** Existing connectors reject nonempty custom headers. Preserve unconditional any-key rejection before acquiring credentials; document WebRTC/backend proxy. No ephemeral bearer workaround.
8. **Source records, examples and reviews.** Add one offline/local recovery example, collapsible advanced README topic, source disagreement record and review evidence. No changelog or release/version edits, no canonical manifest promotion.

## Receipt SHA256

| File | SHA256 |
| --- | --- |
| Python `_websocket_connection.py` | `75c8b1ca04b07567932ed4c8bcf88cd1d892cf17045f175cd3f359cc294889c2` |
| Python `_send_queue.py` | `78060c44c7d9f200cd65088e3118b57f35231ad1880c33ca02ea0e3bc25a16b5` |
| Python `resources/realtime/translations/translations.py` | `dd26ca4fe27aa6b23b9d0add6e5aa41d10379ee3c6fa8c22293a26da867ca90e` |
| Python `resources/live/live.py` | `4f9a3128d0a4d56f14c74c80a1d6bb8ee76fdb8096699f6573bc6c4ed434b9d6` |
| Node `internal/ws-connection-controller.ts` | `244672ee00ee1bfad10d993816bfbc6e2d55adef2f9ab0637cb49465cfcafbc9` |
| Node `internal/realtime-recovery.ts` | `9fb73903361f212c6d97b5ce7ce2f1acc2a07f3cde5629a0775deef61ea618de` |
| Node `internal/ws.ts` | `36b5fadcbe6a372a2fb055223ef4787a3d9bf45288e11458b87206ab98b7e689` |
| Node `resources/live/ws-base.ts` | `c0a180b66c3ca97fc5de7802074d590689cdce20f4b96685ebbfaa3886ac2c61` |
| Node `realtime/translations/ws.ts` | `2d0b345c742859da9ff7ecf623a57e5a73324d7a9825e3650ae5aa774207f8c2` |

## Implemented policy

All reconnection remains opt-in and requires an application preparation callback.
The existing Responses public names remain valid; generic WebSocket aliases
share their type identity rather than creating duplicate delivery models.
The common transport now preserves immutable text/binary payloads and FIFO order.
Frames leave the queue before their one write attempt; attempted failures are
reported as delivery-unknown and excluded from detached unsent reports.
Retry delays reject values above 2,147,483,647 ms to prevent browser timer
overflow, matching Node validation. A compiled Dart JS probe demonstrated an
uncapped 30-day delay reconnecting after 40 ms on the shared setTimeout path.
A strict byte budget and a default 1024-frame count budget cover even empty
frames. Zero in either budget rejects pending sends. Reentrant sends join the
pending tail while a flush is active. Reentrant explicit flushes are rejected;
physical interruption during manual flush throws while retaining the remainder.

Live primary, fork and sideband resources accept LiveReconnectOptions and
per-call query parameters. Live uses per-interruption retries, manual pending
flush and a zero-byte default. This deliberately differs from the SDKs' raw
Live auto-flush, because Dart's typed startup guard must not be bypassed.
Primary/fork socket replacement resets session/startup state, settles old
waiters and requires fresh explicit startup acknowledgment before flushing.
No startup or accepted commands are repeated. Finalization commands are rejected
during recovery before changing local closing state. Finalized/closing sessions do not
start a replacement session. Live recovery handles enforce the startup barrier
when flushPending is called through either the connection or the recovery handle.

Realtime and Translation accept RealtimeReconnectOptions, connector injection,
headers/query, timeout and abort. Both use Node Realtime's manual pending policy,
zero-byte default and lifetime retry budget. Translation recovery follows the
Python capability while documenting Node's different specialized finish API.
Initial configuration is sent only once; new configuration can be sent on the
fresh socket before pending frames are explicitly flushed. Call-ID/intent
Realtime sessions do not enable model-session automatic recovery.

All attempts rebuild request-scoped authorization and URLs, preserving repeated
base queries and immutable initial per-call options. Callback replacement maps
overlay those inputs; empty maps clear reconnect overrides. Caller connector
closures retain their native options on each dial. Default IO connectors disable
compression and support large frames without adding an artificial payload cap.
Browser connectors reject every custom-header key and direct users to WebRTC or
a trusted proxy; authentication values are redacted from diagnostics.

Responses setup now disposes sockets when wrapper construction/reader setup
fails, retaining the original failure if cleanup also fails. Realtime cleanup
now exposes done/peer facts, consumes late dial outcomes, releases readers and
sockets on abort/setup/close failure, and completes independently of paused taps.
Close-fact preservation also covers retry configuration/preparation/delay failures.
Responses lane session helpers intentionally remain scoped to one nonrecovering
connection: callers create a new helper and reconcile each lane after interruption.
This preserves #416's explicit physical-session boundary.

## Verification handoff

No HTTP operation, API wire schema, global manifest binding, version or changelog
is changed by this helper slice. Candidate fetch/review/describe/scaffold dry-run
and isolated promotion use the frozen source in /tmp/openai-issue417-contract.
Global canonical promotion and remaining baseline findings remain owned by #427.
The scaffold preview of LiveSessionCreateParams was reviewed only; recovery is
an SDK lifecycle helper, so generated wire classes were not changed.

### Final evidence

- Package format, dart fix and fatal-info analysis pass. No automatic fixes remain.
- Shared recovery: 17 focused tests pass, including binary ownership/kinds/FIFO,
  exact byte and empty-frame count limits, reentrant/interrupted manual flush,
  lifetime budget, timer boundary and preservation of physical close facts.
- Live selection: 183 pass, including primary/fork startup barriers, sideband,
  late dial disposal, queued terminal preservation, finalization rejection during
  recovery, synchronous-listen cleanup and operation-local versus global aborts.
- Realtime/Translation: 40 new VM tests pass, including four local native peers.
  Defaults, explicit compression override/native options, 2 MiB text/binary,
  fresh credentials/options, abort/timeouts, cleanup and pending policy are covered.
- Responses resource/native setup selection: 27 pass, including construction
  failure disposal and 2 MiB text/binary native frames without compression.
- Chrome JavaScript and Wasm each pass 23 shared/browser tests. Browser policy
  rejects every custom-header key before credential lookup.
- The local public Realtime example runs successfully without API credentials
  or charges and confirms configuration arrives before the pending work.
- Independent engineering review found and verified fixes for retained dial
  races, synchronous reader cleanup, rejected finalization state, interrupted
  finalization and stale operation-local startup aborts. A separate requirements
  review checked every acceptance criterion, all nine source hashes and reproduced
  the browser timer overflow before its fix. Neither review has remaining blockers.
- Toolkit candidate fetch/review/describe/scaffold dry-run and isolated promotion
  complete. Final verification compared against the exact main-code baseline:
  implementation 1091 errors/156 warnings/280 infos, consistency 0 errors/114
  warnings and eight export findings are identical. Documentation/readme have
  zero findings; the README now has 54 collapsible usage topics. Global baseline
  remediation/promotion remains #427; this is not a claim of a globally passing
  toolkit implementation audit.

The final full unit run reported 25,624 passed, two skipped and one failure:
the unchanged HTTP/2 paused-consumer observation fixture timed out under the
combined run. Its isolated 23-test file passed. An earlier concurrent run also
hit two subprocess test timeouts; those passed in the lower-concurrency full
rerun. These timing failures are recorded without treating the full suite as
green. No live external API tests were run.
