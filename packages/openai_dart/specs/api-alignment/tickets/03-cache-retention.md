# Use canonical cache retention wire values

Status: specified; implementation queued after the container slice.
GitHub: [#321](https://github.com/davidmigloz/ai_clients_dart/issues/321).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CACHE-005.
Dependencies: None.

## Demonstrable outcome

Existing retention values emit in_memory consistently; legacy hyphen input still parses.

## Acceptance criteria

- [ ] Implement every observable requirement in CACHE-005 through the public API.
- [ ] Exact Chat/Responses/compaction fixtures; unchanged 24h and unknown fallback; remove obsolete spelling exceptions.
- [ ] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [ ] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [ ] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Enum names stay stable; document changed serialized string.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Pending. Record commands/results, remaining coverage diagnostics, review resolutions, and PR before closure.
