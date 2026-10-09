# Vaults and write-only credentials acceptance

Status: implementation for [#388](https://github.com/davidmigloz/ai_clients_dart/issues/388),
[ticket 36](../tickets/36-vaults-credentials.md). All local checks, independent published-head reviews and exact-head CI passed; merged in PR #403.

## Frozen contract and delivered scope

Wire authority is immutable OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Workflow evidence uses the [official Vaults guide](https://developers.openai.com/api/docs/guides/agents-api/tools/vaults),
pinned Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
Independent source review verifies all 10 operations, 47 component fingerprints
and 21 actual SDK source blobs. Canonical/adoption bytes stay unchanged.

`client.vaults` supplies create/list/retrieve/update/delete;
`client.vaults.credentials` supplies create/list/retrieve/rotate/delete.
The complete closure adds 44 actual source contracts and reuses three merged
error/order contracts. This milestone adds no secret-readback/validation endpoint,
hosted execution, OAuth consent/revocation workflow, issue, dependency or release.

## Contracts and privacy

Create, rotation and returned auth remain distinct unions. Creation supports
OAuth, static bearer and hosted environment-variable secrets; OAuth token-endpoint
auth has none/basic/post branches, while rotation permits basic/post client-secret
updates. Rotation cannot change method/destination/secret-name/networking.
Outer rotation requires auth or metadata; `{metadata: {}}` is valid. Omission
retains metadata and JSON null is invalid for optional-nonnull update fields.
Vault creation instead permits nullable metadata with 1,024/256/1,048,576 pair/
key/value limits; updates/credential bodies/filters use 16/64/512. Returned maps
retain their separate unbounded shapes and empty keys.

Names satisfy the source character bound and documented 1–256 UTF-8 bytes after
trim, while preserving wire spelling. Request strings count Unicode characters;
OAuth/bearer tokens keep canonical empty/control-string permissiveness and expiry
text is not parsed or normalized. Only environment secret values require nonempty
single-line strings without CR/LF/NUL. Secret names use ASCII identifier syntax,
source-case `CODEX_` restrictions and known conventional proxy/certificate names;
further managed-name decisions remain service-owned. Limited networking validates
1–16 hosts, lowercase-normalized uniqueness and hostname/IPv4 shape, without
schemes/paths/ports/wildcards/IPv6. Host spelling remains intact for service
normalization.

OAuth rotation preserves omission/null semantics for expiry, refresh, scope and
client-secret updates. New access tokens without expiry clear expiry at the
service; omitted expiry alone retains it. Omitted/null refresh tokens/client
secrets retain stored secrets; null scope clears scope. Clear flags express JSON
presence rather than inventing a common storage action.

Known returned-auth/refresh/credential objects and unknown returned-auth fallbacks
reject the five write-only keys privately. Other finite future values are deeply
detached and immutable; metadata labels are not treated as auth. Equality/hash
use the same full serialized fields. Default model/validation/HTTP/logging
messages redact private data; explicit exception properties retain HTTP context.

All operations preserve caller authentication/project/organization and borrowed
HTTP ownership, snapshot headers/options before asynchronous dispatch and enforce
Agents beta/JSON after provider/default/caller conflicts. IDs remain separately
encoded opaque segments, with local empty/dot safeguards. Lists use exclusive ID
cursors, required-nullable empty boundaries, deep-object AND metadata filters,
eventual consistency and scalar/repeated status forms. Empty arrays supply no
pairs and clear inherited conflicting status shapes, preserving both-status
service defaults. A lasting test caught and resolved the empty final-query-map
case where `Uri.replace` with null would retain the inherited query.

## Workflow boundaries and documentation

Hosted sandbox code receives placeholders. Proxy substitution applies only to
allowed HTTPS requests on ports 443/8443; the environment network policy must
also permit the destination. Credential networking unrestricted requires
restricted environment access with explicit allowed domains. Placeholders cannot
supply secrets for local computation/self-hosted/function tools. Rotation affects
new sessions/environments without promising immediate replacement in an existing
sandbox. Deleting stored records does not revoke provider tokens or cancel work.

The [offline example](../../../example/vaults_example.dart) demonstrates all ten
operations with synthetic secrets and safe returned auth. README documents the
actual methods, presence and policy boundaries; the earlier saved-agent paragraph
now reflects delivered sessions/history/traces/Vaults. All 64 llms source counts
are regenerated with the actual encoder: 152,739 tokens (~153k). No live API,
API key or paid execution is used ($0).

## Runtime and quality evidence

Independent source values yield 94 actual parser/roundtrip/copy/hash/private
witnesses for all 47 schemas. Independent public review captures 30 requests
across all 10 operations with 389 canonical/behavior assertions, including 28
successful JSON requests and two permission failures with structural-collision
IDs. All 164 captured default log records and failure diagnostics remain private.
185 source-invalid known inputs fail privately; 34 independent boundary checks
and 27 independent JavaScript nonfinite timestamp paths pass.

Permanent coverage has 272 focused cases: 135 contract/presence/extra cases,
72 typed field-copy cases, 32 boundary cases and 33 public-resource cases. VM,
real Chrome JavaScript and real Chrome Wasm pass; final boundary coverage checks
all 27 Vault/credential timestamp constructor/copy/parser paths. The full package
suite passes 24,054 cases with two existing environment skips. Ordered stable
formatting, fixes and fatal-info analysis pass. Combined source/docs/test and
actual published-head acceptance is recorded in the PR before user merge;
this record does not claim an unpublished commit passed CI.

## Honest toolkit diagnostics and progress

All 1,335 prior manifest entries stay structurally unchanged. Forty-four entries
map actual implemented contracts, including the exact-string status wrapper and
scalar/array status filter; no planned mappings or synthetic schema names appear.
The toolkit retains nonzero totals: implementation 980 errors/126 warnings/278
infos, consistency 115 warnings. Identity delta: the resolved missing Vaults
resource error is replaced by one scalar-wrapper inspection error for
`VaultStatusParam`. The class serializes the exact scalar and writable filters
validate the closed source values; canonical model/query evidence verifies the
contract. This inspection limitation remains visible. All other implementation
and consistency identities stay unchanged; docs/exports/README checks pass.
Actual example bindings are added without exclusions, skips or verifier changes.

History merge acceptance for #402 is recorded. Parent #317 remains open for three
core issues #389–391 and HTTP/2 evaluation #399 until individual merge acceptance.
Helpers #392–397 and Admin/legacy remain deferred; no further issue is created.

## Final merge

Merged in [PR #403](https://github.com/davidmigloz/ai_clients_dart/pull/403) at `9a31d51ddaf59f4a415cdea08c914accd5f255dd` on `2026-10-09T20:38:41Z` after both independent published content/CI approvals and all 14 exact-head contexts completed (13 successes/standard skip). Reviewed head: `01a72bd5ca439dafe180bf84d1fef570fe0eecec`.
