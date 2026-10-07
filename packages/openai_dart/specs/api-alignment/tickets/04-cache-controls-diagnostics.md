# Align cache controls and diagnostics

Status: implemented and independently reviewed; awaiting PR merge.
GitHub: [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CACHE-001–004, CACHE-006.
Dependencies: [Cache retention correction #321](https://github.com/davidmigloz/ai_clients_dart/issues/321)
for the deprecated Responses retention control; dependency merged in #328.

## Demonstrable outcome

Configure Responses cache prewarm/comparison, inspect typed cache diagnostics, and send narrower Chat cache options.

## Acceptance criteria

- [x] Implement every observable requirement in CACHE-001–004, CACHE-006 through the public API.
- [x] GA/beta ordinary and stream request fixtures; all diagnostic variants/reasons; false/zero/empty/omitted/null; comparison echo; immutable unknown payloads.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Complete Chat request equality/hash over every existing field when adding
  cache options; regression fixtures include differing retention and nullable clearing.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Distinct Responses cache-options type replaces the narrower request field; document constructor migration. Preserve old/provider response payloads.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Implementation and validation evidence is recorded in
[the cache-controls review](../reviews/04-cache-controls-diagnostics.md).
All acceptance criteria are verified: 2,121 unit tests pass with two existing
skips, analysis is clean, and all independent reviewers approve. Two bounded
live requests passed, used 3,222 input/five output tokens (conservative
$0.00040525), and both stored responses were deleted. Wider toolkit diagnostics
remain visible and recorded. Issue #322 remains open until its PR merges.
