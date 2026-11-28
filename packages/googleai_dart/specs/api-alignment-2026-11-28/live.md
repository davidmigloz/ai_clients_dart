# Gemini Live, Genie 4, and Live Music inventory

The cutoff is 2026-11-28 in Europe/Madrid. The baseline is `googleai_dart`
13.1.0 at `36a0c21803b969a9942bc42f84ac0658a6cb2f19`. The original
`live-api-schema.source.json` and `live-api-schema.json` both had SHA-256
`16b54f24866ce7772dc939b3b0c2adbba9f9a44d424b1329809aa9295e7df49d`.
The local WebSocket toolkit fetch copies a checked-in source. The pinned
public references and SDK revisions establish the upstream contract.

## Pinned sources

- [Release notes](https://aistudio.google.com/docs/changelog), [Developer Live protocol](https://aistudio.google.com/api-reference/live), [Bidi route and envelopes](https://aistudio.google.com/api-reference/live/bidi-generate-content), [authentication](https://aistudio.google.com/docs/ephemeral-tokens), [capabilities/model differences](https://aistudio.google.com/docs/live-api/capabilities), [transcribe and voice editing](https://aistudio.google.com/docs/live-api/live-transcribe), [thinking](https://aistudio.google.com/docs/live-api/thinking), [tools](https://aistudio.google.com/docs/live-api/tools), [live translation](https://aistudio.google.com/docs/live-api/live-translate).
- [Agent Platform Live protocol](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/multimodal-live), [Agent Platform session/auth](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session), [Agent Platform model locations](https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/locations), [Agent Platform release notes](https://docs.cloud.google.com/gemini-enterprise-agent-platform/release-notes).
- [Python connect](https://github.com/googleapis/python-genai/blob/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6/google/genai/live.py), [Python mappings](https://github.com/googleapis/python-genai/blob/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6/google/genai/_live_converters.py), [Python types](https://github.com/googleapis/python-genai/blob/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6/google/genai/types.py), v3.6.1.
- [JS connect](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/live.ts), [JS mappings](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/converters/_live_converters.ts), [JS types](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/types.ts), v3.6.1.
- [Genie 4 guide](https://aistudio.google.com/docs/genie), [Python WebSocket](https://github.com/googleapis/python-genai/blob/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6/google/genai/_interactions_websocket.py), [JS WebSocket](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/_interactions_websocket.ts), [JS WebRTC](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/_interactions_webrtc.ts), [scoped token SDK route](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/gaos/funcs/interactions-auth-tokens-create.ts).

Source byte pins for the Markdown endpoints above appear below. The canonical snapshot carries the complete list of Live Bidi source URLs and hashes.

| Document | SHA-256 |
| --- | --- |
| Developer Live reference | `9064b020b88a8aca0e435761ece7ab740bc9a12191570a8033949e62bcce7689` |
| Developer Live Bidi route | `28f5a254a8806f6270a9862b80e0f699f43be580920b97070ce54526759c0535` |
| Developer Live ephemeral tokens | `e7570380e32e1e6b97236ac3e97aad6f0fe2566697ee141b6c995175513c28f4` |
| Developer Live Transcribe guide | `309597302fa8f089976fb0f1366c7db1759b9f673f227fc48a6eda70ec480608` |
| Developer Genie 4 guide | `21419b67e2ced97849d894f07a15856b97a42c04023b4de8711f5aa3f8f70a48` |

## Gemini Live connection and lifecycle

| Surface | Dart disposition and evidence |
| --- | --- |
| Developer API key and proxy | `GoogleAIClient.createLiveClient()` sends an API key in the query for the public `v1beta` `GenerativeService.BidiGenerateContent` route and retains custom gateway scheme, port, path, and unrelated query parameters. [Routing](https://github.com/davidmigloz/ai_clients_dart/pull/653) · [Developer Bidi reference](https://aistudio.google.com/api-reference/live/bidi-generate-content) |
| Developer ephemeral tokens | `authTokens.create` uses the general Developer AuthToken endpoint. `connect(accessToken: ...)` and `EphemeralTokenProvider` select the constrained `v1beta` Bidi route. Browser auth uses `access_token` in the query and native callers can choose the `Authorization: Token` header. The public route takes precedence over older SDK warning text about `v1alpha`. Loopback and browser tests cover credential precedence and sanitized failures. [Routing](https://github.com/davidmigloz/ai_clients_dart/pull/653) · [Ephemeral tokens](https://aistudio.google.com/docs/ephemeral-tokens) |
| Vertex project and regional routing | `ApiVersion.v1` and `v1beta1` select the public `LlmBidiService/BidiGenerateContent` routes with native OAuth headers, a regional host, and a qualified project, location, and publisher model. A browser cannot attach the required OAuth header. Tests cover regional, custom gateway, and explicit model paths. Gemini 3.8 Live lists us, eu, us-central1, and asia-south1. Gemini 3.5 Transcribe Live lists global, us, and eu. [Routing](https://github.com/davidmigloz/ai_clients_dart/pull/653) · [Cloud startup and auth](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session) · [3.8 Live](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-8-live) · [3.5 Transcribe](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-5-transcribe#regional-availability) |
| Setup, errors, and cleanup | Dart listens for setup acknowledgement before sending the first frame. Malformed text, malformed UTF-8, and bad typed fields enter the message error path. Failed setup and explicit close drain tracked sessions. Errors redact applicable auth values and both raw and URI-encoded resume handles, including checkpoints sent after setup. [Lifecycle](https://github.com/davidmigloz/ai_clients_dart/pull/671) · [Native fixtures](../../test/unit/live/live_connection_io_test.dart) |
| Pending connections | Closing the Live client settles pending credential and setup waits and aborts native and browser WebSocket upgrades. A late credential result cannot dispatch an upgrade. The client can connect again. [Pending connections](https://github.com/davidmigloz/ai_clients_dart/pull/678) · [Native fixtures](../../test/unit/live/live_connection_io_test.dart) · [Browser fixtures](../../test/unit/live/live_connection_web_test.dart) |
| Resumption checkpoints | `LiveSession.lastResumableUpdate` retains the last usable checkpoint separately from the latest status. Vertex transparent resumption exposes `lastConsumedClientMessageIndex` as a decimal string. Dart strips Vertex-only `transparent` from Developer setup and reports failed resume as `LiveSessionResumptionException`. The caller owns buffering and replay. [Lifecycle](https://github.com/davidmigloz/ai_clients_dart/pull/671) · [Cloud session management](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session) |
| Models and stage | Current examples use `gemini-3.8-live`. Developer Gemini 3.8 Live models are GA while the Developer Bidi reference labels the API preview. The extended-thinking guide lists low, medium, and high. The retired `gemini-2.0-flash-live-001` remains historical. [Developer model](https://aistudio.google.com/docs/models/gemini-3.8-live) · [Thinking](https://aistudio.google.com/docs/live-api/thinking) · [Deprecations](https://aistudio.google.com/docs/deprecations) |

## Bidi messages and configuration

| Wire surface | Dart disposition and evidence |
| --- | --- |
| Setup and generation | `LiveConfig` and `BidiGenerateContentSetup` carry labels, safety settings, history, and Vertex explicit VAD. `LiveGenerationConfig` carries media resolution, seed, thinking, affective dialogue, and translation. The decoder accepts integral numeric `topK` and the public Dart property remains `int?`. `SafetySetting.method` preserves Vertex `SEVERITY` and `PROBABILITY`. Developer Live rejects that Vertex-only argument before auth. [Setup changes](https://github.com/davidmigloz/ai_clients_dart/pull/675) · [Cloud Bidi reference](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/live-api) · [Developer translation](https://aistudio.google.com/docs/live-api/live-translate) |
| Proactivity and compression | Dart carries `proactiveVideo` where the model supports it. Vertex Gemini 3.8 Live enables affective dialogue and proactive audio by default, so applications omit the older flags on that model. Cloud 2.5 fixtures cover explicit audio controls. Compression sends protobuf int64 decimal strings and continues to read previously saved integer fields. [Cloud 3.8 Live model guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/guides/gemini-3-8-live) · [Developer Bidi reference](https://aistudio.google.com/api-reference/live) |
| Context and real-time input | The Live context/input follow-up supports completion without resending `turns`, Vertex `sendContextUpdate` and explicit empty tools, Developer per-frame `mediaResolution`, and the deprecated `mediaChunks` wire key. Existing setup, tool response and unknown envelopes continue through the same dispatch. [Developer Bidi reference](https://aistudio.google.com/api-reference/live) · [Cloud Bidi reference](https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/models/live-api) |
| VAD and turn coverage | Canonical `START_SENSITIVITY_*` and `END_SENSITIVITY_*` are written, with legacy bare `HIGH` and `LOW` accepted for decoding. Enums expose unspecified values and `TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO`. [Enum alignment](https://github.com/davidmigloz/ai_clients_dart/pull/665) · [Public wire values](https://aistudio.google.com/api-reference/live) |
| Transcription | Dart carries language hints, vocabulary, word timestamps, the diarization wire field, SMART and VERBATIM modes, and SMART voice editing with `sourceText`. It parses final and interim transcript frames, language, speaker, offsets, and words. Legacy `AudioTranscriptionConfig.enabled` controls setup object presence. The dedicated Transcribe guide limits availability even where the shared Bidi schema has a field. In particular, real-time diarization is unavailable there and SMART mode is incompatible with timestamps and diarization. [Transcription alignment](https://github.com/davidmigloz/ai_clients_dart/pull/658) · [Live Transcribe guide](https://aistudio.google.com/docs/live-api/live-transcribe) |
| Usage and turn metadata | Dart keeps envelope `usageMetadata` alongside existing messages or standalone input. `responseUsageMetadata` normalizes Developer response and Vertex candidate count names while preserving the original wire casing. It also carries per-turn `waitingForInput`, `turnCompleteReason`, interaction status, speech state, URL context, and legacy nested usage decoding. [Response metadata](https://github.com/davidmigloz/ai_clients_dart/pull/666) · [Developer server envelope](https://aistudio.google.com/api-reference/live) |
| Voice activity | `message.voiceActivity` carries activity type and protobuf-duration audio offset with existing messages or standalone frames. The Dart extension type retains future strings. [Lifecycle alignment](https://github.com/davidmigloz/ai_clients_dart/pull/671) · [Developer voice activity](https://aistudio.google.com/api-reference/live#VoiceActivity) |
| Prebuilt avatars | The Vertex v1 avatar slice selects a built-in avatar in `LiveAvatarConfig` and `ResponseModality.video` with `gemini-3.8-live`. Native and browser fixtures check the setup frame and MP4 media. The first subscription receives early MP4 frames in order. The startup buffer retains up to 64 frames or 16 MiB and reports a typed error on overflow. Optional numeric compression bitrates follow the pinned SDK models. The Developer wire reference describes audio output and the prebuilt avatar path is verified for Cloud. [Cloud avatar guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/configure-live-avatars) · [Avatar implementation](https://github.com/davidmigloz/ai_clients_dart/pull/687) |
| Shared tool responses | `FunctionDeclaration.behavior` selects blocking or asynchronous execution on supported models. `FunctionResponse` carries the provider call ID, structured response and scheduling. Vertex Live expects a single complete response, while the shared `willContinue` field is available on supporting APIs. Tool cancellation carries call IDs. Incremental function arguments belong to Vertex REST streaming and its `streamFunctionCallArguments` option. [Developer Live tools](https://aistudio.google.com/docs/live-api/tools) · [Cloud Live tools](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/asynchronous-function-calling) · [Cloud REST tools](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/tools/function-calling) |

The WebSocket manifest verifies the canonical Bidi configuration and
discriminator paths. Immutable message wrappers, open wire values and
normalization wrappers are covered by offline Dart fixtures where the
toolkit assumes a generated `copyWith` or fixed enum. The package also
documents before-and-after migration for exhaustive switches.

### Availability limits

- The public project-scoped Vertex OAuth transport is covered. The pinned
  SDK Express API-key transport has separate routing and authorization.
  [Cloud session management](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/start-manage-session)
- Reference-image avatars and custom-voice registration have their own
  access and consent requirements. The public Cloud avatar example uses a
  prebuilt avatar and prebuilt voice.
  [Cloud avatar guide](https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/live-api/configure-live-avatars)
- The pinned converters name `voiceActivityDetectionSignal` and
  `voiceConsentSignature`. The reference supplies a public response shape
  for `voiceActivity` and no corresponding public general response contract
  for the other fields.
  [Developer Bidi reference](https://aistudio.google.com/api-reference/live)
- Verification uses simulated HTTP, WebSocket, browser, and WebRTC peers.
  Provider sessions require separate authorization.

## Genie 4

Genie 4 is a paid-tier Developer API model that uses Interactions
`v1beta`. Its SDK live transports have independent preview functionality.

- The interaction-scoped token endpoint
  `POST /v1beta/interactions/{id}/auth_tokens` is separate from general
  Bidi Live auth. Native WebSocket uses the API-key header. In browsers the
  scoped token uses the `auth_token` query parameter.
- The WebSocket connects through `/v1beta/interactions/live` and sends
  `interaction.connect` before controls. Dart decodes singleton and batched
  events, typed server outcomes, and JPEG and PCM media. Completing or
  cancelling changes the provider interaction. Detaching closes the local
  transport and leaves the provider interaction active.
- Browser WebRTC sends `offer_sdp` to the interaction signaling route and
  receives `answer_sdp`. The browser peer receives audio and video tracks
  and sends controls with the events data channel. Native callers can use
  the WebSocket client.

[Genie 4 guide](https://aistudio.google.com/docs/genie) ·
[WebSocket implementation](https://github.com/davidmigloz/ai_clients_dart/pull/659) ·
[WebRTC implementation](https://github.com/davidmigloz/ai_clients_dart/pull/664)

## Live Music

`createLiveMusicClient()` connects to Developer API `v1beta`
`GenerativeService.BidiGenerateMusic` for the experimental
`lyria-realtime-exp` model. Dart supports weighted prompts, generation
settings, PLAY, PAUSE, STOP, RESET_CONTEXT, and the model's 48 kHz stereo
16-bit PCM. Offline tests cover setup acknowledgement, warnings, filtered
prompts, timeouts, cancellation, and closed sessions. Cloud's Lyria REST
models use a separate contract.

The public Markdown protocol SHA-256 is
`21fa98c24bd62a0a8a612aa502f0d17e1d67fa309f296617b68b5fc34e1f210f`.
The generation guide SHA-256 is
`e75053a3a24ccc63da76f62e7113949f0a83710f7d3283f30c9272df77de895f`.

[Live Music reference](https://aistudio.google.com/api-reference/live-music) ·
[Generation guide](https://aistudio.google.com/docs/realtime-music-generation) ·
[Dart implementation](https://github.com/davidmigloz/ai_clients_dart/pull/667) ·
[Pinned Python transport](https://github.com/googleapis/python-genai/blob/aa813f8bf805b6f4f3e57abb8f04b91d769e23e6/google/genai/live_music.py) ·
[Pinned JavaScript transport](https://github.com/googleapis/js-genai/blob/719dffc91dbf38f8a5f2d90bf93efa5dc8207999/src/music.ts)
