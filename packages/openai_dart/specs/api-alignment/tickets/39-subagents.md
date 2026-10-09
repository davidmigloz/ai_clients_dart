# Subagent inspection and history

Status: active bounded milestone; implementation acceptance pending.
GitHub: [#391](https://github.com/davidmigloz/ai_clients_dart/issues/391).
Primary requirements: `AGENTS-SUBAGENT-01`.
Native GitHub blockers: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386), [#387](https://github.com/davidmigloz/ai_clients_dart/issues/387).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-SUBAGENT-01`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 39.
Dependency: [Ticket 34](34-durable-sessions.md) supplies session/subagent event contracts and [ticket 35](35-history-traces.md) supplies shared history/turn models and pagination. All methods accept known IDs without requiring a new coordinator turn or a client-side worker process.

Bounded scope: one of seven active core tickets (#385–#391). Verify the frozen source pins; no automatic upstream adoption or additional issue creation. Existing raw wire/privacy/quality acceptance remains required.

## Problem and user outcome

Multi-agent session users need to inspect each child separately from coordinator output. Deliver subagent list/retrieve plus child item, turn and turn-item history. This slice exposes service-owned child state without pretending that inspection creates, executes, resumes or closes subagents.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgentSessionSubagents` | `GET /agents/sessions/{session_id}/subagents` |
| `retrieveAgentSessionSubagent` | `GET /agents/sessions/{session_id}/subagents/{subagent_id}` |
| `listAgentSessionSubagentItems` | `GET /agents/sessions/{session_id}/subagents/{subagent_id}/items` |
| `listAgentSessionSubagentTurns` | `GET /agents/sessions/{session_id}/subagents/{subagent_id}/turns` |
| `retrieveAgentSessionSubagentTurn` | `GET /agents/sessions/{session_id}/subagents/{subagent_id}/turns/{turn_id}` |
| `listAgentSessionSubagentTurnItems` | `GET /agents/sessions/{session_id}/subagents/{subagent_id}/turns/{turn_id}/items` |

This ticket owns these 6 operations and their complete request/response/parameter closure of 63 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose subagent operations under the session subagents resource, including nested child items and turns/turn-items. Keep exact session/subagent/turn path nesting, caller transport/auth/project context and mandatory `OpenAI-Beta: agents=v1` header precedence.
- The subagent list response is an inline canonical list schema; provide a real typed Dart envelope and accurate inline-contract manifest treatment rather than inventing a canonical `SubagentListResource` name.
- Preserve resource `name`, `instructions`, and `closed_at` as required nullable fields and the active/closed status contract. Initial instruction content may include image/audio previews. A closed child can later resume; `opened_at` remains unchanged while resumed `closed_at` becomes null. Describe these as received service state, not client-generated transitions.
- Reuse ticket 35's history/turn implementations only where the complete shape agrees, including all 17 history item branches, turn timestamps/error/usage and nested content/browser-safe-history data. Retain child IDs and hierarchy; root coordinator interactions are not a substitute for child history.
- Every list uses source ID pagination with `limit` 1–100, `order`, exclusive `after` and required nullable first/last boundaries. Safely encode opaque IDs at all nesting levels, documenting any stricter local URI guard separately from canonical path length constraints.
- Inspection does not execute tool calls found in old child history or grant independent worker/provider permissions. Subagent call items/events belong to the raw session event contract; there is no separate child create/resume/interrupt/close HTTP action in this six-operation surface.
- Preserve immutable deep ownership, equality/hash/copy and finite private received fallback behavior for nested children/items/turns. Malformed known fields remain errors and private instructions, content and arbitrary JSON must not enter default diagnostics.

## Acceptance criteria

- [ ] Public mock GETs cover all six operations, exact nested ID paths, headers/auth context, nonempty/empty typed inline subagent list pages and every child history pagination placement.
- [ ] Active/closed/resumed fixtures retain required nullable name/instructions/closed_at and stable opened_at; every reused history branch and turn nullable field has valid/malformed/ownership/private-diagnostic evidence.
- [ ] A runnable offline example inspects a coordinator's child list, retrieves child state and pages its items/turns/turn-items while showing root and child history separately; README/llms avoid invented action endpoints or automatic replay.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/multi-agent) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Verify these frozen pins and retain actual source/verification receipts at implementation time. New upstream changes are outside this milestone unless they block an included operation; handle those within the existing ticket or bring a scope-changing blocker to the user.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Coordinator multi-agent configuration and live events remain tickets 33/34. Local automatic tool dispatch, idle-run/result helpers, child creation/termination orchestration and self-hosted provider processes are separate capabilities. No release/version bump is part of this ticket.
