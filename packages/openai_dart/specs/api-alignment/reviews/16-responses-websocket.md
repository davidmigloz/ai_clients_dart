# Responses WebSocket transport acceptance

Status: implemented, verified and independently reviewed; PR pending.
Tracking: [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-WS-01–04](../responses.md#websocket-sessions).
Branch: `feat/openai-responses-websocket`.

## Connection and wire contracts

`client.responses.connect` returns an already-open caller-owned
`ResponsesConnection`. It resolves `/responses` under the configured base path,
preserves repeated query parameters, converts HTTP/HTTPS to WS/WSS and accepts
already-WS schemes. Model selection belongs in create frames. Header precedence
is case-insensitive: defaults, auth provider, configured organization/project/
version, then additional headers. Beta forces `responses_multi_agent=v1` last,
without a REST beta query. No content/request-ID header is invented. Headerless
proxy configuration remains headerless.

Handshake timeout uses the configured connect timeout or a per-connect override.
Closed clients reject before dialing; late sockets after timeout/client closure
are disposed and late failures are consumed. Diagnostics redact credentials and
native/injected dial failure text. Existing sockets remain caller-owned after
client close; no HTTP retry, automatic replay or client socket ownership is added.

`ResponsesCreateEvent` composes `CreateResponseRequest`, preserving currently
supported request fields and stream options. Stream is implicit; background true
is rejected, and absent/false/null transport flags normalize to omission. Lane
names validate 1–256 ASCII letters/digits/underscore/dot/hyphen. Returned lane
metadata has the source's simpler optional string contract. `generate: false` is
an explicit guide-supported WS extension, absent from canonical create and REST.
Lane routing/FIFO is separate from previous-response ancestry; there is no client
lane scheduler or model allowlist.

`ResponsesServerEvent` dispatches all 58 existing ordinary event discriminators
through `ResponsesStreamEvent.event`, with independent lane metadata. Dedicated
`ResponsesErrorEvent` retains type/message, code/param presence, top-level
status/sequence, beta nullable agent, headers, misalignment and future fields.
Canonical code/param are required nullable, but guide/provider omission is accepted
and retained separately from explicit null. Misalignment validates known fields
while preserving future classification strings and raw extensions. Future event
types, including the three steering and two beta injection events awaiting their
tickets, remain complete `UnknownResponsesServerEvent` raw objects.

Known error/future models use effective wire data for deep equality/hash and
copy/reparse value equality. Typed copy edits override stale known raw keys while
retaining nested future metadata; changing nested identity discards stale metadata
and clearing/truncating typed fields behaves explicitly. Parsed raw/error/schema
snapshots are recursively immutable; existing shared HTTP/SSE DTO nested collection
ownership is retained. Ordinary shared enum normalization remains compatible:
`rawJson` retains the provider frame, while typed serialization can normalize
known enum fallbacks. This does not claim full field parity for every older DTO.

## Transport lifecycle and platform coverage

One socket reader emits a persistent broadcast stream. Response completion and
request-scoped server errors leave the socket open. The first listener receives
buffered early events/errors even after an early socket close. Opening capacity
defaults to 1,024; overflow closes explicitly with an observable error. Later
listeners receive current broadcasts, without history replay. Listener cancellation
is local; callers explicitly close the connection. `done` is independent of event
drainage, including absent/paused listeners.

Protocol errors (binary, malformed JSON/object/known events) are identifiable,
redacted stream errors; transport failures are separate and shut down safely.
Close is asynchronous/idempotent with cleanup in finally, even when socket close
or cancellation fails. Caller close codes are 1000 or 3000–4999; reason length is
limited to 123 UTF-8 bytes. A reason supplied without a code uses 1000. Actual
peer/abnormal close facts remain observable for later recovery.

Dedicated native/browser/stub connectors preserve existing Realtime behavior.
The browser rejects every supplied custom header before dialing, exposes only
keys and gives Responses backend-proxy guidance. It does not invent Realtime
ephemeral/WebRTC authentication. The browser adapter uses actual DOM close
notifications; the upstream web_socket wrapper's premature controller shutdown
was unsuitable for retaining close facts.

## Sources, schema and sibling boundaries

Fresh source checks retain
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json),
356 operations and 2,010 schemas with no wire changes. Releases remain
[Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e)
and [Node 7.30.0 / a4942ba](https://github.com/openai/openai-node/tree/a4942ba48e999f9f637f81c5c925ed91b326343f).
The [WebSocket guide](https://developers.openai.com/api/docs/guides/websocket-mode),
[multi-agent guide](https://developers.openai.com/api/docs/guides/responses-multi-agent),
[Python connection](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/resources/responses/responses.py)
and [Node connection](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/ws.ts)
establish transport and continuation contracts. Generate is documented beyond the
schema; omitted error keys are explicit compatibility tolerance. Shared canonical
fixtures were independently checked against all 58 GA schemas with zero errors.

The manifest changes 17 entries: 14 real GA/beta schema mappings and three Dart
envelope/transport extensions. One obsolete Realtime-related skip is replaced.
No new exclusions or invented schemas hide gaps. Existing user/prompt/conversation
request gaps remain visible through composition. Final full toolkit scope reports
216 implementation errors, 44 warnings, 202 infos, and 28 consistency warnings.
Relative to #340, 71 new create errors include six repeated pre-existing missing
properties and composition/intentional-omission scanner limitations; six more
errors reflect delegated serialization. Six create warnings and 16 effective-wire
equality/hash warnings are scanner limitations, while two infos reflect open
classification strings. All prior issues remain. Docs/exports/README checks pass;
four additional errors expose unchanged older annotation item-ID/sequence
requiredness tolerance through real GA/beta mappings, with one shared-beta type
info and two more heterogeneous-event consistency warnings. The annotation
payload itself now matches required nullable source semantics. Sibling full
toolkit scope has no implementation errors/warnings, 20 infos and three
consistency warnings; exports/docs/README are clear. No diagnostics were hidden.

`open_responses` already has DTO-only WS create/error types with its own published
contract: it excludes stream options and requires error status. No speculative
OpenAI transport, lanes or generate fields are added there. Both packages do have
the directly encountered shared required-nullable annotation gap; this narrow
correction is included with focused regressions and migration guidance. Other
provider-specific requiredness/default behavior is retained.

## Verification and independent review

- New model, public resource, native/browser/stub and lifecycle suites cover wire
  contracts, error presence, copy/value behavior, all shared event discriminators,
  native upgrades, header/query precedence, timeout/late-open cleanup and lane
  continuation. OpenAI has 524 new VM tests: 373 WebSocket model contracts,
  45 transport/connector cases, 52 public resource cases and 54 annotation
  contracts. Sibling adds 49 annotation contracts.
- Full package unit suites pass: OpenAI 10,676 with two existing skips; sibling
  506 with three existing skips. Format/fix/fatal-info analysis and diff checks
  pass (494 OpenAI files and 108 sibling files).
- 39 transport/policy tests and 427 model/annotation tests pass in real Chrome
  with both JavaScript and Wasm. The expanded codec run exposed JavaScript
  treating infinity as an integer; checking num.isFinite before accepting
  numbers fixes the JSON validation gap and retains finite numeric values.
  Both backends were rerun successfully after this correction. A temporary real browser proxy
  smoke checks production header rejection, headerless connection, exact create,
  binary protocol handling, actual close code/reason and awaited cleanup.
- README's exact usage block compiles with clean fatal-info analysis. Request
  errors and premature close complete the wait with an error; nested finally
  guarantees listener cleanup even if close fails.
- The runnable offline example verifies warm-up, two interleaved lanes and
  incremental continuation with four local create frames. All resources close.
  API cost is $0; no live API calls, publishing or version bump.
- Read-only requirements/source review covers the full diff. Engineering review
  is independent across peer modules: the model owner reviews transport/resource/
  public tests and docs, and the transport owner reviews models/fixtures/docs.
  Resolved findings include nested future metadata loss, wire-value equality,
  invalid direct ordinary-envelope construction, browser reason-only close,
  README error/early-close waits, actual beta injection discriminator coverage,
  inherited nullable transport flags and JavaScript numeric finiteness. Independent engineering review also
  approves the OpenAI/sibling annotation correction, preserving each provider
  tolerance and documenting the nullable getter/copy migration. Final combined
  read-only requirements review approves the completed runtime, tests and docs.
  Peer engineering scopes together cover every changed module independently.
  Two stale roadmap status sentences were corrected after review.
- PR/final CI/merge remain pending. Close #341 only after merge; typed steering
  #342, recovery #343 and injection #344 remain separate follow-ups.
