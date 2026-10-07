# Async tools implementation acceptance

Status: implementation, validation and independent reviews complete.
[PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346) merged after
all applicable CI checks passed, closing #334.
Tracking: [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-ASYNC-01–03](../responses.md#async-calls).
Implementation branch: `feat/openai-async-tools`.

## Outcome and contracts

Function/custom definitions and public factories carry optional bool async.
Absent/false/true remain distinct; supplied parsed null/wrong types fail with
contextual FormatException. Function/custom call inputs, outputs and conversation
items retain the flag through real GA/beta create/stream/list-input and conversation
create/item-create/list/retrieve paths. Existing item-added/done and lifecycle
Response parsing preserves it, including accumulator final response. No new
stream event or automatic execution runner is invented.

The new `CustomToolCallInputItem` is a typed input/replay variant, distinct from
existing output `CustomToolCallItem`. Its conversion preserves every input-supported
field and omits output-only status/createdBy. Function replay now preserves agent
and async alongside original call ID, namespace, caller and status. Conversation
calls also retain previously omitted namespace/caller/creator/beta-agent metadata.
Existing custom optional id/status and output optional status tolerate provider
payloads as before; this slice does not silently tighten those constructors.

Every changed model has full copy/equality/hash/diagnostic contracts. Optional
copies use sentinel clearing; nested parameter/output-schema/custom-format JSON
uses deep equality and matching hashes. Diagnostics summarize opaque tool text,
schemas and grammar. Fixed type getters expose immutable discriminators without
setters/copy arguments. Required definition/call strings and discriminators fail
contextually when malformed. Existing optional-field tolerance, const constructors
and caller-owned collection identity remain compatible.

## Source and toolkit evidence

Fresh October 7 fetch/review is semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Metadata-only fetch churn is restored; no new candidate promotion is needed.
[Async guide](https://developers.openai.com/api/docs/guides/async-tool-calling)
confirms GPT-6 Astra and later support, direct application-owned tools, original
call-ID/latest-response continuation and multi-agent async/parallel restriction.
Pinned Python 3.26.0 and Node 7.30.0 contracts remain the reviewed clients.

Describe/scaffold dry-run reviewed the custom input shape. Real object mappings
replace relevant old skips and cover definition/input/resource/conversation plus
GA/beta aliases. No new skip or field exclusion is introduced. The fixed discriminator
getters allow truthful verification instead of inventing writable type fields.

Full toolkit exports/docs/README checks pass. Wider implementation diagnostics:
48 errors, ten warnings, 113 infos, plus one consistency warning. Relative to
#333's 41/10/103, seven newly visible errors describe existing optional output
status (GA/beta function/custom and both conversation mappings) and optional
custom conversation id. These known provider/constructor tolerances are retained;
new typed/naming infos describe contextual status/caller schemas. No async field,
copy, export or serialization omission is hidden. Remaining unrelated gaps stay
in the complete-parity inventory.

## Verification

- Format: 437 Dart files, zero changes; dart fix: nothing to fix.
- Package fatal-info analysis: no issues.
- Unit suite: 2,903 passing, two existing environment-dependent skips.
- 366 new deterministic tests: 80 definition, 128 input/output call, 63 conversation
  model, 95 public REST/SSE/conversation fixtures.
- Focused suites check exact every-field copies/clears, full JSON/value/hash,
  contextual required/invalid fields, nested schema content and payload redaction.
- Public fixtures cover omitted/false/true across GA/beta, namespaced/deferred/
  discovered tools, item-added/done and lifecycle responses, final accumulation,
  faithful replay, malformed supplied flags and every changed conversation path.
- New README and migration snippets compile with fatal-info analysis.
- README, migration, public model docs and llms are current. The runnable local
  example passed with three MockClient requests: both tool calls start, an
  intervening turn advances the response ID, and original call IDs return results
  against the latest response. No external request, API charge or paid test.

The sibling audit found no async field in the published open_responses contract.
Its older deep-schema convenience gaps remain separate; no speculative async
schema addition was made to the sibling package.

## Independent reviews

Requirements review approves the final combined source, tests, example,
documentation and mappings with no actionable findings. Engineering standards
review found one canonical-fixture correction: the local returned custom call
must include completed status. The example now includes it and was rerun; existing
provider omission tolerance and its compatibility fixtures stay intentional.
Engineering review otherwise approves full model contracts, redaction, exports,
const ownership, public wiring and assertion quality. No validated findings remain.
The issue closed when implementation PR #346 merged.
