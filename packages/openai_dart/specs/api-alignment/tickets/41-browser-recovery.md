# Browser approvals and current-state recovery

Status: deferred outside the bounded milestone; not implemented.
GitHub: [#393](https://github.com/davidmigloz/ai_clients_dart/issues/393).
Primary requirements: `AGENTS-FLOW-01`, `AGENTS-FLOW-02`.
Native GitHub blockers: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386), [#387](https://github.com/davidmigloz/ai_clients_dart/issues/387), [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389).
Original tracker: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317); removed from its active child list.
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-FLOW-01–02.
Dependencies: [ticket 34](34-durable-sessions.md), [ticket 35](35-history-traces.md) and [ticket 37](37-environments-templates.md).

Deferred backlog: retained for future explicit prioritization; this ticket does not block completion of #317. Its acceptance remains unchecked, and implementation will not start automatically.

## User capability and scope

A caller can recover a durable session after losing its observation stream,
present the service's **current** browser actions to a person, submit an explicit
approval or private authentication response, and observe the resulting state.
This owns **zero new HTTP operations**. Ticket 34 owns the canonical raw input,
received-event and required-action types; this ticket makes their complete
workflow public, documented and demonstrable through offline examples and any
small local adapters justified by that workflow.

Recovery opens a fresh SSE observation and buffers updates before retrieving the
current session and saved items. Reconcile buffered updates with restored final
items by ID, then expose current required actions. SSE has no replay cursor:
never automatically resend an earlier user task, approval or authentication.

## Acceptance criteria

- [ ] A controlled public HTTP/SSE example proves subscribe/buffer → retrieve current session and saved history → reconcile by ID. Stream loss, duplicates and updates arriving during retrieval neither replay inputs nor omit current required actions.
- [ ] All three browser-origin wire decisions (`approve`/`deny`/`cancel`, meaning allow/deny/dismiss) and authentication submit/cancel have branch fixtures and preserve their distinct canonical shapes, current request/field IDs and absence of an invented turn_id. Old action IDs are never silently reused after recovery.
- [ ] Origin approval is explained separately from environment network policy and per-action confirmation; neither response broadens network permissions or grants a standing approval for unrelated actions.
- [ ] Authentication form values travel only through the dedicated typed input. They never enter model messages, saved history, ordinary logs, error strings or diagnostic snapshots; explicit caller access remains possible where required.
- [ ] Automatic HTTP/SDK retries are disabled for authentication submission, including otherwise retryable transport/status failures. Uncertain delivery triggers a current-state refresh and explicit caller decision rather than replay.
- [ ] An empty HTTP 202 response means accepted only. The example awaits observed current state and distinguishes idle/in_progress/requires_action/failed session states from turn completion and pending/ready/connected/disconnected/suspended/expired/failed environment states.
- [ ] Close/break/abort releases observation and buffers without implicitly submitting cancellation or deleting the session. Explicit backend cancellation remains the raw event operation; self-hosted compute shutdown remains application-owned.
- [ ] Known invalid fields/values fail before submission, including authentication field bounds and unions from the pinned schemas; privacy, immutable capture and copy/equality semantics use the existing raw models rather than duplicate variants.
- [ ] Offline browser and interruption/recovery examples plus README/llms explain service/session/environment/artifact lifetimes and caller ownership. Public mock fixtures run on VM, actual Chrome JavaScript and Wasm; appropriate package checks, independent reviews and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Wire authority is [OpenAPI `0ef225c4`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json).
Workflow evidence is the official [session events guide](https://developers.openai.com/api/docs/guides/agents-api/sessions/events)
and [computer-use guide](https://developers.openai.com/api/docs/guides/agents-api/tools/computer-use).
The [pinned Python authentication-submit contract](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/types/beta/agent_browser_authentication_submit_param.py)
provides an additional SDK cross-check; canonical fields remain authoritative.

Use synthetic values and a controlled mock server: **no API key, live call or
cost**. Planning evidence satisfies no checkbox. No executor/provider SDK,
automatic replay, credential retrieval or release/version bump is included.
