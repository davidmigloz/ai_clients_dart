# Realtime input references and audio controls review

Issue #421; parent #413. Reviewed November 4, 2026 against the fixed October 31
source cutoff. Later upstream releases do not expand this slice.

## Authority and inventory

- OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`.
- Python 3.42.0, `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, `c717857c3151bde92e07e4d396301a9c67163e68`.
- Official Realtime Translation guide and audio deprecation schedule, with frozen
  source hashes in the adjacent manifest. The current schedule was rechecked for
  the same announced audio shutdowns.

All 40 assigned schemas are accounted for: 26 type/role aliases and 14 contextual
bindings, plus six supporting component/inline bindings. No HTTP operation was
added. Contextual query parameters, scalar strength, raw response status details,
legacy model-name changes, and helper envelopes are recorded as their real Dart
contexts rather than fabricated request models. Canonical spec/global manifest
promotion remains #427.

## Native response input and event changes

RealtimeResponseInputItem is a separate closed GA family: item references,
role-aware messages, function calls and function outputs. Public
RealtimeConnection.createResponse(input:) serializes these values; omission uses
the default context and [] creates an empty response context. conversation:none
keeps response output outside the default conversation. References require an
existing session item ID and never become newly created conversation items.

The native family validates exact ID/call-ID 1–32-character ASCII constraints
and reserved root exclusion; names use the separate 1–64-character alphabet
without incorrectly excluding root. System/developer messages require exactly
one input_text part, users allow text/audio/image, and assistants allow output_text.
Optional nullable IDs/status/transcripts/image detail retain absence/null/value.
Status is completed/incomplete; image detail is low/high/auto, with no Live-only
original value. Text/argument/output limits count Unicode code points. Tool
strings are preserved exactly, not parsed as JSON. Audio retains session format
without borrowing fixture-only sample/size limits. Images follow the canonical
inline image-data URI contract. Lists are snapshotted; constructor/parser/copy
paths validate and diagnostics redact payloads.

The frozen SDKs still expose the broader ConversationItem family, optionally
combined with a reference in their WithReferences helpers. Canonical introduces
the narrower GA family; Dart follows it for the new typed input API. Canonical beta
input still references the broader conversation family despite an example using
an item reference. Raw send remains the wider compatibility path; GA types are not
falsely aliased to beta, and the removed beta service is not restored.

InputAudioTranscriptionDeltaEvent now permits absent contentIndex/delta while
rejecting explicit wire null for those fields. Nullable typed logprobs preserve
absent/null/empty/populated lists. RealtimeTranscriptionLogprob follows the actual
LogProbProperties component, including exact integer bytes with no invented byte
range. Future finite JSON and token lists are deeply snapshotted, equality/hash
use complete effective JSON, and copies cannot resurrect cleared known fields.
The event constructor is no longer const to support snapshots. MIGRATION.md covers
both dropping explicit const and consuming nullable getters. Python Optional
output fields tolerate null; canonical/Node nonnull-when-present rules govern here.

Existing response.created/done raw maps already retain status_details.error.message
for GA and beta. Parser fixtures prove both protocol shapes with the canonical
realtime.response object literal. DTMF event/received_at and retrieved item events
already survive through the existing raw unknown-event path. Their assigned deltas
change examples/metadata; no extra sealed variants or full response DTO rewrite
was required.

## Noise strength, voice selection and returned transcription configuration

The existing shared GA and Translation noise leaves now accept optional finite
strength from 0 through 1. Omitted strength stays omitted on update and preserves
the service's current value; the initial server default of 1 is never inserted.
clearStrength omits the local field rather than resetting the server. Existing
wrapper clear flags emit null to disable filtering. Translation retains required
type, whereas GA type is optional.

Existing const noise constructors remain compatible: null constructor strength
means omission. Parsers reject wire null; copyWith explicit null rejects and its
clear flag omits. Validation before serialization is unconditional, so invalid
values cannot reach the wire with assertions disabled. Both frozen SDKs omit
strength; this slice deliberately follows canonical's new field and documented
update semantics. SDK request noise types also omit nullable disable despite
prose supporting it; canonical and existing Dart wrappers retain disable.

RealtimeAudioConfigOutput keeps String? voice and adds shared AudioVoice
voiceSelection for named/custom references. Only one representation may be set;
copying between them explicitly clears the previous field. Shared codecs validate
custom objects, effective wire equality treats equivalent names equally, and
redacted diagnostics name the new field. Audio-sample custom voices are eligible
subject to service access; prompt-created voices remain Live-only.

AudioTranscriptionResponse is returned session input-transcription configuration,
not ordinary /audio transcription output. Existing InputAudioTranscription already
handles open model/languages/keywords fields; mock REST responses verify returned
keywords independently of submitted values. Its pre-existing const list ownership
behavior is unchanged; this slice does not claim a new immutable wrapper there.
Open model strings already admit current Realtime/transcription model aliases.

## Connection and Translation workflows

Realtime connect now accepts optional model, callId and documented intent. Typed
nonnull values override corresponding query keys, retaining other per-call/base
queries. Secret-selected and transcription sessions can omit model. Canonical and
Python permit independent optional selectors; Node imposes a stricter target XOR.
Dart keeps canonical query semantics and service validation rather than inventing
a new combination restriction.

Existing opt-in Realtime recovery retains its Node-derived model-session boundary:
no call_id/intent, an effective model is required, and callbacks may reconcile
before flushing explicitly retained work. Translation retains #417's existing
Python-derived recovery support. No attempted configuration/history/audio/action
replay is added. This SDK disagreement is explicit, not claimed API parity.

Translation already has its dedicated route, required model, typed config/events,
REST scoped-secret resource, cancellation and cleanup. No new event engine or
Node-only finish helper was needed. closeSession sends session.close; callers keep
reading trailing output through session.closed and then close locally. It does not
wait for acknowledgment or guarantee flush after transport loss. Browser defaults
reject configured headers before credential lookup; WebRTC or authenticated
backend proxies remain the supported browser paths.

## Reviews, examples and verification

Separate requirements and engineering reviews covered all 40 inventory entries,
source hashes/inline pointers, native constraints, model value contracts, public
HTTP/WebSocket paths, recovery admission, browser policy and documentation. No
remaining blocker was identified. Review corrections clarified closeSession's
send-only behavior, scoped the legacy RealtimeSession model-name receipt instead
of claiming its whole flat schema, and used canonical beta fixtures.

- Full package unit suite: **26,038 passed, two skipped, no failures**.
- Chrome: **73 new model/public-path tests passed**.
- Independent selections: 32 input/event/public tests; 71 connection/recovery/
  Translation tests; 103 audio-control/adjacent model/public REST tests.
- An assertions-disabled probe rejected all 11 invalid strength/voice settings.
- Package formatting, dart fix and fatal-info analysis pass.
- Both new offline examples execute successfully: acknowledged history reference
  plus new input; scoped Translation secret, noise config, typed audio/transcripts
  and flush/close. They use synthetic HTTP/WebSocket peers, no API key, live API
  requests, microphones or audio devices.
- README topics remain concise and collapsible; existing Realtime example uses
  gpt-realtime-2.1. Audio sunset guidance distinguishes endpoint/workflow migration
  from merely changing a model string. No version/changelog edits or live tests.

The toolkit fetched/reviewed the frozen candidate, described the input union,
scaffolded an image preview in dry-run mode, and verified an isolated promoted
candidate plus scoped mappings in /tmp/openai-issue421-contract. No new exclusions
or suppressions were added; package canonical promotion stays with #427.

The frozen overlay reports implementation **1194 errors, 251 warnings, 330 infos**;
consistency zero errors/125 warnings; eight existing export findings. Docs/readme
have no findings, with 59 collapsible topics. These are explicit global discovery
results, not a globally green parity claim. The new strict native input codecs
have no implementation errors; lexical infos reflect role/allOf context. Remaining
scoped errors expose existing missing prompt fields, HTTP discriminator injection
outside DTOs, and unchanged older events without copyWith. Effective-JSON equality
and redacted summaries also exceed the lexical scanner's field tracing. Public
fixtures and independent review validate the assigned changes; #427 owns global
reconciliation and final source promotion. The wider legacy flat session schema
is not mislabeled as implemented by the current GA view.
