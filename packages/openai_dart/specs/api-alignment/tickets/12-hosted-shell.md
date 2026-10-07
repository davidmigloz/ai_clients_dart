# Hosted/local shell configuration, replay and streams

Status: specified; implementation pending.
GitHub: [#337](https://github.com/davidmigloz/ai_clients_dart/issues/337).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-SHELL-01–03.
Dependencies: Container [#320](https://github.com/davidmigloz/ai_clients_dart/issues/320), merged in #327.

## Demonstrable outcome

Configure hosted or local shell with skills, return typed local results and observe command/output progress.

## Acceptance criteria

- [ ] All three definition environment variants and directional input/output variants are exact; reuse container leaf memory/network/skills and distinct local skills.
- [ ] Typed input/conversation calls/results, required nullable output keys, created_by/caller/agent metadata, exit/timeout outcomes and forced shell choice retain full fidelity.
- [ ] Public SSE parses all five event types with interleaved command indices, stdout/stderr fragments, empty delta and obfuscation; completed lifecycle response retains shell metadata.
- [ ] Offline example configures a hosted environment and builds synthetic local continuation; no arbitrary proposed commands execute automatically.
- [ ] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [ ] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [ ] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Targeted contextual requiredness/serialization corrections need migration. No new general shell accumulator or execution engine. No paid container acceptance requirement.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

Pending implementation, verification and independent review. Link the evidence
record and PR here when complete; close the issue only after merge.
