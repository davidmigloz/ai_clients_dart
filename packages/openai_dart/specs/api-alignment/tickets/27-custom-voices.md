# Create sample-derived custom voices from explicit consent

Status: merged in PR #377; #369 closed.
GitHub: [#369](https://github.com/davidmigloz/ai_clients_dart/issues/369).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), AUDIO-VOICE-01–03.
Dependencies: [26](26-voice-consents.md) for the consent lifecycle example. Reference JSON is demonstrated without calling another resource.

## Demonstrable outcome

Create sample-derived custom voices from explicit consent through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [x] client.audio.voices.create implements only POST /audio/voices with one audio_sample branch: required name/audio_sample/consent and optional type default. No prompt branch or invented voice CRUD.
- [x] Multipart preserves sample bytes/filename/MIME, eight base MIME types and 10 MiB limit; name length 1–256 Unicode characters and omitted/explicit type have public fixtures.
- [x] VoiceResource preserves object/id/name/integer created_at and canonical fixed creation type audio_sample (late OpenAPI b2751c66 now agrees with SDKs); any future received type tolerance is explicit and separate from canonical acceptance, and closed-canonical receive-only extras follow the declared policy.
- [x] The returned ID is demonstrated as a custom reference object supplied by the caller, without invoking speech or Live; actual production consumption is covered by their own slices. No universal Realtime widening or shared constraint leakage.
- [x] Offline workflow obtains consent through 26, creates from synthetic sample and shows its reference object at $0 cost. Docs explain eligibility/api.voices.read/write/same person and project/5 seconds/15 tokens/30 seconds without invented quality validators.
- [x] Samples, consent context and IDs stay private in default diagnostics/enabled request/response logging; caller wire/model data remains intact. Public HTTP/abort/closed-client/error fixtures pass.

- [x] Changed models cover every declared field/variant, optional/null/absence, immutable parsed ownership, complete copy/clear, equality/hash and safe diagnostics. Known malformed values fail contextually; future receive-only metadata and closed writable admission remain distinct.
- [x] Public factories/resources/parsers and real canonical manifest mappings are verified; no fake components or diagnostic exclusions. README/llms, runnable offline example and any actual breaking migration are complete.
- [x] Focused public fixtures pass VM/Chrome JavaScript/Wasm where applicable; format → fix → fatal-info analysis, package unit suite and full OpenAPI toolkit evidence are recorded. Unrelated diagnostics/remaining parity gaps remain visible and classified.
- [x] Independent requirements and engineering reviews approve the final combined diff after validated findings are resolved; final-head CI is green before merge.

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

See the [custom voice acceptance record](../reviews/27-custom-voices.md).
Package/platform/documentation checks and independent combined reviews pass.
PR #377 merged after the published head passed final CI; #369 is closed.

## Source refinement before implementation

[OpenAPI b2751c66](https://github.com/openai/openai-openapi/commit/b2751c6625493c9c64db21b1b26a4d9300e589e3),
published October 8, 2026 at 17:55:47 UTC, narrows VoiceResource.type to the
audio_sample enum. This supersedes the planning pin’s open-string discrepancy.
Consent #368 adopted this reviewed snapshot. Custom voice implementation rechecks
the same current heads; candidate and canonical are identical, so original source
and fetch metadata remain preserved. The acceptance record separates current
runtime evidence from this historical refinement.
