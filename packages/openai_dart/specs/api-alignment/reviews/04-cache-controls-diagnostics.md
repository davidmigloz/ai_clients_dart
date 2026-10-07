# Cache-controls and diagnostics review and acceptance evidence

Reviewed October 7, 2026 against CACHE-001–004 and CACHE-006 in the
[Phase 2 specification](../correctness.md).
Tracking: [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Implementation branch: `feat/openai-cache-controls-diagnostics`.
Implementation [PR #329](https://github.com/davidmigloz/ai_clients_dart/pull/329)
merged at `7da3133539b1e60cdd2a2fbaedbad566cbb6f764` after all CI checks passed, closing #322.

## Outcome and contracts

Responses create/stream now use distinct `ResponsePromptCacheOptionsParam` with
optional mode/TTL, comparison ID, and prewarm. Empty options and explicit false
survive. Chat create/stream and compaction use the narrower mode/TTL type.
The response echo gains comparison ID without request-only prewarm. Responses
requests also accept the optional deprecated retention control; maximum retention
and minimum TTL remain independent.

`Response.promptCacheDiagnostics` supports cache miss/hit, missing comparison,
and unavailable outcomes. All nine current miss reasons have constants; future
reason strings remain exact. Future diagnostic variants retain recursively
immutable raw JSON with deep equality and stable hashing. Known malformed
variants fail instead of becoming unknown. Completed stream events retain nested
diagnostics. Diagnostic token estimates differ from actual usage counters.

New create/Chat options and returned diagnostics reject present-null or malformed
objects. Valid string-keyed dynamically typed maps normalize at these boundaries.
Inner mode/TTL/prewarm and diagnostic counts reject null; comparison ID accepts
null and normalizes to omission. Compaction retains its outer-nullable options.
Existing returned Response options tolerate outer null for provider compatibility.

All 44 Chat request fields participate in equality/hash, including provider
settings and content-based collections. Shared Chat/Responses JSON schemas and
arbitrary request metadata compare deeply with matching hashes. Response gains
full copy/clear support. Existing const holder constructors remain available;
only unknown diagnostics snapshot arbitrary JSON. Expanded holder diagnostics
summarize opaque payloads, identifiers, collections, and location/custom-mode
contents while retaining useful ordinary configuration details.

## Sources and workflow

The fresh upstream candidate remains semantically identical to canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json).
Canonical and beta cache schemas normalize identically across all 11 affected
pairs. No spec promotion or metadata-history change was needed. Fetch, review,
describe, and a wide-options scaffold dry-run preceded final verification.
The manifest registers explicit GA/beta options, discriminated diagnostics, and
open miss-reason wrappers. Internal JSON helpers join the existing helper-file
skip list; no API coverage exclusions were added.

The [prompt-caching guide](https://developers.openai.com/api/docs/guides/prompt-caching),
[diagnostics guide](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics),
[Python request types](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/response_create_params.py),
[Python response types](https://github.com/openai/openai-python/blob/v3.26.0/src/openai/types/responses/response.py),
and [Node Chat types](https://github.com/openai/openai-node/blob/v7.30.0/src/resources/chat/completions/completions.ts)
establish the contracts. The current diagnostics guide explicitly explains
comparison IDs, completed-event access, and missing/expired/inconclusive outcomes;
the stale specification caveat has been removed.

## Validation

| Check | Result |
| --- | --- |
| `dart format --show=none --summary=line .` | Passed |
| `dart fix --apply` | Applied lint-only fixes; analysis then clean |
| `dart analyze --fatal-infos` | Passed, no issues |
| `dart test --reporter=failures-only test/unit/` | 2,121 passed, two existing environment-dependent skips |
| Public request/stream fixtures | Exact GA/beta Responses create/stream and Chat create/stream bodies; all variants/reasons, false/zero/empty/omitted/cleared controls |
| Model regressions | Requiredness, dynamic JSON objects, copy clearing, every Chat field, immutable future diagnostics, nested schema/metadata equality/hash, diagnostic redaction |
| Toolkit `verify --checks all --scope all` | Exports/docs/README pass; no new cache-options/diagnostics errors or warnings |
| `generate-llms-txt` | Refreshed descriptions and token estimates |
| Isolated authorized live smoke | Passed, two bounded creation calls and both stored responses deleted |
| `git diff --check` | Passed |

Dart commands run from `packages/openai_dart`; toolkit commands run from the
repository root with
`--config-dir packages/openai_dart/.agents/skills/openapi-openai/config`.
There are 249 additional deterministic unit tests relative to merged #328.
Public Responses fixtures include every flattened required canonical response
field; lightweight model fixtures separately exercise existing lenient holders.

The user explicitly authorized low-cost API tests. Only
`test/integration/prompt_cache_test.dart` was run, with retries disabled, a
transport guard allowing at most two creation calls, `gpt-6-luna`, no reasoning,
Standard service tier, and 16 output tokens maximum. Successful raw response IDs
are captured before SDK parsing so cleanup also runs on parse failures; cleanup
attempts every recorded ID. No API key, headers, prompt, or raw responses are
logged. The example uses the same bounded workflow and cleanup.

Observed usage: 3,222 input tokens and five output tokens, with `cache_hit`.
At [current Standard rates](https://developers.openai.com/api/docs/models/gpt-6-luna),
billing every input at the higher $0.125/million cache-write rate plus output at
$0.50/million gives a conservative $0.00040525 estimate. The fixture accepts
legal absent/unavailable/missing-comparison diagnostics and does not require a
cache hit. Optional echoed comparison fields are checked only when returned;
the generated response may complete or exhaust its output budget.

## Independent reviews and resolved findings

A requirements reviewer authored none of this slice. Engineering reviewers
cross-reviewed the other author's work and the shared models. Review findings
were verified against canonical schemas, source, and public fixtures:

- Diagnostic count documentation now identifies estimates after divergence,
  rather than actual uncached/billed counts.
- New holder boundaries normalize valid dynamic string-keyed maps and reject
  non-string keys with contextual errors.
- Public Chat create/stream fixtures were added to prove the narrow controls,
  exact bodies, empty/omitted/cleared options, and absence of Responses-only fields.
- Request metadata and both structured-schema child types use shared deep
  equality/hash, including nested lists and generic maps; containing request
  map/set keys now agree.
- Expanded diagnostic strings summarize raw content, metadata, tools, routing,
  web-search location, identifiers, and custom reasoning mode. Ordinary reasoning
  configuration remains useful. Redaction regressions cover private payloads.
- The sealed parent enumerates all concrete diagnostic subtypes. Stale Chat
  manifest notes and comparison-ID documentation were corrected.
- The live test no longer requires optional echo fields or a deterministic
  generated-response completion/cache outcome. Migration snippets use the verified
  `gpt-6-luna` identifier and README explains caller-provided stable context.

The independent requirements reviewer and both cross-author engineering
reviewers approved the final source, fixtures, docs, and bounded live-test source.
No validated findings remain unresolved. The combined affected-model/resource
suite passed 746 tests after review fixes.

## Wider diagnostics and boundaries

Toolkit implementation output improves from 21 errors/four warnings to 17
errors/one warning, with 86 infos and one unchanged consistency warning.
Remaining errors cover image model requiredness, existing shared usage-model
contracts, ImageDetail fallback, six missing API resource families, and two
intentional nullable container-pagination exceptions. The remaining implementation
warning is the existing usage diagnostic string; the consistency warning is the
intentional differing choice/score probability types.

Three informational String-versus-retention-enum suggestions now include the
new Responses request member alongside existing Chat/Response fields. Existing
breakpoint naming suggestions are unchanged. Exact wire fixtures verify the
deliberate shared types. These wider findings remain visible; they are not waived
by narrowing verification scope.

The required sibling-package check found pre-existing shallow structured-schema
and generic-map equality in `open_responses`; those remain outside this ticket.
Administration, missing API families, Chat usage/obfuscation/audio, retries, image
requiredness, and package release are separate milestones. This slice changes
neither package version nor publishing state.
