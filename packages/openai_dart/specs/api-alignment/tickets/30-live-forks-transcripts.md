# Fork stored Live sessions and group transcripts with manual delegation

Status: implemented; local acceptance recorded below. Publication CI and merge pending.
GitHub: [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), LIVE-FORK-01–03, LIVE-WORK-03, LIVE-TRANSCRIPT-01–02.
Dependencies: [29](29-live-websockets.md), transitively [28](28-live-http.md).

## Demonstrable outcome

Fork stored Live sessions and group transcripts with manual delegation through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [x] Public forkConnection uses the exact fork WS route and distinct session.start with session:{}; finalized stored source/new ID/inherited model/voice/instructions/history and store/backend/format overrides match source.
- [x] Reuse 29 codecs and role-safe writers. No model query/new model override/WebRTC-only client permissions or automatic audio/start/tool/side-effect replay. Restoring caller state is distinct from reconnect.
- [x] Compact Responses dispatch uses lifecycle-specific views and existing granular codecs where compatible, retaining complete raw future objects. Missing type is valid raw data; malformed known fields are errors, not silent fallback.
- [x] Manual client/Responses workflows preserve interleaved IDs, one action owner, every pending function result then one continuation, no item-create ack wait, stale/canceled outcomes and separate backend/playback lifetimes.
- [x] SDK transcript grouping uses defaults and golden fake-clock fixtures for late/duplicate/out-of-order fragments, gaps, silence/backchannels, reset/flush/close/reentrancy/listener errors/timer cleanup; additive Dart caller-clock playback projection claims no SDK hardware parity, audible completion or server turn IDs.
- [x] Helpers attach/detach without stealing subscriptions or canceling other groupers; borrowed typed data-channel adapter owns listeners only and never closes caller media. No WebRTC media engine.
- [x] Offline example completes/stores original, downloads mock recording, forks and deliberately restores task state, groups captions/timing and routes manual results at $0 cost; storage/ZDR/unconfirmed close/abort cases have public fixtures.
- [x] Opt-in reconnect/bounded unsent queues/escape hatches remain retained inventory; README/llms describes actual helpers, constraints and privacy without claiming complete SDK recovery parity.

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

The [acceptance review](../reviews/30-live-forks-transcripts.md) records exact
source contracts, independent public/canonical evidence, platform tests,
documentation and the $0 offline workflow. The final criterion remains open until
independent combined review and published-head CI are confirmed; merge requires
the user's next instruction. Storage/ZDR/recording availability are service
policies exercised through injected service failures, not invented local
organization validators.
