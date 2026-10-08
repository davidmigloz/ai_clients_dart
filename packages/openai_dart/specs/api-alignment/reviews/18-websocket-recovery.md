# Opt-in Responses WebSocket recovery acceptance

Status: implemented, verified and independently reviewed; PR creation pending.
Tracking: [#343](https://github.com/davidmigloz/ai_clients_dart/issues/343),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-RECOVER-01–02](../responses.md#opt-in-connection-recovery).
Dependencies #341/#342 merged in PR #353/#354. Steering merged October 8, 2026
at `eeaa8e7b1b8e821fc518287167c5fb06b549cdd8` after all 14 final-head checks passed.

## Sources and scope

Rechecked October 8, 2026 against
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json),
[Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e),
and [Node main 534e691](https://github.com/openai/openai-node/tree/534e691da6979e75c17a14bc04f1daff81fdbeef),
still package version 7.30.0. The published
[recovery guide](https://developers.openai.com/api/docs/guides/websocket-mode#reconnect-and-recover)
and pinned SDK helpers establish recovery behavior, rather than REST schemas.

Toolkit fetch/review reports 356 operations and 2,010 schemas without semantic
changes. Candidate JSON equals the canonical spec; fetch-only metadata churn was
restored. Describe covers each registered SDK extension with `schema: null`.
Scaffold dry-run correctly refuses `ResponsesReconnectOptions` as an unknown
API schema; no fake REST operation or schema was added to make it generate.
The 15 new concrete/abstract classes and preparation typedef have actual file
mappings; exports remain reachable through the public Responses resource.

The latest Node commit changes only its structured-output parser, docs and
phase tests. WebSocket/recovery sources are unchanged. Dart has no equivalent
Responses `outputParsed` parser helper; the later shared-utilities inventory
records that gap. Open Responses has no corresponding WebSocket API/helper;
this slice is OpenAI-only. Multi-agent injection remains ticket #344.

## Retry and ownership: RESP-RECOVER-01

`client.responses.connect(reconnect: ResponsesReconnectOptions(...))` explicitly
enables recovery and requires a preparation callback. Omission preserves ordinary
connection behavior and a null recovery helper. Existing named parameters,
method tear-offs and create/send/steer entry points remain source compatible.
Initial handshake failures are not retried.

Only actual close categories 1001/1005/1006/1011/1012/1013/1015 admit recovery.
Normal, protocol, policy and other unknown codes terminate. An absent physical
code or stream ending without a notification is classified as abnormal 1006
for preparation; a final report retains null when no actual code was observed.
Receive errors emit a redacted lifecycle notification and await the actual close
category, so a following policy close cannot be preempted by a retry.

Defaults are five attempts per interruption, 500 ms exponential delay capped at
8,000 ms and jitter [0.75, 1.0], rounded to whole milliseconds like Node.
Submillisecond configured durations truncate to milliseconds. Each successful
reopen starts a fresh interruption budget, matching Node's helper; Python instead
resets its budget after non-error application progress. This is not a lifetime
limit or a server delivery guarantee. Validation is release-safe and rejects
negative/nonfinite settings. Zero attempts, zero delay, zero queue budget and
a delay cap below the initial delay are explicit valid policies.

The hook prepares before the delay, may abort or throw, and its synchronous or
asynchronous decision maps are snapshotted immediately on receipt. Authentication
is rebuilt after the delay for every physical dial. Nonnull query/header maps
replace previous overrides; null retains them and empty maps clear them. Base
URL queries and case-insensitive defaults/auth/config precedence remain intact,
with beta opt-in forced last. No implicit content or request-ID headers appear.
Browser connections retain the existing headerless proxy requirement.

Explicit close cancels pending preparation, delay and handshake promptly without
awaiting an unresolved user future. Late errors are consumed and late successful
sockets are disposed. Generation guards prevent retired sockets/listeners from
affecting a successor. Client closure leaves established sockets caller-owned,
but prevents new recovery callbacks, auth refresh or physical dials.

## Unsent queue: RESP-RECOVER-02

Only frames newly submitted during recovery enter the bounded queue. Each record
contains exact immutable serialized text and its UTF-8 length. Default budget is
1,048,576 bytes, including an oversized first frame: this strict limit matches
Python and differs from Node's empty-queue exception. Overflow rejects only the
new frame with a typed exception/lifecycle event; the old queue and recovery
remain intact. Zero queue budget disables buffering.

FIFO flush removes one record immediately before its write attempt. The remaining
never-attempted records stay charged during reentrant sends, which append behind
them. Submitted create/steer/inject frames never replay. A write that throws has
unknown delivery; its attempted frame is never requeued or included in the unsent
report. The delivery-unknown event is distinct from the immutable final FIFO
remainder, available through `recovery.done` even without an event listener or
with a paused listener.

Dart permanently closes after any attempted direct/flush write fails. Discarding
the attempted frame matches Python, but terminalizing the helper deliberately
differs from Python's logged flush failure followed by reopen success and Node's
default attempted-frame requeue. The strict queue limit and terminal failure
policy are documented rather than presented as complete helper parity.

Socket reopening does not restore connection-local cache, accepted steering,
conversation history or tool effects. The application chooses reconciliation
and new work; this helper never automatically resends a create, accepted input,
injection, tool result or tool execution. Ordinary typed server parsing/early
buffer behavior continues through the existing connection over a socket facade.
Connection closeCode/closeReason describe final logical helper closure when
recovery is enabled; attempt contexts retain interruption details.

## Verification and independent review

- New deterministic coverage adds 104 cases: 36 local helper value/snapshot
  contracts, 52 socket recovery fixtures and 16 public resource cases. Tests
  cover every close category, callback prepare/abort/throw, default/capped jitter
  (including whole-ms midpoint rounding), 1,100 zero-delay attempts, exhaustion,
  stale generations and close during preparation/delay/handshake.
- Actual write counts cover sent create/steer/raw injection no-replay, strict
  first-frame/multibyte/exact-budget/zero/overflow cases, caller mutation,
  reentrant FIFO accounting and unknown attempted writes with immutable final
  never-attempted remainder. Lifecycle done remains independent of listeners.
- Public fixtures verify old connect tear-off compatibility, opt-in omission,
  zero/invalid config, per-dial fresh auth, case-insensitive precedence, repeated
  base queries, replace/retain/clear overrides, synchronous callback snapshot
  before caller microtasks, nonterminal overflow, timeout late disposal, client
  closure and prompt explicit cancellation with consumed late outcomes.
- Final package checks pass 11,262 unit tests with two existing environment
  skips, a net increase of 104 over merged #354. All 508 Dart files format
  unchanged, dart fix applies nothing, fatal-info analysis and diff checks pass.
- The literal new README recovery wrapper compiles with no fatal infos. The
  offline example runs without an API key: four writes, no sent create/accepted
  steer replay, two new full-context FIFO creates, one overflow rejection and
  one final immutable unsent snapshot, with awaited cleanup.
- All 104 new cases pass in real Chrome with JavaScript and Wasm, including
  valid beta injection no-replay fixtures and zero-budget empty-frame rejection.
  An additional 119 existing WebSocket/steering/lifecycle/connector VM cases pass.

All fixtures use injected local sockets; API cost is $0. No live requests,
publishing or version bumps are part of this slice.

Final full toolkit comparison remains unchanged from merged #354: 226
implementation errors, 68 warnings and 213 infos; 32 consistency warnings.
Exports/docs/README checks are clear. All prior diagnostics remain visible,
and no exclusions were added. SDK helpers have no fromJson/toJson API contract;
their local snapshot/value/copy contracts and queued protocol JSON round trips
are exercised separately from the unchanged server-event codecs.

## Independent reviews and delivery

The independent read-only requirements review approves the combined source,
public API, runtime policy and documentation. Engineering reviews cross-check
runtime/resource/public fixtures/manifest from the model author and
DTOs/model fixtures/manifest/README/llms/example from the transport author; no
author approves their own implementation. All validated findings are resolved:

- Synchronous callback maps snapshot before caller-scheduled microtasks.
- Bounded whole-millisecond backoff matches Node midpoint rounding and remains
  finite for 1,100 immediate attempts; submillisecond truncation is documented.
- Zero queue budget rejects even empty raw text frames.
- Final-close DTO and connection docs distinguish logical/requested facts from
  observed physical interruption details.
- No-replay raw injection fixtures use canonical beta response_id/tool-result
  input arrays, and zero attempts reports reconnect_disabled.
- Direct/flush failures never requeue attempted frames; explicit close consumes
  late outcomes and final unsent state remains available independently of readers.

The implementation PR will use the exact create-pr template. GitHub CI and merge
remain pending. Close #343 only after merge; beta injection #344 follows.
