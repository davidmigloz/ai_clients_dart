# Webhooks and safety: Phase 4 specification

Status: independently reviewed specification; implementation pending.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Scope: four independently demonstrable implementation tickets, repository 20–23.
Planning changes do not implement these capabilities.

## Outcome and boundaries

A trusted receiver verifies the original webhook body before parsing, recognizes
source-backed notifications and acknowledges promptly. Applications can manage
project endpoints, explicitly retrieve project safety alerts or organization
cases, and inspect structured monitoring errors without losing their original
HTTP/response context. Applications own persistence, deduplication, investigation,
tool execution and any later continuation.

The user selected complete parity, modern APIs/fixes first, repository documents
plus GitHub issues and targeted breaking corrections with migration guidance.
Phase 3 is complete: [PR #356](https://github.com/davidmigloz/ai_clients_dart/pull/356)
merged October 8, 2026 at `1e63d6b93bdf0028eb6925d45371b1f36deb5d7b`, closing #344.
The first Phase 4 capability combines event models and verification so its
example is a usable signed receiver. Endpoint management is independently useful.
Safety examples then build on verified notifications and detail retrieval.

Full Agents/Live runtimes, organization administration, media error alignment,
delivery scheduling and workflow automation remain in their recorded phases.
Their small incoming notification payloads are included here. No monitoring
request setting, generic resume/unblock method or automatic tool runner is
invented. Existing moderation and safety-identifier settings are separate.

## Sources and authority

Audited October 8, 2026 against:

- [OpenAPI main 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json).
- [Python b9bc5c14 / 3.26.0](https://github.com/openai/openai-python/tree/b9bc5c141d395165939eccfcfe42d1ed8219ec6a),
  including [webhooks](https://github.com/openai/openai-python/blob/b9bc5c141d395165939eccfcfe42d1ed8219ec6a/src/openai/resources/webhooks/webhooks.py),
  [verification helper](https://github.com/openai/openai-python/blob/b9bc5c141d395165939eccfcfe42d1ed8219ec6a/src/openai/lib/_webhooks.py)
  and [event union](https://github.com/openai/openai-python/blob/b9bc5c141d395165939eccfcfe42d1ed8219ec6a/src/openai/types/webhooks/unwrap_webhook_event.py).
- [Node 3edaf0f3 / 7.30.0](https://github.com/openai/openai-node/tree/3edaf0f3c3f9a366b6993773d231002fa59c3b4d),
  including [webhooks](https://github.com/openai/openai-node/blob/3edaf0f3c3f9a366b6993773d231002fa59c3b4d/src/resources/webhooks/webhooks.ts)
  and [verification helper](https://github.com/openai/openai-node/blob/3edaf0f3c3f9a366b6993773d231002fa59c3b4d/src/lib/webhook-signature.ts).
- [Changelog](https://developers.openai.com/api/docs/changelog),
  [Webhooks guide](https://developers.openai.com/api/docs/guides/webhooks),
  [Webhooks reference](https://developers.openai.com/api/reference/resources/webhooks),
  [Misalignment monitoring](https://developers.openai.com/api/docs/guides/safety-checks/misalignment-monitoring),
  [Safety enforcement](https://developers.openai.com/api/docs/guides/safety-enforcement),
  [Alerts reference](https://developers.openai.com/api/reference/resources/safety/subresources/alerts)
  and [Cases reference](https://developers.openai.com/api/reference/resources/safety/subresources/cases).

Canonical remains reviewed 3c4759c1 (356 operations/2,009 schemas). Fresh candidate
and independently fetched pinned JSON agree. All component schemas, inbound
webhooks and Phase 4 paths are unchanged. Five Agents/Vault list operations have
pagination parameter changes: `/agents`, `/agents/sessions`,
`/agents/sessions/{session_id}/artifacts`, `/vaults` and
`/vaults/{vault_id}/credentials`. These remain Phase 6 inventory. Toolkit review
reports no changes because its comparison misses this parameter delta; independent
parameter-identity comparison establishes it. No candidate promotion or fetch-only
metadata churn is retained in this documentation-only plan.

Canonical schemas govern wire shapes. Guides establish workflow/permission
boundaries. SDK-only local verification conventions are named explicitly below;
Python/Node decoder/timestamp quirks are not silently inherited. Recheck affected
sources before each implementation and publish any revised decision in its evidence.

## Ticket graph

| Repository ticket | Demonstrable capability | Requirements | Prerequisite |
| --- | --- | --- | --- |
| [20](tickets/20-webhook-receiver.md) | Verify and parse signed notifications locally | WH-VERIFY-01–03, WH-EVENT-01–03 | None |
| [21](tickets/21-webhook-endpoints.md) | Manage project endpoints and discover event types | WH-ENDPOINT-01–04 | None; shares the eventual webhooks namespace |
| [22](tickets/22-safety-retrieval.md) | Retrieve safety details from a verified notice | SAFETY-READ-01–03 | 20 for the signed-notice example |
| [23](tickets/23-monitoring-errors.md) | Inspect monitoring failures across HTTP/Responses | SAFETY-ERROR-01–04 | 22 for the investigation example |

Dependencies describe usable examples, not an invented coupling between HTTP
models and the verifier. Implement in the listed order; each ticket gets its own
PR, example, README/llms update, evidence and independent reviews. No release or
version bump is part of alignment.

## Signed receiver

- **WH-VERIFY-01:** Provide standalone `WebhookVerifier` and local
  `client.webhooks.verifySignature`/`unwrap` wrappers, including bytes counterparts.
  No HTTP request, API-key requirement, auth-provider call, socket/client-lifetime
  guard or automatic logging is involved. An optional configured webhook secret
  (including `OPENAI_WEBHOOK_SECRET`) and explicit override follow SDK precedence;
  an explicit empty override fails rather than falling back. Declare the selected
  pure-Dart cryptography dependency directly. Browser verification is compatibility
  evidence; signing secrets belong on trusted infrastructure.
- **WH-VERIFY-02:** Authenticate original bytes using HMAC-SHA256 over
  UTF-8 `webhook-id + '.' + original webhook-timestamp + '.'` followed by the body.
  String methods encode their untouched text once. Bytes methods do not decode,
  trim or reserialize before verification. Unwrap verifies first, then strictly
  decodes UTF-8/JSON and dispatches. A valid signature may cover arbitrary non-JSON
  or invalid UTF-8 bytes; verify-only accepts those, while unwrap reports a safe
  parse error. A bad signature plus bad JSON reports verification failure first.
- **WH-VERIFY-03:** Apply the documented deterministic policy below, with external
  golden signatures, injected test time and VM/real Chrome JavaScript/Wasm fixtures.
  A dedicated signature exception implements `Exception` outside the existing
  sealed `OpenAIException` hierarchy. Configuration errors expose no secret value;
  verification/parse diagnostics contain reason/context, never body/header values,
  signing secrets, digests or sensitive decoder causes.

### Explicit Dart verification policy

The three required headers are case-insensitive `webhook-id`, `webhook-timestamp`
and `webhook-signature`. Require exactly one nonempty value for each after name
normalization; reject ambiguous case-duplicate keys. Preserve the original ID and
timestamp spelling. IDs have no invented syntax restriction; dots are allowed.
Timestamp text contains ASCII decimal digits only, leading zeros allowed, in
0..2^53−1 for VM/JS/Wasm consistency. Reject signs, whitespace, numeric suffixes,
fractional syntax and unsafe integers. Default tolerance is five minutes,
nonnegative finite `Duration`, with inclusive past/future bounds around UTC integer
current seconds. Compare timestamp distance in microseconds without rounding a
fractional tolerance; zero is permitted. Tests control time without a public bypass.

A `whsec_` secret decodes its suffix as canonical padded standard Base64. A secret
without that prefix is the literal UTF-8 key: raw `x` equals `whsec_eA==`, whereas
bare `eA==` is four literal key bytes. Empty/malformed secrets fail safely. For
prefixed secrets and signatures, require standard alphabet, correct padding and
re-encode-equal canonical text; reject URL-safe alphabet, missing padding, internal
whitespace, noncanonical pad bits and garbage. This deliberately avoids differing
platform decoder tolerance.

Scan ASCII-whitespace-separated signature candidates. Accept `v1,<Base64>` and
bare Base64 for common SDK compatibility; ignore unknown tagged versions and
malformed candidates while trying others. Valid candidates decode to 32 bytes.
Compute the body HMAC once regardless of candidate count; compare all 32 bytes
without shared-prefix early exit. Accept matches in any rotation slot, including
beyond 32 candidates, without a list-sized whole-body work multiplier. This is a
fixed-work comparison contract, not a claim that every runtime/input path has
identical timing. No rotation key store or delivery-ID persistence is added.

These choices differ intentionally from Python empty-key acceptance/int parsing,
Node numeric-prefix timestamp parsing/empty-ID behavior, their whitespace splits,
permissive Base64 decoders and Node's WebCrypto batching threshold. The shared
ordinary dashboard-secret/v1 protocol and official golden vectors remain compatible.

## Received events

- **WH-EVENT-01:** Dispatch a new sealed `WebhookEvent` hierarchy with all 26 real
  components below and `UnknownWebhookEvent` for future discriminators. All known
  events require string id, integer created_at, fixed type and data object. Agent
  and safety envelopes additionally require fixed object:`event`; the other 17
  allow omission but reject a wrong/null supplied object. Preserve its absence
  during round trips rather than synthesizing it. Timestamps gain no invented
  positivity/range constraint from signature-header policy.
- **WH-EVENT-02:** Model every declared payload field and nested requiredness,
  preserving ordered/repeated SIP headers, open environment/media-security strings,
  Agent action summaries and the deprecated Live alias. Validate known malformed
  variants contextually; preserve unknown finite received metadata deeply and
  immutably. This response-only extension is distinct from admission to canonically
  closed payloads. Unsigned `WebhookEvent.fromJson` parsing never claims verification.
- **WH-EVENT-03:** Keep subscription choices distinct from received events. Unknown
  video and Python-only legacy safety notifications retain raw JSON. Examples
  acknowledge with 200 promptly after verification and hand investigation/deduplication
  to explicit application callbacks; no automatic GET, call acceptance, agent/tool
  execution or workflow replay. Delivery event id and data.id have distinct roles.

| Type | Real component | Payload |
| --- | --- | --- |
| `agent.session.action_required` | WebhookAgentSessionActionRequired | id, required_action |
| `agent.session.created` | WebhookAgentSessionCreated | id, environment_type; optional environment_id/connect |
| `agent.session.failed` | WebhookAgentSessionFailed | id, environment_type; optional environment_id |
| `agent.session.idle` | WebhookAgentSessionIdle | same environment summary |
| `agent.session.in_progress` | WebhookAgentSessionInProgress | same environment summary |
| `batch.cancelled` | WebhookBatchCancelled | id |
| `batch.completed` | WebhookBatchCompleted | id |
| `batch.expired` | WebhookBatchExpired | id |
| `batch.failed` | WebhookBatchFailed | id |
| `eval.run.canceled` | WebhookEvalRunCanceled | id |
| `eval.run.failed` | WebhookEvalRunFailed | id |
| `eval.run.succeeded` | WebhookEvalRunSucceeded | id |
| `fine_tuning.job.cancelled` | WebhookFineTuningJobCancelled | id |
| `fine_tuning.job.failed` | WebhookFineTuningJobFailed | id |
| `fine_tuning.job.succeeded` | WebhookFineTuningJobSucceeded | id |
| `live.call.incoming` | WebhookLiveCallIncoming | session_id, sip_headers; optional sip_media_security |
| `live.transport.incoming` | WebhookLiveTransportIncoming | type:`sip`, session_id, sip_headers; optional sip_media_security |
| `realtime.call.incoming` | WebhookRealtimeCallIncoming | call_id, sip_headers; optional sip_media_security |
| `response.cancelled` | WebhookResponseCancelled | id |
| `response.completed` | WebhookResponseCompleted | id |
| `response.failed` | WebhookResponseFailed | id |
| `response.incomplete` | WebhookResponseIncomplete | id |
| `safety.alert.created` | WebhookSafetyAlertCreated | alert id |
| `safety.deactivation_issued` | WebhookSafetyDeactivationIssued | case id |
| `safety.org_alert.created` | WebhookSafetyOrgAlertCreated | workspace alert id |
| `safety.warning_issued` | WebhookSafetyWarningIssued | case id |

Agent `connect.remote_url` is required when connect is present. Required action
has required type, one of computer_use_approval_request, function_call or
environment_connection. Environment type is open text. SIP header name/value are
required strings; media security is optional nonnull open text (known rtp/srtp),
and neither it nor event arrival proves signaling protection or media flow.
Current Live session_id and Realtime call_id remain separate, unchanged values.
Safety alert IDs match exactly `alert_` plus 32 lowercase hexadecimal characters;
case IDs have no invented pattern. Validate anchored tokens without accepting
terminal newline/CR. All inline helpers use extension mappings with schema:null;
actual Agent payload/envelope components get real mappings.

### Source discrepancies and delivery scope

ProjectEventTypeEnum has 23 writable choices: four batch, four response, three
eval, three fine-tuning, realtime.call.incoming, two video, five Agent session and
safety.alert.created. Only 21 have current inbound schemas. Video events have no
source-backed typed payload yet; use unknown raw events. Live variants and three
organization/workspace safety variants are received types but are not project
subscription choices. Event-type discovery returns open strings and does not
change writable canonical admission. Python's separate safety_identifier.blocked
class is absent from its unwrap union, Node and canonical; preserve it as unknown
and retain the discrepancy in the parity inventory.

The guide permits 2xx acknowledgments, exponential retry for up to 72 hours,
possible duplicates and no redirect following. Some older webhook delivery
responses say 200/non-200; safety operation descriptions also identify 410 as a
stop signal. The example returns 200; document general guide behavior and the
safety-specific 410 condition without building a delivery scheduler.

## Project endpoint management

- **WH-ENDPOINT-01:** Add existing authenticated project-resource methods under
  `client.webhooks`, using ResourceBase/RequestBuilder/interceptors, encoded path
  IDs, auth/abort/closed-client behavior and existing conservative retry policy.
  No beta header or new authentication stack. Cover all eight operations below.
- **WH-ENDPOINT-02:** Preserve distinct request/response models and exact
  nullable/optional fields below. Validate only declared writable constraints;
  permit empty updates and omitted rotation body/options. Update event_types
  replaces the complete set. Returned strings remain open, independently of the
  23-choice writable enum. Manual pagination uses returned cursors, not inferred IDs.
- **WH-ENDPOINT-03:** Return required signing_secret only from create/rotate DTOs,
  redacted in model/exception diagnostics and built-in enabled response-body logging.
  Apply narrow structural JSON signing_secret redaction before truncation; actual
  response body/toJson and caller access remain unchanged. Include short, ordinary
  and raw-looking secrets in FINEST logger fixtures. No unrelated logging rewrite.
- **WH-ENDPOINT-04:** Document rotation default false (old key immediately invalid),
  explicit true (24-hour overlap), and no implicit local secret update. A test
  result's fixed success:true means the test request completed; status_code reports
  the receiver response and may be 4xx/5xx. Endpoint test sends a real delivery;
  all acceptance tests/examples use MockClient rather than live receivers.

| Method/path | Real operation | Request/result |
| --- | --- | --- |
| GET /webhook_endpoints | ListWebhookEndpoints | limit/after; WebhookEndpointListResource |
| POST /webhook_endpoints | CreateWebhookEndpoint | PublicCreateEndpointBody; WebhookEndpointWithSecretResource |
| GET /webhook_endpoints/{webhook_endpoint_id} | RetrieveWebhookEndpoint | WebhookEndpointBody |
| POST /webhook_endpoints/{webhook_endpoint_id} | UpdateWebhookEndpoint | PublicUpdateEndpointBody; WebhookEndpointBody |
| DELETE /webhook_endpoints/{webhook_endpoint_id} | DeleteWebhookEndpoint | DeletedWebhookEndpointResource |
| POST /webhook_endpoints/{webhook_endpoint_id}/rotate_secret | RotateWebhookEndpointSigningSecret | optional PublicRotateSecretBody; WebhookEndpointWithSecretResource |
| POST /webhook_endpoints/{webhook_endpoint_id}/test | TestWebhookEndpoint | PublicTestEndpointBody; WebhookEndpointTestResultResource |
| GET /webhook_event_types | ListWebhookEventTypes | unpaginated WebhookEventTypeListResource |

Create requires name (1–256), URL (HTTPS prefix, maximum 2,048), and at least one
project enum event. Update allows any subset including `{}`; supplied fields are
nonnull and retain the same constraints. Rotate has optional nonnull
keep_old_secret_active_for_24_hours; explicit false remains present. Test requires
one enum event_type. List has optional limit 1–100 (server default 20), optional
nullable after (null omitted on the URL); no invented order/before filter.

Endpoint responses require id, object:`webhook_endpoint`, created_at, name, url,
event_types:List<String> and nullable signing_secret_hint. updated_at is optional
nonnull; it changes on configuration/secret changes, not tests/unchanged updates.
With-secret responses additionally require signing_secret. Endpoint list requires
object:`list`, data, nullable first_id/last_id and has_more. Deleted response
requires id, object:`webhook_endpoint.deleted`, deleted:bool. Test result requires
object:`webhook_endpoint.test`, webhook_endpoint_id, event_type:String,
status_code:int and success:true. Event-type list requires object:`list` and
List<String> data. Missing required-nullable values must not collapse into defaults.

## Safety detail retrieval

- **SAFETY-READ-01:** Add `client.safety.alerts.retrieve(id)` for GET
  /safety/alerts/{id}, project-authorized key with api.safety.alerts.read. Add
  `client.safety.cases.retrieve(id)` for GET /safety/cases/{id}, same-organization
  restricted key with api.safety.read. Use existing auth/abort/retry/status/request-ID
  handling and encoded path segments. ID maxima are 38 and 128 respectively;
  canonical declares no minimum/prefix grammar. No lists, pagination, request bodies
  or enforcement-changing methods exist here.
- **SAFETY-READ-02:** Model SafetyAlertResource, SafetyAlertErrorType,
  SafetyCaseResource, SafetyCaseNotice and SafetyCaseNoticeType. Every listed field
  below is required, including nullable reason; missing reason fails canonically
  instead of silently inheriting Python's omission default. Unknown received closed
  enum strings may survive via an explicit known/raw value policy; never normalize
  unknown to other/warning. This is a receive-only compatibility extension.
- **SAFETY-READ-03:** The example verifies a project-alert or organization-case
  notification, explicitly retrieves data.id with a correctly scoped MockClient
  and redacts reason/entity identifiers. Workspace org_alert uses a distinct host
  and administrative permission; do not automatically send a project key there.
  No parser auto-fetch, inferred enforcement action, assumed stopped execution or
  automatic investigation/continuation is added.

Alert fields: id, object:`safety.alert`, created_at:int, request_id, response_id,
model, request_paused:bool, error_type, reason:String|null. Error types are
potentially_unintended_data_transfer, potentially_unintended_data_access,
potentially_unintended_destructive_activity, other. request_paused means block
registration succeeded; it does not prove execution stopped or prior effects
were undone. Do not default it. Case fields: id, object:`safety.case`, created_at,
entity_identifier, reason:String|null, notice with required type warning/deactivation.
The entity identifier is the application's safety identifier, distinct from either ID.

Canonical's [workspace notification description](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json#L33625)
explicitly names https://api.chatgpt.com/v1/safety/alerts/{id}, an administrator key
for the workspace's backing organization and chatgpt.enterprise.safety_alerts.read.
Phase 4 types this notification and documents that distinct lookup boundary;
workspace administration/authentication/response-shape integration remains in
Phase 7's complete-parity inventory. No silent cross-host credential routing or
claim that project alert retrieval covers enterprise workspace responses.

## Structured monitoring errors

- **SAFETY-ERROR-01:** Expose shared typed misalignment details on HTTP ApiException
  (including PermissionDeniedException and pre-stream error paths) and failed
  ResponseError. Reuse/extract existing GA/beta ResponsesMisalignmentDetails/Steer
  with compatible public names/imports/const construction and metadata semantics,
  rather than parallel divergent WS types. HTTP optional malformed detail extraction
  is best effort: preserve original exception class/status/code/requestId/raw body
  and retry classification instead of masking them with a parser error.
- **SAFETY-ERROR-02:** Details have optional nonnull detailed_explanation/error_type,
  optional nullable review_target and optional nonnull steer. error_type is an open
  string, not a closed alert enum. Nonnull review_target is 1–96 ASCII characters
  from A–Z/a–z/0–9/._~:-, with no terminal newline acceptance; preserve absent/null.
  Steer requires message. Unknown nested metadata, deep ownership and exact
  copy/clear/replacement behavior survive. Replacing children must not resurrect
  old effective parent metadata. Diagnostics redact explanations, review tokens,
  steer messages, raw bodies and sensitive identifiers.
- **SAFETY-ERROR-03:** Correct flat Responses SSE ErrorEvent wire output: fixed
  type:`error`, required nullable code/param, required message and sequence_number;
  beta agent is optional nullable. Preserve documented legacy nested input and
  missing-sequence construction compatibly, with explicit presence state rather
  than invented defaults. Known canonical malformed fields fail contextually.
  Nullable code requires targeted migration guidance. No declared SSE misalignment,
  headers or nested error field is invented; future supplied metadata may survive
  opaquely. Failed ResponseError keeps its distinct code/message/misalignment shape
  and documented legacy type/param/nullable-code tolerance without false claims of
  exact canonical admission. HTTP Error's nullable code/param remain distinct.
- **SAFETY-ERROR-04:** Public fixtures cover HTTP 403 before stream, flat error after
  output, response.failed after output and WS structured block metadata. Preserve
  SDK-owned failures/retry boundaries; a policy block must not trigger automatic
  reconnect, replay, tool execution, safety acknowledgment or general continuation.
  This feature does not disable existing opt-in transport recovery for unrelated
  failures/lanes or close a multiplexed socket merely because one response is blocked.
  Guides describe investigation, not a generic resume API. Preserve opaque steer/
  review_target values passively. The offline investigation example combines typed
  errors with explicit alert/case retrieval and reports presence/classification only.

Canonical HTTP Error requires type,message,nullable code/param and optional
misalignment. Failed ResponseError requires code/message and optional misalignment;
it declares no type,param,headers. Flat SSE ResponseErrorEvent declares no typed
misalignment. Existing WS ErrorPayload has optional headers and misalignment and
remains a regression boundary. The similarly named Error-2 headers/misalignment
belongs only to VideoResource; video/shared-stream logging/error fidelity remains
in later media/utility inventory. Agents/Live error envelopes and Admin retention
controls remain distinct; none establish a monitoring request parameter.

## Verification and completion

Every implementation must prove real public behavior with deterministic
MockClient/local-server/injected-connector fixtures under test/unit. No API key,
live webhook test delivery or paid safety action is required. A future optional
live smoke needs the existing bounded-cost authorization and explicit scope;
never run an entire integration suite.

New/changed models require contextual variant, requiredness, null/absence, finite
JSON, unknown-value/raw extension, round-trip, immutable parsed ownership,
complete copy/clear and equality/hash contracts, plus redacted diagnostics for
all old/new fields. New sealed hierarchies and any changed existing signatures
need migration where applicable. Do not add a webhook exception to the existing
sealed hierarchy merely for catch-all convenience.

Register actual components/operations, and schema:null extensions only for real
inline/SDK helpers. Run appropriate focused/browser fixtures, format → fix →
fatal-info analysis → full package unit suite and full toolkit scope. Classify
unrelated diagnostic sets explicitly; no exclusions or fake mappings. Update
README/llms, runnable offline example and per-ticket evidence. Independent
requirements and engineering reviews approve the final combined diff after
validated findings are resolved. Open PRs with the exact create-pr template and
close implementation issues only after merge. This plan's source/link/graph
validation is separate from future runtime acceptance.
