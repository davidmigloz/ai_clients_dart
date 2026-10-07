# Preserve chat token details and obfuscation

Status: implemented and independently reviewed; awaiting PR merge.
GitHub: [#323](https://github.com/davidmigloz/ai_clients_dart/issues/323).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 2 correctness](../correctness.md), CHAT-001–002.
Dependencies: None.

## Demonstrable outcome

Inspect all detailed Chat token counters and control stream obfuscation without adding metadata to content.

## Acceptance criteria

- [x] Implement every observable requirement in CHAT-001–002 through the public API.
- [x] Ordinary completion plus final usage-only chunk; zero versus absence; both control booleans; empty obfuscation; copy/equality/hash; provider and embedding compatibility.
- [x] Changed models have complete serialization/copy/equality/hash/diagnostic contracts and nullable-clear semantics.
- [x] Public wiring, exports/manifest, examples/docs, and required migration guidance are complete.
- [x] Format/fix/analyze, package unit tests, applicable toolkit checks, and independent requirements/standards reviews have recorded evidence; validated findings are resolved.

## Compatibility and boundaries

Add optional fields; preserve existing provider behavior and server defaults.
Use deterministic public fixtures/MockClient/local servers. Unit tests are the default; separately authorized live tests must be bounded. Exclude unrelated API families and package publishing.

## Completion evidence

Implementation and validation are recorded in
[the review/acceptance evidence](../reviews/05-chat-usage-obfuscation.md).
2,199 unit tests pass with two existing skips, analysis is clean, and one
bounded unstored live request passed (11 input/four output tokens; conservative
$0.000003375). All independent reviewers approve; validated findings are resolved. Wider toolkit
diagnostics remain visible and recorded. Issue #323 closes when its PR merges.
