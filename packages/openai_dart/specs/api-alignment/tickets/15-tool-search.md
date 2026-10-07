# Client-discovered tool definition and call fidelity

Status: implemented, verified and independently reviewed; PR pending.
GitHub: [#340](https://github.com/davidmigloz/ai_clients_dart/issues/340).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 3 Responses](../responses.md), RESP-SEARCH-01–02.
Dependencies: [#334](https://github.com/davidmigloz/ai_clients_dart/issues/334) (nested async definitions).

## Demonstrable outcome

Return client-discovered tools with complete definitions and the original search call ID.

## Acceptance criteria

- [x] Request search arguments require an object; returned required arguments preserve arbitrary JSON including null/scalar/list. Returned execution/status/call_id retain contextual requiredness and null.
- [x] Discovered namespace dotted names and all nested function/custom options survive request/output/conversation parse, copy and serialization with contextual requiredness.
- [x] Public hosted/client search continuation fixtures retain original call_id, execution:client and complete tool lists, including empty optional request metadata and returned null call ID.
- [x] Offline example returns discovered tools; sibling open_responses audit and migration for tightened contextual constructors are recorded.
- [x] Changed models have complete contextual serialization, copy/clear, equality/hash and safe diagnostics across all old/new fields; known malformed variants fail and intended provider tolerance stays compatible.
- [x] Public factories/resources/stream parsers, exports and real manifest mappings are verified. README/llms, an offline runnable example and any required migration guide are complete.
- [x] Relevant focused unit fixtures, format/fix/analyze, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Targeted breaking fidelity corrections require migration guidance. Request calls
now require object-shaped arguments. Manually constructed returned output,
input-resource and conversation items require execution, status, call ID and
their arguments/tools; call ID and returned arguments still accept explicit null.
Returned arguments broaden to arbitrary JSON. The input-items resource now
returns `ToolSearchCallResourceItem`/`ToolSearchOutputResourceItem`, rather than
the writable parameter types, and these additions extend the sealed `Item`
hierarchy. Exhaustive switches and manual subtype casts need migration.

Do not impose ordinary function naming or top-level requiredness on discovered
nested definitions. The returned schema references ordinary namespace definitions,
but the writable discovered schema and SDK string typing permit dotted/minimal
nested functions; the guide establishes loaded-tool continuation. Applying
discovered parsing to returned namespaces is an explicit compatibility inference.
Top-level returned functions retain the
canonical required-nullable parameters/strict keys. The older `apply_patch`
ResponseTool union gap remains outside this slice; this ticket does not establish
complete Responses tool parity.

Use deterministic public MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement. Any optional live
smoke uses the user's existing bounded-spend authorization, is run by root with
retries disabled and cleanup, and never runs the full integration suite.
Package publishing and unrelated API families are outside this ticket.

## Completion evidence

[Acceptance evidence](../reviews/15-tool-search.md) records 376 item-model cases,
133 definition cases and 3,491 public fixtures: 4,000 new deterministic tests.
Full package validation passes with 10,152 unit tests and two existing skips;
476-file formatting and fatal-info analysis are clean. The two-request offline
example runs for $0. Full toolkit verification remains diagnostic (135 errors,
22 warnings, 199 infos; consistency 26 warnings); the evidence classifies new
scanner diagnostics without exclusions. Both independent reviewers approve the
final combined diff after all findings were resolved. The PR link remains
pending. Close #340 only after merge; Responses WebSocket
sessions #341 follow this slice.
