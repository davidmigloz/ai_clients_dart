# Align cache controls and diagnostics

Status: specified; implementation queued after the container slice.
GitHub: [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CACHE-001–004, CACHE-006.
Dependencies: [Cache retention correction #321](https://github.com/davidmigloz/ai_clients_dart/issues/321)
for the deprecated Responses retention control.

## Demonstrable outcome

Configure Responses cache prewarm/comparison, inspect typed cache diagnostics, and send narrower Chat cache options.

## Acceptance criteria

- [ ] Implement every observable requirement in CACHE-001–004, CACHE-006 through the public API.
- [ ] GA/beta ordinary and stream request fixtures; all diagnostic variants/reasons; false/zero/empty/omitted/null; comparison echo; immutable unknown payloads.
- [ ] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [ ] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [ ] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Distinct Responses cache-options type replaces the narrower request field; document constructor migration. Preserve old/provider response payloads.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Pending. Record commands/results, remaining coverage diagnostics, review resolutions, and PR before closure.
