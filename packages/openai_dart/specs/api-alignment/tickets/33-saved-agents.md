# Saved agent CRUD and configuration

Status: planned; implementation acceptance pending.
GitHub: [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385).
Primary requirements: `AGENTS-CRUD-01`.
Native GitHub blockers: none.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-CRUD-01`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 33.
Dependency: None. This ticket introduces the namespace and saved configuration contracts. The later session and environment tickets depend on that implementation seam; the service does not require callers to create a saved agent before using inline session configuration or known IDs.

## Problem and user outcome

Applications cannot currently manage reusable Agents through the public Dart client. Deliver a complete saved-agent workflow: create a configured agent, inspect and page saved agents, replace selected configuration, and delete an agent. Introducing the `client.agents` resource also establishes the shared Agents namespace used by later slices.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgents` | `GET /agents` |
| `createAgent` | `POST /agents` |
| `deleteAgent` | `DELETE /agents/{agent_id}` |
| `retrieveAgent` | `GET /agents/{agent_id}` |
| `updateAgent` | `POST /agents/{agent_id}` |

This ticket owns these 5 operations and their complete request/response/parameter closure of 56 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose the five operations through `client.agents`, with the existing client authentication, project/organization context, injected transport and lifecycle. Set `OpenAI-Beta: agents=v1` after caller headers for every method; do not add it globally or silently route through an administrator key. The pinned SDKs use a beta namespace; the Dart family accessor is an explicit design choice.
- Model all six persisted tool request variants and all six persisted tool resource variants, including persisted HTTP/stdio MCP transport. Keep these distinct from per-session tools and Responses tools unless complete wire equivalence is demonstrated. Agents reasoning, text format, multi-agent configuration and service tiers, including `fast`, need their actual contracts.
- Preserve the requested model string. Honor each field's creation defaults and update omission/value/explicit-null semantics. In particular, omitted replacement fields retain state; name/tools/metadata/reasoning can be cleared or reset by their documented null forms. Supplied arrays or maps replace a field rather than merge it.
- Preserve all required resource keys, including nullable name/instructions. Closed known request variants must not serialize raw unsupported properties. Nested tool parameters and supported arbitrary JSON retain their own schema constraints.
- Enforce request-side source limits at constructor/parser/copy and public request boundaries: Unicode character limits, metadata limits, at most 2,000 tools, and the documented 3 MiB compact UTF-8 request tool-list budget. Returned resources follow their separate source limits. Do not replace character counts with UTF-16 code-unit counts.
- List with `limit`, `order`, and `after`; retain required nullable `first_id`/`last_id` on empty pages and carry the same sort/filter context between pages. Encode opaque IDs safely, with any stricter local URL-segment guard documented separately from the canonical path schema.

## Acceptance criteria

- [ ] Public mock requests demonstrate create/list/retrieve/update/delete with exact paths, methods, bodies, query placement, auth context and mandatory beta-header precedence; no administrator routing is introduced.
- [ ] Every persisted tool and MCP transport variant, text/reasoning/service-tier branch, required-nullable field, update clear/reset state, metadata boundary and tool-count/UTF-8 budget boundary has canonical serialization and malformed-input coverage.
- [ ] The offline example completes saved-agent CRUD and pagination; it exercises an actual update clear/reset and a safe deletion result without a paid model run.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/configuration) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Recheck freshness and retain actual source/verification receipts at implementation time.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Raw session creation/events, environment management, automatic tool dispatch, result collection, webhooks, and runtime configuration issue #316 remain in their own slices. No release/version bump is part of this ticket.
