# Access-program selection acceptance

Status: implementation, validation and independent reviews complete; merge pending.
Implementation [PR #351](https://github.com/davidmigloz/ai_clients_dart/pull/351)
is open for review; #339 closes only after merge.
Tracking: [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-ACCESS-01–02](../responses.md#access-programs).
Implementation branch: `feat/openai-access-programs`.

## Outcome and model contracts

`CreateResponseRequest.accessPrograms` uses a distinct `AccessProgramsParam`.
Omitting the selection omits the wire key; an empty object remains an empty
object. Optional `cyber` supports exact `standard`, `daybreak_blue` and
`daybreak_red` values through `CyberAccessProgram`. Request JSON rejects supplied
outer/inner null, wrong shapes, unsupported values and unknown selection keys.
The client supplies no default or model/organization eligibility checks.

`Response.accessPrograms` uses `AccessProgramsBody`, whose supplied object requires
a recognized, nonnull cyber value. Returned extra keys remain tolerated. Outer
absence/null is accepted and normalizes to omitted model JSON, preserving the
existing Dart convention and Python compatibility. This deliberately differs from
canonical/Node required-nullable outer key presence. Explicit Standard retains
its object and remains distinct from an absent/implicit Standard selection.

The enum's standalone parser returns null for unrecognized strings. Both new leaf
parsers convert that result into contextual `FormatException`, avoiding fabricated
Standard selection or lossy unknown-value serialization. Exactly three valid
programs are representable. Const constructors, every field's serialization,
copy/clear, equality/hash, runtime-type guards and safe diagnostics are covered.
All currently exposed request/Response fields retain their existing contracts,
const construction, caller-owned collections and metadata normalization.

Existing resource methods and all six lifecycle parsers use the shared request
and Response models. Ordinary create, retrieve, cancel and list results retain
the effective selection. Plain and accumulated GA/beta SSE retain it in created,
queued, in-progress, completed, failed and incomplete responses, including usage
and terminal status. No new event or transport is needed.

## Public fixtures, documentation and example

616 deterministic public HTTP/SSE fixtures pass. The matrix covers exact request
method/path/auth/header/query/body, omitted/empty/all-three selection values,
returned absence/null/all-three values, provider-extra tolerance, request
immutability, stream override, six lifecycle events and malformed nested data,
retrieve/cancel/list, accumulated response fidelity and unknown-event raw JSON.
Existing 400 `invalid_access_program`, 400 `unsupported_access_program` and 403
`access_program_not_enabled` errors retain their current exception mappings and
do not trigger automatic selection or retries in the fixtures.

README usage and `llms.txt` link the public API and runnable offline example.
The exact README Dart block compiles with fatal-info analysis. The example sends
five injected MockClient requests, demonstrating omitted selection, an empty
selection with a synthetic server choice and all three explicit values. It
verifies effective responses and an unchanged base request, disables retries,
closes resources, requires no API key/provisioning and costs $0.

Omission defaults and explicit selection remain server decisions. The
[Daybreak guide](https://developers.openai.com/api/docs/guides/daybreak) establishes
organization/project/model access and distinguishes program selection from
approval. GPT-6 Astra and GPT-6.1 Sol use Blue selection despite requiring Red
approval for reduced refusals; neither accepts Red selection. The example's model
choices follow the guide, and no hard-coded eligibility allowlist is introduced.
Build/Launch/Grow usage tiers are separate. This adds optional fields and new
types while preserving existing constructor calls; no migration guide or version
bump is required for this slice.

## Official sources and manifest audit

Fresh toolkit fetch/review has 356 operations, 2,010 schemas and zero wire changes.
The promoted candidate matches pinned
[OpenAPI 234829e](https://github.com/openai/openai-openapi/blob/234829e2b634b8fb159df7fcddbffad204173ffd/openapi.json).
Its sole difference from 17f9a66 is the `QuestionParamChoice.choices` description.
Metadata preserves the prior snapshot's actual fetch time and pinned provenance.
The GA/beta access-program contracts are unchanged. Latest official releases
remain Python 3.26.0 and Node 7.30.0 as rechecked October 7.

[Python request](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_create_params.py),
[Python Response](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response.py)
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts)
confirm distinct request/returned shapes and all three values; the Python outer
Response default supports the deliberate omission tolerance. Describe and
scaffold dry-run reviewed the real request leaf after mapping registration.

Six real GA/beta leaf mappings were registered. Two old parent skips justified
only by `allOf` were replaced because the current toolkit flattens composition;
four real GA/beta request/Response parent mappings now verify this surface. No
new exclusions were added. The sibling `open_responses` published schema has no
access-program surface, so no speculative sibling API was added.

Full toolkit verification remains diagnostic: implementation 126 errors,
22 warnings, 167 infos; consistency 19 warnings. Relative to the previous
82/10/133 baseline, the new parent mappings expose 42 existing errors, 12 warnings
and 34 infos. Older request `user`/`prompt`/`conversation` gaps and returned safety
identifier, top log probabilities, maximum tool calls, prompt/text/tool settings,
completed time and conversation remain in the complete-parity inventory. Existing
type/requiredness choices and scanner limits for concatenated diagnostic helpers
also remain visible; this ticket does not claim complete Responses parent parity.

Two additional enum diagnostics reflect the toolkit's requirement for a named
`unknown`/`unspecified` sentinel, although the documented core convention permits
a nullable parser fallback. The tested `_ => null` parser meets that convention
without adding a constructible invalid program. Both diagnostics remain visible;
no skip hides them. Exports, documentation and README checks pass.

## Final validation and independent reviews

- 168 new model contract cases pass, including all 32 request and 26 response
  fields, nullable clearing, const construction, full wire/value/hash behavior,
  subclass symmetry, collection ownership and safe diagnostics.
- 616 new public HTTP/SSE fixtures pass; 784 new tests in total. Requirements and
  engineering reviewers independently ran the focused suites and local example.
- Format checked 471 files with zero changes; `dart fix --apply` had nothing to
  fix; full package `dart analyze --fatal-infos .` passed.
- Full package unit suite: 6,152 passed, two existing environment-dependent skips.
- Exact README Dart usage compiles; the offline example runs successfully with
  five local requests. No API calls, provisioning, package publishing or version
  bump occurred; API cost is $0.
- Full toolkit scope retains the diagnostics classified above; the four new
  object leaf mappings have no diagnostics. Exports/docs/README checks pass.
- `git diff --check` passes.

Requirements and engineering reviewers have independently inspected the combined
source, runtime, fixture, README/llms and example boundary. Test fixture issues
(missing required cache TTL and an empty-map type) were corrected by the model
implementation agent; both reviewers reran the completed cases. Both reviewers
approved the final combined diff and acceptance record with no remaining
actionable findings. The specification status table was corrected to record
#338 merged and #339 implemented/validated. #339 closes only after implementation
merge; tool search #340 follows this slice.
