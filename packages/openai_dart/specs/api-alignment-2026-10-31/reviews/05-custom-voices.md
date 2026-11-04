# Issue #418 frozen custom voice contract audit

Issue #418, parent #413. Reviewed November 4, 2026. Sources: frozen OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`, Python 3.42.0 `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`, Node 7.47.0 `c717857c3151bde92e07e4d396301a9c67163e68`, and cached official custom-voices guide/changelog under `/tmp/openai-oct31-audit`. Initial audit was read-only; root subsequently authorized scoped model implementation.

## Exact operation/encoding contracts

- POST `/audio/voices`: JSON body is **only** `CreateVoicePromptRequest`. Multipart body is `CreateVoiceRequest`, a oneOf `CreateVoiceFromConsentRequest` or `CreateVoicePromptRequest`; discriminator `type`, default-discriminator value `audio_sample`. Both branches return HTTP 200 JSON `VoiceResource`. No preview/audio payload.
- Sample branch: required name/audio_sample/consent; optional type, only `audio_sample`, default `audio_sample`. Omission must remain omission. Name length1–256 code points, not a documented trim/nonblank requirement. Existing sample file constraints remain10MiB/eight MIME bases; no transcript/quality validator or new consent restrictions.
- Prompt branch: required type=`prompt`, name, prompt. Name1–256 code points. Prompt1–2000 code points and must not contain only whitespace. Optional script_hint1–2000 code points, nonblank after trimming; service rejects scripts that are too short, but neither schema nor SDK gives an enforceable local numeric shortness threshold. Preserve untrimmed caller strings. Optional model is an **open string**, with known suggestions `auto`/`2026-10-08`; server default auto. Omit model when unspecified, and do not invent a closed enum, nonblank model rule or eager default emission. Optional fields are not nullable on the wire.
- Multipart prompt: the same five text fields, no audio_sample file, filename or consent part. Encoder must own the multipart boundary; forced JSON Accept remains accurate. JSON prompt must use real JSON encoding and force application/json after configured media headers.
- DELETE `/audio/voices/{voice_id}`: caller-selected opaque ID, no request body; HTTP200 JSON `VoiceDeletedResource`, required id, fixed object=`audio.voice.deleted`, required boolean deleted (false is a legal value, not a fabricated true discriminator). Does not delete a consent recording. Already deleted voice returns404. Encode one path segment once; retain custom base/query. Existing consent helper pattern rejects empty/literal dot/dotdot segments that Dart URI normalizes, without restricting prefixes or otherwise trimming opaque IDs.

## Response contract

`VoiceResource`: required object=`audio.voice`, id:string, name:string, type=`audio_sample`|`prompt`, created_at:integer. Optional prompt:string is original voice description when stored; may be omitted for old prompt voices as well as audio-sample voices. Do not require it whenever type=prompt, apply request length/blank restrictions to received metadata, or synthesize empty text. Canonical and Node reject explicit null; Python's generated `Optional[str]=None` model tolerates it. Choose canonical/Node non-null wire semantics and record this disagreement. Keep finite immutable future receive-only extras, with typed fields authoritative. Optional prompt copy(null) clears/omits the known key rather than resurrecting rawJson.

## SDK/guide disagreements

- Both SDK docs advertise JSON or multipart prompt, but implementations actually choose multipart for all creates. Node always calls multipartFormRequestOptions. Python always sets multipart Content-Type and `_base_client.py` uses ForceMultipartDict even with no files. Canonical and official guide provide explicit JSON support, so Dart should support JSON prompt as well as multipart rather than copying that helper limitation.
- Python generated Voice.prompt Optional versus canonical/Node optional non-null string as above.
- Guide adds deployment/service facts: prompt voices work only in Live, not Realtime, Text to Speech or Chat Completions audio; prompt creation requires no recording/consent. Creation saves a new voice; returns metadata only. Use returned ID under initial Live `session.audio.output.voice.id`, retain original prompt and include voice description in instructions. Existing audio-sample voices continue their own supported workflows.
- Fresh prompt requests save distinct resources. The existing Dart sample path is sent once because multipart cannot be cloned. Root should make an explicit decision about JSON creation retry policy; conservative one-attempt creation keeps encoding choice from changing duplicate-resource exposure. No service idempotency guarantee was found in these sources.

## Nine named Live voices

Oct16 changelog names Nuri/Juni/Flitz (German), Brise/Sillage (French), Nira (Hindi), Harema/Shida (Japanese), Noeul (Korean). Canonical LiveInitialSessionAudioOutputParam.voice inline enum includes all nine. **All nine are already present** as lowercase LiveVoice static constants and are covered in `test/unit/models/live_config_constraints_test.dart`. No missing constants should be added. Dart also preserves arbitrary future names through LiveVoice.named and open custom objects with ID1–128. Pinned Python BuiltInVoice and Node BuiltInVoice include only Shida among the nine; they lag canonical/changelog, so do not remove the other eight or narrow the open Dart voice shape.

## Agreed additive Dart design

Root coordinated: new sealed `VoiceCreateRequest` with validate(); existing final `CustomVoiceCreateRequest` extends it with unchanged constructor/fields/runtime type and omitted audio_sample type semantics; new `PromptVoiceCreateRequest` has fixed type getter prompt, JSON parser/serializer, full value/copy/redacted diagnostics, optional-clear semantics. No synthetic JSON parser for uploaded binary sample branch. VoicesResource.create widens to base and accepts an optional JSON/multipart encoding selection; null infers JSON prompt or multipart sample; explicit JSON sample fails before auth. CustomVoice gains type with constructor default audio_sample for source compatibility, plus optional prompt; known type remains strict to these two values. New CustomVoiceDeleted snapshots finite future metadata, preserves false, and has full copy/value/privacy contracts.

Mappings: CreateVoiceRequest -> VoiceCreateRequest (sealed_parent); CreateVoiceFromConsentRequest -> CustomVoiceCreateRequest; CreateVoicePromptRequest -> PromptVoiceCreateRequest; VoiceResource -> CustomVoice; VoiceDeletedResource -> CustomVoiceDeleted. Global source promotion remains #427-owned; issue overlay should record real mappings/receipts rather than promoting unrelated canonical changes.

Important cross-cutting implementation: current isCustomVoiceRequest only recognizes POST collection. New DELETE item must be included so its opaque ID, auth/trace headers, response and errors retain existing custom-voice redaction/auth/media policy. Current README/llms descriptions claiming sample-only creation/fixedtype/noCRUD need refreshing. Add explicit offline create/use/delete example; selecting Live configuration is enough, no billed voice playback or live creation required.

## Source SHA256 receipts

- openapi.json: 73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc
- Python resources/audio/voices.py: da2533258e202da4969be1843a50bfcdc0a637dbbc6c75194f96d2e90d955150
- Python types/audio/voice_create_params.py: 4ac1fa687ed2615dbcf1a16324b56bb2e85e13d7d901f00b47987defed0e59d3
- Python types/audio/voice.py: ed71fb7590405ac01f5664486c6f3c8b23f5eaf39f5ce8ca9a6a3a0aba981cc5
- Python types/audio/voice_deleted.py: 27147936aea24eee30b50374421299dc26c656a90ff95c075c0cc62c7897514b
- Python types/live/built_in_voice.py: 7681de0cd5d1012e98c25dfebceed7876867d7697e3b97568f66b86639b94aa1
- Node resources/audio/voices.ts: c6a233088632dd5820a53e14c27de571b450d6ab05b960c2089697ec098cc603
- Node resources/live/live.ts: 5a333e33f6a449288c0d6fcc156cb73b5a154e25d470f08edfe089c3f2353df9
- Cached custom voices guide: 4002579024bb717313900837691eba530968b1602b028f00409aca8794cef1e2
- Cached changelog: f467827b1ceac790e6bf11056f9056cd1b4573eb041cb7d68474df1ce053f665

## Implementation and validation

VoiceCreateEncoding is a local transport option, not an API wire enum. Omitted
encoding preserves existing sample multipart dispatch and chooses the documented
JSON prompt branch. Explicit JSON with a sample request fails before credentials
are read. Prompt strings are serialized unchanged and are not trimmed or coerced.

Both creation encodings explicitly disable automatic retries, preserving the
existing sample path's one-attempt policy and avoiding duplicate saved resources
after an uncertain JSON create. DELETE uses the normal shared retry policy and
returns the actual required deleted boolean. Its route joins the existing private
voice classifier, so logs, HTTP errors, headers and IDs are redacted consistently.

The sample DTO/constructor/runtime type remains intact under the additive sealed
request base. Existing sample request omission, binary byte snapshots, MIME and
upload limits are unchanged. Response type defaults to audio_sample for existing
constructor callers, while parsed responses retain the returned creation method.
The optional stored prompt can be cleared without resurrecting old raw metadata.

The public offline example creates a synthetic prompt voice, constructs a Live
startup selection locally, and explicitly deletes the saved voice in finally.
It performs two mock requests and no billed playback or voice creation. README
usage remains in its existing collapsible custom-voice topic; source/global
manifest promotion is deferred to #427. No version or changelog changes belong
to this slice.

## Review and verification evidence

Independent engineering/requirements review verified the frozen schema and both
SDKs, JSON/multipart dispatch, shared HTTP policy, omission and Unicode handling,
all nine existing named voices, response copy/value contracts and private default
diagnostics. It found a malformed UTF-16 opaque-ID edge case: Dart URI encoding
can silently replace an unpaired surrogate. Deletion now requires an exact
encode/decode round trip before authentication; high/low surrogate regressions
prove no dispatch. The example also falls back to the original request prompt
when older response metadata omits it. No review finding remains open.

- The independent focused selection passed 326 tests covering new prompt and
  existing sample models/resources; all five unsafe-ID cases pass.
- Package formatting, dart fix and fatal-info analysis pass.
- The public offline example passes with exactly two mock requests, validates
  the Live voice reference, and deletes explicitly in finally. No live voice
  creation or billed playback was run.
- Toolkit fetch/review/describe/scaffold dry-run and isolated candidate promotion
  use the frozen source. Global canonical/manifest promotion remains #427.
- Scoped prompt model checks have no findings. The sample DTO retains the two
  existing missing JSON-method errors and binary String/Uint8List scanner info:
  uploads are verified as multipart, without inventing JSON binary conversion.
  VoiceResource and VoiceDeletedResource each have two lexical scanner warnings
  because equality/hash delegate to complete serialized JSON. Value tests prove
  all canonical and preserved future fields participate. The union consistency
  warning about optional sample type versus required prompt type is intentional
  canonical default-discriminator behavior.
- Full frozen-overlay totals: implementation 1086 errors, 157 warnings and 280
  infos; consistency zero errors/115 warnings; eight pre-existing export
  findings. Docs/readme have zero findings and all 54 usage topics remain
  collapsible. This is a scoped verification receipt, not a globally green
  toolkit claim.

Final browser run: all 146 new prompt-model/resource tests pass in Chrome.
The full unit run reports 25,770 passed, two skipped and one failure in the
unchanged HTTP/2 paused-consumer observation fixture. Its isolated file reports
22 passed and the same failure on this host. That fixture also failed before
this feature; parent #446's complete CI passed on both supported Dart versions.
No HTTP/2 implementation/test is changed here. The PR records the failure
explicitly and does not claim a green local full-suite result.


