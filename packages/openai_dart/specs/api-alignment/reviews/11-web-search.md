# GA web-search acceptance

Status: merged and complete.
[PR #348](https://github.com/davidmigloz/ai_clients_dart/pull/348) merged at
`43b826f31c0629f588861a867ff9b997c63ec58e` after all CI checks passed, closing #336.
Tracking: [#336](https://github.com/davidmigloz/ai_clients_dart/issues/336),
parent [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Requirements: [RESP-WEB-01–03](../responses.md#web-search).
Implementation branch: `feat/openai-web-search`.

## Outcome and contextual contracts

`ResponseTool.webSearch()` and `WebSearchTool()` default to GA `web_search`.
Both GA definitions (`web_search`, `web_search_2025_08_26`) and both explicit
preview definitions (`web_search_preview`, `web_search_preview_2025_03_11`)
parse and preserve their discriminators. GA supports external access, context
size, nullable filters and approximate location, and guide-backed block lists,
return budgets, content types and image settings. Omission injects no defaults;
false, empty lists/objects and accepted nullable values have exact fixtures.
Preview rejects supplied GA-only controls instead of implying service support.
Existing preview content types and caller-owned collection behavior remain valid.

`WebSearchFilters` freezes both domain lists. `WebSearchImageSettings` has optional
nonnull positive max-results and boolean caption, without invented requiredness or
defaults. `WebSearchReturnTokenBudget` accepts only `default` and `unlimited`.
The existing string context-size API remains source-compatible and validates
low/medium/high. Location's type is optional when parsing; its established fixed
approximate serialization remains, including empty location normalization to
`{'type': 'approximate'}`. Nullable scalar metadata normalizes null to omission.

`ResponseToolChoice.webSearch()` supports GA `web_search` and both explicit
preview choices. Dated GA definitions do not imply a dated forced-choice wire
value. Existing mode/function/allowed/programmatic choices remain unchanged.

Output, input history and conversation web-search calls retain ID, beta agent,
all five statuses, actions and results. `WebSearchCallStatus` replaces the generic
item status on existing output/conversation call fields. `WebSearchCallItem`
provides typed direct input and returned input-list parsing. Both existing call
DTOs provide `toWebSearchCallItem()` retaining every supported field. Canonical
`Item`, `ItemResource` and `ConversationItem` reference the same WebSearchToolCall
shape; the separate Agents WebSearchCallItemResource family is not substituted.

Search actions retain queries, deprecated query and URL sources. Open-page URL
is optional nullable; find-in-page URL/pattern are required. Image results require
image and source website URLs, with optional thumbnail/caption. Absent/null image
metadata normalizes to omission as a client compatibility decision, not a schema
assertion. Future actions/results recursively freeze raw JSON and use deep value
equality/hash. No text-result schema is invented. New leaf collections and parsed
result lists are unmodifiable; existing const call constructors retain caller-owned
lists, documented as stable while used as values/map keys. Every changed field
participates in copy/clear, equality/hash, JSON and safe diagnostics.

Known malformed supplied values fail with contextual FormatException. Existing
optional status/agent tolerance is retained consistently across output/input/
conversation DTOs; null normalizes to omission, and unknown status uses the enum
fallback. Actions/results are optional nonnull when supplied. Opaque queries,
patterns, URLs, captions and raw JSON are summarized in diagnostics.

All four new canonical Includes and two existing legacy values serialize exactly.
Public create/createStream send JSON includes; retrieve/list-input use repeated
`include[]` query parameters, including empty/omitted and existing pagination.
REST, input listings, conversation create/items create/list/retrieve, item-added/
done events, completed events and final accumulator responses preserve metadata.

## Official sources and discrepancies

Fresh October 7 toolkit fetch/review matches canonical
[OpenAPI ee483b4](https://github.com/openai/openai-openapi/blob/ee483b4b26b2695fedc5c8af7b187e5986bd0add/openapi.json)
semantically (356 operations, 2,010 schemas). No semantic promotion is needed;
metadata-only fetch churn was restored. Describe/scaffold dry-run reviewed the
real mapped GA schema before final verification.

Revalidated pinned [Python GA tool](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/web_search_tool_param.py),
[Python preview tool](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/web_search_preview_tool_param.py),
[Python call](https://github.com/openai/openai-python/blob/4e152cdefe1844c2d5d78653310e9b9c0195c44e/src/openai/types/responses/response_function_web_search.py),
and [Node Responses](https://github.com/openai/openai-node/blob/a4942ba48e999f9f637f81c5c925ed91b326343f/src/resources/responses/responses.ts).
Those SDKs require call action; canonical makes it optional, which this slice
follows. Python optional action-member annotations accept null more broadly;
canonical and Node establish optional nonnull search queries/query/sources.
Preview requires location type upstream; the shared parser retains the established
GA-compatible missing-type tolerance and always serializes approximate type.

The [official guide](https://developers.openai.com/api/docs/guides/tools-web-search)
documents block lists, return budgets, GA image controls/results and forced GA
choice ahead of the canonical/pinned SDK tool/result definitions. These are
explicit guide-backed extensions, not excluded spec gaps. Documentation records
scheme-free domains (up to 100 per allow/block list, both can coexist), positive
image count, GPT-5+ reasoning hosted-GA budget support and selective unlimited
budget usage. No automatic budget, model allowlist or remote image fetch is added.

## Manifest and full verification

Thirty-two new mappings cover real GA/beta definitions, three contextual calls,
three action variants, status, locations and IncludeEnum. Inline unions/source/
filters and guide-only/future models are explicit extensions with notes. No new
exclusions or skipped schemas hide diagnostics. Exports, docs and README checks
pass.

Full implementation verification reports 66 errors, ten warnings and 118 infos;
consistency reports three warnings. Baseline #347 was 52/10/115 with two
consistency warnings. The 14 newly exposed errors are:

- Six required-status versus nullable-Dart reports across GA/beta output/input/
  conversation mappings: deliberate existing provider tolerance, recorded above.
- Six action-parser scanner false positives: its method-body extractor selects
  the named-parameter `{String context...}` block rather than the factory body.
  Actual parsers read and validate all reported fields; focused/public fixtures
  prove preservation and malformed-member failures.
- Two location reports saying no spec fields: canonical GA location is a nullable
  anyOf object/null that the verifier does not unwrap. The real preview object
  mapping and model fixtures verify every scalar and fixed type.

Added infos concern existing shared string/enum/location aliases. The new
consistency warning reflects nullable open-page URL versus required find-page URL.
The existing Item-ID warning also includes the new required-ID web-search input
mapping. Wider unrelated diagnostics remain visible in the complete-parity backlog.

## Validation and independent reviews

- Package unit suite: 3,903 passing, two existing environment-dependent skips.
- 634 new deterministic tests: 102 tool contracts, 225 call/action/result contracts,
  33 input/choice/include contracts, and 274 public REST/SSE/conversation fixtures.
- Format: 454 Dart files; final zero-change check. Dart fix applied five routine
  fixes; package fatal-info analysis is clean.
- Exact new README and migration after-snippets compile with fatal-info analysis.
  README examples table, migration, public docs and llms match the implementation.
- Offline example passes two MockClient REST/SSE requests, checks exact controls,
  and prints typed sources/images and a retained future result. No live service
  behavior is claimed; no API key use, external API calls or charges.
- Requirements reviewer independently ran all 634 focused fixtures and the offline
  example, and found no actionable contract or public-wiring findings. Stale
  roadmap inventory bullets for merged #335 and implemented #336 were corrected.
- Engineering reviewer verified the combined implementation, tests, mappings and
  docs. Sealed-parent subtype enumeration was corrected; no actionable findings
  remain. Both reviews approve the final combined diff.

Issue #336 closed after implementation merge. Hosted/local shell #337 follows.
