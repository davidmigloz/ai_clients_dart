# Honor quota failures and server retry hints

Status: implemented and independently reviewed; PR #332 open for review.
GitHub: [#325](https://github.com/davidmigloz/ai_clients_dart/issues/325).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), RETRY-01–06.
Dependencies: None.

## Demonstrable outcome

Permanent quota failures stop replaying; complete server retry hints are honored or exposed without early replay, including pre-stream errors.

## Acceptance criteria

- [x] Implement every observable requirement in RETRY-01–06 through the public API.
- [x] Each permanent structured code/type; transient/unknown POST429; GET/POST503; disabled/exhausted retries; long-hint refusal without sleeps; controlled timers/abort; standard/ms/fraction/date headers and streaming boundaries.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Preserve existing non-idempotent, cloneability, and after-output replay restrictions. Do not copy conflicting SDK fallback behavior.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

[Acceptance evidence](../reviews/07-retry-guidance.md) records 2,454 passing
unit tests, clean analysis, controlled public timing/error/stream fixtures,
independent approvals with all findings resolved, and README/migration/local
example updates. The example ran without API access or cost. Wider toolkit
diagnostics are unchanged and explicit; no skips/exclusions were added. [PR #332](https://github.com/davidmigloz/ai_clients_dart/pull/332) is open for review; close only after merge.
