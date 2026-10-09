# Session history, turns and traces

Status: planned; implementation acceptance pending.
GitHub: [#387](https://github.com/davidmigloz/ai_clients_dart/issues/387).
Primary requirements: `AGENTS-HISTORY-01`.
Native GitHub blockers: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-HISTORY-01`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 35.
Dependency: [Ticket 34](34-durable-sessions.md) supplies session handles and shared turn/item contracts. Calls accept already-known session/turn IDs; callers do not need to create a new session or resume a live stream to retrieve history.

## Problem and user outcome

Durable sessions need an inspectable history after or alongside live observation. Deliver root-session items, root turns and turn items, individual turn retrieval, and currently published OTLP traces. This gives applications a supported source of persisted output for inspection and later recovery without implying that historical items are pending tool work.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgentSessionItems` | `GET /agents/sessions/{session_id}/items` |
| `listAgentSessionTurns` | `GET /agents/sessions/{session_id}/turns` |
| `retrieveAgentSessionTurn` | `GET /agents/sessions/{session_id}/turns/{turn_id}` |
| `listAgentSessionTurnItems` | `GET /agents/sessions/{session_id}/turns/{turn_id}/items` |
| `listAgentSessionTraces` | `GET /agents/sessions/{session_id}/traces` |

This ticket owns these 5 operations and their complete request/response/parameter closure of 62 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose these operations through the session items, turns/turn-items and traces resources under `client.agents.sessions`. Preserve caller transport/auth/project context and mandatory `OpenAI-Beta: agents=v1` header precedence.
- Implement the complete 17-branch turn-history item union and nested content/action branches, including function results, MCP/computer/browser authentication history, command output and subagent interaction items. Browser authentication history is a safe returned representation and does not expose submitted form values; do not reuse a secret-bearing request class for it.
- Preserve all required nullable turn timestamps/error/usage and nullable list-boundary IDs. Keep arbitrary JSON function arguments and detached OTLP JSON maps, with immutable deep ownership and finite private received fallback behavior; known malformed discriminated fields still fail.
- Use canonical ID pagination for all four list operations: `limit` 1–100, `order` and exclusive `after`, with the same order/filter context. Root item/turn history includes coordinator interactions with children; each child has a separate history owned by ticket 39.
- Trace IDs are root-turn pagination anchors. Pages contain only traces published at read time, skip unpublished entries, and do not await late updates. The service limits trace reads/JSON to 16 MiB per request; surface actionable service failures without claiming completeness or client-side waiting. OTLP payloads may contain arbitrary private values and must not enter default diagnostics.
- Historical output is inspection state, not proof of a currently pending tool call, authority to execute an old action, or a durable spending ledger. Distinguish turn terminal states from session idle and observer EOF.

## Acceptance criteria

- [ ] Actual public mock GETs cover all five paths, nested session/turn ID placement, mandatory beta headers, ID pagination including empty/null-boundary pages, retrieval errors and trace-page parameters.
- [ ] All history/content/action variants and required-nullable turn fields round-trip with malformed-known and detached deep-ownership/private-diagnostics coverage; authentication history contains no submitted secret values.
- [ ] Offline fixtures show root history distinct from child history, multiple trace pages and arbitrary OTLP payloads; the example states publication/16 MiB limits and neither replays historical tool calls nor waits for late traces.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/tracing) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Recheck freshness and retain actual source/verification receipts at implementation time.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Raw SSE/manual event posting remains ticket 34; child history is ticket 39, current-state recovery is ticket 41, and completed-result collection is ticket 44. No trace-wait or history-replay helper is added here. No release/version bump is part of this ticket.
