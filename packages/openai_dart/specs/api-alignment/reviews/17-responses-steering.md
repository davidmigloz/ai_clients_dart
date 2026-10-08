# Mid-turn Responses steering acceptance

Status: implemented, verified and independently reviewed; PR pending.
Tracking: [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-STEER-01–03](../responses.md#steering).
Dependency #341 merged in [PR #353](https://github.com/davidmigloz/ai_clients_dart/pull/353).

## Sources and scope

Rechecked October 8, 2026 against
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json),
[Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e),
and [Node main 30d50ab](https://github.com/openai/openai-node/tree/30d50ab301f4c348726d1fcb9c51a84cb8feb71a).
The current Node package version remains 7.30.0; its main revision is newer than
the previously reviewed release pin. Responses/steering/WebSocket source is
unchanged; later Node changes concern dependencies, tests and inferred URL-upload
filename decoding. Dart uploads take explicit bytes and filenames and have no
equivalent URL-to-file helper. No speculative upload change belongs in this slice.

Toolkit fetch/review reports 356 operations and 2,010 schemas with no semantic
changes. The candidate equals the canonical JSON. Fetch-only metadata churn was
restored; no new specification version was invented. Describe and scaffold
dry-run cover the registered real steering request schema. The published
[steering guide](https://developers.openai.com/api/docs/guides/steering) and event
descriptions establish the narrower operational input and continuation rules.
Open Responses has no steering event/schema/transport in its own specification;
the implementation is OpenAI-only.

## Client contract: RESP-STEER-01

- `ResponsesSteerEvent` emits exactly type, previous_response_id and input.
  No lane, create settings, tool output, message ID/status or assistant role leaks
  into a steer. `ResponsesSteerInput` accepts text or a nonempty user-message list;
  messages project only their optional message discriminator, fixed user role
  and text/part content. Empty text and empty content arrays remain valid.
- Dedicated text/image/file part models retain their real request fields and
  existing cache/detail types. Image/file locators do not become required merely
  because older shared constructors imposed that constraint. Supplied fields
  validate their actual nullability. No new base64/binary factory is introduced.
- The canonical/generated input union also admits function outputs and broader
  user-item metadata; those branches are deliberately excluded from the writable
  steering surface because the guide/event description rejects them. Ordinary
  tool results continue through response.create.
- `sendSteer(event)` and `steer(previousResponseId: ..., input: ...)` submit one
  explicit frame. Existing send/create signatures and tear-offs remain available.
  The target determines the lane; model/mode support is decided by the server.

## Server contracts: RESP-STEER-02

- The WebSocket dispatcher recognizes accepted/pending/failed as typed variants;
  SSE retains its existing dispatcher. Each requires its sequence and exact
  nested payload. Optional lane/allocated ID reject supplied null. Beta event
  schemas declare no typed agent; any future metadata stays in raw JSON.
- Accepted and pending require steering ID and parent ID. Pending requires an
  open reason and nonempty list of identifying stubs. Seven distinct stub kinds
  cover function (call ID/name), custom/computer/shell/apply-patch (call ID),
  tool search (call ID/fixed client execution) and MCP approval (approval ID).
  Known stubs reject complete result fields; a future discriminator retains raw
  JSON. Stubs are distinct from result-item DTOs.
- Failed requires fixed invalid_request_error type, open code/message, parent
  ID and the original input key. ID is optional before allocation. Original
  rejected input preserves arbitrary finite JSON, including null/scalars/objects,
  as an explicit compatibility inference beyond the writable schema. This does
  not make rejected shapes valid submissions. A failure after acceptance retains
  its identity; unknown reasons/codes are not normalized into enums.
- Parsed raw collections are recursively immutable. Const constructors retain
  caller-owned collection semantics. Models implement complete contextual
  serialization, nullable copy/clear, deep wire-value equality/hash and safe
  diagnostics. Typed copies retain future nested metadata while replacing
  changed known values; raw input is never converted into writable user input.
- New sealed variants require exhaustive-switch/cast migration. README and the
  migration guide show typed handling and preserve future fallback behavior.
  Known malformed steering messages now fail contextually.

## Continuation ownership: RESP-STEER-03

Acceptance queues server-owned input; successor response.created commits it.
Public socket fixtures keep reading after steered-incomplete and normal original
completion and require successor completion. Acceptance does not send another
create. Started tools are not cancelled, output is not rewritten and prior
actions are not undone.

Pending continuations return saved tool results or approval using one explicit
create per parent on its original lane. That create uses its own settings; the
server prepends queued steering in order. Fixtures cover all seven result/approval
kinds, repeated pending submissions sharing stubs, and a matching create before
the pending notification. Actual write counts prove no accepted-input resend or
tool rerun. Disconnects/missing acknowledgments remain unknown outcomes and never
cause an automatic replay. Accepted-then-failed events preserve the allocated ID.

The runnable offline example demonstrates both automatic successor completion
and two pending submissions sharing one saved function result. It asserts three
create frames and three steer frames across the two runs, with one explicit
pending continuation, no repeated accepted input and awaited cleanup for $0.
Native/backend-proxy platform rules remain those of the existing transport.

## Verification

- Public fixtures: 31 new VM cases plus the existing 52 WebSocket resource cases
  pass. The 30 browser-compatible new protocol cases pass in real Chrome with
  JavaScript and Wasm; the remaining case uses a native local upgraded server.
- Thirty serialized GA/beta request, acknowledgment, required-stub and content
  fixtures independently validate against their canonical schemas with zero
  errors. Rejected-input compatibility cases are intentionally outside the
  writable schema and verified separately.
- The literal new README usage and migration After block compile with no fatal
  analyzer infos. The offline example runs successfully. API cost is $0;
  no live API calls, publishing or version bumps.
- The 454 new model contract cases and 370 remaining legacy WebSocket model
  cases pass (824 combined). Three former raw-steering placeholder cases are
  replaced by the new typed coverage. The 454 models plus 30 browser protocol
  cases pass in real Chrome on both JavaScript and Wasm (484 per backend).
- Final package validation: 11,158 unit tests pass with two existing environment
  skips. This is 485 new cases (454 models/31 public), replacing three old
  placeholders, for a net increase of 482. All 502 Dart files format unchanged;
  dart fix applies nothing and fatal-info analysis is clean. Diff checks pass.
- After correcting failure termination, temporary offline provider-frame probes
  confirm that response.failed, successor incomplete and original nonsteered
  incomplete stop promptly rather than hanging the example reader.

Full toolkit scope remains diagnostic: 226 implementation errors, 68 warnings,
213 infos; 32 consistency warnings. Exports/docs/README checks are clear. All old
diagnostics remain visible; no exclusions were added. Compared with #341:

- Ten additional errors: four field-scanner reports for real union/list schemas
  without direct object properties, and six reports that do not follow the
  acknowledgment serializers' delegated wire-value helpers.
- Twenty-four equality/hash scanner warnings do not follow effective wire-value
  helpers; complete field contracts require runtime fixtures and peer review.
- Eleven infos concern open pending reasons and existing cache/detail type names.
- Four consistency warnings reflect heterogeneous error/identity/sequence/detail
  contracts across legitimate sealed variants rather than a shared wire type.

The restrictive input union and rejected raw input choices are explicit and are
not hidden behind a blanket claim of complete generated-client field parity.

## Independent reviews and delivery

The independent read-only requirements review approves the final combined diff.
Engineering peer reviews cover models/manifest/docs from the transport author and
transport/public/native fixtures/docs from the model author; neither author
self-approves their own implementation. All validated findings are resolved:

- Fixed the identifying-stub documentation's tool-search execution exception.
- Direct future-stub construction/copy cannot bypass known stub validation; all
  seven known discriminators reject serialization without leaking payloads.
- Nested typed edits and identity boundaries retain appropriate future metadata
  while replacing cleared/changed known values and old list entries.
- README/example readers handle shared response failures and unexpected incomplete
  outcomes; the new literal README code and migration After block compile.
- Accepted-then-failed public fixtures return the actual submitted input; arbitrary
  rejected input remains separately covered by model contracts.

Implementation PR and final GitHub CI remain pending. Close #342 only after merge;
opt-in recovery #343 and multi-agent injection #344 remain separate follow-ups.
