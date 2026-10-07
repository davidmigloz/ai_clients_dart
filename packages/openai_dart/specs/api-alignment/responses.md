# Responses capabilities: Phase 3 specification

Status: independently reviewed specification; async tools, configuration updates,
web search and hosted/local shell merged in #346–#349. Compaction progress #338
is implemented, validated and independently reviewed in [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350);
merge remains pending. Access programs #339 follow after compaction. Remaining runtime slices
are tracked below. Parent:
[#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).

## Objective and decisions

Let Dart applications use current Responses tools and conversation controls,
inspect their complete results, and run persistent WebSocket conversations with
mid-turn steering. Deliver complete, independently demonstrable feature slices.
Phase 2 is complete in #327–#333; shared container configuration is available.

The user's complete-parity scope and targeted-breaking policy apply. Preserve
existing construction and provider tolerance where compatible with the documented
wire contract; specify corrections and migration per slice. Runtime client
configuration issue #316 is distinct from conversation configuration updates.
Release/versioning, Agents/Live transports, webhook/safety management, and broader
legacy parity remain separate phases.

Decisions for this phase:

- Application code owns tool execution and returning results. Add typed contracts
  and public examples; do not introduce an automatic tool runner.
- Additive flags preserve omission and explicit false. Validate supplied new
  nonnullable fields; do not tighten unrelated provider behavior incidentally.
- Separate request, returned, and context-specific shapes where requiredness or
  permissible members differ. Complete changed-model copy/value/diagnostic
  contracts across every existing field as well as new fields.
- Default web-search convenience construction to GA, retain explicit preview
  identifiers, and provide migration for the behavior change. Documented GA
  extensions ahead of the canonical schema are adopted with explicit source notes.
- Add a Responses-specific WebSocket interface to the existing package, using
  existing transport dependencies and configurable REST base URL/auth settings.
  Keep SSE behavior intact; carry WebSocket lane metadata in an envelope around
  shared events. Browser direct bearer authentication is unsupported; an injected
  authenticated proxy/connector is the browser path. Realtime WebRTC does not
  authenticate a Responses connection.
- Recovery is explicit by default; a separate opt-in SDK reconnect helper follows.
  Never silently replay a generation or steering frame.
  Local fixtures verify contracts; paid/provisioned tool services are unnecessary
  for acceptance. A future separately bounded live test may be used where useful.

## Evidence and discrepancies

Revalidated October 7, 2026 against package source at merged #333,
`5eae6db755775d904cfe19df3f22e1bd26dedb73`. Fresh toolkit fetch/review found no
semantic difference from the canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json)
(356 operations, 2,010 schemas). The toolkit's unchanged-spec report does not
establish implementation parity: individual fields and union branches are missing.

Official client pins are [Python 3.26.0 / 4e152cd](https://github.com/openai/openai-python/tree/4e152cdefe1844c2d5d78653310e9b9c0195c44e)
and [Node 7.30.0 / a4942ba](https://github.com/openai/openai-node/tree/a4942ba48e999f9f637f81c5c925ed91b326343f).
Discovery follows the [changelog](https://developers.openai.com/api/docs/changelog)
and its linked guides. Revalidate affected contracts before each implementation.

| Difference | Decision and source of truth |
| --- | --- |
| Earlier inventory says configuration updates are missing from output parsing | Canonical `Item`, `ItemResource`, and `ConversationItem` include them; `OutputItem` does not. Add request/list-input/conversation parsing, no invented output/SSE variant |
| Web search image controls/results and token budget lead schema/clients | Follow the published GA web-search guide; record explicit manifest discrepancies rather than suppressing verification |
| WS guide documents `generate: false`, absent from `CreateResponse` and the pinned Python create signature | Add a WS-only warm-up option; do not add this member to REST requests |
| Steering input schema admits function outputs and user id/status, but guide/event description restrict user-message keys | Typed steering accepts only user `type`/`role`/`content`; tool results use `response.create`. Record the narrower documented behavior |
| Effective response `access_programs` is required nullable in schema, optional in Python/provider payloads | Preserve outer omission/null tolerance; a supplied body requires nonnull `cyber`. Request has a distinct optional nonnull shape |
| Tool-search request arguments are objects, returned arguments are arbitrary JSON | Separate contextual contracts; returned null is preserved as a required value, not silently omitted |
| Failed queue flush differs: Python does not requeue an attempted failed send; Node does | Snapshot UTF-8 frames at enqueue. Failed attempted writes have unknown delivery and never replay; report only never-attempted remainder as unsent |
| Canonical WS ErrorPayload requires nullable code/param keys; guide connection-limit errors omit param | Preserve outer omission of code/param for compatible WS errors and supplied null distinctly; require type/message. Include the exact guide limit-error fixture |
| Node reconnect enables only with callback, uses [0.75, 1.0] jitter and admits one oversized frame into an empty queue | Require an explicit reconnect preparation callback and adopt that jitter; enforce the configured queue byte bound with observable rejection, including its first frame (matches Python; differs from Node) |

## Delivery slices

| Order | Outcome | Requirements | Status and dependencies |
| --- | --- | --- | --- |
| [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) (09) | Async function/custom calls and faithful replay | RESP-ASYNC-01–03 | Merged in #346 |
| [#335](https://github.com/davidmigloz/ai_clients_dart/issues/335) (10) | Persistent reasoning configuration updates | RESP-CONFIG-01–02 | Merged in #347 |
| [#336](https://github.com/davidmigloz/ai_clients_dart/issues/336) (11) | GA web-search controls, actions and results | RESP-WEB-01–03 | Merged in #348 |
| [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337) (12) | Hosted/local shell configuration, replay and streaming | RESP-SHELL-01–03 | Merged in #349; container #320 merged |
| [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338) (13) | Observe compaction progress | RESP-COMPACT-01 | Implemented; validation/review pending |
| [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339) (14) | Select and inspect Responses access programs | RESP-ACCESS-01–02 | None |
| [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340) (15) | Return complete client-discovered tools | RESP-SEARCH-01–02 | [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) for nested async definitions |
| [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) (16) | Persistent Responses WebSocket sessions and lane routing | RESP-WS-01–04 | None; use the shared event contracts current at implementation |
| [#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) (17) | Steer a running WebSocket response | RESP-STEER-01–03 | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) |
| [#343](https://github.com/davidmigloz/ai_clients_dart/issues/343) (18) | Opt-in socket reconnection and bounded unsent queue | RESP-RECOVER-01–02 | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341)/[#342](https://github.com/davidmigloz/ai_clients_dart/issues/342) for replay regression |
| [#344](https://github.com/davidmigloz/ai_clients_dart/issues/344) (19) | Inject multi-agent tool results over WebSockets | RESP-INJECT-01–02 | [#341](https://github.com/davidmigloz/ai_clients_dart/issues/341) |

Linked numbers are GitHub issues; parenthetical numbers are repository ticket sequence. Implement in this
order unless a blocker changes; dependencies are required behavior, not source
layers. Steering must follow transport. Each slice includes public wiring,
exports/manifest, exact fixtures, README/llms and an example, migration where
applicable, and independent requirements/standards reviews.

## Async calls

- **RESP-ASYNC-01:** Function and custom tool definitions and their public factories
  carry optional nonnull boolean `async`. Preserve absent/false/true through nested
  namespaces, deferred/discovered tools and every existing definition field.
  Explicit parsed null or wrong type fails for this new member.
- **RESP-ASYNC-02:** Function/custom call input, output and conversation variants
  preserve `async`; add the missing direct `custom_tool_call` input parser/model.
  Replay conversion preserves all supported fields, including existing `agent`,
  call ID, namespace and status. Existing item-added/done and lifecycle response
  events retain it; no dedicated async event is invented. Accumulator final
  lifecycle responses retain it without claiming partial call reconstruction.
- **RESP-ASYNC-03:** Demonstrate handling an async direct call and returning its
  original `call_id` against the latest response. Explain supported GPT-6 model
  limits and multi-agent async/parallel restrictions. No client-side execution,
  scheduling, polling or model eligibility allowlist is introduced.

Sources: [async tools](https://developers.openai.com/api/docs/guides/async-tool-calling),
[Python function call](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_function_tool_call.py),
[Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts).
Local entry points: `response_tool.dart`, `items/item.dart`, `items/output_item.dart`,
`conversations/conversation_item.dart` and public Responses/SSE resource paths.

## Configuration updates

- **RESP-CONFIG-01:** Add input `configuration_update` with required discriminator,
  optional nullable id and optional nonnull reasoning object. Reasoning permits
  only optional nullable `effort`; do not reuse unrestricted `ReasoningConfig` to
  expose summary/context/mode. Existing `ReasoningEffort` values remain available.
  Returned configuration items require id. Support Responses list-input and
  conversation create/list/retrieve parsing, plus normal Responses request reuse.
- **RESP-CONFIG-02:** Demonstrate changing effort for subsequent responses while
  keeping request-level effort stable to preserve the cached prefix. Server
  persistence replaces earlier updates; the client neither mutates previous
  requests nor synthesizes output items/stream events. Document single-agent
  scope. Omitted reasoning, `{}`, nullable effort/id, malformed supplied objects,
  and required returned id each have contextual fixtures.

Revalidated implementation guidance: the response's `reasoning.effort` reports
the request-level setting, not effort selected by an update. Preserve updates
with `previous_response_id` or their original positions in manual history. Avoid
adjacent updates, automatic compaction/truncation, and standalone
`/responses/compact` histories containing updates. Explicit `compaction_trigger`
is supported; add a fresh update after compaction before the next user message.
These service restrictions are documented, without introducing SDK model
eligibility checks or automatic history rewriting.

Sources: [reasoning updates](https://developers.openai.com/api/docs/guides/reasoning#change-reasoning-mid-conversation),
[Python configuration input](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_configuration_update_item_param_param.py).
Local entry points: `Item.fromJson`, `ConversationItem.fromJson`,
`client.responses.inputItems.list` and conversation resources. Use actual public
method names in implementation examples; these names are navigation guidance.

## Web search

- **RESP-WEB-01:** Recognize GA `web_search`/`web_search_2025_08_26` and both
  existing preview types. Convenience/default uses GA; explicit preview stays
  preview. GA supports optional nonnull `external_web_access` and context size,
  optional nullable filters/allowed_domains and approximate location. Approximate
  location type is optional; city/country/region/timezone are optional nullable.
  Preserve empty location, false, empty lists and omission. Add documented GA
  blocked_domains, `return_token_budget` (`default`/`unlimited`), text/image
  search_content_types and image_settings (`max_results`, `caption`). Token budget
  is optional nonnull, never enabled automatically. Do not pretend preview honors
  GA-only controls. Support explicit GA tool choice as a guide-backed extension;
  do not silently convert preview choices. Retain existing allowed/function modes.
- **RESP-WEB-02:** Response and conversation web-search calls retain all exact
  statuses (`in_progress`, `searching`, `completed`, `failed`, `incomplete`), id,
  optional beta agent, action and guide-defined results. Action is optional
  nonnull: search has optional nonnull queries, deprecated query and URL sources;
  open_page has optional nullable URL; find_in_page requires URL/pattern. Known
  image_result requires image_url/source_website_url and preserves optional
  thumbnail_url/caption. No invented text-result schema; future result objects
  are preserved as recursively immutable raw JSON. For guide-only optional image
  metadata, accept absent/null and normalize null to absence; this is a client
  compatibility decision, not an upstream schema assertion. Reject malformed
  required known image members. Existing content/citations remain separate.
- **RESP-WEB-03:** Add all four missing canonical Includes:
  `web_search_call.results`, `web_search_call.action.sources`,
  `message.input_image.image_url`, `computer_call_output.output.image_url`.
  Preserve existing legacy include strings unchanged for compatibility. Public
  create/createStream/retrieve/list-input include paths serialize exact strings.
  Offline examples demonstrate filtered/image results and source metadata.

The guide documents up to 100 allow/block domains and scheme-free domain names;
allow/block lists can coexist. Image max_results is a positive count; no new
maximum/default is invented. Do not invent missing image-setting requiredness
from one example: constructor members are optional, supplied values are nonnull.
Document token-budget model limitations. Guide-only settings/results are marked
as such in manifest/verification evidence, never excluded to obtain a clean report.

Sources: [web search](https://developers.openai.com/api/docs/guides/tools-web-search),
[Python GA tool](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/web_search_tool_param.py),
[Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts).
Local entry points: `WebSearchTool`, `WebSearchCallOutputItem`,
`ConversationWebSearchCallItem`, `Include` and response tool-choice parsers.

## Shell

- **RESP-SHELL-01:** Shell definition/factory accepts optional nullable environment
  and existing allowed callers. Request environment is a tagged union:
  container_auto (optional nonnull file_ids, optional nullable memory_limit,
  optional nonnull network_policy and hosted skills), local (optional nonnull
  local skills with required name/description/path), or container_reference
  (required container_id). Reuse merged memory/network/hosted skill leaves;
  container_auto is not Code Interpreter's `auto`. Respect contextual limits
  (50 file IDs, 200 skills) without inventing execution or validation frameworks.
  Add canonical forced shell tool choice; retain existing choices.
- **RESP-SHELL-02:** Add typed shell_call and shell_call_output input variants and
  conversation bridges. Request call action requires commands, with optional
  nullable timeout/max output; optional input environment permits local/reference,
  never container_auto. Returned action requires nullable timeout_ms and
  max_output_length keys; returned environment requires a nullable local/reference
  key, whose local shape has no skills. Returned call requires id/call_id/action/
  status/environment; returned result requires id/call_id/status/output and
  nullable max_output_length. Preserve optional caller, beta agent and optional
  nonnull `created_by` on calls/results/output content. Request output contents
  have stdout/stderr/outcome, without returned created_by. Outcome remains exit
  with required exit_code or timeout. Required null keys survive serialization;
  input-only optional keys retain their distinct contract.
- **RESP-SHELL-03:** Parse five exact typed events through public SSE and the shared
  WS decoder when available. All require sequence_number/output_index/command_index:
  command.added/done have command; command.delta has delta and optional nonnull
  obfuscation; output_content.delta additionally requires item_id and a delta
  object with independently optional nonnull stdout/stderr; output_content.done
  additionally requires item_id and output content array. All support optional
  beta agent. Discriminators are `response.shell_call_command.{added,delta,done}`
  and `response.shell_call_output_content.{delta,done}`. Do not invent item_id on
  command events. Preserve interleaved command indices, empty delta/fragments and
  padding as metadata. Terminal lifecycle Response retains complete shell results.

An offline example shows hosted configuration and local tool continuation with
synthetic output; it never executes model-proposed commands automatically.
No new generalized shell accumulator is required. Conversation schemas must be
checked directionally; preserve current raw unknown fallback for unrelated items.
Targeted constructor/serialization corrections include migration for required
returned keys and newly typed input variants.

Sources: [shell](https://developers.openai.com/api/docs/guides/tools-shell),
[skills](https://developers.openai.com/api/docs/guides/tools-skills),
[Python shell definition](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/function_shell_tool_param.py).
Local entry points: `ShellTool`, input/output shell models and `ShellEnvironment`,
conversation item parsers, `ResponseToolChoice` and `ResponseStreamEvent`.

## Compaction

- **RESP-COMPACT-01:** Add typed `response.compaction.compacting` with required
  sequence_number/output_index/item_id and optional beta agent. It signals
  progress, contains no summary, and is not terminal. Public SSE and future WS
  decoding retain exact fields between item/lifecycle events. Existing compact
  REST, context_management, trigger and encrypted compaction items stay available;
  do not force large-context paid calls or invent summary text. An offline progress
  example and malformed/unknown-event fixtures verify the boundary.

The new sealed `ResponseStreamEvent` variant requires consumers with exhaustive
switches to add `ResponseCompactionCompactingEvent`. Applications that previously
inspected this discriminator through `UnknownEvent` should use the typed event.
The wire event and existing unknown-event fallback remain unchanged.

The existing `CompactionTriggerItem` DTO omits the optional canonical trigger
`id`; this out-of-slice gap remains tracked for later parity work. Raw history
replay preserves a provider ID without routing it through that DTO. The sibling
`open_responses` published schema has no corresponding progress event; no
speculative sibling variant is introduced.

Implementation #338 has 63 model contract tests and 142 public REST/SSE fixtures
(205 new deterministic tests). [Acceptance evidence](reviews/13-compaction-progress.md)
records completed documentation, validation and independent approvals. Implementation [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350)
remains open until merge; access programs #339 are next.

Sources: [compaction](https://developers.openai.com/api/docs/guides/compaction),
[canonical progress event](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json),
[Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts).
Local entry points: `ResponseStreamEvent` and existing compaction lifecycle models.

## Access programs

- **RESP-ACCESS-01:** Add optional nonnull request `access_programs` with a distinct
  request object whose optional nonnull `cyber` accepts `standard`, `daybreak_blue`
  or `daybreak_red`; `{}` is valid. Omission leaves selection to server defaults.
  Authorized mainline requests can default to Daybreak Blue; Red models default
  to Red and fail without access. Neither omission nor explicit selection grants
  access. Reject supplied null/
  malformed values; do not invent organization/model eligibility checks or add
  Build/Launch/Grow to service-tier/access-program enums.
- **RESP-ACCESS-02:** Preserve effective response `access_programs` through ordinary
  responses and nested SSE lifecycle responses. Outer absent/null stays compatible;
  a supplied object requires nonnull `cyber`. Keep request and returned shapes
  distinct. Every existing CreateResponseRequest/Response field remains present
  through serialization, copies, equality/hash and safe diagnostics.

Sources: [Daybreak](https://developers.openai.com/api/docs/guides/daybreak),
[canonical access-program schemas](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Local entry points: `create_response_request.dart`, `response.dart` and lifecycle
stream-event parsing. Acceptance is offline; provisioned Daybreak calls add no
necessary contract coverage.

## Tool search

- **RESP-SEARCH-01:** Preserve complete search call/output request, response and
  conversation shapes. Request call arguments are required nonnull objects;
  returned arguments are required arbitrary JSON, including null/scalars/lists.
  Returned execution/status/call_id keys are required with nullable call_id;
  request call_id remains optional nullable. Preserve hosted/client execution and
  returned tool lists. Document any correction to permissive current constructors.
- **RESP-SEARCH-02:** Search-discovered namespaces retain dotted function names and
  context-specific definition requiredness. Preserve nested parameters, strict,
  description, allowed callers, defer_loading, output schema and async. Use explicit
  contextual parsing/reuse or separate DTOs; do not impose ordinary function-name
  validation or top-level requiredness on discovered nested functions. Demonstrate
  returning discovered tools with the original call ID and `execution: client`.
  Existing tool-search endpoints and basic capability are retained.

Sources: [tool search](https://developers.openai.com/api/docs/guides/tools-tool-search),
[Python discovered namespace](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/tool_search_output_namespace_tool.py).
Local entry points: response tool, input/output item and conversation models.
Shared contracts must be audited in `open_responses` as required by the skill;
record whether a sibling correction is necessary, rather than assuming parity.

## WebSocket sessions

- **RESP-WS-01:** Expose an already-open caller-owned Responses connection using
  `/responses` under the configured base path/query, HTTP→WS/HTTPS→WSS, existing
  auth-provider/default/org/project/apiVersion (OpenAI-Version) header precedence and an injected connector
  test seam. Model belongs in the create body, not a query. Native Dart/Flutter
  supports handshake headers. Browser connector rejects any nonempty header map
  before dialing, names keys safely and points to an authenticated backend proxy.
  A headerless proxy connector may be used explicitly. Do not guess query-token,
  subprotocol, ephemeral Realtime or WebRTC authentication. Client close prevents
  new connects, including late successful handshakes; callers await connection
  close for existing sockets, consistent with current Realtime ownership.
- **RESP-WS-02:** Typed create composes existing request fields with
  `type: response.create`, optional stream_id and WS-only generate. Omit implicit
  stream, reject background:true, omit false/absent background. Keep transport
  metadata out of REST. Validate lane length 1–256 and `[A-Za-z0-9_.-]+`; absent
  selects default. Preserve false generate for documented warm-up and response ID
  chaining. Lane controls FIFO routing, previous_response_id controls lineage;
  reusing a lane alone starts a new response. No automatic lane admission or model
  allowlist. Document current service limits (16 concurrent responses, 32 distinct
  named lanes, 60-minute connections) without hard-coded client scheduling.
- **RESP-WS-03:** One socket reader emits typed envelopes with optional lane and
  shared Responses events, plus a faithful WS error envelope. Preserve every
  ordinary canonical event, unknown raw objects and named/default lane identity.
  Add the shell/compaction typed variants when those tickets land. Steering and
  injection become typed in their dependent slices; preserve their raw frames in
  this slice. WS error has required nested ErrorPayload, optional top-level
  status/sequence_number/lane, required error type/message and nullable code/param,
  optional headers/misalignment. Canonical code/param keys are required, but accept
  their omission for guide/provider-compatible WS errors; preserve absent versus
  supplied null, including the guide connection-limit error lacking param. Retain
  error metadata; do not collapse them through the narrower existing SSE ErrorEvent. Request-scoped
  server errors leave other lanes available; malformed JSON/non-object frames
  and socket failures remain identifiable transport/protocol errors.
- **RESP-WS-04:** Connection exposes persistent messages and observable close
  code/reason/completion. Response terminal events do not close the socket.
  Preserve early frames and close-before-first-listener; use an explicit bounded
  buffer failure policy rather than silent oldest-drop. Closed sends fail;
  asynchronous close is idempotent and race-safe. Caller-supplied close code is
  1000 or 3000–4999, and reason is at most 123 UTF-8 bytes. Observed server/abnormal
  close codes remain available for recovery.
  Subscription cancellation is local listener cleanup. No undocumented WS cancel
  frame or claim that disconnect cancels hosted work. Default never reconnects
  or resends; HTTP retryPolicy is not a WS replay policy. Document stored-ID/full-
  context recovery after connection-local cache loss, fork start races, and exact
  previous_response_not_found/invalid_stream_id/limit errors.

Sources: [WebSocket mode](https://developers.openai.com/api/docs/guides/websocket-mode),
[Python connection](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/resources/responses/responses.py),
[Node WS transport](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/ws.ts),
[Node WS base](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/ws-base.ts).
Local entry points: ResponsesResource/OpenAIClient, existing conditional Realtime
connector patterns, ResponseStreamEvent and existing auth/config transport code.
Reuse patterns after checking lifecycle gaps; do not copy Realtime's silent event
loss or Realtime-specific browser guidance. Offline example uses two lanes and
explicit cleanup. This slice is basic transport; helper parity requires 18.

## Steering

- **RESP-STEER-01:** Typed `response.steer` carries only type,
  previous_response_id and input; never stream_id or create settings. Input is a
  string or nonempty user-message list, whose messages project only type/role/
  content (text/image/file parts). No assistant/tool output/id/status metadata.
  Document supported GPT-6 single-agent mode, no conversation binding or automatic
  compaction; preserve unsupported-mode server failure without a model allowlist.
- **RESP-STEER-02:** Add exact accepted/pending/failed models and WS dispatch.
  Accepted: required sequence_number and steer{id,previous_response_id}. Pending:
  same identity plus open reason and nonempty required_input. Required-input
  identifying stubs are function(call_id/name), custom/computer/shell/apply_patch
  (call_id), tool_search(call_id,execution:client), and MCP approval
  (approval_request_id); these are not complete result objects. Failed: required
  sequence_number, error{type:invalid_request_error,code,message} and
  steer{previous_response_id,input, optional id}. Preserve original failed raw
  input even if rejected, optional lane, future reasons/codes and optional ID
  before allocation. Known codes include response_not_found, invalid_input,
  steering_not_supported, too_many_pending_steers, response_already_completed,
  response_not_active, successor_creation_failed. Existing string incomplete
  reason already retains `steered`; do not invent an enum change.
- **RESP-STEER-03:** Acceptance means queued server ownership; successor
  response.created is commitment. Keep reading beyond original completed or
  incomplete until successor completion. Pending tool/approval stubs use saved
  results in one explicit create per parent on its original lane; do not resend
  accepted input or rerun tools. Multiple submissions can share required stubs.
  Handle matching-create/no-pending races and accepted-then-failed identity.
  Missing acknowledgment/disconnect is unknown outcome, not rejection, and never
  triggers automatic replay. Steering does not rewrite emitted output or cancel
  started tools. The offline example covers automatic and required-input paths.

Sources: [steering](https://developers.openai.com/api/docs/guides/steering),
[canonical steering events](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Local entry points: new WS envelopes/connection and existing response lifecycle,
input result DTOs. Deterministic fixtures verify write counts and all seven stubs,
not only event types.

## Opt-in connection recovery

- **RESP-RECOVER-01:** Require an explicit reconnect preparation callback; disabled
  by default. Use the pinned Node helper timing/close policy: recoverable closes
  1001/1005/1006/1011/1012/1013/1015, default five attempts, initial 500 ms
  exponential delay capped at 8,000 ms with [0.75, 1.0] jitter. Clean/protocol/
  policy/unknown closes do not reopen. Refresh credentials per attempt, support callback
  preparation/abort, expose lifecycle, and permit explicit close/cancellation
  during delay or handshake. Failed hooks/handshakes and exhaustion close cleanly.
- **RESP-RECOVER-02:** Queue only newly unsent frames during reconnection in a
  bounded byte queue (default 1 MiB), snapshotting serialized UTF-8 bytes at enqueue.
  Caller mutation cannot change queued bytes or accounting. Unlike Node's
  empty-queue oversized-frame exception, reject an over-budget first frame too, observably. This strict bound
  matches Python and deliberately differs from Node. Already-sent create/steer/
  inject messages never replay. A flush write that is attempted and then fails
  has unknown delivery; do not requeue it (Python behavior). Report only the
  never-attempted remainder as unsent, and expose the attempted-frame failure.
  Define observable overflow and final unsent-message reporting;
  never silently drop frames. Reopening a socket does not restore conversation
  cache or queued steering; caller reconciles history and chooses continuation.
  Deterministic tests assert actual send counts, refreshed auth, ordering,
  byte-boundary behavior, no reconnect after explicit close and exhaustion.

Sources: [Node WS helper](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/ws-base.ts),
[Python recovery types](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/websocket_reconnection.py),
[recovery guide](https://developers.openai.com/api/docs/guides/websocket-mode#reconnect-and-recover).
These are SDK helper semantics, not API admission/replay guarantees. Record any
intentional SDK divergence explicitly at implementation review.

## Multi-agent WebSocket injection

- **RESP-INJECT-01:** Add explicit beta connection opt-in with
  `OpenAI-Beta: responses_multi_agent=v1` on plain `/responses`; the published
  guide uses no `beta=true` query for WS. Keep existing HTTP beta behavior distinct.
  Send existing typed response.inject with response_id and client-owned tool
  output input; never stream_id, whose lane comes from the target response.
  Integrate beta events/agent metadata without claiming Agents API transport.
- **RESP-INJECT-02:** Typed created/failed acknowledgments preserve sequence,
  response ID, optional lane and all existing fields. Failed input is uncommitted
  raw JSON and error metadata survives. Keep reading until response completion
  and every injection acknowledgment, including acknowledgments after terminal
  response. Malformed injection may produce generic 400 and socket close;
  surface both. Application owns tool execution; no automatic replay or tool
  rerun. Test exact opt-in handshake/header precedence and acknowledgment races.

Source: [Responses multi-agent](https://developers.openai.com/api/docs/guides/responses-multi-agent).
The guide explicitly says current SDK WS connectors take the beta header rather
than the HTTP `betas` argument. Existing response.inject/created/failed exports
are the starting point; add faithful envelopes and actual transport wiring.

## Acceptance and completion evidence

Each ticket's fixtures must fail on the current missing field/union behavior.
Use actual public REST/SSE methods with MockClient or local servers; use local
WebSocket servers and injected connectors for connection/protocol behavior.
Local external-service-free servers live in `test/unit/`. Keep new supplied-field
nullability contextual, absent/false/zero/empty distinct, nested copy semantics
complete and equality/hash based on the same fields. Preserve existing const
construction/caller collection ownership unless a documented correction needs
otherwise. Unknown variants follow the package's established preservation policy;
known malformed variants fail explicitly.

Diagnostics do not print tool arguments/content, tokens, secrets, network domain
credentials, steering text or image payloads. New model fields are included in
safe diagnostics, not omitted from value/copy contracts. Verify public exports,
real schema mappings and full toolkit scope; leave unrelated baseline gaps visible.

Default acceptance does not call paid APIs. Existing user authorization permits a
bounded cheap smoke if necessary, with retries disabled and cleanup; root owns
any such execution. No entire integration suite. Each implementation runs relevant
focused fixtures, then format/fix/analyze, package unit tests and toolkit checks.
Two independent reviews verify requirements and engineering standards on the final
combined diff, resolve validated findings and publish evidence before completion.

Each Phase 3 ticket must record its own acceptance evidence before completion.
Completed slices do not establish complete parity for the remaining roadmap.
