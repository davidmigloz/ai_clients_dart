# Correct Chat voices and file transcription and translation contracts

Status: specified; runtime implementation pending.
GitHub: [#367](https://github.com/davidmigloz/ai_clients_dart/issues/367).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), AUDIO-EXISTING-01–04.
Dependencies: [24](24-speech.md) for the shared typed voice reference; no dependency on consent creation.

## Demonstrable outcome

Correct Chat voices and file transcription and translation contracts through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [ ] ChatAudioConfig admits canonical open names/custom{id}, adds marin/cedar and AAC, and preserves old conveniences and Chat pcm16 versus Speech pcm. Complete affected Chat contracts and targeted enum migration.
- [ ] All 14 existing transcription fields have public multipart fixtures, including repeated keywords/languages, speaker data URLs, collection limits, nullable chunking/stream, original file bytes/MIME and formats; no false new-field claims.
- [ ] JSON/verbose/diarized/text/subtitle transcription paths, three stream variants, usage/logprobs/timestamps/speakers and immutable future received metadata remain complete; fix affected value/copy/clear ownership contracts.
- [ ] Only chunking_strategy/stream are nullable request fields; explicit null normalizes to multipart omission, false remains false and stream method forces true. Document Python-compatible versus Node-rejecting null behavior; no literal null part. Writable unknown format/include sentinels fail. gpt-transcribe-specific language exclusion/keyword restrictions and unspecified prompt limit are documented without a universal model whitelist or invented tokenizer.
- [ ] All four buffered transcription methods and every translation method accept abort; public missing/nonstring/future discriminator and safe ParseException message/cause/logging fixtures retain caller raw responseBody without secret echoes. REST numeric logprob bytes versus SSE integer bytes have separate exact fixtures.
- [ ] Valid verbose translation without task parses; task is optional legacy metadata, segments optional, language/duration/text required. Language means output English. Text/segments participate in equality/hash and copy without aliasing.
- [ ] Explicit translation JSON/verbose/raw text/SRT/VTT methods select modes before auth; generic create cannot JSON-decode raw formats. Preserve raw whitespace, multipart model/prompt/temperature fields and canonical response contracts.
- [ ] Public fixtures cover every advertised output mode, errors before stream subscription, auth/abort/closed-client lifetime and conservative replay. Any constructor/return-type correction has before/after migration.
- [ ] Offline example covers forwarded modern file fields, verbose/raw translation and custom/open Chat voices; README/llms notes February 26, 2027 sunsets while retaining operational translation/diarization/subtitle modes.

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
