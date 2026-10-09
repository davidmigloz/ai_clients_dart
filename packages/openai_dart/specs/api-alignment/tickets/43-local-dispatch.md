# Opt-in local function dispatch

Status: deferred outside the bounded milestone; not implemented.
GitHub: [#395](https://github.com/davidmigloz/ai_clients_dart/issues/395).
Primary requirements: `AGENTS-HELPER-05`, `AGENTS-HELPER-06`, `AGENTS-HELPER-07`, `AGENTS-HELPER-08`.
Native GitHub blockers: [#394](https://github.com/davidmigloz/ai_clients_dart/issues/394).
Original tracker: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317); removed from its active child list.
Specification: [Agents and Vaults](../agents-vaults.md), AGENTS-HELPER-05–08.
Dependency: [ticket 42](42-idle-run-helper.md), with its raw session dependency.

Deferred backlog: retained for future explicit prioritization; this ticket does not block completion of #317. Its acceptance remains unchecked, and implementation will not start automatically.

## User capability and scope

A caller can register named local function handlers for a streamed creation or
idle follow-up, inspect each original call event, then allow sequential local
execution and explicit result submission. This opt-in helper owns **zero new
HTTP operations**. Wire tool definitions, callback registration and actual local
execution remain separate; unknown names stay available for manual handling.

## Acceptance criteria

- [ ] Handler registration and tool definitions are captured separately. Original call events are yielded before sequential execution, while routing/arguments are detached before yield. Caller mutation cannot reroute the function or change submitted turn_id/call_id.
- [ ] Execution deduplicates (turn_id,call_id) within the handle. Repeated events execute once, the same call ID in another turn remains distinct, and unknown function names produce no automatic result POST.
- [ ] Function callbacks require streamed creation; non-streaming callback use rejects before HTTP. No callback, local observer or parser metadata enters JSON requests.
- [ ] Arguments must parse as a JSON object for local handlers. FutureOr handlers support object-as-JSON-text and supported text/content-array/null outputs using canonical result shapes and captured IDs.
- [ ] Argument, handler and output-serialization failures submit the fixed generic model-visible error “Tool handler failed.” without exception text or private values. Sensitive/cyclic outputs and invalid arguments have deterministic fixtures.
- [ ] An optional local observer receives the real error, stage and session/turn/call/tool identifiers without automatic logging. Await asynchronous observers; observer errors cannot replace the generic model response or prevent its submission. HTTP/API errors remain separate and propagate.
- [ ] Abort during execution or observation submits no false tool-failure result, stops later dispatch/submission and releases timers/streams. Already completed application side effects are not undone; arbitrary application Futures require cooperative cancellation.
- [ ] AGENTS-HELPER-08 has one primary owner here: input and each logical result receive distinct stable keys, case-insensitive caller precedence is respected, and the input key is removed from result headers. A logical result's captured body/key remain identical across retries; the handler is never re-run.
- [ ] The narrow SDK race retry matches only `invalid_request_error` plus the exact `Unknown pending tool call: <captured call_id>` message, with waits of 100/300/600 ms before the three retries. Wrong code/message/call ID and unrelated 400s propagate immediately; fake-clock cancellation releases pending waits. General transport retry policy cannot silently enlarge this four-attempt race loop.
- [ ] Public offline create/follow-up examples, README/llms and exports demonstrate opt-in/manual paths and private diagnostics. VM, actual Chrome JavaScript and Wasm fixtures, appropriate package checks, independent reviews and exact final-head CI pass before user-authorized merge.

## Evidence and validation plan

Behavior is pinned to [Python dispatch](https://github.com/openai/openai-python/blob/c511a77159bc870f31c34388311b7cc62ef15f08/src/openai/lib/streaming/agents/_dispatch.py),
[Node dispatch](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/src/lib/beta/agents/tool-dispatcher.ts)
and the [Node helper guide](https://github.com/openai/openai-node/blob/37af8fc9c78bd5c4d2979c5d51870dd38964e156/docs/agents/helpers.md).
The [planning ledger](../agents-vaults-plan.json) assigns ticket 42 only a shared
input-key reference; it does not double-assign ownership of requirement 08.

Use synthetic errors, controlled Futures, fake clocks and public mock HTTP/SSE:
**no API key, live call or cost**. Planning evidence satisfies no checkbox.
No automatic browser authentication, application sandbox or release is included.
