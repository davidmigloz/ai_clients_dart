# Decisions API specification

Status: implemented and independently reviewed. First milestone of the
[alignment roadmap](README.md), tracked by
[issue #317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation ticket: [#318](https://github.com/davidmigloz/ai_clients_dart/issues/318).
API facts derive from the pinned sources; routine design follows package
patterns and the resolved independent planning review.

## Outcome

A Dart or Flutter caller can submit text or inline images with ordered predicate,
choice, and score questions through `client.decisions.create(...)`, then inspect
typed answers, individual refusals, and all reported usage counters.

This milestone is additive. The optional shared cache-write counter preserves
existing Responses/provider behavior. The user permits targeted breaking fixes
with migration guidance for later corrections to existing public APIs.

## Sources

Reviewed October 7, 2026:

- [Decisions guide](https://developers.openai.com/api/docs/guides/decisions).
- [Create reference](https://developers.openai.com/api/reference/resources/decisions/methods/create).
- [Pinned OpenAPI](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json):
  `/decisions`, `DecisionRequest`, `DecisionResponse`, `DecisionInput*`,
  `QuestionParam*`, `AnswerResource*`, and related probability/usage schemas.
- [Python 3.26.0 resource](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/resources/decisions.py).
- [Node 7.30.0 resource and types](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/decisions.ts).

The checked specification and clients agree on the Decisions contract. The guide
currently identifies `gpt-6-luna` as the available model. Keep the model parameter
open for future identifiers. Neither checked client sends a Decisions beta
header, despite the product's beta release status.

## Public surface

```dart
final DecisionResponse decision = await client.decisions.create(
  DecisionRequest(
    model: 'gpt-6-luna',
    input: DecisionInput.text('The screen arrived broken.'),
    questions: [
      DecisionQuestion.predicate(
        name: 'damaged',
        instructions: 'Does the customer report a damaged item?',
      ),
    ],
  ),
  abortTrigger: abortTrigger,
);
```

`DecisionRequest` and `DecisionResponse` follow existing package naming.
Dedicated Decisions input, content, question, and answer types prevent the much
wider Responses unions from exposing unsupported roles/content/tools here.
Use sealed unions for question/answer variants and string/boolean choice values.
Factories should keep common text and question construction concise.

Models remain immutable and manually serialized. Reuse `ImageDetail` and the
existing `ResponseUsage` after an additive cache-write detail enhancement.
Do not add runtime dependencies or a general validation framework for this feature.
List-bearing models take defensive unmodifiable copies; they use nonconst
constructors/factories when copying prevents const construction. Scalar variants
remain const where possible.

## Requirements

### DEC-01: Resource and transport

Expose a lazy `OpenAIClient.decisions` resource with `create(request,
{abortTrigger})`. Send ordinary JSON `POST /decisions` relative to the configured
base URL. Use existing authentication, organization/project/default headers,
interceptors, timeout/retry behavior, cancellation, and closed-client handling.
Do not add a beta header, model-event streaming, or undocumented CRUD methods.

### DEC-02: Request envelope

Require `model`, `input`, and `questions`. Support optional `safety_identifier`.
Absent nullable request values follow the package's omission convention. Preserve
the provided model identifier, question order, instructions, and optional names.
Names are correlation aids; do not impose undocumented uniqueness rules.

### DEC-03: Text and message inputs

Support string input and a list of dedicated user messages. Message content
supports string content or an ordered list of parts. Messages serialize
`role: user`; the canonical serializer may also emit `type: message`.
Text parts emit `type: input_text` and `text`.

Do not introduce a nonempty-text, nonempty-message-list, or nonempty-part-list
constraint: the reviewed schema permits those values to be empty.

### DEC-04: Inline image inputs

Image parts emit `type: input_image`, `image_url`, and optional `detail`.
Data URL input must begin with `data:`. Reject external URLs and file IDs at the
dedicated image-input construction/parsing boundary. A binary convenience factory
must construct `data:<mediaType>;base64,<encoded bytes>`; it must not send raw base64.

Support `low`, `high`, `auto`, and `original` details through the shared type.
Omit unspecified detail so the server applies its `auto` default. Preserve the
order of mixed text/image parts. Unsupported roles, files, audio, tools, and
item references are excluded from the typed request contract.

### DEC-05: Question variants

Support:

| Discriminator | Required fields beyond `type` | Optional fields |
| --- | --- | --- |
| `predicate` | `instructions` | `name` |
| `choice` | `instructions`, `choices` | `name` |
| `score` | `instructions`, `levels` | `name` |

Each choice option requires `value` and may contain `description`. Each score
level requires `label` and may contain `description`. Optional question names
and descriptions are omitted when absent; do not serialize them as JSON null.

### DEC-06: Choice and score fidelity

Choice values are strings or booleans. Keep `true` distinct from `"true"`; do not
coerce, stringify, or accept numeric/null values as choices. A small sealed value
union provides the typed public representation and primitive wire values.

Score levels use ordered, zero-based indices. Preserve returned numeric scores,
including fractional values; preserve integer indices separately from labels.
Do not convert scores to enums or round them to an integer level.

### DEC-07: Response envelope and answers

Require and retain `model`, ordered `answers`, and `usage`. No response ID or
object discriminator is required by the reviewed response contract.

| Answer | Fields beyond `type` |
| --- | --- |
| `predicate` | nullable `name`, numeric `probability` |
| `choice` | nullable `name`, typed `choice`, numeric `confidence`, ordered `probabilities` containing typed `value` and numeric `probability` |
| `score` | nullable `name`, numeric `score`, numeric `confidence`, ordered `probabilities` containing integer `value`, string `label`, and numeric `probability` |
| `refusal` | nullable `name` |

Every known answer includes `name` on serialization, even when its value is
null. Distinguish an unnamed answer from a malformed known payload missing a
required field. A refusal is an answer outcome, not an HTTP exception, and may
occur alongside successful answers in the same ordered response.

Parse numeric answer fields through `num.toDouble()` so integer-valued JSON
numbers also work. Preserve reported values without clamping or rounding.

### DEC-08: Usage fidelity and compatibility

Preserve input/output/total token counts, cached tokens, cache-write tokens, and
reasoning tokens, including zeros. Add optional `cacheWriteTokens` to shared
`InputTokensDetails`, including parsing, serialization, equality, hashing, and
documentation. Include the constructor, `toString`, and nullable `copyWith`
contracts, with the package sentinel convention for clearing nullable values.
Reuse `ResponseUsage` for the Decisions response.

The latest Decisions contract requires both detail objects and their counters;
`DecisionResponse.fromJson` validates those required objects/counters before
delegating to the shared usage parser. Missing or invalid required Decisions
usage fields fail clearly; do not invent zero values for absent data.
Keep shared Responses parsing compatible with older/provider payloads that omit
optional details and with its existing alternate usage field names.

### DEC-09: Unknown and malformed variants

Preserve a future answer discriminator and its raw JSON in an
`UnknownDecisionAnswer`, following existing package unknown-result patterns.
Re-serialization must retain its payload without fabricating a scored answer.
Known variants with malformed required fields/choice values fail clearly.
Unknown request discriminators fail rather than manufacturing valid-looking input.
This is an intentional exception to the shared checklist's general unknown-union
fallback guidance: Decisions request unions represent a restricted supported
input contract, while response answers retain future server payloads. Do not
silently turn unsupported request content into a supported role or part.

### DEC-10: Limits and model guidance

Document the reviewed limits: 1–200 questions; 2–255 choices per choice question;
2–10 levels per score question; at most 128 images across the request; at most
128 characters for `safety_identifier`. Do not mistake the schema's larger
response-array limits for request limits.

Unless a local check is necessary to enforce a dedicated type boundary, leave
general schema-size/count validation to the API and surface its existing typed
400 errors. Do not impose undocumented restrictions on empty input or probability
ranges. Examples use `gpt-6-luna`; arbitrary future model strings remain valid
client inputs.

### DEC-11: Public integration and documentation

Export the resource and models through the appropriate barrels and normal public
package import. Include a runnable example demonstrating all question types,
answer pattern matching, and refusal handling. Document inline image construction
and current model/input limitations.

Register the Decisions resource/schema coverage in the OpenAPI manifest and
follow candidate promotion/verification instructions. Keep unrelated remaining
alignment gaps explicit rather than suppressing them. README coverage must match
the completed feature, without claiming overall API parity prematurely.

## Public test boundaries and acceptance evidence

Use the public `OpenAIClient` with `MockClient` or a deterministic fake
`http.BaseClient`, plus public model serialization. Assertions compare actual
wire fixtures rather than only round-tripping two instances built the same way.

| Check | Observable evidence | Requirements |
| --- | --- | --- |
| Text and questions | Exact request fixture contains all question variants, mixed boolean/string values, ordered levels, and omitted optionals; empty text/messages/parts retain their valid representation | DEC-02, DEC-03, DEC-05, DEC-06 |
| Messages and images | String message content and ordered text/image parts work; binary input has the exact data URL; unsupported image references fail | DEC-03, DEC-04 |
| Mixed response | All four answer types retain ordering, explicit null names, numeric distributions, integer numeric JSON, and fractional score | DEC-06, DEC-07 |
| Usage | Every reported counter survives; Decisions missing required detail objects/counters fails clearly; older Responses fixtures remain compatible | DEC-08 |
| Unknown/malformed | Unknown answer raw payload survives; malformed known/request values fail clearly | DEC-07, DEC-09 |
| HTTP integration | Correct URL/method/body and configured headers, no beta header, typed 400 error metadata, closed client sends no request | DEC-01, DEC-10 |
| Cancellation | Deterministic abort reaches the transport and maps to existing `AbortedException`; an uncompleted trigger still sends the full request body | DEC-01 |
| Model and limits | A future model string is transmitted unchanged; documentation accurately states the reviewed request limits without adding local count/range restrictions | DEC-02, DEC-10 |
| Public usability | Example compiles from the public import; resource/models are exported and coverage registered | DEC-11 |

Existing abort/error behavior should be exercised at this resource boundary,
without rewriting or duplicating the complete shared transport test suite.
Unit fixtures are the deterministic acceptance baseline. After implementation,
the user authorized one low-cost live Decisions test; the tagged integration
smoke test passed and is excluded from the default unit-test run.

Completed acceptance evidence and verification limitations are recorded in the
[implementation review](reviews/01-decisions-implementation.md).

## Ticket and review plan

Use one medium, complete feature ticket for DEC-01 through DEC-11. Include models,
resource/client wiring, the shared usage addition, exports/manifest, example/docs,
and tests together. Do not split predicate/choice/score or all models/resources
into separate incomplete layers. Split further only if implementation reveals a
concrete independent slice needed to keep the work reviewable.

Review the actual completed diff independently against this specification and
against repository/package standards. Verify reported findings and fix valid
ones before recording completion. Run focused tests during implementation, then
the required format/fix/analyze/unit/toolkit checks; document unrelated toolkit
coverage gaps separately.

Excluded from this milestone: Live/voice integration, Responses WebSockets,
general retry redesign, Administration, package publishing, and the remaining
alignment backlog. Those stay in the overall roadmap.
