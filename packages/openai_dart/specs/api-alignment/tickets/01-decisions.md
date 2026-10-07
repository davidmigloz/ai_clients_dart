# Add the complete Decisions API to openai_dart

Status: implemented and independently reviewed; awaiting merge.
GitHub: [issue #318](https://github.com/davidmigloz/ai_clients_dart/issues/318).
Parent: [OpenAI API alignment #317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Decisions API](../decisions.md), requirements DEC-01 through DEC-11.
Blockers: none on other implementation tickets. This additive feature is
independent of the compatibility policy for later corrections to existing APIs.

## Outcome and demonstration

Through the public package import, create a decision from text or inline images
with predicate, choice, and score questions. Inspect typed ordered answers,
partial refusals, and complete usage. This single ticket includes the models,
resource/client wiring, shared cache-write usage enhancement, exports, manifest,
example, documentation, and unit tests needed to make that workflow usable.

## Acceptance criteria

- [x] **DEC-01:** `client.decisions.create(request, {abortTrigger})` sends normal
  JSON POST `/decisions` through the existing HTTP/auth/error/cancellation pipeline.
  Configured base URL and headers work; no Decisions beta header is introduced.
- [x] **DEC-02/03:** Required model/input/questions and optional safety identifier
  serialize correctly. String input, user messages with string content, and
  ordered text parts work; absent request optionals are omitted.
- [x] **DEC-04:** Dedicated inline-image parts accept data URLs, support existing
  image-detail values, and preserve mixed text/image order. Binary construction
  emits a complete MIME/base64 data URL. Unsupported URLs/file IDs fail at the
  input boundary; unsupported content/roles are absent from the typed contract.
- [x] **DEC-05/06:** Predicate/choice/score question unions work. Choice strings
  and booleans remain distinct; score labels and zero-based indices retain order.
  Optional request names/descriptions do not serialize as null.
- [x] **DEC-07:** All four answer variants work together in an ordered response.
  Unnamed known answers retain the explicit `name: null` key. Refusals remain
  ordinary answer outcomes. Integer JSON numeric fields and fractional scores
  parse correctly; probabilities/confidence are not clamped.
- [x] **DEC-08:** Cached/cache-write/reasoning counters and input/output/total
  counts survive, including zeros. The shared optional cache-write addition
  preserves all existing Responses/provider usage behavior. The Decisions
  response boundary rejects missing/invalid required usage objects/counters
  without making the shared Responses parser stricter.
- [x] **DEC-09:** Unknown answer JSON round-trips through a typed unknown variant.
  Malformed known variants and invalid string/boolean choice values fail clearly.
  Unknown request variants are not normalized into valid-looking requests.
  The specification records the deliberate restricted-request exception to the
  shared checklist's general unknown-union fallback rule.
- [x] **DEC-10:** Guidance describes current model support, input restrictions,
  question/choice/level/image limits, and the safety-identifier bound. The model
  parameter remains an unrestricted string; no general validation framework is added.
- [x] **DEC-11:** Resource/models are publicly exported, the example demonstrates
  the complete contract, and OpenAPI coverage is registered. Coverage claims remain
  truthful about the wider unfinished alignment backlog.
- [x] Public-boundary unit tests cover exact request/response fixtures, mixed
  answers, unknown/malformed variants, headers/URL, typed errors, closed clients,
  cancellation, and transmission with an uncompleted abort trigger. Fixtures
  also preserve permitted empty inputs and transmit a future model ID unchanged.
- [x] Required format/fix/analyze/unit/toolkit checks are complete with evidence.
  Unrelated preexisting toolkit coverage gaps are recorded separately.
- [x] Independent requirements and repository-standards reviews are complete;
  valid findings are fixed and acceptance evidence is recorded before closure.

## Testing boundaries

Use public model serialization and `OpenAIClient` with `MockClient` or a
deterministic `http.BaseClient`. Compare independently specified wire fixtures,
not only model round trips. Reuse existing transport seams for abort/error
behavior; do not rewrite the shared transport or duplicate its whole test suite.
Run unit tests by default. The user separately authorized the low-cost Decisions
integration smoke test, which passed with one request and retries disabled.

## Compatibility and exclusions

All Decisions APIs are new. Extend shared `InputTokensDetails` additively with an
optional cache-write field. Use existing `ImageDetail`, `ResponseUsage`, HTTP
infrastructure, dependency set, and package conventions.

Exclude model-event streaming, undocumented Decision CRUD, Live/voice integration,
Responses WebSocket work, general retry redesign, Administration, and publishing.
Those remain separate roadmap workstreams.

## Sources

- [Guide](https://developers.openai.com/api/docs/guides/decisions)
- [Create reference](https://developers.openai.com/api/reference/resources/decisions/methods/create)
- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json)
- [Python 3.26.0](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/resources/decisions.py)
- [Node 7.30.0](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/decisions.ts)

The full proposed specification is in
`packages/openai_dart/specs/api-alignment/decisions.md`. Revalidate the affected
contract before implementation if the upstream sources have changed.

## Completion evidence

Implemented on `feat/openai-decisions`. All acceptance criteria are verified;
the issue remains open for merge. See the
[implementation review and verification record](../reviews/01-decisions-implementation.md)
for commands, outcomes, the additional nullable-field fix, and the deliberately
visible toolkit backlog. The subsequently authorized live integration test also
passed: 387 input tokens, estimated charge $0.0000387. No package release was
performed.
