# Preserve structured monitoring errors across HTTP and Responses

Status: specified and independently reviewed; implementation pending.
GitHub: [#360](https://github.com/davidmigloz/ai_clients_dart/issues/360).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 4 Webhooks and safety](../webhooks-safety.md), SAFETY-ERROR-01–04.
Dependencies: [#359](https://github.com/davidmigloz/ai_clients_dart/issues/359) for the offline investigation example (transitively 20); shared error extraction does not require safety resource calls.

## Demonstrable outcome

Inspect typed monitoring details on HTTP and failed Responses, retain canonical flat SSE errors and preserve every original failure context without implicit execution or replay.

## Acceptance criteria

- [ ] HTTP ApiException/subclasses and pre-stream extraction expose shared typed misalignment while retaining original status/code/requestId/raw body/retry classification; malformed optional detail metadata never masks the original HTTP exception.
- [ ] Failed ResponseError retains misalignment alongside its distinct code/message shape and documented legacy type/param/nullable-code input behavior. No video-only headers are invented. Public REST/failed lifecycle/SSE/WS paths verify the same values.
- [ ] Existing GA/beta WS detail/steer types are reused or extracted with compatible old imports/names/const construction and value semantics. All detail fields include open error_type, absent/null review_target, exact token validation, required steer.message and immutable future metadata.
- [ ] Nested copies/clears/fresh replacements remove stale effective parent metadata; explicit parent override priority is preserved. Exceptions/models/default automatic logs redact explanations, steer messages, tokens and sensitive identifiers without removing caller-readable data.
- [ ] Flat SSE ErrorEvent emits canonical flat code/param nullable fields/message/sequence_number, keeps optional nullable beta agent and documented legacy nested/missing-sequence compatibility with explicit presence. Future raw metadata is preserved without declaring SSE misalignment/headers.
- [ ] Targeted nullable-code/serialization corrections have before/after migration guidance and old-constructor/parser fixtures. HTTP Error, failed ResponseError, flat SSE error and WS error remain separate shapes; media/Agents/Live gaps stay inventoried.
- [ ] Public local fixtures cover 403 before stream, flat error after output,response.failed after output,WS structured block,malformed optional details and unknown classifications. Policy failure causes no 403 retry, automatic reconnect/replay/tool execution/acknowledgment/general continuation. Existing opt-in transport recovery for unrelated failures/lanes stays available; do not close a multiplexed socket solely for one blocked response.
- [ ] Offline investigation example combines typed failure information with explicit alert/case retrieval using MockClient, treats opaque steer/review_target passively and explains that the API provides no generic resume/unblock or monitoring configuration parameter.

- [ ] Changed models have contextual serialization, requiredness/null/absence, complete copy/clear/replacement, equality/hash, immutable parsed ownership and redacted diagnostics across all old/new fields. Known malformed variants fail and documented receive-only tolerance stays explicit.
- [ ] Public factories/resources/parsers, exports and real manifest mappings are verified; no fake components or exclusions. README/llms, a runnable offline example and any migration guidance are complete.
- [ ] Relevant focused VM/browser fixtures, format → fix → fatal-info analysis, the package unit suite and full toolkit scope have recorded evidence. Unrelated diagnostics remain visible and classified.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved.

## Compatibility and boundaries

Targeted breaking flat SSE nullable-code/output fixes are allowed with migration guidance; preserve documented legacy input/constructor behavior. Existing HTTP status/retry exceptions and WS envelopes remain compatible. No new exception subtype is added merely for monitoring metadata.

Use deterministic MockClient/local HTTP/SSE/WebSocket or injected-connector
fixtures under `test/unit/`. No live acceptance requirement, API key, endpoint test
delivery or paid API action. Any later live smoke uses the existing bounded-cost
authorization with explicit scope; never run the full integration suite. Package
publishing/version bumps and unrelated API families are outside this ticket.

## Completion evidence

Implementation, runtime verification and independent implementation review remain
pending. Link its acceptance evidence and PR when complete; close the issue only
after implementation merge. The planning review does not claim runtime acceptance. Planning [PR #361](https://github.com/davidmigloz/ai_clients_dart/pull/361) is open for review.
