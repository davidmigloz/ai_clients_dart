# Generate buffered and streamed speech with current voices and options

Status: specified; runtime implementation pending.
GitHub: [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), AUDIO-SPEECH-01–04.
Dependencies: None.

## Demonstrable outcome

Generate buffered and streamed speech with current voices and options through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [ ] Buffered client.audio.speech.create keeps its Uint8List return; explicit byte and SSE streams select their modes and reject incompatible options before auth/request work; audio/SSE Accept headers match their actual media.
- [ ] Closed CreateSpeechRequest supports instructions, six formats, audio/sse, speed 0.25–4, input/instructions up to 4,096 Unicode characters, open models and typed open/custom voices; all 13 named voices have conveniences.
- [ ] Existing const built-in requests and named voice constants remain compatible where practical; any enum.values/exhaustive switch change has migration. No untyped Object voice or invented language/format field.
- [ ] Both speech SSE components preserve required audio/usage, all three integer token counts, unknown events/metadata and original Base64 strings. An explicit decode helper yields raw bytes without a data URL.
- [ ] Public byte/SSE fixtures cover split UTF-8/lines/events, malformed known payloads, non-2xx error context, termination, pre-auth/midstream abort, subscription cancellation, owned/borrowed clients and no consumed-data replay.
- [ ] Offline example demonstrates buffered output and both streams with built-in/custom/open names at $0 cost; docs explain current models and tts-1/tts-1-hd SSE restrictions.
- [ ] Docs include January 6, 2027 TTS snapshot sunset and recommended Realtime workflow migration, distinguish the unlisted mini-TTS alias and other January/February sunset dates, and never recommend a model-string swap across endpoints.

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
