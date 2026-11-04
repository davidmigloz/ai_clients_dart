# Responses cache TTL, hosted usage and error review

Issue #415; parent #413. Reviewed November 4, 2026.

## Sources and scope

- [Frozen OpenAPI 2e9ebb3](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json).
- [Python 3.42.0 Response](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response.py) and [ResponseError](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response_error.py).
- [Node 7.47.0 Responses](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/responses/responses.ts).
- [Prompt caching guide](https://developers.openai.com/api/docs/guides/prompt-caching).
- Existing `open_responses/specs/openapi.json` for the sibling compatibility audit.

The review traced all 15 schemas reachable from the six scoped roots:
`PromptCacheBreakpointConfig`, `PromptCacheBreakpointParam`, `ResponseToolUsage`,
`ResponseError`, `Error-2`, and `WebSearchActionFind`. All ten affected GA/beta
schema pairs have identical contracts after normalizing the Beta reference names.
No new HTTP operation is introduced.

`Error-2` is referenced by **VideoResource**, rather than the Responses WebSocket
payload. Its actual public video retrieval path is covered. The SSE event's
`type` remains its `error` discriminator; nullable provider types belong to
failed response error objects or the retained legacy nested error payload.

## Source discrepancies

The guide advertises 12-hour caching. The pinned Config/Param breakpoint schemas
and SDK content markers support `30m`/`12h`, but the top-level
`PromptCacheTTLEnum` and SDK request options still only admit `30m`. A dedicated
`PromptCacheBreakpointTtl` represents the override. This does not widen top-level
options, legacy retention values, or Decisions' independent cache marker.

The guide also describes write-token detail counters not present in the frozen
ResponseUsage schema/SDK. This slice implements the pinned counters and does not
claim that additional guide-only reporting is exposed.

OpenResponses does not declare OpenAI's cache options, hosted-tool usage or web
search action union. Those vendor fields are not added to the sibling contract.
Its `ErrorPayload` still canonically requires a string type for nested streaming
errors; nullable provider types are explicitly documented receive tolerance.

## Requirements review

| Requirement | Evidence |
| --- | --- |
| Breakpoint lifetime | Optional 30m/12h TTL, omission/inheritance, const legacy construction, fixed mode validation, copies/clearing and enum fallback. Input/echoed text, image and file parts round-trip the marker. Public GA/beta POST and input-item retrieval fixtures cover the boundary. |
| Hosted usage | `Response.toolUsage` uses six immutable value models. Required reported counts fail contextually; optional cached/output details remain absent/unknown. Image input/output/cache breakdown and billable search counts remain separate from base-model usage. GA/beta HTTP and terminal SSE fixtures exercise serialization, copies and equality. |
| Nullable errors | Failed ResponseError preserves absent/null/text type and parameter, code/message and finite future/review metadata. Existing HTTP and flat SSE nullable parameter behavior is regression-tested. Legacy nested SSE raw error type remains available without changing the event discriminator. Video Error-2 retains nullable type/param, retry headers and review/future metadata through public retrieval. |
| Optional find URL | GA/beta shared action accepts omitted/null/text URL; pattern remains required. Clear/copy/round-trip tests and public HTTP/SSE web-search fixtures cover it. Invalid URL types still fail contextually, including conversation retrieval. |
| Sibling audit | open_responses ErrorPayload preserves explicit null type/code/param and field presence. Header parsing/copying owns immutable maps; old const construction remains. Own model, HTTP and nested SSE tests and migration/README guidance included. |
| Consumer guidance | Offline example, existing collapsible README cache topic and example index, llms entries and migration guidance in both packages. No release/changelog edits. |

## Engineering review

This is self-review using the package/core checklists, not an independent review
or a claim of global OpenAI parity.

- Full-field equality, content hashing, optional clear semantics, diagnostics and
  exports checked for each added/changed model. Public fixtures and example use
  the package barrels. Hosted-tool models contain only immutable scalar/value
  fields; they do not retain caller-owned JSON.
- A regression exposed an existing omission in echoed input-text content. Its
  cache marker now survives parsing/serialization and participates in copies,
  equality, hashing and redacted diagnostics.
- Constructor ownership review moved new VideoError metadata construction to
  `VideoError.withDetails`, which deeply snapshots JSON/review data and headers.
  The existing scalar const constructor remains available. Parsed/copied video
  metadata and sibling error headers are immutable.
- Existing tests that asserted required find URLs or invented error type defaults
  were updated to the new contract. Malformed URL types and malformed required
  patterns still fail. No fixtures are weakened to accept invalid content.
- Existing legacy nullable/omitted ResponseError code and VideoError code/message
  tolerance is preserved and explicitly distinguished from canonical admission.
  Top-level cache option and Decisions types remain unchanged.

## Validation

- Affected OpenAI models/public paths: **950 tests pass**. Final cache/usage/error
  regressions after ownership review: **19 pass**.
- Full OpenAI unit suite: **25,268 passed, 2 skipped, 2 failed**. Both failures are
  in unchanged `http2_evaluation_test.dart`: bounded 4-MiB paused-peer observation
  timeout (line 425) and reusable HTTP/1 baseline connection count (line 509).
  Both reproduce in an isolated unchanged `d7ef952f` checkout: 21 passed, 2 failed.
- Full open_responses unit suite: **509 passed, 3 skipped**; its three new model/
  HTTP/SSE tests also pass independently.
- Analyzer and quick-fix checks pass for both packages; formatting checked.
- Offline `responses_cache_usage_example.dart` succeeds with one MockClient POST,
  displaying synthetic separate counts and an unknown cached count. No API key,
  live hosted tools or API charges.

## Toolkit and #427 handoff

Fetch/review/describe/scaffold/verify were run with the pinned source in an
isolated `/tmp/openai-responses-cache-usage` copy. The reviewed candidate was
promoted there before verification. The `ResponseToolUsage` scaffold dry run
succeeded; hand-written models supply complete value/copy/validation behavior.
Canonical global spec/manifest/source metadata promotion remains assigned to
#427. [Scoped manifest mappings](02-responses-cache-usage-manifest.json) include
all new usage models and GA/beta bindings, the breakpoint TTL and Error-2.

Whole-snapshot verification reports 1,121 implementation errors, 177 warnings and
279 infos; consistency has no errors and 114 warnings. Docs/README pass with
52 collapsible usage subsections. Eight existing internal helper libraries are
flagged by the export checker; public type consumption compiles.

There are no implementation errors for the new hosted-tool models or breakpoint
fields. Scoped error diagnostics include the verifier's inability to extract
fields from the nullable ResponseError/BetaResponseError `anyOf` wrapper, plus
retained legacy nullable VideoError code/message fields. These are recorded
rather than suppressed. This is not a passing global alignment gate; final
cross-ticket reconciliation belongs to #427. CI and PR review remain required.
