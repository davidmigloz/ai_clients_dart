# Decisions implementation review and acceptance evidence

Reviewed October 7, 2026 against [DEC-01–DEC-11](../decisions.md).
Tracking: [#318](https://github.com/davidmigloz/ai_clients_dart/issues/318),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `feat/openai-decisions`. The ticket remains open for merge.

## Implemented outcome

The public package exposes `client.decisions.create(...)`, typed text and inline
image inputs, all three question types, all four answer types, a forward-compatible
unknown answer, and complete Decisions token usage. The shared optional
`InputTokensDetails.cacheWriteTokens` addition preserves existing Responses and
provider-compatible payloads. No existing public API was broken.

The runnable example demonstrates questions, typed answers, refusals, usage, and
an optional local PNG converted to a MIME/base64 data URL. README, public barrels,
client/resource wiring, documentation/example mapping, and all 27 reachable
OpenAPI schemas are registered. The October 7 pinned candidate is promoted, with
the previous fetch timestamp preserved in metadata history.

## Acceptance and validation

All ticket acceptance criteria are met by the public-boundary fixtures and checks
below. There are 51 focused Decisions tests; the full package run also exercises
existing Responses/provider usage compatibility.

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed; formatted the new code |
| `dart fix --apply` | Applied three style fixes in Decisions tests |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 1,783 passed; two existing environment-dependent tests skipped |
| Independent focused Decisions and Responses unit run | 388 passed |
| `dart test --reporter=expanded --tags integration test/integration/decisions_test.dart` | One live test passed after the user authorized a low-cost call; measured usage and cost below |
| Toolkit `verify --checks all --scope all` against promoted snapshot | Exports, docs, and README passed; known implementation diagnostics remain as detailed below |
| `git diff --check` | Passed |

Dart commands run from `packages/openai_dart`. Toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.
Fetch, review, describe, and a Decisions scaffold dry-run preceded implementation.
The source-backed unions were implemented by hand where scaffold output did not
represent the API's primitive and array shapes correctly.

Fixtures assert exact JSON, ordered mixed answers, required nullable answer names,
string/boolean distinction, fractional scores, all usage counters, permitted empty
input, future model IDs, defensive list snapshots, and nested unknown JSON
immutability/equality. Malformed known values fail clearly. HTTP fixtures verify
URL/body/headers, absence of a beta header, typed error metadata, closed-client
guards, and deterministic cancellation without losing the request body.

One additional review by the implementing coordinator caught an optional-nullable
field mismatch: `safety_identifier: null` must parse. The parser was corrected,
an explicit fixture was added, and the full suite then passed.

## Independent reviews

Two reviewers independently inspected the actual source, including untracked new
files, rather than relying on author summaries:

- Requirements review: DEC-01–DEC-11 pass. A follow-up inspection confirmed all
  reachable schema mappings, discriminators, array/primitive wrappers, example
  mapping, metadata, and semantic equality of the promoted candidate.
- Repository standards review: no actionable correctness findings. Checked
  serialization, copy semantics, equality/hashCode, defensive collections, unknown
  JSON, transport/errors/cancellation, shared usage compatibility, and docs/example.
  The reviewer also ran the 388-test focused check above.
- Final PR packaging review: scope, exports, schema mappings, metadata, examples,
  integration safeguards, and documentation links are consistent. Two stale
  roadmap entries describing Decisions and cache-write usage as missing were
  corrected to show their completed status.

No validated findings remain unresolved for this ticket.

## Visible toolkit limitations and remaining backlog

The full report has 19 implementation errors, four implementation warnings,
82 informational diagnostics, and one consistency warning. It is not a clean
full-parity report. No new exclusions were added to hide missing capabilities.

Eleven errors concern wider existing or planned work:

- Required image-generation `model` versus a nullable Dart field (one diagnostic).
- Missing `PromptCacheOptions.comparison_response_id` and its parse/serialize/copy
  paths (four diagnostics, with three corresponding equality/hash/string warnings).
- Missing Agents, Live, safety, vaults, webhook-endpoint, and webhook-event-type
  resource families (six diagnostics).

Eight errors arise from newly registering existing shared types:

- Five requiredness checks cannot express the boundary validation in
  `DecisionResponse.fromJson`: it requires every Decisions usage object/counter
  before invoking the shared parser. Shared detail fields intentionally remain
  nullable for older Responses/provider compatibility, as required by DEC-08.
- `ResponseUsage` and `OutputTokensDetails` already lack `copyWith` (two
  diagnostics); `ResponseUsage.toString` also omits its detail fields (one warning).
- Existing `ImageDetail` deliberately rejects unknown values; the generic enum
  checker expects an unknown/unspecified fallback (one diagnostic). Decisions
  reuses the existing type and closed request contract.

The consistency warning compares choice and score probability lists. Their
element types deliberately differ: choice values are strings/booleans, while
score values are integer indices with labels. This matches the pinned schema.
The optional message `type` is intentionally a fixed nonnullable getter; emitting
`message` is valid. Other informational diagnostics concern existing models.

The initial implementation used unit tests only. The user subsequently authorized
a low-cost live integration test using the existing API key. The tagged
`test/integration/decisions_test.dart` passed with exactly one request and retries
disabled. It sent a locally generated 16×16 red PNG through `imageBytes`, plus
predicate, boolean-choice, and score questions. The live response confirmed the
data URL contract, ordered typed answers/distributions, and all required usage
counters. No credentials, request headers, or raw response payloads were logged.

Reported usage: 387 input tokens, zero output tokens, zero cached/cache-write
tokens, and zero reasoning tokens. At the documented Decisions rate of
[$0.10 per million input tokens](https://developers.openai.com/api/docs/guides/decisions#pricing-and-availability),
the estimated charge is $0.0000387 (about 0.004 cents). This is a calculation from
reported usage and published pricing, not an invoice measurement. No additional
paid calls were made. The test skips when the key is missing or empty and remains
under the integration tag, outside the default unit-test run.

An independent follow-up review identified one test robustness correction:
individual refusals are valid, so the smoke test now accepts a refusal at each
position and validates scored fields conditionally. All three scored paths were
exercised in the successful live run. The request was unchanged; formatting and
analysis were repeated without a second paid call.

Package publishing and later parity milestones remain outside this ticket.
