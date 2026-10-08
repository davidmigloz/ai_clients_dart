# Audio and Live: Phase 5 specification

Status: planning merged in [PR #373](https://github.com/davidmigloz/ai_clients_dart/pull/373);
speech #366 implemented pending merge, six runtime tickets pending.
Parent: [#317](https://github.com/davidmigloz/ai_clients_dart/issues/317).
Phase 4 is complete: [PR #365](https://github.com/davidmigloz/ai_clients_dart/pull/365)
merged October 8, 2026 at `fca1a3f4e453d88caed9ffa573d4ec665126c3cb`, closing #360
after all 14 final-head CI contexts completed (13 successes, standard Test(all) skip).
Scope: seven independently usable implementation tickets, repository 24–30.
The planning specification claims no runtime acceptance; speech implementation
has its separate [acceptance record](reviews/24-speech.md).

## Outcome and boundaries

Applications generate buffered or streamed speech using current options and voice
references, manage voice consent recordings, and create sample-derived voices.
They establish Live sessions through WebRTC signaling, outbound/inbound SIP or
server WebSockets, inspect events and cumulative usage, and explicitly return
delegated work or fork a completed stored session. Each slice includes public
fixtures, a runnable offline example, documentation and independent review.

The user selected complete parity, modern APIs/fixes first, repository documents
plus GitHub issues, and targeted breaking corrections with migration guidance.
These settled choices require no further scope interview. Source inspection
answers protocol and architecture questions before tickets are written.

Live is a distinct API from Realtime and durable Agents. The package handles
HTTP signaling, event codecs and connections. Applications supply SDP, media
tracks, capture/playback, SIP providers, backend task execution, storage policy,
approval and deduplication. There is no new microphone/media engine dependency,
automatic tool runner, call acceptance, recording upload or paid live acceptance.
Agents/vaults follow in Phase 6; Administration and remaining legacy/shared-client
parity retain their roadmap entries. Completion of these slices will not imply
complete SDK parity where the inventory below explicitly retains a gap.

## Sources and authority

Audited October 8, 2026 against fresh source heads:

- [OpenAPI 506aff0a](https://github.com/openai/openai-openapi/blob/506aff0a8099581b50e119b87f8f2692cdad043f/openapi.json),
  356 operations and 2,009 schemas; the candidate equals the repository canonical
  JSON. Planning preserves the existing canonical file and fetch metadata.
- [Python 9301e319 / 3.26.1](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1),
  including [Audio](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1/src/openai/resources/audio),
  [Live](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1/src/openai/resources/live)
  and [transcript helpers](https://github.com/openai/openai-python/tree/9301e319ea33ef28fba380f39a289dedc14652c1/src/openai/lib/live).
- [Node bc6c0bfb / 7.30.1](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5),
  including [Audio](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5/src/resources/audio),
  [Live](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5/src/resources/live)
  and [transcript helpers](https://github.com/openai/openai-node/tree/bc6c0bfb70f253d5caa3f335699e9713ea9067b5/src/lib/live).
- [Changelog](https://developers.openai.com/api/docs/changelog),
  [Audio reference](https://developers.openai.com/api/reference/resources/audio),
  [speech](https://developers.openai.com/api/docs/guides/text-to-speech),
  [transcription](https://developers.openai.com/api/docs/guides/speech-to-text),
  [custom voices](https://developers.openai.com/api/docs/guides/custom-voices),
  [Live overview](https://developers.openai.com/api/docs/guides/live),
  [conversations](https://developers.openai.com/api/docs/guides/live-conversations),
  [delegation](https://developers.openai.com/api/docs/guides/live-delegation),
  [migration](https://developers.openai.com/api/docs/guides/live-migration),
  [WebRTC](https://developers.openai.com/api/docs/guides/voice-webrtc?api=live),
  [WebSockets](https://developers.openai.com/api/docs/guides/voice-websockets?api=live),
  [SIP](https://developers.openai.com/api/docs/guides/voice-sip?api=live),
  [server controls](https://developers.openai.com/api/docs/guides/voice-server-controls?api=live)
  and [deprecations](https://developers.openai.com/api/docs/deprecations).

Canonical schemas establish wire fields, unions and requiredness. Descriptions
and guides add documented workflow and permission limits; SDKs establish helper
behavior. Disagreements are resolved explicitly below. Every implementation
rechecks affected sources and records changes before promoting any new candidate.
The [planning review](reviews/24-audio-live-planning.md) records source receipts,
independent findings, contract coverage and validation separately from runtime evidence.

## Ticket graph

| Repository ticket | Demonstrable capability | Requirements | Prerequisite |
| --- | --- | --- | --- |
| [#366](https://github.com/davidmigloz/ai_clients_dart/issues/366) ([24](tickets/24-speech.md)) | Generate buffered, byte-streamed and SSE speech with current voices/options | AUDIO-SPEECH-01–04 | None |
| [#367](https://github.com/davidmigloz/ai_clients_dart/issues/367) ([25](tickets/25-existing-audio.md)) | Correct Chat voice/formats and file transcription/translation contracts | AUDIO-EXISTING-01–04 | 24 for the shared typed voice reference |
| [#368](https://github.com/davidmigloz/ai_clients_dart/issues/368) ([26](tickets/26-voice-consents.md)) | Upload, paginate, retrieve, rename and delete voice consents | AUDIO-CONSENT-01–03 | None |
| [#369](https://github.com/davidmigloz/ai_clients_dart/issues/369) ([27](tickets/27-custom-voices.md)) | Create a voice from an explicit consent and audio sample | AUDIO-VOICE-01–03 | 26 for the consent workflow |
| [#370](https://github.com/davidmigloz/ai_clients_dart/issues/370) ([28](tickets/28-live-http.md)) | Signal WebRTC/SIP, control calls, fork through HTTP and download recordings | LIVE-HTTP-01–04, LIVE-CONFIG-01–04 | None; incoming-call example reuses merged receiver #357 |
| [#371](https://github.com/davidmigloz/ai_clients_dart/issues/371) ([29](tickets/29-live-websockets.md)) | Run primary and sideband connections with complete commands/events | LIVE-WS-01–04, LIVE-EVENT-01–04, LIVE-WORK-01–02 | 28 for shared startup/configuration models |
| [#372](https://github.com/davidmigloz/ai_clients_dart/issues/372) ([30](tickets/30-live-forks-transcripts.md)) | Fork through WebSocket and route delegated/transcript updates manually | LIVE-FORK-01–03, LIVE-WORK-03, LIVE-TRANSCRIPT-01–02 | 29 for shared codecs/connections; transitively 28 |

Implement in this order with a separate PR per ticket. No artificial dependency
on speech/custom-voice creation precedes Live: built-in voices work independently.
REST fork belongs to 28, WebSocket fork to 30, without duplicated codecs. Ticket
29 already provides usable manual delegation; 30 adds compact-response dispatch,
transcript grouping and fork workflows rather than a second basic event parser.

## Ordinary Audio operation inventory

| Operation | Canonical operationId | Existing package | Ticket |
| --- | --- | --- | --- |
| POST `/audio/speech` | createSpeech | Buffered bytes, six closed voice choices | 24 |
| POST `/audio/transcriptions` | createTranscription | File, streaming, diarization, keywords/languages already present | 25 |
| POST `/audio/translations` | createTranslation | JSON-only resource; verbose DTO requires undeclared task; raw formats misdecoded | 25 |
| POST `/audio/voice_consents` | createVoiceConsent | Missing | 26 |
| GET `/audio/voice_consents` | listVoiceConsents | Missing | 26 |
| GET `/audio/voice_consents/{consent_id}` | getVoiceConsent | Missing | 26 |
| POST `/audio/voice_consents/{consent_id}` | updateVoiceConsent | Missing | 26 |
| DELETE `/audio/voice_consents/{consent_id}` | deleteVoiceConsent | Missing | 26 |
| POST `/audio/voices` | createVoice | Missing | 27 |

There is no canonical voice list/retrieve/update/delete API. Consent phrase
lookup is a separate unresolved documentation-only operation below.

## Speech and existing Audio

- **AUDIO-SPEECH-01:** Cover the complete closed `CreateSpeechRequest`: required
  open-string model, input and voice; optional nonnull instructions, response_format,
  speed and stream_format. Input/instructions limits are 4,096 Unicode characters,
  speed 0.25–4, six response formats and audio/sse stream modes. Preserve open model
  IDs and voice-name strings, including 13 named conveniences: alloy, ash, ballad,
  coral, echo, fable, onyx, nova, sage, shimmer, verse, marin and cedar. The custom
  voice branch is the closed object `{id: string}`. Do not introduce a `language`
  or `format` speech field from the conflicting custom-voice guide example.
- **AUDIO-SPEECH-02:** Keep buffered `client.audio.speech.create` returning bytes
  and add explicit byte-stream and SSE-event methods. Route buffered/byte methods
  to audio mode, SSE methods to sse mode; reject incompatible supplied options
  before authentication/request work. Do not silently return SSE JSON as an audio
  file. Use media-appropriate Accept headers (application/octet-stream for audio,
  text/event-stream for SSE), rather than the existing shared JSON default.
  Stream requests use the existing dedicated stream-client factory and
  abort/error/lifetime policies; subscription cancellation closes only owned
  transports, preserves borrowed clients and never retries/replays consumed audio.
- **AUDIO-SPEECH-03:** Type both `CreateSpeechResponseStreamEvent` branches:
  `SpeechAudioDeltaEvent` requires type:`speech.audio.delta` and audio string;
  `SpeechAudioDoneEvent` requires type:`speech.audio.done` and usage containing
  required integer input_tokens/output_tokens/total_tokens. No sequence field is
  declared. Preserve open received metadata and future event discriminators with
  immutable raw JSON. Known malformed variants fail contextually. Audio fields
  contain raw Base64 bytes, distinct from input image/file data URLs; retain their
  original string and offer an explicit decoding helper rather than inventing a
  canonical Base64 grammar. Non-2xx HTTP failures retain shared error context;
  malformed SSE and unexpected termination/cancellation have deterministic tests.
- **AUDIO-SPEECH-04:** Preserve existing const `SpeechRequest` built-in calls and
  `SpeechVoice` named constants where practical while supporting typed custom
  references and arbitrary names. Select a typed value/sealed voice design rather
  than an untyped Object parameter. If enum.values/exhaustive switching must
  change, document that precise source break with before/after migration. Complete
  old/new equality, hash, copy/clear, JSON and safe diagnostics; update model and
  SSE capability guidance (SSE unsupported on tts-1/tts-1-hd) without a closed model
  whitelist. The October 1 notice schedules tts-1, tts-1-hd and the listed
  gpt-4o-mini-tts snapshots for January 6, 2027 shutdown. The recommended
  gpt-realtime-2.1-mini replacement requires a transport/workflow migration, not
  a speech endpoint model-string swap; the gpt-4o-mini-tts alias is not explicitly
  listed. Keep this distinct from the January 20 legacy snapshots and February 26
  transcription sunsets. The example demonstrates all three speech forms offline.
- **AUDIO-EXISTING-01:** Correct ChatAudioConfig voice admission to canonical
  VoiceIdsOrCustomVoice (open name or closed custom ID object), retaining existing
  named conveniences and adding marin/cedar. Include canonical AAC in Chat's six
  formats despite its stale five-format description; keep Chat pcm16 distinct
  from Speech pcm. Reuse 24's typed reference only where wire contracts match;
  Realtime's separate voice field is not universally widened. Preserve existing
  constructors/constants where practical and explain any enum source changes.
- **AUDIO-EXISTING-02:** Audit all 14 current transcription request fields at the
  public multipart boundary. Keywords and plural languages already exist; verify
  repeated names, omitted/explicit optional values, canonical min/max collections,
  explicit file MIME/filename/bytes and legacy singular language. Only
  chunking_strategy and stream are optional nullable in the closed request; other
  optional fields are nonnull. Multipart explicit null for chunking_strategy/stream
  normalizes to omission, matching current Dart and pinned Python; false remains
  a false part and streaming explicitly sends true. Node rejects null instead.
  No literal null part or claim of server-distinct null/omission is introduced.
  Writable unknown format/include sentinel values
  must fail before dispatch instead of emitting unknown. Scope guide-only
  gpt-transcribe constraints to that model: plural languages replaces singular
  language, and keywords contain no angle brackets, CR or LF. No numeric prompt
  length is published for that model; do not borrow speech's character limit or
  approximate Whisper's token limit with characters. Preserve diarized/verbose/
  JSON/text/subtitle outputs, three transcription stream branches, usage/logprobs/
  timestamps/speakers and safe future metadata. Make bounded corrections to changed
  model copy/value/ownership/null contracts and resource abort/error/client lifetime
  where public fixtures expose defects, without claiming new fields that exist.
  All four buffered transcription methods gain abort support; streaming keeps its
  existing support. REST logprob bytes are number arrays, while SSE delta/done
  bytes require integers: enforce direction-specific contracts without rounding.
  Require string discriminators (missing/nonstring is malformed, unknown strings
  preserved), finite counters and deep immutable future metadata. Parse exception
  messages/causes/logging do not echo transcripts, audio or decoder raw values;
  caller-readable raw responseBody remains available.
- **AUDIO-EXISTING-03:** Correct translation's valid verbose response without
  invented required task: canonical requires language/duration/text, segments
  optional, and language describes the output (English), not the detected source.
  Preserve optional legacy task if received without requiring it. Fix
  translated text/segments ownership and equality/hash, and expose explicit raw
  text/SRT/VTT methods so generic JSON create cannot decode a raw-format response
  as JSON. Preserve/create separate JSON and verbose methods with mode checks
  before authentication, complete multipart/model/prompt/temperature contracts,
  HTTP failures and cancellation on every method. Never trim server text or
  subtitle whitespace. A writable unknown response-format sentinel is invalid;
  temperature's 0–1 bound is documented, not schema minimum/maximum.
- **AUDIO-EXISTING-04:** Update transcription/translation/Chat examples and model
  guidance for gpt-transcribe/gpt-live-transcribe, including announced February 26,
  2027 shutdown of whisper-1 and legacy GPT-4o transcription models. Keep still-
  supported translation/subtitle/diarization paths until their actual sunset. File
  transcription and Realtime transcription differ; do not universally prohibit
  singular+plural languages where the schema does not, or substitute a model that
  lacks an existing output mode. The offline example proves current file fields,
  raw translation formats and a custom/open Chat voice without API cost.

## Consent recordings and custom voices

- **AUDIO-CONSENT-01:** Add cached `client.audio.voiceConsents` with all five exact
  operations above through shared HTTP/auth/abort/retry/closed-client behavior.
  Create uses multipart required name/recording/language; language is an open BCP
  47 string, not a manufactured enum. Update is POST JSON with required name, not
  PATCH or an empty update. Encode opaque path IDs once. Pagination only has after
  and integer limit (default 20, documented 1–100); the range comes from the
  parameter description, not schema min/max. Test omitted/explicit values and
  successive pages without inferred cursors or hidden network iteration.
- **AUDIO-CONSENT-02:** Cover closed canonical `VoiceConsentResource`,
  `VoiceConsentListResource` and `VoiceConsentDeletedResource`. Resource requires
  object:`audio.voice_consent`, id, name, language and integer created_at; list
  requires object:`list`, data and has_more, while first_id/last_id are optional
  nullable. Preserve omitted/null/value distinctly. Deletion requires id/object
  and boolean deleted, which is not an invented fixed true discriminator. Known
  malformed required fields fail; the documented receive-only policy below
  preserves future extras without claiming the schemas themselves are open.
- **AUDIO-CONSENT-03:** Upload original bytes with filename and MIME metadata,
  supporting the eight documented base MIME types and the 10 MiB maximum.
  Normalize a browser recorder's MIME parameters to the supported base type
  without transcoding or changing bytes. The offline lifecycle example uses
  synthetic fixtures, explains same-person consent/project eligibility and
  permission boundaries, and deletes only when explicitly requested by its caller.
  No automatic consent recording, voice enrollment or biological verification.
- **AUDIO-VOICE-01:** Add `client.audio.voices.create` for the single
  `CreateVoiceRequest` branch `CreateVoiceFromConsentRequest`: required name,
  audio_sample file and consent ID, optional type defaulting to audio_sample;
  name length 1–256 Unicode characters. Multipart keeps bytes/MIME/filename and
  omits unspecified type instead of inventing a second branch. Text-prompt voice
  creation was removed upstream in 3c4759c1; no obsolete Dart DTO needs removal.
- **AUDIO-VOICE-02:** Cover every `VoiceResource` field: fixed object:`audio.voice`,
  id/name/integer created_at and open string type. Canonical type permits future
  values despite SDK Literal narrowing to audio_sample. Preserve immutable
  receive-only extras under the declared policy, exact copy/hash/JSON ownership,
  and safe diagnostics. Return a voice ID for the custom speech/Live reference
  object without universally widening Chat or Realtime voice fields.
- **AUDIO-VOICE-03:** The usable offline workflow uploads an explicit consent,
  creates from a synthetic sample and demonstrates its returned custom reference.
  Explain approved-project requirements and api.voices.read/write permissions,
  same project/person, samples with at least five seconds of actual speech and
  15 transcribed tokens, maximum 30 seconds and 10 MiB. These eligibility/content
  checks belong to the service; do not add invented local transcription/quality
  validators. Keep recordings, sample bytes and consent context private in default
  diagnostics/logging. No live upload or automatic creation from a received notice.

### Source discrepancies and admission decisions

1. Voice consent management exists in canonical and the official Audio reference,
   but neither pinned SDK has a voice_consents resource. Implement canonical five
   operations rather than treating SDK absence as permission to skip them.
2. The custom-voice guide documents GET `/audio/consent_phrases`, absent from
   canonical and both SDKs, without a response schema. Keep phrase discovery in
   the remaining parity inventory; no fabricated DTO, phrase text or claimed
   typed coverage. Examples explain that callers obtain the current phrase from
   official documentation/service before recording. Recheck before implementation.
3. The speech guide introduction says 11 voices, but its body, canonical and SDKs
   support 13. Use the contract's 13 conveniences and open strings. Live has its
   own larger voice list/custom object contract; do not reuse the speech enum as
   its complete domain. The guide's custom-voice speech language/format example
   does not override canonical response_format/no-language.
4. Requests with additionalProperties:false admit only declared fields. Received
   Voice/Consent objects are also canonically closed: deliberately tolerate
   unknown finite JSON extras as an immutable receive-only extension, with known
   fields validated and authoritative during toJson/copy. Label future-extra
   tests as compatibility cases, separate from canonical golden fixtures. Never
   send those extras through a closed writable request or coerce unknown enums.
5. Many Live objects omit additionalProperties and are open; others are closed.
   Apply the policy per actual component, not a blanket strict/open declaration.
   A nullable field's omission and explicit null must survive where distinct.

## Live HTTP operations and startup configuration

| Operation | Canonical operationId | Request / success | Ticket |
| --- | --- | --- | --- |
| POST `/live/sessions` | create-live | LiveSessionCreateRequest / 201 LiveSessionCreateResponse | 28 |
| POST `/live/sessions/{session_id}/accept` | accept-live-session | LiveCallAcceptRequest / empty 200 | 28 |
| GET `/live/sessions/{session_id}/content` | download-live-recording | No body / stereo WAV bytes | 28 |
| POST `/live/sessions/{session_id}/fork` | fork-live-session | LiveForkRequest / 201 LiveCreateResponse | 28 |
| POST `/live/sessions/{session_id}/hangup` | hangup-live-session | No body / empty 200 | 28 |
| POST `/live/sessions/{session_id}/refer` | refer-live-session | LiveCallReferRequest / empty 200 | 28 |
| POST `/live/sessions/{session_id}/reject` | reject-live-session | LiveCallRejectRequest / empty 200 | 28 |

- **LIVE-HTTP-01:** Add cached `client.live`/sessions resource with all seven public
  operations, exact statuses/body modes and complete request/response unions.
  Create uses canonical closed JSON containing session and WebRTC or SIP transport;
  canonical is broader than pinned SDK `LiveCreateParams`/`LiveCreateResponse`
  WebRTC-only helpers. WebRTC requires nonempty offer/answer SDP. SIP request
  requires E.164 destination, trunk and digest auth; response returns only SIP
  type, never credentials/SDP. A 201 means initialization, not that a callee answered. Every outbound SIP
  create places a new call; disable automatic retry after ambiguous timeout or
  connection failure. X-Client-Request-Id provides tracing, not deduplication.
  Public request-count fixtures must prove one attempt for these ambiguous failures.
- **LIVE-HTTP-02:** Accept requires session config, reject integer status_code
  300–699, refer a nonblank target_uri, hangup no body. Preserve opaque IDs with
  route encoding; content has its own declared live_ pattern, not a universal
  constraint imposed on incoming call IDs. Reuse verified incoming-call data's
  session_id, distinct from delivery/event IDs. All control decisions remain
  explicit; fixture examples never dial, accept or transfer a real call.
- **LIVE-HTTP-03:** GET content returns untouched stereo WAV (input left/output
  right); expose buffered and byte-stream download through owned stream clients.
  Preserve HTTP status/request ID/headers and Retry-After, including plain-text
  errors where declared; no JSON decoding of successful audio or binary body
  logging. Storage defaults false, requires project storage policy, is unavailable
  with ZDR, and finalized recordings are available for 30 days. No implicit polling,
  forced storage or retention service is added.
- **LIVE-HTTP-04:** REST fork uses WebRTC transport and optional
  `LiveMediaSessionForkParams`, inheriting when omitted/empty. A completed stored
  recording is prerequisite; returned ID is a new session. There is no generic
  Live list/retrieve/update/delete endpoint. Test every operation with MockClient
  or local HttpServer, pre-auth cancellation, errors, encoded IDs and closed client.

- **LIVE-CONFIG-01:** Model all reachable startup/media/fork/session schemas
  faithfully, including text-only initial developer/user/assistant messages with
  one text part each, max 128 messages/8,192 rendered tokens and frontend
  instructions limit 16,384 tokens. Do not invent a token counter. Model selection,
  voice, initial history, audio format, startup instructions and delegation mode
  are immutable after startup. Preserve server snapshot id/expires_at and fixed
  status active, including the final session.closed snapshot.
- **LIVE-CONFIG-02:** Primary WebSocket audio supports mono PCM16LE at 16/24 kHz
  and G.711 PCMA/PCMU at 8 kHz. WebRTC/SIP omit audio.format and negotiate media.
  Voice names are open strings with Live's own named conveniences or an open
  LiveCustomVoiceParam object requiring id of length 1–128, default marin. Speech
  custom references remain separately closed with no declared ID length limit. Fork inherits model/voice/instructions/history; format
  overrides are WebSocket-only and client capability overrides WebRTC-only.
- **LIVE-CONFIG-03:** Preserve startup delegation omitted/null/client versus
  responses. Responses startup requires its backend model; update can omit it.
  Cover distinct Live reasoning/text/service-tier/tool_choice and all 13 Live
  tool branches plus nested namespace/function/programmatic helpers. The guide
  documents a narrower runtime-supported subset; full wire modeling is not a
  service capability guarantee for every tool. Preserve that discrepancy without
  claiming the ordinary Responses tool union already has every branch. Nullable
  instructions/max_output_tokens/parallel_tool_calls/reasoning/service_tier/text
  retain omission/null/value; max_output_tokens minimum is 16. session.update
  changes only approved backend settings, never delegation mode; empty updates
  retain settings, and null cannot switch an existing Responses session to client.
- **LIVE-CONFIG-04:** Cover frontend data-channel capabilities: omission allows
  all, literal all permits all, empty arrays permit none. Client event names and
  server selectors (including nested response.event selectors/lifecycle choices)
  preserve canonical constraints. Restrictions apply to untrusted WebRTC frontend,
  not trusted sideband. SIP trunk/provider URL/digest credentials, SDP, audio,
  transcripts and backend instructions are private in default diagnostics and
  enabled built-in logging; caller-readable wire data remains intact. Provider
  URL/content/UTF-8 byte limits follow documented contracts with safe validation
  errors, without DNS probing or unrelated logger changes.

## Live connections, commands and received events

- **LIVE-WS-01:** Provide injected platform connector seams for a primary
  WebSocket at `/live/sessions` and trusted sideband at
  `/live/sessions/{session_id}/attach`, preserving custom base URI prefixes and
  scheme conversion/path encoding/auth organization/project headers. Primary
  connect has no model/query parameters; send session.start with config first,
  wait for session.started, then application commands. HTTP creation already
  starts a session, and sideband attaches without another session.start or audio
  submission. Sideband supports optional graceful_close query exactly. Attach
  promptly for outbound SIP: the service replays only the preceding three seconds
  of call progress with original event IDs. Application deduplication where IDs
  exist is explicit; this does not imply replay of audio or application actions.
- **LIVE-WS-02:** Keep primary/sideband writers role-aware (11 versus 9 commands)
  and include all command fields and nested contracts. Caller-supplied event_id
  is optional nullable, maximum 512 characters; preserve presence/correlation.
  Appends require plain content string and required nullable delegation_id; a
  nonnull ID names an existing client delegation, null supplies general context.
  The 500-token append limit is documented, not a fabricated local tokenizer.
  Do not add Realtime buffer.commit, audio response loops or a DTMF send command.
- **LIVE-WS-03:** Reuse package VM/JS/Wasm connector policy: browser WebSockets
  reject every nonempty headers map before authentication/connect. Browser media
  examples use a trusted backend for HTTP signaling and caller-owned WebRTC data
  channel; do not invent a Live ephemeral-key endpoint or silently reuse Realtime
  client secrets. Authentication, close/abort, listener cleanup, errors and owned/
  borrowed connections have explicit behavior tested at the public connection seam.
  A caller-supplied data-channel adapter may reuse codecs, but building WebRTC
  media/capture is outside this package.
- **LIVE-WS-04:** session.close requests finalization; session.closed confirms it
  with reason/final snapshot/cumulative usage. Socket close alone is unconfirmed.
  Install the final-event listener before sending close, reject new work while
  closing, and test an immediate peer final event so it cannot be missed.
  Drain final events before releasing an owned connection, with explicit bounded
  caller timeout/cancellation behavior; distinguish graceful session close from
  local transport close. No automatic reconnect, session.start replay, sent audio/
  task replay or state restoration. Unsupplied reconnection/queue conveniences stay
  in the inventory rather than inheriting incompatible Responses semantics.

### Exact role inventories

| Writable type | Primary | Sideband | Fork | Canonical component |
| --- | --- | --- | --- | --- |
| session.start | Yes | No | Distinct overrides | LiveSessionStartEvent / LiveForkSessionStartEvent |
| session.update | Yes | Yes | Yes | LiveSessionUpdateParam |
| session.input_audio.append | Yes | No | Yes | LiveInputAudioAppendEvent |
| session.input_audio.mute | Yes | Yes | Yes | LiveInputAudioMuteParam |
| session.input_audio.unmute | Yes | Yes | Yes | LiveInputAudioUnmuteParam |
| session.instructions.append | Yes | Yes | Yes | LiveInstructionsAppendParam |
| session.thinking.append | Yes | Yes | Yes | LiveThinkingAppendParam |
| session.commentary.append | Yes | Yes | Yes | LiveCommentaryAppendParam |
| response.item.create | Yes | Yes | Yes | LiveResponseItemCreateParam |
| response.create | Yes | Yes | Yes | LiveResponseCreateParam |
| session.close | Yes | Yes | Yes | LiveSessionCloseParam |

| Received type | Canonical component | Special contract |
| --- | --- | --- |
| session.started | LiveSessionStarted | Startup acknowledgment and resolved session |
| session.updated | LiveSessionUpdated | Backend settings acknowledgment |
| session.input_audio.muted | LiveInputAudioMuted | Input mute acknowledgment |
| session.input_audio.unmuted | LiveInputAudioUnmuted | Input unmute acknowledgment |
| session.instructions.appended | LiveInstructionsAppended | Estimated context injection acknowledgment |
| session.thinking.appended | LiveThinkingAppended | Silent context acknowledgment |
| session.commentary.appended | LiveCommentaryAppended | Speakable context acknowledgment |
| session.input_audio.append | LiveInputAudioAppend | Sideband reflected audio; no event_id |
| session.output_audio.delta | LiveOutputAudioDelta | No event_id; sideband timestamps vs primary format |
| session.input_transcript.delta | LiveInputTranscriptDelta | Input transcript/timing metadata |
| session.output_transcript.delta | LiveOutputTranscriptDelta | Output text/timing metadata |
| session.delegation.created | LiveDelegationCreated | Required offset_ms and delegation metadata |
| response.event | LiveResponseEvent | Open nested Responses event; optional nullable delegation_id |
| session.usage.updated | LiveSessionUsageUpdated | Cumulative fractional seconds |
| session.closed | LiveSessionClosed | Finalization despite active snapshot status |
| error | LiveErrorEvent | Distinct Live error shape/correlation |
| info | LiveInfoEvent | Provider informational notice |
| transport.dtmf.received | LiveTransportDTMFReceived | One character 0–9/A–D/*/# |
| transport.dtmf.send | LiveTransportDTMFSend | Received reflection, not writable command |
| transport.ringing | LiveTransportRinging | Outbound SIP progress |
| transport.answered | LiveTransportAnswered | Outbound SIP answered |
| transport.failed | LiveTransportFailed | Outbound SIP failure details |

- **LIVE-EVENT-01:** Resolve `LiveServerEvent` through its allOf alias to
  `LiveServerEvent-2`: type all 22 actual components above and every reachable
  payload, fixed discriminator, required/null/optional field. Primary/fork writable
  unions have 11 branches (distinct startup), sideband nine. Received unknown
  discriminators/finite metadata remain immutable raw variants; known malformed
  required fields fail without secret/body values in errors. No blanket required
  event_id: the two audio events have none.
- **LIVE-EVENT-02:** Canonical sideband received union has 18 variants, omitting
  reflected input/output audio and DTMF; pinned SDK sideband union has 15. Guides
  and the actual full-union audio descriptions document reflected sideband audio.
  Reuse all 22 received codecs for sideband, document role delivery extras as a
  source discrepancy and do not reject a valid event merely because a narrower
  alias omitted it. Reflections use mono PCM16LE 24 kHz; output start_ms/end_ms
  are required by the sideband description, omitted on primary. Audio frame gaps
  are real; no invented retransmission/order sorting. Test role-specific constraints.
- **LIVE-EVENT-03:** LiveResponseEvent.event is a canonically open object; retain
  complete nested JSON, including objects without type, and dispatch conditionally
  when a type is present. Lifecycle snapshots omit
  input and clear instructions/tools/output: the strict ordinary Response parser
  alone is insufficient. Granular events supply generated content. Raw preservation
  in 29 is full declared wire coverage; 30 adds contextual compact typed views.
  Require outer nonnull event_id; client_event_id is optional nonnull string,
  and only delegation_id is optional nullable. Preserve its omission/null/value; do not
  guess delegation identity from response content or strip failed-response details.
- **LIVE-EVENT-04:** Live errors remain distinct from shared HTTP, flat Responses
  SSE and Agents errors. Cover `LiveLiveError` required type/code/message and
  optional param/client_event_id without inventing monitoring fields. The
  conversation guide permits code:null despite canonical/SDK string typing:
  deliberately accept required-present null as a narrow receive-only compatibility
  case, preserve it/raw context without a synthetic code, and reject missing/wrong
  types. Mark these fixtures separately from canonical examples. A command error
  or moderated audio cutoff does not automatically terminate the whole session. Preserve
  original nested context safely. LiveSessionUsage.seconds is cumulative number,
  not increments; track latest value and finalization separately, never sum
  snapshots or conflate audio duration with Responses backend token billing.

## Explicit delegation, stored forks and transcript helpers

- **LIVE-WORK-01:** Client delegation-created carries metadata/id/target and
  optional response_id, not a task utterance. Applications collect transcripts and
  their own state, launch backend work deliberately and send thinking/commentary/
  instructions appends with the correct client delegation ID. Thinking is not
  spoken immediately and is not a secrecy boundary; commentary is model-paraphrased
  speech context. Acknowledgments indicate estimated context injection, not
  playback completion, tool execution or transaction commitment. User interruption
  does not automatically cancel external work; application policy owns that decision.
- **LIVE-WORK-02:** Server-owned Responses delegation has its separate backend
  instructions/tools/config and response.event envelope. For custom function
  requests, the application authorizes/executes once, returns function_call_output
  with response.item.create, then explicitly sends one response.create only after every pending function
  result is submitted. Do not wait for a nonexistent response.item.create success
  acknowledgment.
  Preserve call ID, delegation ID and backend response ID. An example assigns one
  action owner when frontend and sideband observe the same event. No implicit
  runner, backend steering, approval, continuation, durable Agents dependency or
  retry of an attempted external action.
- **LIVE-WORK-03:** Add a compact Responses-event dispatch adapter that reuses
  existing granular event codecs where their contracts match, with distinct
  lifecycle snapshot views and immutable raw fallback for future nested types.
  Known malformed declared fields remain errors, not a catch-all fallback that
  hides defects. Demonstrate client and Responses modes with interleaved IDs,
  explicit result routing and app-owned restored state; do not widen ordinary
  Responses requests to accommodate Live-specific tools/snapshots.
- **LIVE-FORK-01:** Add fork WebSocket connection at
  `/live/sessions/{session_id}/fork`. First event is the distinct
  LiveForkSessionStartEvent with session `{}` allowed, model inherited, no new
  model query parameter or primary startup DTO. Reuse 29 event/command codecs
  and role-safe writer. Expose caller cancellation/lifetime/URI/auth seams.
- **LIVE-FORK-02:** Only documented fork overrides are admitted: WebSocket audio
  format, existing Responses backend settings and store inheritance; WebRTC-only
  client permissions never go on a WebSocket fork. Cannot change stored delegation
  mode or inherited model/voice/frontend instructions/history. A fork creates a
  new ID from a finalized stored recording, not a continuation of the same socket.
  Reattach outstanding application state deliberately and never replay audio,
  session.start, completed tools or pending side effects automatically.
- **LIVE-FORK-03:** Offline example completes/stores a synthetic original,
  downloads its mock recording, starts a new fork and deliberately restores saved
  application/delegation state. Test empty/omitted overrides, new IDs, inherited
  store, format restrictions, unavailable recording, abort and unconfirmed close.
  Neither a transport reconnect nor a fork claims restoration of application tools.
- **LIVE-TRANSCRIPT-01:** Provide pure transcript grouping helpers covering the
  pinned SDK algorithms: speaker/text timing segments, group boundaries,
  acknowledgments/interruptions and playback timeline projection. Playback helpers
  transform caller-supplied timing, not drive hardware. Use pinned SDK defaults: minimum turn separation 500 ms, assistant silence
  2,000 ms, backchannel maximum 1,000 ms and isolation 2,000 ms. Include synthetic
  SDK golden fixtures, chunk boundaries, timing gaps, late/duplicate/out-of-order
  metadata, fake clocks, flush/reentrancy/listener failures and timer disposal;
  preserve raw events even when no caption can be produced.
- **LIVE-TRANSCRIPT-02:** Helpers attach/detach without stealing subscriptions or
  canceling another grouper, clear/reset deliberately, and finish correctly on
  session versus transport close. A borrowed typed data-channel adapter owns listeners only and never closes
  caller media. Explicit non-consuming event taps/broadcast
  connection design must serve transcript helper plus application simultaneously.
  Complete immutable values, copy/equality/hash and privacy. Transcript UI/export
  is application-owned; reconnect/bounded queue behavior is retained inventory.

## Implementation acceptance policy

All seven tickets must satisfy their listed requirements through exported public
factories/resources/connections, not only private DTO tests. Use real canonical
schema manifest mappings; never fake components, hide findings with exclusions,
or promote metadata as proof of implementation. Audit all reachable fields and
union variants within a claimed family. Changed known fields are fully validated;
received future metadata is lossless finite immutable JSON and request admission
remains separate. Include old and new fields in value/hash/copy/clear contracts.

Offline unit fixtures cover MockClient/local HttpServer, chunked bytes/SSE, and
injected WebSocket peers, with VM plus Chrome JavaScript/Wasm for new portable
codecs/connection seams. Exercise correct URI/body/headers/status, retries before
stream consumption, cancellation before auth and midstream, owned/borrowed client
cleanup, malformed variants, omission/null, custom-base prefixes, unknown events,
concurrent consumers and privacy under enabled built-in logging. Local servers
remain unit tests, not mislabeled live integration tests. An existing shared
transport weakness exposed by a new seam gets a narrow fix and evidence.

Each ticket adds a runnable offline example and README/llms coverage describing
the actual implemented API. Record migration only for real source/wire corrections.
Run format → fix → fatal-info analysis, appropriate focused fixtures, package unit
suite and the full OpenAPI toolkit verification scope. Classify unrelated errors
and retained gaps honestly. Requirements and engineering reviews approve the
final combined implementation after validated findings are resolved. Final-head
CI must be green before merge. Live smokes, if useful later, use the user's bounded
cost authorization, a narrow selected test and cleanup; no full live suite is needed.
Publishing or package version bumps are outside this work.

## Remaining parity inventory

- Documentation-only consent phrase lookup lacks an authoritative response shape.
  Revisit when canonical/SDK/reference establish one; do not mark Audio complete
  while this gap remains.
- Ticket 25 corrects bounded ordinary Audio/Chat defects and audits their complete
  declared affected contracts. Any remaining shared Chat/Realtime parent-model
  gaps stay in the inventory with exact names/evidence; do not imply full Chat or
  Realtime protocol parity from voice admission. Full Realtime parity is separate.
- SDK opt-in reconnect, bounded unsent queues, raw extra query/header escape hatches
  and role-manager convenience parity remain later shared transport inventory.
  Any future recovery must distinguish unattached socket replacement from stored
  fork and must never replay attempted work or claim backend state restoration.
- Frontend WebRTC media implementation, SIP provider administration and audio
  capture/playback hardware are caller-owned integrations, not missing typed API
  operations. A codec/data-channel adapter may be additive, without a media engine.
- Phase 6 Agents/vaults, Phase 7 Administration/storage, Phase 8 authentication and
  remaining operational legacy APIs retain the [roadmap](README.md). Existing
  Responses/shared Item/tool/model gaps are unchanged; Live-specific full tool
  coverage does not establish parity for those older unions.
