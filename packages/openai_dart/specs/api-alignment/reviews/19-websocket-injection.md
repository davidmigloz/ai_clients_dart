# Beta multi-agent WebSocket injection acceptance

Status: merged in PR #356 after green CI; #344 closed.
Implementation [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356) merged October 8, 2026 at `1e63d6b93bdf0028eb6925d45371b1f36deb5d7b`, closing #344, after all applicable final-head checks passed (14 contexts completed: 13 successes and the standard Test(all) skip).
Tracking: [#344](https://github.com/davidmigloz/ai_clients_dart/issues/344),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-INJECT-01–02](../responses.md#multi-agent-websocket-injection).
Dependency #341 merged in #353. Recovery #343 merged in
[PR #355](https://github.com/davidmigloz/ai_clients_dart/pull/355) October 8, 2026
at `22b8cfdace42edd8dbe54e88de0341ee2b73426a` after all applicable checks passed
(14 contexts completed: 13 successes and the standard Test(all) skip).

## Sources and reviewed specification

Rechecked October 8, 2026 against
[OpenAPI 3c4759c1](https://github.com/openai/openai-openapi/blob/3c4759c1ecc98a2ac3d3df85d54f4eb409f5957d/openapi.json),
[Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e)
and [Node main 534e691](https://github.com/openai/openai-node/tree/534e691da6979e75c17a14bc04f1daff81fdbeef),
still 7.30.0. The published
[multi-agent guide](https://developers.openai.com/api/docs/guides/responses-multi-agent)
establishes ownership, acknowledgment races and explicit continuation.

The new OpenAPI commit removes text-prompt custom voice creation and its request
schema; audio-sample creation with consent remains. The reviewed candidate was
promoted and independently compared with the pinned source, with 356 operations
and 2,009 schemas. Metadata archives the actual previous source/fetch timestamp
and pins the new URL. The audio roadmap is corrected; no implemented Dart voice
DTO is affected, and audio-family implementation remains in Phase 5. The review
tool's missing-entry suggestions for changed/removed voice request types remain
visible; no fake removed schema mapping was added to satisfy them.

All three real injection components are unchanged. Describe and scaffold dry-run
cover the registered actual request schema. Both SDK beta client/server unions
include injection and created/failed acknowledgments. Real manifest entries map
the three components and two inline error/code helpers to their actual libraries,
including moved part declarations. No invented HTTP operation, typed agent field,
submission identity or exclusion is introduced. Open Responses has no equivalent
injection schema/transport, so this slice is OpenAI-only.

## Request and execution ownership: RESP-INJECT-01

`connect(beta: true)` forces `OpenAI-Beta: responses_multi_agent=v1` last using
normal case-insensitive header precedence on the plain `/responses` URL. Existing
base queries survive; HTTP beta query conventions are not added to WebSocket
connections. Browser connectors still reject every custom header, including the
forced beta header. An authenticated proxy owns upstream auth/beta opt-in; callers
can wrap an already-open headerless proxy socket with `ResponsesConnection(...,
beta: true)` or provide a deliberate proxy connector.

`sendInject(ResponseInjectEvent)` and `inject(responseId: ..., input: ...)`
require a beta/open connection before any write and emit exactly type,
response_id and input. No stream_id argument exists; the target determines the
lane. The existing broad List<Item> request surface remains. Canonical maximum
16,384 is enforced on serialization and parsing, with no invented minimum or
tool-kind whitelist. Finite extra parsed frame keys retain ignored/projection
tolerance; they are not copied into writable JSON. The server currently admits
client-owned outputs that resume waiting agents.

The shared Item decoder remains unchanged: some generated input variants are
unsupported, future fields on known items can be trimmed and nested defaults/
ownership retain legacy behavior. Only the outer parsed request list is immutable.
These known limitations stay in the complete-parity inventory rather than a claim
of complete generated union/raw request fidelity. Failed reporting does not use
that decoder, and explicit continuation can retain validated raw maps.

Only developer-defined function calls are executed by the application. Calls may
originate from root or subagents; existing beta item/event ownership tags and lane
envelopes survive. Hosted multi_agent_call and multi_agent_call_output remain
server-owned. No tool runner, automatic continuation or replay is added.

## Acknowledgments and races: RESP-INJECT-02

The existing ResponseInjectCreatedEvent and ResponseInjectFailedEvent class names
now extend the sealed WebSocket server hierarchy. Legacy imports/constructors and
enum names remain available via re-export. The SSE dispatcher stays unchanged.
Required response ID, integer sequence and fixed discriminator reject missing,
null or malformed values contextually. Optional stream_id rejects supplied null
but permits omission; copies can clear it. Parsed raw metadata is deeply immutable
and preserves future agent/other fields without inventing typed agent metadata.

Created means input was committed atomically. It has no submission ID or echoed
input, so applications count outstanding submissions per response/lane rather
than inventing call-ID correlation. Readers keep receiving until the response is
terminal and every injection has an acknowledgment, including acknowledgments
after response.completed and multiple concurrently outstanding injections.

Failed input is a required raw List<Object?> array, preserving finite JSON and
future/malformed nested values without coercion through Item.fromJson. Scalar or
null outer input is rejected. Direct legacy List<Item> constructions still
serialize by converting top-level items; the getter widening requires migration.
Reporting arbitrary nested values is forward tolerance, not an admission promise
for a new request. The canonical error code remains the two-value enum; rawCode
retains unknown provider strings instead of normalizing them to unknown. Copying
a new enum clears its old raw override unless explicitly supplied; conflicting
enum/raw states reject serialization. Error future metadata remains lossless.

For response_already_completed, the caller may choose an explicit new create with
known uncommitted saved results, completed parent and original lane. Raw validated
maps pass through ResponseInput.fromOutputItems so future fields are not trimmed.
For response_not_found, reconcile identity. Generic malformed-request status 400
and the following socket close are both observable. Failed/incomplete responses
and premature disconnects stop readers explicitly. Accepted or delivery-unknown
input is never automatically resubmitted, and a tool never reruns automatically.

The common send path retains recovery's nonterminal new-frame overflow and
terminal unknown-delivery policy. Already-submitted injections never replay;
only newly unsent frames queue as immutable UTF-8 snapshots and flush FIFO.

## Copy contracts and compatibility

Request, acknowledgment and error values implement complete effective-wire
equality/hash, copy/clear and redacted diagnostics. Nested explicit error metadata
clears must not resurrect old parent provenance. Review found the same parent
copy pattern in existing steering acknowledgments; this slice also reconciles
their replaced child identity/error metadata and pending required-input list
values/order while preserving ordinary scalar copies, identity boundaries and
explicit parent raw overrides. Replacements remove old effective parent-only
child metadata as well as child-owned metadata that was explicitly cleared;
unmodified direct constructors retain their existing overlay policy. No steering wire
format or writable input constraint changes.

New sealed variants, raw failed-input getter and stricter known-frame validation
are documented in MIGRATION.md. Existing send/create/steer/recovery signatures and
HTTP beta behavior remain available. The README uses a caller-owned connection,
filters other lanes, returns completed identity/lane/raw input and leaves the
explicit continuation/close decision to the caller. Its literal code compiles;
the ownership/continuation probe proves one new create without tool rerun.

The runnable offline example shows two developer tools owned by /root and
/root/sub, ignores a hosted collaboration action, submits two injections,
observes two acknowledgments including a failure after completion, and performs
one explicit raw-result continuation on the same lane/socket. It asserts four
writes, two tool executions, retained raw future fields and awaited cleanup for
$0, without an API key or external service.

## Verification and independent reviews

- All **11,448 package unit tests pass**, with two existing environment-dependent
  skips. This is 186 net additional cases over merged recovery: 135 new injection
  model cases, 28 new public protocol cases and 25 steering copy regressions,
  replacing two obsolete unknown-injection model cases. Existing 14 injection
  model and 52 public WebSocket cases remain covered.
- The final **656-case** matrix passes on VM and real Chrome JavaScript/Wasm:
  479 steering models, 149 injection models and 28 public protocol fixtures.
- All **512 Dart files** format unchanged; fix applies nothing. Fatal-info package
  analysis and diff checks pass. Two Dartdoc angle-bracket infos found during the
  final package check were corrected; final analysis has no issues.
- The offline example runs with two tool executions, two injections, two
  acknowledgments and one explicit continuation, with awaited cleanup and $0
  cost. Literal README and migration After snippets compile; the README runtime
  probe also proves caller-owned connection/identity/lane/raw continuation.
- Independent requirements/source review approves the full combined contracts,
  source refresh, fixtures and classified toolkit delta. Cross-author engineering
  reviews approve models/provenance regressions and transport/public fixtures,
  documentation, example and manifest. All validated findings are resolved,
  including direct-constructor parent-only child metadata replacement.

Twenty-three serialized request/created/failed fixtures independently validate
against canonical schemas with zero errors,
including the 16,384-item boundary. For identical boundary items, outer count/
frame constraints are checked at full length and each distinct item is validated
once. Raw-reporting and unknown-code tolerance cases are separately verified
outside narrower canonical item/code shapes.

Full toolkit scope currently reports 229 implementation errors, 74 warnings and
213 infos; 32 consistency warnings. Compared with merged recovery #355:

- Three serializer scanner errors and six equality/hash scanner warnings do not
  follow the actual delegated _valueJson helpers. Every flagged member is present
  in effective-wire serializers and covered by field/copy/value fixtures.
- The failed input generic mismatch info now reflects deliberate List<Object?>
  raw reporting at the moved part file, replacing the old List<Item> mismatch;
  there is no net info increase.
- Two existing consistency warnings now include injection's required sequence
  and distinct inline error payload alongside legitimate heterogeneous variants;
  the warning count stays 32.

The refreshed specification alone did not change baseline diagnostic sets.
Exports/docs/README checks pass; all prior gaps remain visible and no exclusions
were added. No live API calls, publication or version bumps are part of this slice.
