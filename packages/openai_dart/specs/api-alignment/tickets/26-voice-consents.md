# Manage voice consent recordings through all five operations

Status: merged in [PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376); #368 closed.
GitHub: [#368](https://github.com/davidmigloz/ai_clients_dart/issues/368).
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Specification: [Phase 5 Audio and Live](../audio-live.md), AUDIO-CONSENT-01–03.
Dependencies: None; useful independently of custom voice creation.

## Demonstrable outcome

Manage voice consent recordings through all five operations through public APIs, with an independently runnable offline workflow.

## Acceptance criteria

- [x] Cached client.audio.voiceConsents exposes five exact routes through shared auth/abort/errors/closed-client behavior with encoded IDs and conservative retry. Update is POST JSON with required name, never PATCH/empty update.
- [x] Create multipart requires name/recording/language and preserves original bytes/filename/MIME; eight base MIME types, 10 MiB limit and browser MIME-parameter normalization have public boundary fixtures.
- [x] Pagination has only after/limit (default 20, documented 1–100), omitted/explicit values and successive pages without inferred cursors or hidden network iteration.
- [x] Three exact response resources preserve required fixed objects/fields, optional nullable first_id/last_id omission/null/value, has_more and deletion boolean including false.
- [x] Canonically closed response objects have explicit immutable receive-only future-extra tolerance; malformed known fields fail contextually and extras never enter closed writable requests.
- [x] Offline lifecycle uses synthetic bytes and explains phrase/project/person/permission requirements and explicit deletion. No consent_phrases DTO, automatic recording/enrollment or live upload.

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

See the [consent acceptance record](../reviews/26-voice-consents.md).
Package/platform/documentation checks and independent combined reviews pass.
Final reviewed head `cadd3f39ba82e12cb0764a87dc5808f01894e5b4` passed all
14 CI contexts (13 successes, standard Test(all) skip). PR #376 merged October 8
at 20:13:36 UTC, squash `2856c21eed697b7ec24a79e70e66800fe5ec0b79`.
