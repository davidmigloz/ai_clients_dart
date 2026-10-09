# Session history, turns and traces acceptance

Status: merged in [PR #402](https://github.com/davidmigloz/ai_clients_dart/pull/402),
closing #387, on October 9, 19:58:29 UTC. Squash commit
`c3a3191121f3c32b760189801cb6ecb0cfe69753`; approved head
`31b689893a4929287a0d7762844e5ff617917cea` had both independent published
content/CI approvals, zero findings and all 14 completed contexts
(13 successes and the standard Test (all) skip), with CLEAN merge state.

## Frozen contract and delivered scope

Wire authority is immutable OpenAPI
[0ef225c4](https://github.com/openai/openai-openapi/blob/0ef225c4f701046f8fe88cae9d29d0df4d1a9fa9/openapi.json),
normalized SHA256 `3e3ddd4f2a584f657294a0a9266ed07b1103a103a38c4dd45a008c8be5450686`.
Workflow receipts use the [official tracing guide](https://developers.openai.com/api/docs/guides/agents-api/tracing),
[observability guide](https://developers.openai.com/api/docs/guides/agents-api/observability),
Python [c511a771 / 3.26.1](https://github.com/openai/openai-python/tree/c511a77159bc870f31c34388311b7cc62ef15f08)
and Node [37af8fc9 / 7.31.0](https://github.com/openai/openai-node/tree/37af8fc9c78bd5c4d2979c5d51870dd38964e156).
All 62 component receipts and the five-operation closure are independently verified.
Canonical/adoption bytes and source pins remain unchanged.

The five GET operations add `client.agents.sessions.items.list`, `.turns.list`,
`.turns.retrieve`, `.turns.items.list` and `.traces.list`. They accept known IDs
without creating sessions or live observation. The closure has 62 real source
components: 58 already implemented contracts and four new envelopes. Existing 17-way
history items and safe authentication response records are reused after canonical
wire-equivalence verification. No child-history, recovery, orchestration, trace-wait
or replay helpers are added. No new issues, dependency changes, release/version
bump or automatic source adoption occurs.

## Public behavior and privacy

All operations preserve authentication/project/organization and injected transport
ownership, snapshot caller headers before async work, force Agents beta and JSON
Accept after provider/default/caller conflicts, and remain bodyless GETs. Session
and turn IDs are separately encoded as opaque URI segments, with documented local
empty/dot safeguards. All four lists validate limit 1–100, known order and exclusive
ID cursors; omitted queries retain server defaults. Required nullable empty-page
boundaries, turn timestamps/error/usage and unknown received values survive copying.

Root items include coordinator interactions with children; each child has separate
history. Historical function/approval records do not authorize execution or replay.
A terminal turn is distinct from session idle or observer EOF. Unknown usage is
not zero, and recorded usage does not constitute a final spending ledger.

Trace IDs are root-turn anchors. Each page reflects currently published data,
skips unpublished turns and never waits for later trace updates. Sequential
pagination cannot promise a complete historical export. The service limits trace
reads and JSON responses to 16 MiB per request; request fewer traces when it reports
that limit. Trace export must be enabled for the organization; the key belongs to
the session project with `api.traces.read` or `api.agents.read` permission. API errors
retain status and explicit HTTP context with private default diagnostics.

The trace OTLP map is arbitrary finite JSON, deeply detached and immutable. The
client does not force additional OTLP keys or interpret spans. Received future
fields remain finite/private and cannot override declared typed fields. Default
logging, URLs, correlation IDs, headers, model diagnostics and HTTP/parse errors
redact private history/authentication/OTLP values. Authentication history uses
returned DTOs with no submitted form-value fields, rather than secret-bearing
submission classes. Equality/hash include the same complete serialized fields.

## Offline tests, examples and source evidence

Independent source fixtures cover 124 minimal/full values for 62 components. The
new complete history page contains all 17 known item branches. Permanent fixtures
exercise exact public methods/paths, opaque Unicode IDs/cursors, header conflicts,
empty/null-boundary pages, retrieval/JSON failures, early abort, all item variants,
finite ownership, copies, history authentication and trace pagination without polling.

The offline [history example](../../../example/agent_session_history_example.dart)
performs six mock GETs: root items/turns, turn retrieval/items and two published
trace pages with root-turn cursors. It explicitly separates root/child history,
terminal/idle states and missing/late traces, preserves unknown usage, and never
replays historical actions. README provides the public methods and permission/
publication/16MiB limitations. All 63 llms source counts are regenerated with the
actual encoder: 150,489 tokens (~150k). No live integration, API key or paid
execution is used ($0).

## Quality and independent acceptance

All 99 focused cases pass on VM, real Chrome JavaScript and real Chrome Wasm:
21 model cases, 62 complete-closure cases and 16 public resource cases. The full
package unit suite passes 23,782 cases with two existing environment skips.
Ordered stable formatting, fixes and fatal-info analysis pass. Independent review
identified and resolved JavaScript accepting non-finite values as integers in
trace construction/copy; permanent constructor, parser and copy tests cover it.
Final combined requirements and engineering approval, published-head review and
CI completed before the user-authorized merge. Published content receipts:
requirements `d066910d31f454ad4af975c5dbab5837ce7b38e7ef3ed21977482365d79c03cd`,
engineering `2ebae14da6913923eed9ee92351706700ff788116a6b62f366dcf2c630a6e310`;
CI supplements `6312b55507af875424d5f34c04cf96c266212547e7a52b7cacfe86d8465cba18`
and `79c41654c7449602c1836382597fc28f8d9a5ca89853a904e36f690cd1c0048f`.

## Toolkit diagnostics and bounded progress

All 1,331 prior manifest entries remain structurally unchanged; four new entries
map actual implemented envelopes. Toolkit implementation 980 errors/126 warnings/
278 infos and consistency 115 warnings remain exactly at the merged baseline,
with no added or removed diagnostic identities. All inherited limitations stay
visible; no checker, exclusion, skip or global lint is weakened. Docs/exports/
README checks pass. Prior durable-session merge acceptance is updated truthfully.

Parent #317 remains open for four core issues #388–391 and evaluation #399 until
individual merge acceptance. Helpers #392–397 and Admin/legacy work remain deferred.
