# Persistent reasoning configuration updates

Status: specified; implementation pending.
GitHub: pending issue creation after independent planning review.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-CONFIG-01–02.
Dependencies: None.

## Demonstrable outcome

Change subsequent reasoning effort through a conversation item without changing request-level effort or cached prefix.

## Acceptance criteria

- [ ] Input configuration_update supports nullable optional id and optional nonnull reasoning with only nullable optional effort; returned item requires id.
- [ ] Omitted, empty, nullable effort/id and malformed required/supplied objects have contextual fixtures.
- [ ] Public Responses create/list-input and conversation create/list/retrieve parse and emit exact shapes. No invented OutputItem or dedicated streaming event.
- [ ] Offline example reuses stable request-level effort and shows successive configuration updates; single-agent persistence is documented.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive contextual DTOs. Existing broad ReasoningConfig is not reused for a narrower wire object. Distinct from issue #316 runtime client updates.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
