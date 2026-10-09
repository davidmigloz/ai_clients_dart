# Vault and write-only credential management

Status: implemented; published-head review, CI and merge acceptance pending.
Acceptance record: [Vaults implementation](../reviews/36-vaults-credentials.md).
GitHub: [#388](https://github.com/davidmigloz/ai_clients_dart/issues/388).
Primary requirements: `AGENTS-VAULT-01`, `AGENTS-VAULT-02`.
Native GitHub blockers: none.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Agents and Vaults](../agents-vaults.md), `AGENTS-VAULT-01`, `AGENTS-VAULT-02`.
Coverage: [operation/schema ownership ledger](../agents-vaults-plan.json), ticket 36.
Dependency: None. Introduce `client.vaults` and `client.vaults.credentials` in the existing Dart resource style. Session/environment attachment can optionally use tickets 34/37 after they merge; the Vaults service accepts management calls independently, and an attachment demo is not a service prerequisite.

Bounded scope: one of seven active core tickets (#385–#391). Verify the frozen source pins; no automatic upstream adoption or additional issue creation. Existing raw wire/privacy/quality acceptance remains required.

## Problem and user outcome

Applications need typed management of Vaults and their credentials without retrieving stored secrets. Deliver complete vault CRUD/list plus credential create/list/retrieve/rotate/delete for MCP OAuth, static bearer and hosted environment-variable authentication. A usable slice demonstrates creation, safe inspection and rotation while keeping secret and returned metadata contracts distinct.

## Exact operation ownership

| Operation ID | HTTP request |
| --- | --- |
| `listVaults` | `GET /vaults` |
| `createVault` | `POST /vaults` |
| `deleteVault` | `DELETE /vaults/{vault_id}` |
| `retrieveVault` | `GET /vaults/{vault_id}` |
| `updateVault` | `POST /vaults/{vault_id}` |
| `listVaultCredentials` | `GET /vaults/{vault_id}/credentials` |
| `createVaultCredential` | `POST /vaults/{vault_id}/credentials` |
| `deleteVaultCredential` | `DELETE /vaults/{vault_id}/credentials/{credential_id}` |
| `retrieveVaultCredential` | `GET /vaults/{vault_id}/credentials/{credential_id}` |
| `rotateVaultCredential` | `POST /vaults/{vault_id}/credentials/{credential_id}` |

This ticket owns these 10 operations and their complete request/response/parameter closure of 47 canonical schema components. The ledger records every component; overlapping closures and primitive/inline/shared helpers mean this count is not a number of new Dart classes. Add real implementation mappings only after the corresponding contracts exist; do not add planned mappings, synthetic schema names, new exclusions or relaxed verifier rules.

## Contract requirements

- Own all ten `/vaults` operations, preserving ordinary caller bearer/auth/project context and forcing `OpenAI-Beta: agents=v1` after caller headers. The official SDKs group Vaults under beta Agents; the separate Dart family accessor is an explicit design choice, not a change to physical API paths.
- Separate create, rotation and returned credential unions. Create supports `mcp_oauth`, `static_bearer` and `environment_variable`; returned auth is safe metadata with no readback fields for tokens/access tokens/client secrets/secret values. Rotation may update the existing authentication method's supported values but cannot change method or destination. Do not invent a validate/read-secret endpoint.
- Preserve OAuth creation's three token-endpoint auth branches (`none`, `client_secret_basic`, `client_secret_post`) and rotation's two client-secret update branches. On OAuth rotation, omitted expiry keeps the old value unless a new access token is supplied; a new token without expiry or explicit-null expiry clears it. Refresh-token/client-secret omission or null keeps stored secrets, while scope omission retains and explicit null clears scope.
- Require at least one of rotation auth or metadata. Rotation/update metadata is optional nonnull: omission retains, `{}` clears, explicit null is invalid. Create vault metadata and update metadata have different size contracts; preserve those distinctions rather than importing one shared 16-pair assumption. Names obey both their source string schema and the documented 1–256 UTF-8-byte bound after trimming.
- Encode list metadata as deep-object query pairs `metadata[key]=value`, with AND matching and eventual-consistency semantics. Encode scalar status as `status` and list status as repeated `status[]`; preserve both active/archived default behavior. Use source ID pagination and nullable empty-page boundaries; do not turn metadata into a JSON string or stringify a map.
- Hosted environment-variable credentials expose placeholders, not the real secret, to sandbox code; substitution applies only to allowed outgoing HTTPS requests on ports 443/8443. They do not authorize local computation, self-hosted execution or functions. The environment's network policy must also permit the destination. Credential networking `unrestricted` specifically requires environment network `access: restricted` and explicit `allowed_domains`; the two policies are separate.
- Environment-variable rotation preserves the secret name and networking configuration. Limited networking allows 1–16 distinct normalized hostname/IPv4 entries, without scheme/path/port/wildcard/IPv6. Preserve source secret-name reserved-name constraints; secret values must be nonempty and exclude CR/LF/NUL. Validate without revealing rejected secrets in constructor/parser/copy/resource exceptions, toString, logs or default metadata diagnostics.
- Returned credential metadata/auth remains deeply detached, comparable and safe even when future received fields appear. Deleting a credential/vault is not provider revocation or cancellation; rotation changes values used by new sessions/environments and does not claim immediate replacement inside an existing sandbox.

## Acceptance criteria

- [x] Public mock requests demonstrate all ten operations, secret-bearing create/rotation bodies, safe returned inspection/delete results, exact beta/auth context, deep-object metadata query encoding, scalar/list status encoding and ID pagination.
- [x] Every create/rotate/returned auth and networking variant, metadata omission/value/null rule, nonempty rotation requirement, OAuth expiry/refresh semantics and name/string/UTF-8/host/secret boundary has canonical and malformed-input coverage.
- [x] Secret sentinel fixtures prove request values are intentionally serializable for transport while safe resources, default diagnostics, validation errors, equality/hash ownership and unknown received data handling do not leak secrets.
- [x] An offline vault/credential example completes create, safe retrieve/list, rotation and deletion; README/llms document write-only secrets, caller-owned consent/revocation and placeholder/new-environment limitations.
- [x] Public request bodies/parameters are captured through the exported client and validated against the pinned canonical contracts; the feature assertions fail against base `08f9594dc73703e521aae4cb070a0be34509642a`, rather than merely mirroring model implementation.
- [x] Constructor/parser/copy tests cover all owned discriminator variants, required-nullable/optional-nonnull/tri-state values, nested ownership, equality/hash with the same fields, safe diagnostics, unknown-received fallback and malformed-known errors.
- [x] A runnable offline example, package README and regenerated llms documentation describe the real public capability and its limits; actual implemented types have honest manifest mappings and unchanged unrelated exclusions/verifier policy.
- [ ] Required formatting/fixes/analysis, affected focused fixtures on VM/browser JavaScript/Wasm, and the package unit suite pass; independent requirements and engineering reviews approve the published final commit, and that exact head has green CI before a user-authorized merge.

## Source and validation evidence

Wire authority is immutable OpenAPI [`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json), normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`. Cross-check workflow/header behavior against the [official guide](https://developers.openai.com/api/docs/guides/agents-api/tools/vaults) and pinned [Python 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08) / [Node 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156) clients, resolving source discrepancies as recorded in the specification. Verify these frozen pins and retain actual source/verification receipts at implementation time. New upstream changes are outside this milestone unless they block an included operation; handle those within the existing ticket or bring a scope-changing blocker to the user.

All tests and examples default to deterministic mock HTTP/SSE, local servers or pure fixtures, with no live API calls, API key or paid hosted execution required ($0). Schema-only planning witnesses do not satisfy runtime acceptance. The implementation PR must record actual canonical assertions, supported-platform checks, independent review and retained toolkit diagnostics; this planning ticket claims none of those checks have already passed for a future implementation.

Session/environment resource attachment is owned by tickets 34/37. Hosted execution, provider OAuth consent flows, provider token revocation, browser authentication UI and runtime configuration issue #316 remain outside this slice. No release/version bump is part of this ticket.
