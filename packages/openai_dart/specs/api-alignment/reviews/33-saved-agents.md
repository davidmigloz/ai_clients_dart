# Saved agent CRUD and configuration acceptance

Status: implemented for [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385),
[ticket 33](../tickets/33-saved-agents.md), AGENTS-CRUD-01. Local runtime and
source acceptance pass; published-head independent review and CI are the remaining
publication gates. The implementation PR records those receipts before any
user-authorized merge. This record does not claim an unpublished commit has passed CI.

## Source contract and scope

Planning [PR #398](https://github.com/davidmigloz/ai_clients_dart/pull/398) merged
October 9, 2026 at 15:15:56 UTC, squash
`ff1fe118d403b1dfd077627962e3cd8eb2f5f520`, after all 14 reviewed-head contexts
completed (13 successes and the standard Test(all) skip).

Wire authority remains frozen OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Workflow cross-checks use the [official configuration guide](https://developers.openai.com/api/docs/guides/agents-api/configuration),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
The five operation closures independently recompute to 56 components; every
canonical component fingerprint and 112 minimal/full source fixtures is verified.
Canonical bytes and adoption metadata remain unchanged; there is no source refresh
or automatic scope expansion.

This slice adds list/create/retrieve/update/delete through `client.agents`.
It stores configuration without running a model or tools. Persisted request and
received tools, MCP transports, text formats, reasoning, multi-agent configuration
and string-valued enums retain their separate canonical contracts. Sessions,
environments, traces, Vaults and helper workflows stay in their existing tickets.
No dependency migration, version bump or release is included.

## Public behavior

All five methods preserve ordinary authentication, project context, injected
transport ownership and abort handling. Each snapshots caller headers before
asynchronous work, forces the case-insensitive Agents beta header even after
provider header refresh, and encodes JSON as UTF-8 with matching media type.
List parameters remain query parameters and empty-page cursors remain JSON null.
Opaque IDs are encoded as one segment; empty and exact dot segments have documented
local URI safeguards. The valid ID `agents` remains a private item route.

Create omission retains service defaults. Update omission preserves saved state;
supplied maps, lists and configuration objects replace fields, and explicit null
clears name/tools/metadata or resets reasoning. Copy APIs preserve presence and
apply the same constraints. Requested model strings remain unchanged. Required
nullable response keys survive round trips. All six persisted tools and both MCP
transports have known-variant error coverage; future received variants and enum
strings retain their raw values, while unknown request variants are rejected.

Request construction, parsing, copying and resource boundaries enforce Unicode
character limits, metadata limits, 2,000 tools and the 3 MiB compact UTF-8 JSON
budget. Returned resource limits are checked separately. Arbitrary nested JSON
is finite and deeply owned. Equality/hash use the same complete serialized fields.
Default diagnostics and logging redact private configuration, URLs, headers and
correlation identifiers; explicit values and serialization remain available.

The offline example makes seven mock requests covering all six tool types, CRUD,
pagination, replacement, clear/reset and deletion with caller-owned transport
cleanup. The exact README Dart block independently compiles and executes six mock
requests. Both cost $0 and need no key or live API. README/llms/export mappings
accurately describe only the delivered capability. All 61 llms source token
annotations are regenerated with the actual encoder: 146,420 tokens (~146k).

## Validation and independent review

Ordered package fixes and fatal-info analysis pass on Dart 3.12.2. Stable
Dart 3.13.5 package formatting passes after restoring an existing Safety fixture
to its unchanged base layout; the earlier 3.12 formatter used a different closure
layout. This CI correction changes no runtime or test behavior.
All 586 focused cases pass on VM, real Chrome JavaScript and real Chrome Wasm.
The full package unit suite passes 21,981 cases with two existing environment skips.
Eight permanent transport regressions cover header ownership, beta precedence,
UTF-8, private collection-name IDs, and exported configuration/clear states.

Independent requirements review validates 37 captured public operations against
frozen canonical contracts with 339 source assertions, all writable enum values,
all tool/MCP variants, returned corpora, and 165 per-field copy/replace/clear checks.
The real base counterfactual fails at `client.agents` against
`08f9594dc73703e521aae4cb070a0be34509642a`. Independent engineering verifies the
combined runtime, public fixture and platform receipts. Both reviewers report no
remaining runtime findings; final publication acceptance binds exact source,
documentation and test fingerprints to the published commit and its CI results.
No integration or paid hosted execution was run.

Full toolkit verification remains nonzero with 955 implementation errors,
126 warnings, 277 infos and 103 unchanged consistency warnings. Baseline was
941/126/277 with the same consistency identities. Exact diagnostic comparison
removes the previous missing Agents resource error and adds 15 primitive-wrapper
inspection errors ("No spec fields found") for the actual string-valued enum
classes. These classes preserve future strings and deliberately are not Dart
enums or object-shaped wire values; public source fixtures test every known value,
future strings and closed request validation. The manifest honestly maps real
classes and files. No checker, exclusion or skip is weakened to hide these limits.
All 1,083 prior manifest entries remain unchanged, with 56 real additions.
Documentation maps the actual saved-agent example; docs, exports and README
verification pass. Remaining baseline API coverage findings stay visible.

Parent #317 remains open for seven core implementations and one authorized HTTP/2
evaluation until their individual merge acceptance. Issue #385 remains open until
its implementation PR merges. Six helper issues and remaining Admin/legacy work
remain deferred; no new tickets are created by this slice.
