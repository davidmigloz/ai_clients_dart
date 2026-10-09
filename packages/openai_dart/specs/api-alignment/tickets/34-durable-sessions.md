# Raw durable sessions and manual event loop

Status: active bounded milestone; implementation acceptance pending.
GitHub: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386).
Primary requirements: `AGENTS-SESSION-01`, `AGENTS-SESSION-02`, `AGENTS-SESSION-03`, `AGENTS-SESSION-04`.
Native GitHub blockers: [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-SESSION-01`, `AGENTS-SESSION-02`, `AGENTS-SESSION-03`, `AGENTS-SESSION-04`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 34.
Dependency: [Ticket 33](33-saved-agents.md) owns `client.agents` and shared saved-agent configuration contracts. This is an implementation namespace dependency. A caller may create a session with inline agent configuration and `environment: none`; no saved-agent, vault or owned-environment creation request is a service prerequisite.

Bounded scope: one of seven active core tickets (#385–#391). Verify the frozen source pins; no automatic upstream adoption or additional issue creation. Existing raw wire/privacy/quality acceptance remains required.

## Problem and user outcome

Applications need a usable durable-session API before SDK orchestration helpers. Deliver JSON or SSE session creation, retrieval/list/update/delete, persistent event observation, and manual event submission. A caller must be able to observe a function call, submit its result, handle current approval requests, cancel execution explicitly, and distinguish accepted input from completed work.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgentSessions` | `GET /agents/sessions` |
| `createAgentSession` | `POST /agents/sessions` |
| `deleteAgentSession` | `DELETE /agents/sessions/{session_id}` |
| `retrieveAgentSession` | `GET /agents/sessions/{session_id}` |
| `updateAgentSession` | `POST /agents/sessions/{session_id}` |
| `listAgentSessionEvents` | `GET /agents/sessions/{session_id}/events` |
| `createAgentSessionEvents` | `POST /agents/sessions/{session_id}/events` |

This ticket owns these 7 operations and their complete request/response/parameter closure of 223 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose the seven operations under `client.agents.sessions` and its events resource, preserving caller transport/auth context and forcing `OpenAI-Beta: agents=v1` after caller headers. JSON creation receives HTTP 201 JSON; streamed creation receives HTTP 201 SSE. Provide an explicit stream path, and reject a conflicting `stream: true` on the JSON path before dispatch. GET events is HTTP 200 SSE and POST events is HTTP 202 with no JSON result body.
- Implement the complete `SessionEvent` union: all 33 known received branches, including root/subagent turn changes, content/item/text/reasoning deltas, command output, session actions/failure, and all eight environment events. Implement all four writable `SessionInputParam` variants and every nested approval/authentication response branch, together with all three received required-action variants. A text-only stream or DTO-only batch is insufficient.
- Keep raw observation persistent across idle/turn boundaries. GET events has no replay cursor or `after` query; do not add a WebSocket endpoint or imply missed events are replayed. SSE closure/cancellation releases local observation resources without cancelling/deleting durable work. Explicit cancel input has no target `turn_id`; DELETE session is a separate lifecycle action, not an execution-cancel convenience.
- Enforce creation's documented saved/inline agent and environment-dependent initial-input requirements. Preserve the saved-agent override replacement semantics and arbitrary JSON function arguments. Input messages use the user role; image inputs have `image_url` without a Responses `detail` field; Agents `output_text` does not invent an annotations property. Session tool request/resource and MCP transport shapes remain distinct from persisted tools.
- Support all environment branches: none, hosted and self-hosted. An existing hosted `environment_id` excludes every present inline/template/container setting, including an explicit-null desktop. Keep inline/template/archive/setup/network shape validation and privacy intact here; owned prewarming is ticket 37. Do not treat self-hosted provider/executor connectivity or compute cleanup as performed by the Dart HTTP client.
- `SessionSpendControlParam.limit` is required and nullable; nonnull whole USD cents range from 1 to 4,503,599,627,370,495. Create omission/null is unlimited; update omission retains the cap, while top-level null or `{limit: null}` removes it without resetting spend. Returned controls require positive nonnull limit and nullable nonnegative consumption; unlimited resources omit `spend_control`, and explicit received null is invalid. Cover the upper bound on VM, browser JavaScript and Wasm.
- Preserve all required nullable error/usage/turn/environment fields and four session statuses. HTTP 202, session idle, stream EOF, turn completion and environment lifetime have different meanings. All seven environment statuses, including suspended and expired, follow canonical OpenAPI when the pinned SDK type is narrower.
- Accept `Idempotency-Key` for POST events with its 1–256 Unicode-character bound; do not apply the prewarming endpoint's 24-hour retention guarantee to event submission. Authentication form-value submissions must disable automatic HTTP/interceptor retries; uncertain delivery requires retrieving current required actions before an application chooses another submission. Never log raw form values, tokens, commands, archives or metadata through default diagnostics.
- List sessions with `limit`, `order`, `after` and `agent_id`; preserve nullable list-boundary IDs. Known malformed event fields fail validation; a finite detached private unknown-received fallback must not be presented as schema-valid canonical input or silently execute work.

## Acceptance criteria

- [ ] A public mock/local-SSE workflow exercises JSON and streamed creation, persistent GET observation, manual message/function-result/approval/authentication/cancel inputs, HTTP 202 empty acceptance, list/retrieve/update/delete, exact headers and no invented replay parameters.
- [ ] Every one of the 33 received event variants, four writable input variants, nested browser response branches and three required-action variants has valid canonical, malformed-known and ownership/privacy coverage; all environment/session states and required-nullable fields are represented.
- [ ] Fresh UTF-8/chunk-boundary, multi-event, error, early EOF, stream abort/caller-owned transport and cancel-versus-delete fixtures verify raw observation behavior; closing the observer sends no backend cancellation request.
- [ ] Spending-control omit/null/value transitions, returned null rejection, exact platform-safe maximum, hosted-ID exclusivity including null inline fields, per-session tool/MCP distinctions and source request limits are covered at public and model boundaries.
- [ ] The low-level browser authentication submission path cannot be automatically retried, including by configured retry interceptors; public mock evidence proves sensitive values stay out of default diagnostics/errors and persisted safe history.
- [ ] A runnable offline raw-session example shows an inline `environment: none` turn, manual function result and explicit cancellation with saved/hosted attachment as optional configuration; README and llms explain persistent observation and HTTP acceptance.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/sessions/events) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Verify these frozen pins and retain actual source/verification receipts at implementation time. New upstream changes are outside this milestone unless they block an included operation; handle those within the existing ticket or bring a scope-changing blocker to the user.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Automatic idle-run observation, local tool execution, result/structured parsing, browser UI/recovery orchestration, owned prewarming, history retrieval and file convenience remain separate tickets. Their future methods add no canonical operation ownership to this slice. No release/version bump is part of this ticket.
