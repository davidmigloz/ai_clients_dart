# Signal Live WebRTC and SIP sessions and control stored recordings

Status: implemented and independently approved; runtime PR merge gate pending.
GitHub: [#370](https://github.com/davidmigloz/ai_clients_dart/issues/370).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), LIVE-HTTP-01–04, LIVE-CONFIG-01–04.
Dependencies: None; incoming-call example reuses merged signed receiver [#357](https://github.com/davidmigloz/ai_clients_dart/issues/357).

## Demonstrable outcome

Signal Live WebRTC and SIP sessions and control stored recordings through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [x] Cached Live sessions resource exposes all seven HTTP operations with exact 201/empty 200/WAV modes, encoded IDs/custom base prefixes/auth/abort/closed-client behavior and JSON/plain-text errors.
- [x] Canonical create supports WebRTC and outbound SIP despite narrower SDK helpers. Offer/answer SDP and minimal SIP response are distinct; SIP 201 means initialized, not answered, and declares no typed credentials; finite open receive-only future metadata remains intact.
- [x] Preserve conservative POST safety: ambiguous SIP timeout/connection failure gets exactly one attempt in public request-count fixtures. X-Client-Request-Id is tracing, not deduplication; safe rejected-request retry remains existing policy.
- [x] Accept has fixed live/session startup; reject status 300–699, refer nonblank target_uri and hangup no body. Example uses verified incoming data.session_id and no automatic call action.
- [x] Content returns untouched buffered/streamed stereo WAV, its own ID pattern and 503 Retry-After; no audio JSON decoding/logging. Storage false/ZDR/project policy/finalized 30-day recordings are documented.
- [x] REST WebRTC fork inherits omitted/empty settings and returns a new ID. Complete startup/media/fork/session/audio/history/delegation/frontend schemas include 13 Live tools plus nested helpers and exact open/closed/null policies; distinguish wire branches from narrower runtime support.
- [x] Immutable startup/backend-only updates and WS/media format/fork permissions have fixtures. Live custom references are open with ID length 1–128; Speech references are separately closed without an ID length limit.
- [x] Documented SIP URI/phone/UTF-8 credential and 1 MiB serialized body constraints produce safe errors. Default diagnostics and enabled logging redact credentials/SDP/audio/transcripts/instructions/IDs/future private data without changing caller wire data or DNS probing.
- [x] Offline caller-SDP example covers controls/download/REST fork and verified incoming notice at $0 cost; caller owns media, provider and service eligibility.

- [x] Changed models cover every declared field/variant, optional/null/absence, immutable parsed ownership, complete copy/clear, equality/hash and safe diagnostics. Known malformed values fail contextually; future receive-only metadata and closed writable admission remain distinct.
- [x] Public factories/resources/parsers and real canonical manifest mappings are verified; no fake components or diagnostic exclusions. README/llms, runnable offline example and any actual breaking migration are complete.
- [x] Focused public fixtures pass VM/Chrome JavaScript/Wasm where applicable; format → fix → fatal-info analysis, package unit suite and full OpenAPI toolkit evidence are recorded. Unrelated diagnostics/remaining parity gaps remain visible and classified.
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

See the [Live HTTP acceptance record](../reviews/28-live-http.md).
The package suite passes 16,967 tests with two existing skips; new common fixtures
pass VM/Chrome JavaScript/Wasm. Public canonical/source/docs evidence and independent
combined reviews approve. Final published-head CI and actual merge are separate
gates; #370 remains open until its runtime PR merges.
