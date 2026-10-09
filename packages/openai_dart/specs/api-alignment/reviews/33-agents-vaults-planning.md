# Agents and Vaults planning review

Status: canonical engineering, SDK/workflow requirements and roadmap/coverage
reviews approve the combined planning documents; no open planning findings.
Specification: [Agents and Vaults](../agents-vaults.md).
Coverage: [operation, component and source ledger](../agents-vaults-plan.json).
Scope: 13 planned implementation tickets, repository 33–45. This record accepts
planning only; it does not claim runtime implementation or complete parity.

## Source receipts and authority

An actual toolkit fetch/review and independent immutable download on October 9,
2026 at 12:36:45 UTC confirm the adopted OpenAPI
`0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9`, Python
`c511a77159bc870f31c34388311b7cc62ef15f08` (3.26.1) and Node
`37af8fc9c78bd5c4d2979c5d51870dd38964e156` (7.31.0) heads.
Canonical JSON and the freshly fetched normalized candidate are byte-identical,
SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Immutable raw upstream JSON has SHA256
`ff5a4408cabb13e09430813b67a59f67366a58a4dec1f20bac89e4c96fab7fb5`;
its parsed value equals canonical JSON although serialization bytes differ.
The original adopted metadata, including its 07:22:02.257304 UTC fetch receipt,
is preserved byte-for-byte. This planning change promotes no source.

The SDK/guide audit retrieved 136 actual SDK files (73 Python, 63 Node) and
22 official guide/reference snapshots. The ledger preserves 52 focused primary
source URLs, SHA256 hashes and source anchors. Every focused snapshot hash was
verified locally. Canonical governs wire shape, official guides establish workflow,
and pinned SDK implementations establish helper behavior. SDK discrepancies and
Dart choices are explicitly declared rather than silently overriding canonical.

## Planning validation

The ledger assigns all 47 operation IDs exactly once: 37 Agents and 10 Vaults,
covering 28 paths. Its seven HTTP slices have transitive component closures of
56, 223, 62, 47, 49, 12 and 63 respectively. Their combined union has 321 schemas
(Agents 277, Vaults 47, with three shared components), each fingerprinted from
canonical JSON with all relevant ticket owners. These are component counts,
not counts of new Dart classes. Shared models require proved wire equivalence.
Six webhook/workflow/helper slices own zero new canonical HTTP operations.

All 30 primary requirement IDs have one ticket owner; helper source ownership is
recorded separately from operation ownership. The dependency graph is acyclic.
Implementation/demo dependencies do not imply service prerequisites to create a
saved agent, Vault, template or owned environment when callers already have IDs
or use inline configuration. Vault management has no pending prerequisite.

Thirty-one schema-only contract probes were used during the engineering inventory.
They check planning assertions, not future Dart serializers or runtime behavior.
Each future ticket requires tests that fail at the merged base, public transport
fixtures, model/value/privacy tests, examples and actual manifest mappings.
Every new runtime acceptance box remains unchecked.

## Resolved planning findings

- Browser-origin UI wording must preserve all three canonical wire decisions:
  `approve` (allow), `deny` and `cancel` (dismiss). Browser authentication has a
  separate submit/cancel action union. The specification and workflow ticket now
  require all three origin fixtures and do not serialize the UI label `allow`.

## Review focus and preserved boundaries

Reviewers verify complete operation/field/union admission, JSON/SSE/empty/binary
response modes, required-nullable fields, presence-aware spend updates and exclusive
environment configuration. They also check write-only credential ownership,
case-insensitive beta/idempotency headers, browser-auth no-retry handling, current
state recovery without replay, and observer cleanup separate from backend cancel.
Optional dispatch/result/file helpers have separate tickets and sourced state
machines; no invented result endpoint, canonical Agents output_text annotations field, filesystem sandbox,
executor/provider management or environment suspend/resume/delete endpoint exists.

Namespace, immutable capture, failed-parser memoization and
filesystem overwrite choices are declared as Dart decisions where SDKs differ.
Pinned SDK spend-control/state omissions remain canonical requirements. Runtime
configuration #316 remains separate Phase 8 work; Administration/storage and other
remaining shared/legacy gaps remain open. Parent #317 is not complete.

## Independent approvals

Canonical engineering independently reviewed the specification, helper/workflow
contracts and root ledger, with 1,884 successful assertions. SDK/workflow review
independently checked the HTTP/helper tickets, root ledger and source interpretation.
A third scope review independently checked the specification, HTTP tickets, ledger
and roadmap. Reviewers disclose the temporary drafts they authored: their own
integrated text was consistency-checked, while another reviewer supplied the
independent review. Root integrated and checked all documents. These are local
planning reviews; they do not accept unimplemented runtime code.

| Review | Receipt SHA256 |
| --- | --- |
| Canonical engineering | `aecdc89decdc710ec7bea12fea64f00b313e4d6e2a6b1fb27a3b499c45c00e91` |
| SDK/workflow requirements | `4d0cfa319f80d2a11315b2bc6f2cc22635ac148e80bc33afe8aa5e3b41c5777f` |
| Roadmap/coverage scope | `6baac2d0a7fab8ca8a985490704c614811f9a939758042b9959bacf4c164f96b` |

All three receipts fingerprint the actual 20-file combined diff after the browser
origin correction, validate the 47 operations/321 components/30 primary owners,
and preserve source/metadata/manifest bytes. Real issue links, native graph and
approval-status text are publication updates; they receive a final byte/graph
check before the published planning PR is reported as ready.

## Validation limits

This change touches only planning Markdown and its JSON ledger. It adds no runtime,
example, test, dependency, manifest, canonical, metadata, export or skill changes.
No Dart runtime tests are rerun solely for planning. The merged Safety baseline
retains 21,395 passing package tests plus two environment-dependent skips and
245 focused cases on each of VM, real Chrome JavaScript and Wasm. Those are
historical implementation receipts, not acceptance of planned Agents/Vaults code.
Toolkit baseline remains visibly nonzero: 941 errors, 126 warnings, 277 infos
and 103 consistency warnings. No planned mappings, exclusions or checker changes
hide missing implementations. No live API requests, hosted compute, keys,
version bumps or package publication occur; cost $0.

The create-pr description follows Summary, Details, References and Test Plan,
ending with the five literal implementation checklist lines. Those stay unchecked
because this planning PR has no runtime acceptance; Details records that boundary.
Final publication graph/blob/template checks and exact-head CI are separate gates.

## Native issue publication

GitHub issues [#385](https://github.com/davidmigloz/ai_clients_dart/issues/385)–[#397](https://github.com/davidmigloz/ai_clients_dart/issues/397)
are open native children of #317, with package/type labels and the CODEOWNERS
assignee. Nineteen native blocker edges match the planned graph, including the two
already-merged webhook prerequisites. Parent #317 has 45 children: the prior 32
closed and these 13 pending. All 111 ticket acceptance boxes remain unchecked.
Saved-agent CRUD #385 is the first runtime slice; Vaults #388 is independently
usable with no pending blocker. Publication changes only add actual links and
review status; they introduce no source/runtime contract edits.

Local validation recomputes every operation owner, direct schema root and transitive
closure, checks all 321 schema fingerprints and 52 source hashes, confirms the
30 primary owners and acyclic dependencies, resolves local links and verifies the
planning-only file boundary. Whitespace checks pass. Final published blob/template/
graph checks and exact-head CI are reported in the PR and parent before merge.
