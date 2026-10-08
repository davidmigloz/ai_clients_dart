# Custom voice creation acceptance

Status: implementation verified; independent requirements and cross-author
engineering reviews approve. Runtime PR merged, closing #369.
[#369](https://github.com/davidmigloz/ai_clients_dart/issues/369),
[ticket 27](../tickets/27-custom-voices.md), AUDIO-VOICE-01–03 in the
[Phase 5 specification](../audio-live.md). Prerequisite consent #368 is closed by
merged [PR #376](https://github.com/davidmigloz/ai_clients_dart/pull/376).

## Source and genuine mappings

Fresh [OpenAPI b2751c66](https://github.com/openai/openai-openapi/blob/b2751c6625493c9c64db21b1b26a4d9300e589e3/openapi.json)
equals the adopted canonical snapshot (356 operations, 2,013 schemas). Candidate
fetch/review and independent source closure preserve canonical bytes and original
fetch/source metadata. The local Python TLS trust bundle required an explicit
certifi CA path; certificate verification remained enabled. Python
[8e1fd258 / 3.26.1](https://github.com/openai/openai-python/tree/8e1fd2587deae364367e791385997ab45aa2a520)
and [Node bc6c0bfb / 7.30.1](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5)
heads are unchanged. Four current pinned SDK files agree with the canonical
single audio_sample branch, optional request type and fixed received type.
The [official guide](https://developers.openai.com/api/docs/guides/custom-voices)
confirms service eligibility, permissions, person/project and sample-content rules.

All three genuine roots have describe/scaffold dry-run receipts and object mappings:
CreateVoiceRequest and CreateVoiceFromConsentRequest bind the same concrete
CustomVoiceCreateRequest, as a single-branch union alias; VoiceResource binds
CustomVoice. No obsolete prompt branch, extra voice CRUD, fake schema, skip/tag or
diagnostic exclusion is added. A removed temporary discovery config enabled
actual-root describe before final mapping registration; the CLI rejects
unregistered types. Binary creation has no invented JSON factories or encoding.

## Requirement evidence

| Requirement | Observable acceptance |
| --- | --- |
| AUDIO-VOICE-01 | Cached client.audio.voices exposes create, which sends only multipart POST /audio/voices with required name/audio_sample/consent and omitted or explicit audio_sample type. Names enforce 1–256 Unicode code points, without trimming or inherited consent restrictions. Original immutable sample views/bytes, exact filename, eight base MIME types, browser parameter normalization and 10 MiB−1/exact/+1 admission have public fixtures. Open consent metadata has no invented ID grammar. Shared auth/abort/errors/closed guards apply; multipart never replays under quota, transient 429, 5xx, connection/socket or timeout failures. |
| AUDIO-VOICE-02 | CustomVoice validates fixed audio.voice object and audio_sample creation type, required id/name/finite integer created_at, with deeply immutable finite receive-only future extras. Unknown known creation types fail contextually rather than being coerced. Complete effective JSON/copy/value/hash ownership tests keep typed fields authoritative; response names have no request-only constraints. Existing AudioVoice.custom creates the returned ID reference without invoking speech or Live or changing another API's voice domain. |
| AUDIO-VOICE-03 | Runnable voices_example.dart uploads one synthetic consent and one synthetic sample, then selects reference JSON: two mock POSTs, $0 cost. README/llms explain approved access, api.voices.write/read, same person/project, current consent phrase, five seconds of speech/15 transcribed tokens/30-second maximum as service checks, without recording/transcription/quality validators. Private model diagnostics and FINEST request/response/error logs retain explicit caller model and HTTP context. No automatic enrollment, live upload, consuming API call or deletion is performed. |

## Shared behavior and resolved findings

- Shared upload helpers preserve all consent size/MIME/inference error strings,
  readonly exact-view snapshots, nullable metadata and existing const contracts.
  New name/type constraints apply only to custom voice creation.
- Consent dispatch, parsing and pre-auth cancellation now share the extracted
  private-audio HTTP helper with identical error messages/status/raw caller context,
  abort fields and existing interceptor retry decisions. Custom creation adds
  only its POST route to private URL/header/body/trace/media-header handling.
- Existing consent and audio/error regressions pass all 783 cases after both
  extractions. Public tests inject a real private AuthProvider trace ID after
  generated tracing, and a VM-only real SocketException without network traffic.
- Review corrected cached-method wording to cached resource and renamed the real
  example to voices_example.dart to satisfy resource documentation conventions;
  no checker exclusion was added.
- Public main-barrel exports cover request, metadata and resource. No existing
  enum/sealed variants, constructors or signatures change; no breaking migration
  is invented.

## Validation

- Format: all 581 package and 2,704 repository Dart files unchanged; fix has
  nothing to apply and fatal-info analysis reports no issues.
- Package unit suite: 14,989 pass, two existing environment-dependent skips.
- All 180 new shared cases (75 model, 105 resource) pass VM, real Chrome
  JavaScript and Chrome Wasm; one additional injected SocketException case is
  VM-only. The 86 existing consent model cases also pass all three platforms.
- Independent source closure has 14 assertions against base and fresh candidate:
  three actual components and POST /audio/voices, single union branch/two closed
  objects, full candidate equality and adopted metadata preservation.
- Actual canonical public corpus has three rows (public parse, constructor and
  copy), six exact-output/closed-schema assertions. The exact README FAQ snippet
  compiles and runs with two mocked POSTs, original multipart bytes/MIME and omitted
  type, then reference JSON only. The renamed voices_example.dart independently
  runs with two mocks, $0. Thirteen relevant local-link occurrences resolve, with
  the new llms GitHub file link mirrored to the existing example.

Full final toolkit verification reports 281 errors / 120 warnings / 217 infos,
plus 35 consistency warnings. Baseline: 278 / 118 / 216 / 35. Exact multiset delta:
six added identities, zero removed; all 612 previous implementation and all 35
consistency identities remain visible and unchanged.

- One error cannot resolve the genuine single-branch request union's properties
  through its concrete object alias.
- Two errors report intentionally absent multipart JSON methods on the branch;
  one info compares immutable Uint8List with string/binary file representation.
- Two warnings cannot follow complete serialized-value response equality/hash
  through toJson; public per-field/effective-JSON fixtures verify both contracts.

Exports/docs/README checks are clean after the real example rename. No new
exclusions, skipped schemas, fake fields/JSON factories or checker changes were
added. Independent requirements and cross-author engineering reviews approve the
combined change after resolved findings, with no open issues. Published-head CI,
artifact verification and actual merge remain separate gates recorded in PR/issue.
#369 stays open until actual merge; #370 Live HTTP and configuration is next.

## Merge evidence

Custom voice creation #369 merged in [PR #377](https://github.com/davidmigloz/ai_clients_dart/pull/377) on October 8, 2026 at 20:49:30 UTC, commit `3e2b488e896f820118b575108c50586ae08ec867`, after all 14 final-head CI contexts completed (13 successes and the standard Test(all) skip).
The reviewed head was `0bdb022bf59fe4ca6713aad902a139a7c40d7dfc`; #370 follows independently.
