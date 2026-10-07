# Honor quota failures and server retry hints

Status: specified; implementation queued after the container slice.
GitHub: [#325](https://github.com/davidmigloz/ai_clients_dart/issues/325).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), RETRY-01–06.
Dependencies: None.

## Demonstrable outcome

Permanent quota failures stop replaying; complete server retry hints are honored or exposed without early replay, including pre-stream errors.

## Acceptance criteria

- [ ] Implement every observable requirement in RETRY-01–06 through the public API.
- [ ] Each permanent structured code/type; transient/unknown POST429; GET/POST503; disabled/exhausted retries; long-hint refusal without sleeps; controlled timers/abort; standard/ms/fraction/date headers and streaming boundaries.
- [ ] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [ ] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [ ] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Preserve existing non-idempotent, cloneability, and after-output replay restrictions. Do not copy conflicting SDK fallback behavior.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Pending. Record commands/results, remaining coverage diagnostics, review resolutions, and PR before closure.
