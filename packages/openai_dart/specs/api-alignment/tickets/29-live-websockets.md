# Run primary and sideband Live conversations with complete event codecs

Status: specified; runtime implementation pending.
GitHub: [#371](https://github.com/davidmigloz/ai_clients_dart/issues/371).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), LIVE-WS-01–04, LIVE-EVENT-01–04, LIVE-WORK-01–02.
Dependencies: [28](28-live-http.md) for complete shared session/configuration models.

## Demonstrable outcome

Run primary and sideband Live conversations with complete event codecs through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [ ] Injected primary/sideband connections preserve exact sessions/attach routes, auth/org/project headers, custom prefixes/encoded IDs and optional sideband graceful_close; no model query or duplicate startup on media/sideband. Document three-second SIP progress replay with original event IDs and explicit application deduplication, never audio/action replay.
- [ ] Role-safe writers cover 11 primary/9 sideband commands and full fields/correlation/contracts; shared fork codecs avoid a duplicate hierarchy. No sideband start/audio append, Realtime commit or writable DTMF command.
- [ ] All 22 received components plus unknown immutable events/metadata are public. Resolve the allOf alias and document 18 canonical/15 SDK sideband mismatch, supporting reflected audio/DTMF/SIP progress without a blanket event_id.
- [ ] Client and reflected audio append use directional contracts. Primary formats versus sideband PCM16LE 24 kHz/timestamps are exact; raw Base64 bytes, delivery order and frame gaps preserve original data.
- [ ] Response.event keeps any finite nested object, even without type. Outer event_id is required nonnull, client_event_id optional nonnull and delegation_id optional nullable. Compact snapshots retain raw data rather than pass through strict standalone Response.
- [ ] Live errors/usage are distinct from HTTP/SSE/backend token billing. Canonical code string and guide-only required-present code:null compatibility are separately tested; wrong/missing known fields fail. A command error or moderated cutoff does not close the session automatically.
- [ ] Session.closed confirms finalization despite active snapshot status; premature socket close remains unconfirmed. Install the final listener before sending close, reject new work while closing and test immediate final events. Bounded drain/abort/local close releases owned resources once, with borrowed clients preserved.
- [ ] Browser policy rejects all nonempty headers before auth/connect; use trusted server signaling/caller data channel or injected backend proxy. No invented Live ephemeral keys, automatic reconnect/start/audio/tool replay or action runner.
- [ ] Concurrent taps support application plus transcript helper. Offline primary/sideband and manual delegation examples keep IDs/action ownership; submit every pending function result before one explicit response.create, without waiting for a nonexistent item-create ack.

- [ ] Changed models cover every declared field/variant, optional/null/absence, immutable parsed ownership, complete copy/clear, equality/hash and safe diagnostics. Known malformed values fail contextually; future receive-only metadata and closed writable admission remain distinct.
- [ ] Public factories/resources/parsers and real canonical manifest mappings are verified; no fake components or diagnostic exclusions. README/llms, runnable offline example and any actual breaking migration are complete.
- [ ] Focused public fixtures pass VM/Chrome JavaScript/Wasm where applicable; format → fix → fatal-info analysis, package unit suite and full OpenAPI toolkit evidence are recorded. Unrelated diagnostics/remaining parity gaps remain visible and classified.
- [ ] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved; final-head CI is green before merge.

## Compatibility and boundaries

Follow the specification's canonical/guide/SDK discrepancy decisions and exact
request versus receive-only policies. Preserve old calls where practical; document
actual enum/constructor/return-type corrections rather than inventing breakage.
Every requirement assigned above has public fixtures and acceptance evidence.

Use deterministic MockClient/local HTTP/SSE/WebSocket or injected-connector/channel
fixtures under `test/unit/`. No API key, real recording upload, call/media action
or paid live acceptance is required. Live tests authored later remain tagged in
`test/integration/`; a selected bounded smoke may use the user's existing low-cost
authorization, but never run the full integration suite. Package publishing/version
bumps and unrelated API families are outside this ticket.

## Completion evidence

Implementation acceptance evidence will be added when the runtime PR is reviewed.
This planning ticket is unimplemented; its unchecked criteria are not test results.
