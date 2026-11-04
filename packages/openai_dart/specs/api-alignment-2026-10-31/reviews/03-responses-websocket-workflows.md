# Responses WebSocket warmup and session review

Issue #416; parent #413. Reviewed November 4, 2026.

## Sources and scope

- [Frozen OpenAPI 2e9ebb3](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json).
- [Python 3.42.0 session helpers](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/lib/responses_websocket/_session.py).
- [Node 7.47.0 session](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/lib/responses/responses-websocket-session.ts) and [lane](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/lib/responses/responses-websocket-lane.ts) helpers.
- [Official WebSocket guide](https://developers.openai.com/api/docs/guides/websocket-mode), using the October 31 cached source.

The inventory assigns eight schema changes to this slice: the four GA/beta
configuration-update request/resource schemas, two WebSocket create schemas and
two general text-format union schemas. The shared configuration-update text
contract is identical after normalizing Beta references and its additional agent
metadata. Create contracts and general text-format unions match after Beta
reference normalization. No new HTTP operation is introduced.

Configuration-update `text` is optional and nonnull. A supplied object requires
`format`, restricted to `text` or `json_schema`; `json_object` belongs only to the
broader general Responses text format union. Omitting `text` leaves that setting
unchanged; an explicit plain-text format resets it. Input update IDs remain
optional/nullable, whereas stored resource IDs are required.

The existing Dart create envelope already supports `generate: false`, but its
documentation incorrectly described this as absent from the canonical schema.
The frozen create schemas now contain that field. The general text-format delta
adds its discriminator; it does not introduce a new format branch.

## Deliberate SDK differences and limits

The SDKs disagree on helper ownership: Python owns/closes its connection; Node
releases helper listeners and leaves the caller-owned socket open. Dart follows
the Node ownership model. Direct connection events and sends remain available.
Only registered lanes are accumulated; unregistered events remain observable on
the low-level connection rather than changing another lane's response state.

Dart uses explicit positive application budgets for lane slots, queued event
counts, queued JSON bytes and cumulative consumed response bytes. JSON byte
accounting measures the UTF-8 encoding of immutable parsed JSON snapshots. It
excludes original wire whitespace, transport/decoder/object overhead and the
connection's opening buffer before the helper attaches. This is a retained-data
budget, not a transport message-size or total-process-memory guarantee. The
cumulative response budget counts all consumed events, including ignored deltas;
queue limits alone cannot bound a continuously drained accumulator.

Node poisons a partially consumed final collection after cancellation; Python
retains its accumulator across canceled waits. Dart retains accumulation and
queued events, checks cancellation before dequeue, and releases the single-reader
lease. Lane detach discards local state. Shared queue pressure fails the largest
backlog until the session is within budget, isolating independent lanes; Python
instead terminates its router on queue overflow.

Detached IDs remain reserved for this connection's lifetime, including after
helper recreation, because delayed steering successors may follow a terminal
response. Recovery-enabled connections are deliberately rejected: SDK lane sends
bypass their legacy recovery queues and pin the physical socket to avoid replay
of attempted work. Explicit recovery alignment remains #417.

The terminal response is authoritative. Finalized `output_item.done` snapshots,
ordered by output index, fill omitted or null output; an explicit empty array
remains empty. WebSocket-only tolerance preserves raw omission/null distinctions
without weakening HTTP/SSE `Response` parsing. Deltas need not include the setup
events required for SSE reconstruction, so the existing delta accumulator is not
used to synthesize final WebSocket items.

## Requirements and engineering review

The source audit and implementation review traced the public behavior below:

| Requirement | Evidence |
| --- | --- |
| Warmup and continuation | Typed `generate: false`, no HTTP-only stream/background fields, returned warmup terminal ID reused explicitly; request ancestry remains separate from routing. |
| Configuration updates | Typed text/plain/JSON schema on input, stored input and conversation replay, GA/beta metadata, immutable schemas, contextual validation, copies/clearing, equality/hash and omission/null tests. The same-schema Live input adapter and compact-history validator also recognize and validate text. Local parser metadata is not sent. |
| Lane collection | One ordered reader per lane; interleaved/default/future events, refusal/tool items and failed/incomplete terminal results; sorted finalized output fallback with omitted/null/empty distinctions. |
| Resource limits | Per-lane/session events and JSON-byte budgets, cumulative response-byte cap, independent-lane failure, reserved detached IDs and release of retained buffers. |
| Lifecycle | Close, detach, cancellation, malformed events and EOF unblock pending readers and release subscriptions; no automatic tool execution or replay. |
| Workflow guidance | Offline runnable warmup, manual tool continuation, fork in-progress barrier and complete compacted-history replay on a new chain. |

Independent source/requirements review compared both pinned SDK helpers with
the existing low-level Dart connection and SSE accumulator. Model review checked
all configuration-update contexts against the same schema rather than accepting
raw future-field passthrough as complete typed support. That audit identified
the Live input adapter and its second embedded compact-history validator; both
now validate the new text field without refreshing unrelated Live contracts.

Engineering review checked immutable raw snapshots, schema ownership, nullable
copy clearing, equality/hash consistency, public barrel consumption and redacted
failure diagnostics. Separate final-output snapshots prevent caller edits to a
delivered typed event from corrupting collection. Cancellation completion settles
wait listeners after a reader exits; unexpected EOF releases partial accumulation;
all budgets reject nonfinite values as well as nonpositive values. Session close
removes its subscription without closing the caller-owned connection. No retry,
tool execution or automatic response continuation is introduced.

## Validation

- Model and WebSocket envelope regression selection: **562 tests pass**.
- Shared Live configuration-update adapter, compact-history and existing Live
  regression selection: **3,220 tests pass**.
- Public-client session routing, lifecycle and budget fixtures: **44 tests pass**.
  Synthetic WebSocket frames enter through `client.responses.connect()` with an
  injected socket; these fixtures do not contact OpenAI.
- Offline `responses_websocket_session_example.dart` succeeds with six synthetic
  creates and one mocked HTTP compaction call. The README snippet compiles.
  No API key, live generation, hosted tools or API charges are involved.
- Full OpenAI unit suite: **25,427 passed, 2 skipped, no failures**. Five final
  tests added after that run were checked in a final **48-test** selection
  (44 session tests and four public HTTP contract fixtures), all passing.
- Full-package analyzer passes with fatal infos; targeted model/Live analysis,
  formatting and quick-fix checks pass. The README snippet compiles.

Source/fixture review establishes local behavior against the frozen contract;
it does not claim a live server run or passing global alignment gate.

## Toolkit and #427 handoff

The toolkit fetch/review/describe/scaffold workflow ran in an isolated
`/tmp/openai-responses-websocket-workflows` package. The fetched candidate equals
the frozen JSON source (raw SHA-256
`73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`).
The configuration-update scaffold dry run succeeds; hand-written typed code adds
validation, immutable schema ownership and value contracts absent from the raw
map scaffold. The candidate is promoted only inside this isolated workspace
before verification. Canonical package spec, global manifest and source metadata
promotion remains assigned to #427.

[Scoped manifest mappings](03-responses-websocket-workflows-manifest.json) record
the actual GA/beta schema bindings, contextual stored-conversation bindings,
inline text wrapper, existing general text-format variants and local session/lane
helpers. Local helpers and inline objects are explicit extensions rather than
invented OpenAPI components. The isolated verifier also incorporates the already
merged #414/#415 handoff mappings.

Final whole-snapshot verification reports 1,103 implementation errors, 178
warnings and 290 infos; consistency has no errors and 115 warnings. Docs and
README checks pass with 52 collapsible usage subsections. Eight existing internal
helper libraries are flagged by the export checker; public helper/model access
is exercised by the session fixtures and compiled example. This is not a passing
global alignment gate.

Scoped configuration-update, WebSocket-create and contextual Live input mappings
have no implementation errors. The mapped pre-existing text-format classes
surface missing copy methods and fixed-discriminator inspection diagnostics;
those remain visible. The handoff corrects an inherited manifest mistake that
bound the inline Live reasoning adapter to its entire parent component: it is
now an extension for the actual `properties.reasoning` object. This accurately
records the source structure rather than suppressing verifier diagnostics.
Canonical/global reconciliation and remaining unrelated gaps stay with #427.
