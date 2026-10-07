# Require explicit image model selection

Status: specified; implementation queued after the container slice.
GitHub: [#326](https://github.com/davidmigloz/ai_clients_dart/issues/326).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), IMG-01–04.
Dependencies: None.

## Demonstrable outcome

Generation and multipart editing always send an explicit selected model; JSON editing keeps its separate server-default contract.

## Acceptance criteria

- [ ] Implement every observable requirement in IMG-01–04 through the public API.
- [ ] Construction/parsing/copy/JSON/multipart/stream model fidelity; arbitrary model IDs; JSON-edit omission; compile affected examples and migration snippets.
- [ ] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [ ] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [ ] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Targeted breaking requiredness follows canonical API/documentation despite optional SDK signatures; document omitted/null caller migration. No invented generation default.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Pending. Record commands/results, remaining coverage diagnostics, review resolutions, and PR before closure.
