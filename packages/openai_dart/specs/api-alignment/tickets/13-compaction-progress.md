# Compaction progress events

Status: implemented, verified and independently reviewed; merged in #350.
GitHub: [#338](https://github.com/davidmigloz/ai_clients_dart/issues/338).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-COMPACT-01.
Dependencies: None.

## Demonstrable outcome

Observe typed compaction progress while consuming a Responses stream.

## Acceptance criteria

- [x] Public SSE decodes response.compaction.compacting with exact required sequence/output/item fields and optional beta agent.
- [x] Fixture places progress between item events and completion; progress is nonterminal and has no invented summary content.
- [x] Existing compact REST, context-management/trigger/encrypted item contracts and unknown-event fallback remain available.
- [x] Offline progress example runs without generating a large context or printing encrypted content.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

The new sealed `ResponseStreamEvent` variant requires an additional
`ResponseCompactionCompactingEvent` branch in exhaustive switches. Applications
that previously matched this discriminator inside `UnknownEvent` should migrate
to the typed event. The wire contract and unrelated unknown-event fallback stay
compatible. No duplicate compaction implementation or paid large-context test.

The existing `CompactionTriggerItem` DTO still omits the optional canonical
trigger `id`. This gap remains outside the progress-event slice; raw history
replay preserves provider IDs. The sibling `open_responses` published schema has
no corresponding progress event, so no speculative sibling event is added.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Implementation includes 205 new deterministic tests: 63 model contract cases and
142 public REST/SSE fixtures. Focused checks cover exact GA/beta fields, required
and malformed JSON, interleaved nonterminal progress, retained compact/trigger/
encrypted-item contracts and future-event fallback. [Acceptance evidence](../reviews/13-compaction-progress.md)
records 5,368 passing unit tests, two existing skips, clean fatal-info analysis,
compiled README/migration snippets, the offline example, full toolkit diagnostics
and independent requirements/engineering approvals.

Implementation [PR #350](https://github.com/davidmigloz/ai_clients_dart/pull/350)
merged October 7, 2026 at 19:49:04 UTC after green CI, closing #338.
Merge commit: `4110c174b6b84947cd609f59a0104cacc8b6373c`. Access programs [#339](https://github.com/davidmigloz/ai_clients_dart/issues/339)
follow this slice.
