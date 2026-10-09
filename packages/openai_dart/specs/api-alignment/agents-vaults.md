# Agents and Vaults: Phase 6 specification

Status: **bounded milestone; seven core tickets plus one evaluation active; acceptance pending**. Parent:
[#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
The preceding 32 implementation tickets are closed after
[PR #384](https://github.com/davidmigloz/ai_clients_dart/pull/384) merged at
`08f9594dc73703e521aae4cb070a0be34509642a`. That completion does not establish
complete API/SDK parity. The current milestone closes after its seven active core tickets and the separately approved HTTP/2 evaluation are accepted.

Active API scope: seven core HTTP capabilities, repository tickets 33–39 / issues #385–#391. Six workflow/helper capabilities (tickets 40–45 / issues #392–#397) are retained as deferred backlog. The
[machine-readable plan](agents-vaults-plan.json) is the exhaustive operation,
component and primary requirement ownership ledger. All new ticket acceptance
criteria remain unchecked. This specification implements no public Dart API,
adds no runtime manifest mapping and makes no live API request.

## Outcome and boundaries

Applications manage saved agents, create and inspect durable sessions, consume
raw event streams, submit explicit messages/tool results/cancellation/approval
responses, inspect turn/subagent history and traces, provision hosted environments,
manage write-only credentials, and download published artifacts. These seven core HTTP slices define the API implementation finish line; the separately authorized HTTP/2 evaluation adds one report, not another API implementation. Lifecycle webhooks, recovery examples and optional run/dispatch/result/file helpers are deferred; their audited requirements remain below for future explicit prioritization.

On October 9, the user accepted a bounded finish line, superseding the original complete-parity execution target. Freeze the audited OpenAPI/Python/Node pins below, implement only the seven core HTTP tickets, then stop this alignment milestone after the separately approved [HTTP/2 evaluation](http2-evaluation.md) ([#399](https://github.com/davidmigloz/ai_clients_dart/issues/399) ([ticket 46](tickets/46-http2-evaluation.md))) has an accepted adopt/defer report. This adds one finite evaluation, not a production migration. Repository documents plus GitHub issues and targeted breaking corrections with migration guidance remain agreed policies.

Parent #317 can close when #385–#391 meet their existing implementation/review/CI acceptance and the one HTTP/2 evaluation has reviewed, reproducible evidence and a final adopt/defer decision. A defer outcome satisfies the evaluation. The six deferred workflow/helper issues stay open in the backlog without native membership in this tracker. Administration/storage, authentication/legacy, runtime configuration [#316](https://github.com/davidmigloz/ai_clients_dart/issues/316) and remaining shared SDK/model gaps are also deferred; they are not completion prerequisites.

No new alignment issues or milestones are created without an explicit user request. Resolve blockers or regressions affecting these 47 operations within the existing seven tickets. Report a scope-changing blocker for a user decision. Verify fixed source bytes and contracts rather than adopting new upstream heads automatically. Finishing this milestone establishes its stated capabilities, not complete API/SDK parity.

Durable Agents are distinct from Responses, Live and Realtime. A durable session,
a selected turn, the application's local observation and an environment have
separate lifetimes. Closing observation does not cancel backend work. Explicit
input cancellation differs from session deletion. Applications own approval,
secret acquisition, provider consent/revocation, external executor compute,
callback side effects and optional cleanup. No helper grants permissions or
establishes a platform entitlement.

## Sources and authority

Audited October 9, 2026 at `2026-10-09T12:36:45.060428+00:00` against fresh heads:

- [OpenAPI 0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
  358 operations and 2,039 components across the complete API. The fetched candidate
  equals the adopted canonical JSON byte for byte; immutable raw source equals its
  parsed semantics. Canonical JSON SHA256 is
  `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
- [Python c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08),
  including [Agents resources](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/resources/beta/agents)
  and [streaming helpers](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/streaming/agents).
- [Node 37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156),
  including [Agents resources](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/resources/beta/agents),
  [helpers](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents)
  and [helper guidance](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/docs/agents/helpers.md).
- Official [changelog](https://developers.openai.com/api/docs/changelog),
  [overview](https://developers.openai.com/api/docs/guides/agents-api/overview),
  [configuration](https://developers.openai.com/api/docs/guides/agents-api/configuration),
  [sessions](https://developers.openai.com/api/docs/guides/agents-api/sessions),
  [events](https://developers.openai.com/api/docs/guides/agents-api/sessions/events),
  [computer use](https://developers.openai.com/api/docs/guides/agents-api/tools/computer-use),
  [Vaults](https://developers.openai.com/api/docs/guides/agents-api/tools/vaults),
  [hosted environments](https://developers.openai.com/api/docs/guides/agents-api/environments/openai-hosted),
  [self-hosted environments](https://developers.openai.com/api/docs/guides/agents-api/environments/self-hosted),
  [lifecycle](https://developers.openai.com/api/docs/guides/agents-api/environments/lifecycle),
  [environment files](https://developers.openai.com/api/docs/guides/agents-api/environments/files),
  [security](https://developers.openai.com/api/docs/guides/agents-api/environments/security)
  and [tracing](https://developers.openai.com/api/docs/guides/agents-api/tracing).

Immutable OpenAPI establishes fields, paths, response media types, discriminators
and requiredness. Descriptions and guides establish workflow constraints. Pinned
SDK implementation establishes helper behavior; language-specific behavior is
identified separately below. Each active implementation ticket verifies these fixed
sources. New upstream releases do not change milestone acceptance automatically.
This planning work preserves the adopted source and its actual fetch metadata.

## Public Dart design decisions

Use `client.agents` for saved agents and nested session/environment resources,
and `client.vaults` with nested credentials for Vaults. This is an idiomatic Dart
namespace choice consistent with existing client family accessors. The official
clients use `client.beta.agents` and `client.beta.agents.vaults`; that namespace does
not alter the physical `/agents` and `/vaults` paths. This phase introduces no
second general-purpose beta namespace or alias hierarchy. Public model names use
Agents/Vault domain prefixes where necessary to avoid global/Flutter collisions.
Precise method signatures are reviewed in their implementation tickets.

Every relevant resource adds `OpenAI-Beta: agents=v1` using the existing mandatory
beta-header builder after caller headers. This **forced per-resource precedence
is a Dart choice**: pinned SDKs default the header and permit caller overrides.
Streaming requests also preserve the required SSE Accept header. Other resource
families do not receive the Agents beta header. All 47 operations inherit ordinary
bearer API-key authentication and caller organization/project context; no operation
requires silently substituting an administrator credential.

Portable models, byte streams and helpers remain importable on VM, JavaScript
and Wasm. Any `dart:io` selected-file adapter is exposed separately. Existing
transport configuration and caller-provided clients remain reusable; Phase 6
introduces no mutable shared-client reconfiguration requirement.

## Ticket graph and complete HTTP ownership

| Repository ticket | Independently demonstrable capability | Primary requirements | Prerequisite | Scope |
| --- | --- | --- | --- | --- |
| [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385) ([33](tickets/33-saved-agents.md)) | Saved agent create/list/retrieve/update/delete with complete configuration | AGENTS-CRUD-01 | None | Active |
| [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386) ([34](tickets/34-durable-sessions.md)) | JSON/SSE session creation and raw manual durable event loop | AGENTS-SESSION-01–04 | 33 for namespace/shared configuration | Active |
| [#387](https://github.com/davidmigloz/ai_clients_dart/issues/387) ([35](tickets/35-history-traces.md)) | Session/turn history and currently published OTLP traces | AGENTS-HISTORY-01 | 34 | Active |
| [#388](https://github.com/davidmigloz/ai_clients_dart/issues/388) ([36](tickets/36-vaults-credentials.md)) | Vault CRUD and secret create/rotate with safe returned metadata | AGENTS-VAULT-01–02 | None | Active |
| [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389) ([37](tickets/37-environments-templates.md)) | Owned hosted environment provisioning and template CRUD | AGENTS-ENV-01–02 | 33 for namespace/shared configuration | Active |
| [#390](https://github.com/davidmigloz/ai_clients_dart/issues/390) ([38](tickets/38-files-artifacts.md)) | Mutable live files and immutable published artifact bytes | AGENTS-FILES-01 | 34, 37 | Active |
| [#391](https://github.com/davidmigloz/ai_clients_dart/issues/391) ([39](tickets/39-subagents.md)) | Session-scoped subagent items, turns and turn items | AGENTS-SUBAGENT-01 | 34, 35 | Active |
| [#392](https://github.com/davidmigloz/ai_clients_dart/issues/392) ([40](tickets/40-environment-webhooks.md)) | Typed environment lifecycle notifications and endpoint subscriptions | AGENTS-WEBHOOK-01 | 37; existing merged webhook receiver/management | Deferred |
| [#393](https://github.com/davidmigloz/ai_clients_dart/issues/393) ([41](tickets/41-browser-recovery.md)) | Explicit browser actions and recovery from current session/history | AGENTS-FLOW-01–02 | 34, 35, 37 | Deferred |
| [#394](https://github.com/davidmigloz/ai_clients_dart/issues/394) ([42](tickets/42-idle-run-helper.md)) | Optional single-use idle-session run observation | AGENTS-HELPER-01–04 | 34 | Deferred |
| [#395](https://github.com/davidmigloz/ai_clients_dart/issues/395) ([43](tickets/43-local-dispatch.md)) | Opt-in local function dispatch and stable result submission | AGENTS-HELPER-05–08 | 42 | Deferred |
| [#396](https://github.com/davidmigloz/ai_clients_dart/issues/396) ([44](tickets/44-result-parser.md)) | Completed-result collection and local structured parsing | AGENTS-HELPER-09–12 | 42, 43 | Deferred |
| [#397](https://github.com/davidmigloz/ai_clients_dart/issues/397) ([45](tickets/45-file-helpers.md)) | Portable selected-file staging and exact artifact lookup; optional IO adapter | AGENTS-FILE-HELPER-01–03 | 38, 44 | Deferred |

Dependencies describe shared implementation and complete demonstrations. The
service accepts inline agent configuration and environment `none`; a session
caller need not first create a saved agent, vault or owned environment. Known IDs
remain usable directly. Vault management has no artificial session prerequisite.

| HTTP owner | Canonical operation IDs | Operations | Standalone transitive components |
| --- | --- | ---: | ---: |
| 33 | listAgents, createAgent, deleteAgent, retrieveAgent, updateAgent | 5 | 56 |
| 34 | listAgentSessions, createAgentSession, deleteAgentSession, retrieveAgentSession, updateAgentSession, listAgentSessionEvents, createAgentSessionEvents | 7 | 223 |
| 35 | listAgentSessionItems, listAgentSessionTurns, retrieveAgentSessionTurn, listAgentSessionTurnItems, listAgentSessionTraces | 5 | 62 |
| 36 | listVaults, createVault, deleteVault, retrieveVault, updateVault, listVaultCredentials, createVaultCredential, deleteVaultCredential, retrieveVaultCredential, rotateVaultCredential | 10 | 47 |
| 37 | listAgentEnvironments, createAgentEnvironment, retrieveAgentEnvironment, listAgentEnvironmentTemplates, createAgentEnvironmentTemplate, deleteAgentEnvironmentTemplate, retrieveAgentEnvironmentTemplate, updateAgentEnvironmentTemplate | 8 | 49 |
| 38 | listAgentEnvironmentFiles, createAgentEnvironmentFile, listAgentSessionArtifacts, deleteAgentSessionArtifact, retrieveAgentSessionArtifact, retrieveAgentSessionArtifactContent | 6 | 12 |
| 39 | listAgentSessionSubagents, retrieveAgentSessionSubagent, listAgentSessionSubagentItems, listAgentSessionSubagentTurns, retrieveAgentSessionSubagentTurn, listAgentSessionSubagentTurnItems | 6 | 63 |

These groups partition **37 Agents operations across 24 paths plus 10 Vault
operations across four paths: 47 operations and 28 paths**. Agents reaches 277
transitive schema components and Vaults 47; the union is 321, with three shared
error/order components. These are source component counts, **not 321 new Dart
classes**. Primitive aliases, unions and reusable shapes need honest concrete
implementation mappings. Component closures deliberately overlap between slices;
operation and primary requirement ownership do not. Tickets 40–45 introduce no
new canonical HTTP operation.

## Shared wire, ownership and privacy rules

Requests serialize exact closed known shapes. Legitimate nested arbitrary JSON
(function parameters/arguments, metadata and OTLP content) retains deep ownership
and its own constraints. The component union contains 236 explicitly closed object
roots and 45 discriminated unions; an open nested map does not make every outer
variant arbitrary. Do not adapt Responses DTOs by similar names without checking
wire equivalence. Persisted-agent, per-session configuration and effective returned
tool schemas differ, as do MCP transport, service tier and reasoning contracts.

Required nullable keys remain present. Optional nullable changes support omission,
value and explicit null; optional nonnull values reject explicit null. Deeply nested
collections, maps, bytes and callback/option captures are detached where exposed
immutability requires it. Equality and hashing use the same fields, including
presence; copy operations retain unchanged presence and own supplied mutable
values. Secret-bearing objects have private printable diagnostics even when their
explicit typed properties or request `toJson` necessarily expose data to the caller.

Known malformed discriminator variants fail parsing. Forward-compatible received
fallbacks, if supported by established package policy, retain finite detached raw
JSON privately; they do not excuse malformed known fields or establish canonical
schema validity for unknown discriminators. Retained received extras follow that
same policy. `OutputTextResource` has **no canonical annotations field**; helpers
must not manufacture a typed Responses-style annotations member.

ID pagination uses limit 1–100/default 20, order asc/desc and `after`, plus each
operation's actual filters. Required list first/last IDs may be null. Live file
pagination instead uses opaque `page`, nullable path/limit and required nullable
`next`. Vault metadata query filtering is deepObject/explode (`metadata[key]=value`)
with AND matches and eventual consistency. Status serializes its permitted scalar
or array as `status` or `status[]`; it cannot be encoded as JSON/map text.

Path IDs have source bounds of 0–1,048,576 Unicode characters. Preserve opaque
segment encoding; do not introduce an invented prefix or reuse Safety ID limits.
Any stricter empty/dot URI-segment guard is a documented local transport safeguard.
Body references have different limits, including agent/template IDs up to 64 and
existing environment IDs 9–256. Validate each source contract separately.

Default errors, logging, `toString` and descriptions must not reveal access tokens,
client secrets, environment secret values, browser authentication values, archive
bytes, confidential setup commands or arbitrary caller metadata. Tests use synthetic
values and assert sanitized public diagnostics without pretending request serializers
can omit fields required for an explicitly authorized transmission.

## Saved agents and raw sessions

- **AGENTS-CRUD-01:** Implement all five saved-agent operations, complete request,
  update and returned shapes, text/reasoning/multi-agent configuration and all six
  persisted tool variants with their own persisted MCP transports. Update omission
  retains fields; explicit null clears fields where source descriptions permit it.
  Open model strings retain the requested value. The complete CRUD closure is 56
  components, rather than the 52 reachable from creation alone.
- **AGENTS-SESSION-01:** Implement seven raw session/event operations with complete
  inline/saved-agent override configuration, environment branches and state. JSON
  creation returns 201; streaming creation returns 201 SSE. A JSON method rejects
  `stream:true` before sending or exposes a separately explicit streaming method.
  GET events returns 200 SSE and remains a persistent observation across idle.
  POST events returns empty 202 accepted-only. It proves neither turn selection nor
  completion. DELETE session is distinct from explicit input cancellation.
- **AGENTS-SESSION-02:** Parse all 33 received `SessionEvent` branches, 14 output-item
  branches, four writable input variants and three required-action choices. Include
  manual function results, browser responses, environment connection actions and
  explicit cancellation in the public offline workflow. Agents function arguments
  may be arbitrary JSON; input message role is user-only, input images have
  `image_url` without Responses `detail`, and output text has no annotations field.
  Session states are idle/in_progress/requires_action/failed; required nullable
  error/usage/event fields retain null rather than invented defaults.
- **AGENTS-SESSION-03:** Implement source spend-control presence and separate request
  and response shapes. Request `limit` is required nullable; nonnull whole USD cents
  range from 1 through **4,503,599,627,370,495**. Create omission/null is unlimited;
  update omission retains, while top-level null or `{limit:null}` removes the cap
  without resetting recorded spend. Returned capped sessions require positive limit
  and nullable nonnegative best-effort consumed cents, floored; unlimited sessions
  omit `spend_control`, and explicit returned null is invalid. Preserve the maximum
  exactly on VM/JavaScript/Wasm. This is a session cap, separate from organization
  spending limits and usage tiers.
- **AGENTS-SESSION-04:** Preserve explicit observation/backend ownership, required
  beta/SSE headers, errors and event-submission idempotency. POST events admits an
  optional 1–256 Unicode-character `Idempotency-Key`. It supports retrying the same
  submission without adopting environment creation's different retention promise.
  Closing or aborting SSE sends no cancel/delete request. There is no canonical
  Agents WebSocket route or event replay/after cursor. Browser authentication
  submission disables automatic HTTP/SDK retries; uncertain delivery requires a
  current-state refresh. The cancellation input has no `turn_id` field.

Ticket 34 is a complete raw public workflow, not a DTO-only/text-only subset.
Helpers introduced later must use these codecs and methods rather than duplicate
or narrow them.

## History, subagents and traces

- **AGENTS-HISTORY-01:** Implement the five root item/turn/trace operations, all 17
  turn-history item branches, list cursors and complete turn status/timestamp/error/
  usage presence. Retain completed history independently from local stream buffers.
  Trace pages expose currently published OTLP JSON, skip unpublished traces and do
  not wait for later publication. Respect the documented 16 MiB per-request read/
  JSON limit; do not claim complete traces or infer pending calls from old outputs.
- **AGENTS-SUBAGENT-01:** Implement the six session/subagent-scoped inspection
  operations with complete returned subagent and history models. The list response
  is an inline canonical envelope; do not invent a schema component name to make a
  manifest entry. Preserve required nullable closed_at/name/instructions and turn
  identifiers. Child events and terminal states do not select or finish a root run.

## Hosted environments, templates, files and notifications

- **AGENTS-ENV-01:** Implement three owned-environment operations and all five
  template operations. Session environment admits none/openai_hosted/self_hosted;
  owned prewarming admits only openai_hosted. Prewarm has no environment_id or
  container_size, and vault_ids has maximum 10; session configuration is a distinct
  contract. Existing hosted environment_id is exclusive with any present inline,
  template or container option, including explicit-null desktop. Template settings
  apply before inline overrides; overrides cannot broaden its network policy.
  Omitted network defaults belong to the API version and are not hardcoded locally.
- **AGENTS-ENV-02:** Implement seven received lifecycle states and eight session
  environment events, including suspended/expired/reset, preserving required
  nullable turn_id. Provisioning's optional Idempotency-Key is 1–256 Unicode chars:
  24-hour deduplication is scoped to organization/project/creator and the same JSON,
  returns the original environment's current state, gives 409 for mismatched params
  or incomplete creation, and does not recreate a deleted retained environment.
  Hosted setup commands/archives/secrets remain write-only; returned views contain
  safe metadata. Inline ZIP data uses the source's base64/archive shapes, not an
  invented Responses data URL. Suspended can resume from a private checkpoint;
  expired cannot. No suspend/resume/reset/delete environment HTTP route is invented.
- **AGENTS-FILES-01:** Implement two live file and four published artifact operations,
  including raw binary content download with octet-stream headers. Live files are
  mutable and require a connected environment. Published artifacts are immutable
  output copies from completed hosted turns, downloadable after expiry. Preserve
  the different file-page and artifact-ID cursors, actual filters and legacy nullable
  fields. Never promise persistence of unpublished output or decode bytes as JSON.
- **AGENTS-WEBHOOK-01:** Add typed agent.environment.ready/failed/suspended/expired
  notifications and endpoint subscription choices. Reuse the merged signed receiver
  and endpoint management, preserving unknown-event/privacy behavior. These envelopes
  use webhook id/object/type/created_at/data, distinct from SessionEvent SSE. Existing
  five agent.session notifications are already typed. These additions own zero of
  the 47 new HTTP operations and grant no lifecycle control action.

Self-hosted session configuration is typed here; executor process/proxy/filesystem
and provider compute lifecycle stay application-owned. The application API key stays
outside the executor; any connection-only environment key follows service scope.
Deleting a session does not terminate provider compute. An example must describe
ownership without adding an unverified Dart executor daemon or transport endpoint.

## Vaults and credentials

- **AGENTS-VAULT-01:** Implement five Vault operations plus credential create/list/
  retrieve/rotate/delete, all canonical paging/filter/status and metadata contracts.
  Create auth admits mcp_oauth/static_bearer/environment_variable. Create, rotate and
  returned auth have distinct schemas: tokens/client_secret/secret_value are write-only,
  safe returned auth metadata contains no secret, and no secret-readback or credential
  validation route is invented. Rotation cannot change auth method or destination;
  auth or metadata must be supplied. Rotation metadata is nonnull and `{}` clears it.
  OAuth new-access-token expiry omission and explicit null follow the described clearing
  behavior. Omitted/null refresh tokens and client secrets retain the stored secret;
  scope omission retains it and scope null clears it. Create token-endpoint auth has none/client_secret_basic/client_secret_post;
  rotation's client-secret updates permit only the latter two.
- **AGENTS-VAULT-02:** Implement credential networking unrestricted/limited; limited
  needs 1–16 distinct normalized hostnames/IPv4 addresses without scheme/path/port/
  wildcard/IPv6. Environment policy must also permit a requested host. Credential networking
  `unrestricted` specifically requires environment network `access: restricted`
  with explicit `allowed_domains`; it does not mean unrestricted environment access.
  Environment-variable rotation preserves its secret name and networking. Environment
  secret value is nonempty and forbids CR/LF/NUL. Document environment-variable
  placeholder substitution only for permitted hosted HTTPS requests (ports 443/8443),
  not arbitrary local execution, self-hosted environments or function callbacks.
  Rotation affects a new sandbox/session. Provider consent/revocation is application-
  owned; Vault deletion neither revokes provider tokens nor cancels ongoing work.

## Browser actions and current-state recovery (deferred backlog)

These requirements are retained as audited backlog and do not block this milestone. Raw manual action/approval inputs and their privacy/no-retry rules remain active in ticket 34.

- **AGENTS-FLOW-01:** Demonstrate all current browser-origin decisions: wire `approve` (allow),
  `deny`, and `cancel` (dismiss), separately from
  authentication submit/cancel and per-action confirmation. Origin approval is
  distinct from configured network policy. Responses target current request and
  field IDs using their distinct input shapes, without an invented turn_id. Keep
  authentication field values out of prompts, saved history and default diagnostics;
  submit only through the dedicated event input with automatic retries disabled.
  HTTP 202 indicates acceptance. Refresh the current required actions after uncertain
  delivery; never replay credentials or stale approvals automatically.
- **AGENTS-FLOW-02:** Demonstrate recovery by opening a new observation and buffering
  events before reading current session/history, restoring final saved items by ID,
  then reconciling buffered updates. There is no event replay cursor. Restore only
  current required_actions and the observed session state; do not resubmit old tasks,
  tool calls or approvals. Preserve environment/artifact/session lifetimes and make
  duplicate rendering/side-effect ownership explicit. A dropped observer does not
  establish that the server turn failed or was cancelled.

Ticket 41 builds runnable examples and any explicitly bounded workflow conveniences
on already-public raw operations. Its acceptance must show request/recovery behavior;
prose alone does not close it. Full browser automation, UI, password manager and
self-hosted compute management remain application responsibilities.

## Optional run and function-dispatch helpers (deferred backlog)

These requirements are retained as audited backlog and do not block this milestone. Raw manual action/approval inputs and their privacy/no-retry rules remain active in ticket 34.

Pinned behavior comes from Python
[follow-up observation](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/streaming/agents/_streams.py)
and [dispatch](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/streaming/agents/_dispatch.py),
and Node
[session observation](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/agents/agent-session-stream.ts),
[turn selection](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/agents/turn-state.ts)
and [dispatch](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/tool-dispatcher.ts).

- **AGENTS-HELPER-01:** Keep raw persistent SSE distinct from an idle-only follow-up
  convenience. Raw input can steer active work; the convenience requires an idle
  session and one application input writer because input POST returns no selected
  turn ID. This is a helper/application constraint, not a server-enforced lock.
- **AGENTS-HELPER-02:** A lazy single-use handle captures input/options and performs
  no request until start/iteration. Retrieve an idle session, await the new SSE
  subscription's readiness, then POST normalized input; close observation if POST
  fails. Nonempty string input becomes one user input_text message; empty rejection
  is helper-only. Deeply immutable input/options capture is a **Dart design choice**;
  upstream Node does not deep-clone every supplied input array.
- **AGENTS-HELPER-03:** Select the first coordinator/root turn.created with
  subagent_id null; preserve original events and bounded recent event-ID deduplication
  (1,024 IDs in the SDKs). Initial idle and child terminals cannot finish observation.
  Stop after the selected turn completes/fails/cancels and the session becomes idle,
  or on session.failed. Unexpected EOF is observation failure, not success. The guide
  sample's terminal-only boundary and the raw persistent observer are distinct modes.
- **AGENTS-HELPER-04:** Closing/breaking/aborting the handle releases local HTTP/SSE,
  timers and temporary buffers, with abort cause where exposed. It never implicitly
  cancels/deletes backend work or invents a replay cursor. Callback side effects that
  already happened cannot be undone, and arbitrary application Futures require
  cooperative cancellation rather than a promise of forced interruption.
- **AGENTS-HELPER-05:** Snapshot opt-in handlers separately from wire tool definitions.
  Execute registered calls sequentially after yielding their original event, with
  detached routing IDs/arguments captured before yield. Deduplicate execution by
  `(turn_id,call_id)` for the handle; unknown names remain manual. Creation callbacks
  require streaming and reject incompatible JSON mode before HTTP. Callbacks never
  appear in request JSON.
- **AGENTS-HELPER-06:** Parse dispatcher arguments as a JSON object for FutureOr local
  handlers, even though the raw canonical argument field permits arbitrary JSON.
  Object results serialize as JSON text; supported text/content-array/null outputs
  preserve captured turn/call IDs. Argument, handler and output-serialization failure
  submit the fixed generic `Tool handler failed.` message without exception text.
- **AGENTS-HELPER-07:** An optional awaited local error observer sees real error, stage
  and tool/session/turn/call IDs without automatic logging. Observer failure cannot
  replace the generic model-visible failure or prevent its submission. API/transport
  errors remain separate; local abort is never converted into a model-visible failure.
- **AGENTS-HELPER-08:** Input and each logical tool result receive distinct stable
  idempotency keys with case-insensitive header precedence. Strip the input key from
  tool-result POSTs; retries reuse the result key and exact body. The optional SDK race
  retry is limited to `invalid_request_error` plus exact
  `Unknown pending tool call: <captured call_id>`, at 100/300/600 ms. Never invoke the
  handler again; unrelated 400/code/message/call failures propagate, and abort releases
  retry timers. **Primary owner: ticket 43**; ticket 42 references its input-key policy
  only, without duplicating complete acceptance ownership.

## Completed results and structured parsing (deferred backlog)

These requirements are retained as audited backlog and do not block this milestone. Raw manual action/approval inputs and their privacy/no-retry rules remain active in ticket 34.

Pinned behavior comes from Python
[result](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_result.py)
and [output adapters](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_output.py),
and Node
[collection](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/result-collection.ts),
[collector](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/agent-turn-result-collector.ts)
and [parser](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/parse-result.ts).

- **AGENTS-HELPER-09:** Collection is opt-in before events advance; a final-result
  getter may enable collection on an unused handle and drain the same iterator/tools.
  Default observation retains no result messages; late enable rejects. Repeated
  successful retrieval reuses the immutable result without HTTP/handler/parser reruns,
  and temporary collector buffers are released. No result HTTP endpoint is invented.
  Node memoizes a rejected finalResult promise; Python may re-run a failed parser.
  The Dart ticket must declare and test its failed-getter caching policy explicitly
  rather than claim those clients have identical failure semantics.
- **AGENTS-HELPER-10:** Collect detached completed assistant item.done snapshots only
  for the selected root turn. Exclude partial/commentary/child output, admit completed
  legacy null-phase messages, deduplicate item IDs and order by output_index. Preserve
  complete source-supported snapshots and legitimate received extras under the codec
  policy. Do not add a typed annotations field absent from OutputTextResource. A pure
  raw-message text projection joins blocks in content order; it differs from selecting
  final-answer messages. A completed text-free raw result remains valid.
- **AGENTS-HELPER-11:** Successful final result requires selected completed turn plus
  idle. Failure/cancellation/unhandled function-browser-environment required action/
  incomplete observation produce typed local outcomes retaining detached partial turn,
  messages/actions and cause. An unhandled required action fails promptly instead of
  hanging. Printable diagnostics stay generic; explicit partial properties serve the
  caller. An observation error must not assert backend failure or poison an already
  established completed boundary with an unrelated later transport failure.
- **AGENTS-HELPER-12:** Bind a caller-supplied canonical JSON schema plus local parser/
  validator at creation. Existing-session follow-up binds only local parsing, without
  mutating server configuration. Validate every final output_text block and select the
  first parsed value only after all succeed. Missing text or any parse failure gives
  a generic parse error retaining the completed raw result. Reject conflicting bindings
  before HTTP; parser/callback metadata never enters wire JSON. Use Dart adapters,
  rather than importing Pydantic/Zod runtimes or inferring unsupported schema behavior.

## Portable file and artifact helpers (deferred backlog)

These requirements are retained as audited backlog and do not block this milestone. Raw manual action/approval inputs and their privacy/no-retry rules remain active in ticket 34.

Pinned behavior comes from Python
[files](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_files.py)
and [artifacts](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/beta/agents/_artifacts.py),
and Node
[files](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/files.ts),
[result artifacts](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/result-artifacts.ts)
and [filesystem adapter](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/helpers/beta/agents/filesystem.ts).

- **AGENTS-FILE-HELPER-01:** Portable caller-selected byte/stream staging uses existing
  Files upload with purpose=user_data, mapping IDs to explicit /workspace destinations.
  Separate local filesystem selection. Preflight invalid destinations before requests;
  on partial failure/abort expose observed successful upload IDs for caller cleanup.
  No automatic deletion or directory synchronization is implied.
- **AGENTS-FILE-HELPER-02:** Locate result artifacts by exact session, selected turn and
  hosted path across all pages; zero/multiple matches fail. Preserve opaque last_id;
  legacy null IDs do not prevent cursor advancement, but repeated/nonadvancing cursors
  fail. Download raw bytes to a portable stream/sink and close on sink errors. A hosted
  artifact path never silently selects a local destination.
- **AGENTS-FILE-HELPER-03:** An optional VM IO adapter uses explicit selected files and
  destinations, regular-file identity/symlink/replacement checks and a documented
  stable application-owned directory assumption. It is not a filesystem sandbox.
  Node overwrites verified regular destinations and Python delegates file streaming;
  the Dart ticket chooses and tests an explicit overwrite policy rather than asserting
  a shared upstream policy. Browser/Wasm entrypoints must not import dart:io.

## Recorded discrepancies and retained scope

Canonical spend_control and suspended/expired environment states are newer than the
pinned SDK type shapes; canonical fields/states win. Raw SSE, a guide terminal-only
consumer and an idle-helper terminal-plus-idle boundary remain separate. Prewarming
beta routes do not prove account entitlement. Forced beta-header precedence and
immutable captures are declared Dart choices. Failed-parser memoization and local
file overwrite differ between upstream clients and require explicit Dart decisions.
Received fallback policy does not turn unknown closed variants into source-valid JSON.

This phase does not add a WebSocket Agents endpoint, replay cursor, automatic task/
approval replay, provider token revocation, secret readback, environment lifecycle
HTTP actions, general browser automation or self-hosted executor runtime. Those
behaviors are not invented from similarly named states, helper files or guides.
Any later verified SDK-only executor convenience remains separately inventoried
rather than silently included in the 47 HTTP-operation completion claim.

## Verification, examples and acceptance

Each active ticket demonstrates its public capability with deterministic MockClient/local
HTTP/SSE fixtures and a runnable **offline example**, updates package README and
`llms.txt` where its public surface is introduced, and records independent review.
Public serialization fixtures use the actual request/resource methods and canonical
closed/required/nullable/union constraints, not handcrafted examples that bypass
runtime serialization. New variants require all-branch construction, round-trip,
error and equality/hash ownership coverage, including deep-copy mutation tests.
Real manifest entries are added only for implemented types with accurate source
component names; existing exclusions and verifier rules cannot hide pending work.

Transport fixtures exercise media/header precedence, every pagination mode, JSON/
SSE/binary responses, chunk boundaries, explicit HTTP errors, malformed known events,
unknown received fallbacks, subscription readiness and disposal. Deferred helper acceptance, if explicitly resumed later, uses
controlled streams and fake time to prove selected-root boundaries, 1,024-ID eviction,
exactly-once callback invocation, retry body/key stability, observer privacy, partial
outcomes and parser execution. File fixtures prove binary fidelity, exact artifact
matching, cursor progress, selected-file isolation and cleanup ownership.

Portable contract/value/public workflow checks run on VM, real Chrome JavaScript
and Wasm where supported by the existing package workflow. Optional IO-helper checks belong to deferred ticket 45 if explicitly resumed. Format, automatic fixes and clean static analysis run in repository
order. Exact published-head CI and independent requirement/engineering approval are
recorded before any implementation is declared accepted or merged. A docs-only
planning PR does not claim those future runtime checks have passed.

The planning audit has 31 successful **schema-only planning witnesses**, including
spend null/presence/maximum, environment reference exclusivity, prewarm Vault bounds,
rotation metadata, cancellation and Agents image/argument shapes. These establish
source interpretation, not Dart runtime acceptance. The planning API cost is **$0**.
Default future checks/examples stay offline; no hosted session, environment, browser
or provider operation is run solely to satisfy this plan. Any separately selected
live smoke uses the user's cost-bounded authorization and records actual scope/cost.

Acceptance remains pending:

- [ ] All 47 canonical HTTP operations are mapped to implemented public methods and actual source-contract tests.
- [ ] All 12 active primary requirements have ticket acceptance evidence; 18 deferred requirements do not count toward milestone completion.
- [ ] All seven core workflows have executable offline demonstrations; raw browser approval/auth inputs remain covered without requiring deferred orchestration helpers.
- [ ] Every introduced public API has an example, README guidance, correct manifest/export entries and migration notes for any breaking correction.
- [ ] All affected platform checks, independent reviews and final-head CI pass; implementation issues are closed only by their accepted PRs.
- [ ] Parent #317 closes when the seven core tickets and the one HTTP/2 evaluation are accepted, with deferred work recorded and no complete API/SDK parity or automatic transport migration claim.
