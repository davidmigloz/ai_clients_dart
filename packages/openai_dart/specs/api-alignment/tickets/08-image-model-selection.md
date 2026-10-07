# Require explicit image model selection

Status: merged in PR #333 after all CI checks passed; #326 closed.
GitHub: [#326](https://github.com/davidmigloz/ai_clients_dart/issues/326).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), IMG-01–04.
Dependencies: None.

## Demonstrable outcome

Generation and multipart editing always send an explicit selected model; JSON editing keeps its separate server-default contract.

## Acceptance criteria

- [x] Implement every observable requirement in IMG-01–04 through the public API.
- [x] Construction/parsing/copy/JSON/multipart/stream model fidelity; arbitrary model IDs; JSON-edit omission; compile affected examples and migration snippets.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Targeted breaking requiredness follows canonical API/documentation despite optional SDK signatures; document omitted/null caller migration. No invented generation default.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

[Acceptance evidence](../reviews/08-image-model-selection.md) records 2,537
passing unit tests, clean analysis, all public request paths, complete changed-model
contracts, independent approvals, README/migration/current examples and a runnable
local demo with no API charges. Wider toolkit findings remain explicit; no
skips/exclusions were added. [PR #333](https://github.com/davidmigloz/ai_clients_dart/pull/333) merged October 7, 2026 (commit `5eae6db755775d904cfe19df3f22e1bd26dedb73`), closing #326.
