# Compaction progress events

Status: specified; implementation pending.
GitHub: pending issue creation after independent planning review.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-COMPACT-01.
Dependencies: None.

## Demonstrable outcome

Observe typed compaction progress while consuming a Responses stream.

## Acceptance criteria

- [ ] Public SSE decodes response.compaction.compacting with exact required sequence/output/item fields and optional beta agent.
- [ ] Fixture places progress between item events and completion; progress is nonterminal and has no invented summary content.
- [ ] Existing compact REST, context-management/trigger/encrypted item contracts and unknown-event fallback remain available.
- [ ] Offline progress example runs without generating a large context or printing encrypted content.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive stream variant. No duplicate compaction implementation or paid large-context test.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
