# GA web-search controls, actions and results

Status: implemented, verified, and independently reviewed; merge pending.
GitHub: [#336](https://github.com/davidmigloz/ai_clients_dart/issues/336).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-WEB-01–03.
Dependencies: None.

## Demonstrable outcome

Configure GA filtered/image search and inspect sources, action metadata and complete results through ordinary or streamed Responses.

## Acceptance criteria

- [x] All four GA/preview discriminators parse; convenience default is GA with explicit preview compatibility and migration.
- [x] Exact request fixtures cover access, context size, nullable filters/location and guide-only block list, budget, content types and image settings without injecting defaults.
- [x] All five statuses, three action variants, deprecated query, sources, image/unknown results and beta agent survive response/conversation and completed-stream parsing.
- [x] All four missing canonical Includes serialize through create/createStream/retrieve/list-input; existing legacy strings remain unchanged.
- [x] Guide/schema/SDK differences and chosen image metadata null policy are explicit; offline example demonstrates filters/images.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Targeted GA default behavior change with migration. Preserve explicit previews. Guide-only extensions are recorded, not hidden through manifest exclusions.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/11-web-search.md) records exact contextual
contracts, 3,903 passing unit tests, clean analysis, full toolkit diagnostics,
README/migration guidance, the offline example, and independent reviews. Close
the issue only after implementation merge.

Implementation [PR #348](https://github.com/davidmigloz/ai_clients_dart/pull/348)
is open for review; #336 closes only after merge.
