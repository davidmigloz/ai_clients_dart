# Speech options and streaming acceptance

Status: implementation verified; independent requirements and cross-author
engineering reviews approve. Runtime PR merge remains pending.
Issue: [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366).
Specification: [Audio and Live](../audio-live.md), AUDIO-SPEECH-01–04.
Ticket: [24](../tickets/24-speech.md).

## Source and canonical receipts

Pre-publication October 8 source checks matched OpenAPI
`506aff0a8099581b50e119b87f8f2692cdad043f`, Python
`9301e319ea33ef28fba380f39a289dedc14652c1` (3.26.1) and Node
`bc6c0bfb70f253d5caa3f335699e9713ea9067b5` (7.30.1).
Toolkit fetch/review reports no wire changes. The reviewed candidate was promoted
and is byte-identical to canonical JSON; only the actual fetch timestamp changes
in metadata. Source URL remains the immutable pin that matches the fetched head.

Describe/scaffold dry-runs cover actual CreateSpeechRequest,
VoiceIdsOrCustomVoice, CreateSpeechResponseStreamEvent, SpeechAudioDeltaEvent and
SpeechAudioDoneEvent. Their real manifest mappings name the public implementations;
inline usage stays inline, with no invented component or diagnostic exclusion.
Canonical governs wire shape; the speech guide governs model restrictions and the
sunset notice governs workflow migration, as settled in the phase specification.

A final upstream check after publication found [OpenAPI 35b0d4e](https://github.com/openai/openai-openapi/commit/35b0d4ebb841f2706e1c0aa31c7d47ecdd43c71d),
published October 8 at 16:33:26 UTC. Fresh fetch/review and normalized comparison
find exactly five additions: CreateAgentSessionParams/UpdateAgentSessionParams
spend_control, SessionResource spend_control and two distinct closed
SessionSpendControlParam/SessionSpendControlResource components. The complete
Speech schema closure and POST operation are unchanged; Python/Node heads also
remain unchanged. These Agents contracts are recorded in the Phase 6 inventory.
This Speech implementation keeps the reviewed 506aff0a snapshot; the later
candidate is reviewed for inventory and not promoted as an adopted runtime
contract. Committed canonical bytes and their fetch/source metadata stay pinned.

## Requirement evidence

| Requirement | Verified observable behavior |
| --- | --- |
| AUDIO-SPEECH-01 | Closed request supports all seven fields, six audio formats, audio/SSE mode, finite speed 0.25–4 and 4,096 Unicode-character limits. Models/named voices remain open; typed custom references are exact `{id: string}` objects. Supplied null/unknown writable fields fail safely. All thirteen built-in enum conveniences are present. |
| AUDIO-SPEECH-02 | Buffered `create` retains `Uint8List`; `createByteStream` yields raw chunks and `createStream` yields typed SSE. Each selects matching request mode/Accept media, accepts abort and rejects incompatible supplied modes before authentication. Public factories preserve owned per-stream versus injected borrowed transport lifetime; there is no consumed-data retry/replay. HTTP subtype/status/request ID/retry/body context and original bytes/headers remain caller-readable. |
| AUDIO-SPEECH-03 | Required delta audio and done usage retain exact Base64, all three integer token fields, future event discriminators and deeply immutable future JSON. `decodeAudio()` yields raw bytes, with safe malformed diagnostics. Split UTF-8/lines/events, all six binary formats, inline/HTTP errors, premature EOF, abort and pending-header cancellation are tested. Valid done is delivered before prompt completion/cleanup, even on a held-open HTTP body; postterminal bytes are ignored. |
| AUDIO-SPEECH-04 | Existing const requests and six enum constants/indices remain usable; seven variants are appended. Widened voice getter/copy parameter, enum switches and stricter request admission have migration guidance. README and the offline three-request example show buffered, byte and SSE output with built-in/open/custom references. January 6 TTS snapshots/alias distinction, January 20 legacy snapshots and February 26 file transcription are separate migrations; Realtime requires its workflow, not a model-string swap. |

Model tests exercise every field/variant, optional absence/null, copy/clear,
finite immutable snapshots, contextual malformed input, future receive-only
metadata, effective wire equality/hash and safe diagnostics. Known named voices
normalize to the existing enum on request parsing; request equality compares
wire identity so an equivalent open named built-in round-trips correctly.
Replacing done usage drops stale nested metadata; explicit parent raw overrides
retain intentional ownership. Closed writable admission stays distinct from
opaque received metadata. The public main barrel is the only test import.

FINEST privacy fixtures verify input/instructions/names/custom IDs and binary/
Base64 audio stay out of default diagnostics and built-in body logging, while
explicit caller data remains available. Successful buffered audio is never
UTF-8 decoded for logging. Malformed HTTP UTF-8 retains original bytes and cannot
mask HTTP status. Other API diagnostic policies remain unchanged.

## Resolved independent findings

- A covariant `Stream<Uint8List>` cannot feed a runtime `StreamTransformer<List<int>>`
  safely. The SSE bridge now has an actual `List<int>` stream and public split-byte
  fixtures pass on VM, JavaScript and Wasm.
- An async generator could leave cancellation waiting for pending response headers.
  Explicit controller/subscriptions now cancel promptly, retire the pending timer
  and release owned clients once; a late custom-client response is discarded.
- A valid done event previously waited for HTTP EOF and could retain an owned
  transport indefinitely. The client now treats canonical synthesis completion
  as its explicit terminal boundary. Held-open owned/borrowed fixtures verify
  delivery, cleanup and ignored late data. This client behavior is an inference
  from canonical completion semantics, not a claim about generic SDK SSE parsers.
- The shared voice union's old skip note incorrectly claimed six closed enums were
  sufficient. It now maps the real mixed scalar/object `AudioVoice` interface,
  retaining the known scanner limitation and the separate Chat integration #367.
- Mixed-case configured media headers could override required Speech headers.
  Required values now win on the actual case-insensitive request. Authentication
  refresh filters conflicting provider media headers before copying the body,
  preserving fresh credentials and Unicode JSON even with an invalid charset.
- Throwing owned-client disposal could hang completion or produce unhandled errors.
  Best-effort teardown now settles the stream and preserves its successful output
  or original HTTP/source/abort error, with cleanup attempted at most once.
- Explicit parent usage metadata previously lost to stale child metadata during
  done-event copying. Merge order now gives parent extras priority while typed
  counts remain authoritative; conflicting old and fresh child fixtures verify it.
- Shared error decoding initially changed valid advertised Latin-1 responses to
  malformed UTF-8 text. It now honors successful advertised decoding and falls
  back only for malformed UTF-8, preserving status and exact raw bytes. Public
  Speech mode fixtures and a non-Speech Models fixture verify both boundaries.
- Sunset guidance now explicitly distinguishes all three January/February dates.

## Validation

- Dart 3.13.5 package format → fix → fatal-info analysis passes. The full unit suite
  passes **13,814 tests** with two existing skips. All 560 package and 2,683
  repository Dart files format unchanged.
- All **273 new focused cases** (132 model, 140 public resource and one shared
  charset regression) pass on VM,
  real Chrome JavaScript and Chrome Wasm. Existing Audio regression fixtures pass.
  No browser test uses a live API or key.
- All three literal README speech blocks compile and run against a MockClient,
  verifying three requests, audio, future event and usage. All 333 local documentation links/anchors resolve. The runnable offline
  example checks three synthetic requests and costs **$0**. Migration After code
  compiles and runs separately against a custom reference.
- The user's existing low-cost authorization covers one selected tagged integration
  test with exactly two `Hi.` PCM requests, no retry, upload or storage. It passes:
  byte audio **55,200 bytes**; SSE audio **38,400 bytes**, input **4**, output **26**,
  total **30** tokens. No key, text, voice ID or audio is logged. Only that selected
  test ran; the full integration suite did not.
- [Published model pricing](https://developers.openai.com/api/docs/models/gpt-4o-mini-tts)
  is $0.60/million text input tokens and $12/million audio output tokens. The SSE
  usage implies **$0.0003144** before any account-specific adjustment. Raw-byte mode
  reports no token usage, so its exact bill is unknown; the two short outputs total
  1.95 seconds of PCM and are estimated well below **$0.01**, not asserted as a bill.
- Full toolkit exports/docs/README checks pass. Visible diagnostics are **275
  implementation errors / 84 warnings / 213 infos**, and **35 consistency warnings**,
  against merged baseline 274/78/212 and 35. Exact identity delta is eight additions,
  zero removals, 564 unchanged implementation diagnostics and unchanged consistency.
  One added error cannot extract fields from the real mixed scalar/object voice
  anyOf. Six warnings miss effective-JSON equality/hash helpers for request/delta/
  done; one info suggests String for the closed stream-format enum. Public wire,
  round-trip and field-sensitive value fixtures verify these scanner limitations.
  All unrelated missing APIs remain visible; no exclusions or checker changes.

Independent requirements, resource/shared-HTTP engineering and model/docs/manifest
engineering reviewers approve the final combined change with no open findings.
Cross-author reviews rechecked each validated fix, while the requirements review
also ran 90 public canonical-schema cases with 363 assertions. The final published
head CI and actual merge receipt are recorded in the PR/issue. #366 stays open
until merge; #367 is the next bounded existing-Audio correction. No package
release, version bump, real recording upload or phone call occurs.
