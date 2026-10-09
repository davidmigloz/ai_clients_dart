# Live environment files and published artifacts

Status: planned; implementation acceptance pending.
GitHub: [#390](https://github.com/davidmigloz/ai_clients_dart/issues/390).
Primary requirements: `AGENTS-FILES-01`.
Native GitHub blockers: [#386](https://github.com/davidmigloz/ai_clients_dart/issues/386), [#389](https://github.com/davidmigloz/ai_clients_dart/issues/389).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-FILES-01`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 38.
Dependency: [Ticket 34](34-durable-sessions.md) supplies session handles and [ticket 37](37-environments-templates.md) supplies environment resources for the complete offline workflow. Existing Files API support is reused for file-ID input. Known session/environment/artifact IDs remain independently callable; staging or creating new service resources is not imposed as a network prerequisite.

## Problem and user outcome

Applications need both mutable live environment files and immutable session artifacts, with the correct download and pagination modes. Deliver live file list/copy and artifact list/retrieve/delete/content download. A complete slice can stage an existing Files API file or inline bytes and retrieve a published completed-turn artifact through public Dart APIs.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listAgentEnvironmentFiles` | `GET /agents/environments/{environment_id}/files` |
| `createAgentEnvironmentFile` | `POST /agents/environments/{environment_id}/files` |
| `listAgentSessionArtifacts` | `GET /agents/sessions/{session_id}/artifacts` |
| `deleteAgentSessionArtifact` | `DELETE /agents/sessions/{session_id}/artifacts/{artifact_id}` |
| `retrieveAgentSessionArtifact` | `GET /agents/sessions/{session_id}/artifacts/{artifact_id}` |
| `retrieveAgentSessionArtifactContent` | `GET /agents/sessions/{session_id}/artifacts/{artifact_id}/content` |

This ticket owns these 6 operations and their complete request/response/parameter closure of 12 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Expose live file operations under `client.agents.environments.files` and artifacts under the session artifacts resource. Preserve caller auth/transport/project context and `OpenAI-Beta: agents=v1` on JSON and download paths.
- Live files require a connected environment and are mutable current workspace contents. Create copies either a Files API file ID or canonical inline bytes to the requested workspace path; retain exact file-input discriminator/base64 constraints and source path semantics. Do not automatically upload local files or choose a local filesystem path in this low-level slice.
- Live file pagination uses opaque `page`, optional nullable `path`/`limit` and `order`; response `object: page`, `next: string|null` and `has_more` are required. Keep path/order/limit consistent between pages and preserve null `next`; do not reuse artifact `last_id` pagination.
- Artifact lists instead use ID-based `limit`/`order`/`after` with nullable `environment_id` filtering and required nullable list-boundary IDs. Preserve immutable artifact IDs, session/environment/turn ownership, original hosted path, size and publication timestamp.
- Artifact content is HTTP 200 `application/octet-stream`, requiring a binary response path that preserves arbitrary bytes and uses download-appropriate Accept headers rather than JSON decoding. Offer portable bytes/stream access consistent with existing download primitives and define local cancellation/transport ownership. Do not expose hosted paths as automatic local destinations.
- Artifacts are outputs already published by completed hosted turns and remain downloadable after environment expiry. Unpublished outputs are not guaranteed to survive cancellation or session deletion. Artifact deletion removes that artifact, while deleting a session or stopping local observation has different semantics.
- Reject malformed known file/artifact fields and invalid inline payloads privately. Preserve deep ownership and immutable comparisons without leaking file bytes, archive contents or sensitive paths/metadata into default errors/diagnostics. Future received fallback data must stay finite and detached.

## Acceptance criteria

- [ ] Actual public mock JSON/download requests cover all six paths, nested IDs, forced beta and download Accept precedence, file-ID/inline-copy bodies, artifact deletes and binary content with null/non-UTF-8/NUL bytes intact.
- [ ] Separate public pagination fixtures prove opaque `page`/required nullable `next` behavior for live files and `after`/nullable environment filter/boundary IDs for artifacts, including empty and multi-page results.
- [ ] File/artifact required fields, branch/byte/path/size limits, malformed known data, deep ownership/equality/copy, private diagnostics and local stream cancellation are covered on supported VM/browser JavaScript/Wasm targets.
- [ ] An offline example stages a file, lists live workspace pages, inspects a completed-turn artifact and downloads exact bytes after a mocked expired environment; README/llms explain publication and lifetime limits.
- [ ] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [ ] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [ ] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/environments/files) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Recheck freshness and retain actual source/verification receipts at implementation time.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Portable Files API upload orchestration, local filesystem safety adapters, output-result artifact matching/download convenience and partial-upload cleanup are ticket 45. No automatic directory synchronization, unpublished-output retention or local destination selection is added here. No release/version bump is part of this ticket.
