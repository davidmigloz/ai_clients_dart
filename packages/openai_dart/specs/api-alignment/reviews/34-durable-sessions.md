# Raw durable sessions and manual event loop acceptance

Status: merged in [PR #401](https://github.com/davidmigloz/ai_clients_dart/pull/401)
on October 9, 2026 at 19:00:00 UTC, squash
`7893afa2ab07014dbeddd19e4bc017b5d6e507c2`. Both independent reviewers approved
published head `b733e8b79dcad02fe727b3b2635d4f5193ce56c7` with zero findings.
All 14 exact-head contexts completed (13 successes and standard Test(all) skip),
merge state CLEAN; issue #386 is closed.

## Frozen source and scope

Wire authority remains immutable OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Workflow cross-checks use the official [sessions guide](https://developers.openai.com/api/docs/guides/agents-api/sessions)
and [event guide](https://developers.openai.com/api/docs/guides/agents-api/sessions/events),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
Canonical bytes, adoption metadata and verification policy remain unchanged.

This slice owns seven operations and their complete 223-component closure:
192 actual new mappings and 31 shared merged contracts. Counts describe canonical
components rather than classes. It adds session CRUD, explicit JSON/SSE creation,
persistent raw event observation and manual input submission under
`client.agents.sessions` and `.events`. It does not add future history/trace/subagent
inspection, owned prewarming, Vault operations or orchestration helpers. No source
refresh, new issue, dependency migration, release or version bump is included.

## Consumer behavior

JSON creation returns HTTP 201; `createStream` sets `stream: true` and receives 201
SSE. GET events receives 200 SSE and POST events receives 202 with no JSON result.
Observation delivers every one of 33 known event branches and continues across
idle, required actions, turn completion and typed errors. EOF/DONE ends local
observation without proving completion. Cancellation/abort closes only local
observation; it sends no backend cancel/delete. Explicit cancel input has no turn
ID. Delete remains a separate lifecycle action after cancellation. No replay
cursor, automatic reconnection or WebSocket endpoint is invented.

The public operations retain auth/project/organization context, capture caller
headers before async work, force Agents beta/response media after conflicting
headers and use UTF-8 JSON. IDs are encoded as opaque segments with documented
empty/dot safeguards. Lists preserve nullable boundary IDs and the four canonical
query parameters. Stream transports honor injection, borrow caller-owned clients,
and close factory-owned clients once, including late responses after cancellation.
Header/error-body reads have configured deadlines; successful persistent SSE has
no idle timeout. Error-body deadlines are total even under trickling input.

Session request/received tools and MCP transports have separate canonical shapes.
All four writable input kinds, nested browser-origin/auth submit/cancel branches,
three required-action kinds, four session states and seven environment states are
represented. Inline configuration needs a model without a saved agent ID;
initial input is required for environment none and streamed hosted creation.
Self-hosted sessions may wait for connectivity; the client does not run an executor.
Existing hosted environment IDs exclude every present inline/template field,
including explicit-null desktop. Inline archives use standard base64 and workspace
paths stay inside `/workspace`; service archive processing is not emulated.

Spending controls preserve omit/null/value transitions. The required nullable request
limit accepts positive whole cents up to `4503599627370495`; update clear/null removes
the cap without resetting consumed spend. Unlimited resources omit the field;
explicit received null and negative consumption are rejected. Organization usage
tiers are separate. Initial input/output schemas and submitted follow-up bodies
have compact UTF-8 4 MiB checks; server-added metadata can require more headroom.
Browser authentication values have a 120 KiB JSON budget, six-field bound and
16,384-character value bound.

Authentication form submissions physically dispatch once even if configured retry
middleware calls its continuation repeatedly. Uncertain delivery requires retrieving
current required actions before an application chooses another submission. The
client does not save form values or invoke callbacks automatically. Explicit
idempotency keys win over conflicting caller/provider/default header spellings;
keys have a 1–256 Unicode-character bound without a retention-duration promise.

Arbitrary JSON arguments/results/errors remain finite and deeply owned; explicit
null is accepted where canonical unconstrained JSON permits it. Required-nullable
keys and optional-nonnull/tri-state fields survive parser/copy/serialization.
Equality and hash use the same complete fields. Private unknown received values
remain detached; unknown request variants cannot be submitted. Known malformed
fields fail privately. JavaScript's JSON decoder can embed bad payload text in its
error message, so SSE parsing replaces decoder messages with fixed safe diagnostics.

## Offline validation and documentation

The permanent fixtures include 446 canonical minimal/full round trips for all 223
components and 603 independent per-field copy/clear mutations. Source-limit tests
exercise 149 canonical character/list/numeric and closed requested-enum bounds.
Additional fixtures cover future enums/unions, nullable/creation/environment rules,
finite ownership, runtime/auth budgets, all public operations and raw SSE lifecycle.

The runnable [offline example](../../../example/agent_sessions_example.dart) performs
ten mock requests for inline creation, observation, manual function result, message,
cap changes, pagination, explicit cancellation, retrieval and deletion. Saved/hosted
attachment is optional configuration. No API key, paid execution or live integration
is used ($0). README describes the delivered methods and limits; llms source counts
are regenerated using the actual encoder (62 source files, 148,789 tokens, ~149k).

## Quality and independent review

All 1,702 focused cases pass on VM, real Chrome JavaScript and real Chrome Wasm.
Ordered formatting/fixes/fatal-info analysis pass; stable Dart 3.13.5 package format
checks report zero changes. Existing Safety fixture and unrelated resource factory
behavior remain unchanged. Engineering separately verifies 510 existing Speech/Live
cases for the shared transport change. The full package unit suite passes 23,683 cases with two existing environment
skips. No integration or paid execution is run.

Independent requirements review validates every source-component fingerprint,
all 446 wire witnesses, 1,206 original/replacement values behind the 603 typed copy
cases, all seven captured public operations with 185 canonical assertions, and
creation/spend/hosted/authentication boundaries. The actual base counterfactual
fails to compile the public capability against
`08f9594dc73703e521aae4cb070a0be34509642a`; no mocked substitute or network is used.
Independent engineering verifies source/transport/lifecycle/retry/privacy behavior,
portable tests and retained toolkit classifications. Both reviews bind final
combined source/docs/tests fingerprints and then the actual published head;
publication/CI approval is recorded in the PR, not claimed for an unpublished commit.

## Toolkit diagnostics

All 1,139 existing manifest entries remain unchanged, with 192 real additions.
The full toolkit remains nonzero: 980 implementation errors, 126 warnings and 278
infos versus baseline 955/126/277. The exact delta is 16 scalar-wrapper inspection
errors, three unconstrained JSON argument nullability inspection errors, six
saved/session union-name association inspection errors, and one optional message
tag info. These are retained rather than hidden: wrappers serialize scalar values;
unconstrained required JSON permits null; canonical session tools have distinct
Dart names from persisted tools, and the tag's presence is tracked separately.
Consistency has 115 warnings versus 103 baseline: one new identity is the same
saved/session parent-name association; the other 11 describe canonical heterogeneous
union fields/types/nullability. Canonical fixture assertions
and independent review establish their actual contracts. Docs, exports and README
verification pass. No checker, exclusion, skip or global lint rule is weakened.

Parent #317 remains open for five core implementations (#387–391) and evaluation
#399 until their individual merge acceptance. Helpers #392–397 and Admin/legacy
work remain deferred. This slice creates no further tickets.
