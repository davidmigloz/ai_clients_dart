# Owned hosted environments and templates

Status: planned; implementation acceptance pending.
GitHub: [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389).
Primary requirements: `AGENTS-ENV-01`, `AGENTS-ENV-02`.
Native GitHub blockers: [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-ENV-01`, `AGENTS-ENV-02`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 37.
Dependency: [Ticket 33](33-saved-agents.md) establishes `client.agents` and its resource plumbing. This is a namespace implementation seam; saved-agent creation is not required by the environment service. Sessions and vault attachment are optional demonstrations using tickets 34/36, not blocking service prerequisites.

## Problem and user outcome

Applications need to manage reusable hosted environment templates and owned prewarmed environments. Deliver owned environment create/list/retrieve plus complete template CRUD/list, with public safe resource views and precise template/inline configuration semantics. A status value alone must not create an unsupported lifecycle action.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgentEnvironments` | `GET /agents/environments` |
| `createAgentEnvironment` | `POST /agents/environments` |
| `retrieveAgentEnvironment` | `GET /agents/environments/{environment_id}` |
| `listAgentEnvironmentTemplates` | `GET /agents/environments/templates` |
| `createAgentEnvironmentTemplate` | `POST /agents/environments/templates` |
| `deleteAgentEnvironmentTemplate` | `DELETE /agents/environments/templates/{environment_template_id}` |
| `retrieveAgentEnvironmentTemplate` | `GET /agents/environments/templates/{environment_template_id}` |
| `updateAgentEnvironmentTemplate` | `POST /agents/environments/templates/{environment_template_id}` |

This ticket owns these 8 operations and their complete request/response/parameter closure of 49 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose owned environment operations through `client.agents.environments` and template operations through its templates resource. Preserve normal caller auth/transport/project context and force `OpenAI-Beta: agents=v1` after caller headers. Prewarming is beta; do not infer account eligibility from method availability.
- Prewarming `CreateEnvironmentParam` permits only hosted configuration and differs from session `EnvironmentParam`: no existing `environment_id` or `container_size`. Prewarming accepts at most ten vault IDs; the session attachment contract has its own limits. Reuse helpers only after proving wire equivalence.
- Support complete packages, desktop, setup commands, network policy, environment maps, capability directories, file-ID/inline files, skill-reference/inline skills and inline plugins. Preserve canonical plain base64/ZIP representations and their size/directory constraints, rather than introducing data URLs or opaque SDK-only raw builders.
- Template configuration is applied before inline session settings, and inline network settings cannot broaden the template policy. Omitted network defaults are owned by the API version; never hardcode enabled/disabled. Preserve source restricted-network/allowed-domain/blocked-domain rules and all optional nullable replacement states, including update network null reset and desktop null disable.
- Setup command bodies, environment values, inline file/archive bytes and stored secrets are confidential request data. Returned environment/template shapes expose safe metadata and do not recover command bodies or secrets. Preserve their actual resource fields instead of reusing a request object or mirroring hidden data back from local caches.
- Canonical environment states are pending/ready/connected/disconnected/suspended/expired/failed. Canonical types override narrower pinned SDK enums. Session, environment, provider and published-artifact lifetimes are independent. This API has no environment suspend/resume/reset/delete operation; do not synthesize those from event or status names.
- `Idempotency-Key` for environment create is optional and 1–256 Unicode characters. Document the 24-hour organization/project/creator scope, same-JSON requirement, current-state return, mismatch/incomplete-create HTTP 409, retained deleted-key behavior and possible fresh creation after retention. This client carries the key and surfaces responses; it does not implement a local 24-hour dedup cache.
- Owned environment/template lists use ID pagination; environment list has its canonical type filter. Preserve nullable boundary IDs, opaque path encoding and documented local URL guards. The public environment resource is distinct from the effective session environment state.

## Acceptance criteria

- [ ] Public mock requests demonstrate all eight operations, source headers/auth context, owned/template paths and filters, safe retrieval/deletion results, ID pagination, idempotency header Unicode bounds and surfaced HTTP 409 behavior.
- [ ] Every hosted file/skill/plugin/network/package/desktop branch, template update omit/null/value state, source array/byte/directory limit, prewarming ten-vault bound and required resource field has canonical malformed-input and copy/ownership coverage.
- [ ] Public and session-environment shape differences, all seven statuses, omission-driven network defaults, confidentiality and absent unsupported lifecycle actions are verified; no locally cached hidden command/archive/secret data is returned.
- [ ] A runnable offline example creates/retrieves a template, prewarms and lists/retrieves an owned environment using a caller-chosen idempotency key; README/llms explain safe views, beta eligibility and independent session/environment lifetimes.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/environments/openai-hosted) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Recheck freshness and retain actual source/verification receipts at implementation time.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Session attachment/exclusivity is ticket 34; live files/artifacts ticket 38; environment notifications ticket 40. Self-hosted providers/executors, hosted live runs, suspension/resume/reset actions and resource-cleanup guarantees are not introduced here. No release/version bump is part of this ticket.
