# Async function/custom tools and replay

Status: complete; [PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346) merged.
GitHub: [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-ASYNC-01–03.
Dependencies: None.

## Demonstrable outcome

Define async tools, recognize their calls and return results using the original call ID while the model continues.

## Acceptance criteria

- [x] Absent, false and true async flags survive function/custom definitions, namespaces, all input/output/conversation call variants and public convenience factories; supplied null/wrong types fail.
- [x] Direct custom_tool_call input parses; function-call replay preserves agent and every supported field alongside async.
- [x] Public create/createStream, item-added/done and completed lifecycle fixtures retain async; accumulator final response retains it without claiming partial call reconstruction.
- [x] Offline demonstration returns a saved tool result against the latest response; supported-model/direct-call/multi-agent restrictions are documented.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Additive flags and missing typed custom input. Retain existing constructors; no automatic tool runner or paid tool call.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/09-async-tools.md) records full changed-model
contracts, 2,903 passing unit tests, clean analysis, real schema mappings and
the offline runnable example. Independent requirements/engineering reviews approve the final combined change;
completed with implementation PR merge.

Implementation [PR #346](https://github.com/davidmigloz/ai_clients_dart/pull/346) merged after applicable CI passed; #334 is closed.
