# Use canonical cache retention wire values

Status: implemented and independently reviewed; awaiting PR merge.
GitHub: [#321](https://github.com/davidmigloz/ai_clients_dart/issues/321).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CACHE-005.
Dependencies: None.

## Demonstrable outcome

Existing retention values emit in_memory consistently; legacy hyphen input still parses.

Through the public enum, Chat create/stream requests, returned Responses and their
completed-event echoes, and GA/beta compaction, input spelling compatibility is
shared and output is canonical. Responses creation-request retention remains
CACHE-006 in #322; this ticket adds no new request fields.

## Acceptance criteria

- [x] Implement every observable requirement in CACHE-005 through the public API.
- [x] Exact Chat/Responses/compaction fixtures; unchanged 24h and unknown fallback; remove obsolete spelling exceptions.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Enum names stay stable; document changed serialized string.
Keep the existing enum order, `24h`, and unknown fallback. Holder fields retain
their existing omission/null/copy-clearing behavior. Remove the manifest spelling
skip and compaction's separate mapping; register identical canonical/beta enums.
Explain that retention is the deprecated maximum-policy control, independent of
the modern minimum TTL, and respect model-specific support in examples.

The audit found pre-existing Chat request equality compares only model/messages.
Complete that contract with CACHE-004 in #322, which adds a Chat cache-options
field; this spelling-only ticket must not introduce a one-field partial fix.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Implemented on `fix/openai-cache-retention`. All acceptance criteria are verified.
The [review and acceptance evidence](../reviews/03-cache-retention.md) records
1,872 passing unit tests, two existing skips, clean analysis, public GA/beta
fixtures, and both independent reviews. Wider toolkit diagnostics remain visible;
there are no retention findings. No live API calls or package release were made.
Issue #321 remains open until its implementation PR merges.
