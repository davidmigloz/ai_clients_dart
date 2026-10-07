# Support complete and streamed chat audio

Status: implemented and independently reviewed; PR handoff in progress.
GitHub: [#324](https://github.com/davidmigloz/ai_clients_dart/issues/324).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CHAT-003–005.
Dependencies: Complete/partial audio shapes precede accumulation inside this complete feature slice.

## Demonstrable outcome

Inspect audio completions, replay id-only references, and reconstruct interleaved streamed audio with stable partial snapshots.

## Acceptance criteria

- [x] Implement every observable requirement in CHAT-003–005 through the public API.
- [x] Exact request projection; local SSE data/id/transcript/expiry chunks; late expiry; interleaved choices; empty/missing distinction; snapshots/reset; complete conversion and explicit incomplete-audio failure.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Keep text-only conversion/provider extensions; document the new incomplete-audio conversion boundary. Do not make paid audio for unit acceptance.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

[Acceptance evidence](../reviews/06-chat-audio.md) records 2,282 passing unit
tests, clean analysis, full public/model regressions, resolved review findings,
README/migration/runnable example, and the authorized one-request live smoke
(conservative $0.008544). Toolkit wider diagnostics remain explicit; no exclusions
were added. PR linkage will be recorded before handoff; close only after merge.
