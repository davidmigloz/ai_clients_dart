# Live audio fixtures and SIP DTMF review

Issue #420; parent #413. Reviewed November 4, 2026. The frozen source cutoff
remains October 31; later changes do not expand this slice.

## Source authority and coverage

- OpenAPI `2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce`.
- Python 3.42.0, `0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f`.
- Node 7.47.0, `c717857c3151bde92e07e4d396301a9c67163e68`.
- Official SIP guide, with frozen source hashes in the adjacent manifest.

All 20 assigned schema changes are accounted for: 16 real class/codec bindings,
three existing contextual scalar validators and one removed server schema.
LiveDetailEnum, LiveFunctionCallItemStatus and LiveMessagePhase are already exact
string constraints in the native Live Decisions models from #419; no duplicate
public enums are introduced. Primary/fork/sideband unions use the existing shared
classes and channel-specific factories/validation rather than fabricated DTOs.
There is no new HTTP operation. Canonical spec/global manifest promotion stays
with #427.

## Fixture contract and media semantics

LiveOutputAudioFixturePlayParam accepts a complete standard-base64 payload, or
snapshots a Uint8List view through fromBytes. Before send, validation checks the
1,920,000-character encoded limit, valid alphabet/decoding, nonempty even samples,
and the 1,440,000-byte maximum: 30 seconds of mono PCM16 little-endian at 24 kHz.
Recognized RIFF/RIFX/RF64/BW64 WAVE containers are rejected without conversion.
The original text accepted by the standard decoder is preserved; no additional
re-encoding equality rule is imposed. Headerless samples cannot prove their
rate/channel count/endianness: supplying the documented format remains the
caller's responsibility. Negotiated session format never changes fixture format,
and ordinary input appends retain their own format and limits.

Fixture play is admitted on primary/fork WebSockets and trusted sidebands,
with existing startup barriers. Borrowed LiveDataChannelSocket writers reject
it, while an already-started primary WebSocket remains supported.
LiveOutputAudioFixturePlaying acknowledges validated acceptance, not the first
listener sample. LiveOutputAudioFixturePlayed reports server mixer drain, not
listener completion; transport audio can remain buffered. Neither failure nor
close synthesizes a successful drain event.

The service owns overlap, input dropping and append restrictions. Only one
fixture can play; input arriving during it is dropped rather than replayed, and
instructions/thinking/commentary appends are rejected. Explicit mute/unmute is
independent: those acknowledgments are never inferred from fixture events.
Independent mute sends silence to the model while sideband reflection continues;
unmuting during a fixture does not resume inference before it ends. No guessed
playback state, buffering or automatic retry/replay is added.

## DTMF directions and source disagreements

LiveTransportDTMFSendParam is a sideband SIP command with one unchanged ASCII key
from 0–9, A–D, * or # and optional nullable event_id. Primary/fork parsers and
writers reject it, including direct typed-constructor admission through shared
inheritance. A generic attachment does not prove SIP eligibility; the service
checks transport support and reports failures through ordinary LiveErrorEvent,
including error.clientEventId when available.

LiveTransportDTMFSent uses transport.dtmf.sent, required server event_id/key and
optional nonnull client_event_id. It confirms submission to the SIP trunk, not
a remote IVR action. LiveTransportDTMFReceived remains the caller-to-session
notification. Both notifications are admitted only on sidebands.

Canonical removes the old receive-only LiveTransportDTMFSend/.send schema.
Both official SDKs retain a legacy alias for saved-event compatibility. This
issue follows its explicit canonical direction correction: the old Dart class
is removed, while saved receive .send frames retain finite immutable JSON through
UnknownLiveServerEvent. They are never reinterpreted as outbound commands or
silently renamed to .sent. MIGRATION.md provides before/after and exhaustive-switch
guidance for the renamed and added sealed variants.

Canonical/Node optional server correlations are nonnull when present; Python's
Optional defaults tolerate null. Dart follows canonical/Node. Request IDs retain
omitted/null/value semantics and the existing 512-codepoint bound; no request-only
ID length rule is added to server IDs. Canonical's narrow sideband server alias
omits reflected audio, but individual schema descriptions, both SDK
ConnectServerEvent unions and the SIP guide include it. Existing sideband input
and timestamped output reflection is preserved rather than narrowed.

## Independent review and validation

Separate source, requirements and engineering reviews covered the full inventory,
DTO/value contracts, immutable future metadata, channel guards, public fixtures,
example and migration. One new test incorrectly assumed the platform decoder
accepted an unpadded base64 string; its expectation was corrected without changing
runtime decoding. Commentary documentation was generalized to retain #419's
supported Decisions replies. No remaining blocker was identified.

- New focused model/public-path selection: **66 passed**, independently reviewed.
- Chrome: **66 passed**.
- Full package unit suite: **25,958 passed, two skipped, no failures**.
- Package format, dart fix and analysis with fatal infos pass.
- Legacy server codecs: 712 tests passed; adjacent lifecycle/fork/Decisions
  selection: 205 passed. Client new/legacy codecs: 164 passed.
- Public primary/sideband/fork fixtures distinguish acceptance/drain, independent
  mute, reflection, overlap/append errors, failure/close without fabricated drain,
  SIP DTMF directions/correlation, saved legacy events and borrowed ownership.
- The runnable live_media_example.dart completes fixture playback notifications,
  explicit mute/unmute, SIP DTMF send/receive and graceful finalization using only
  synthetic peers. Independent execution succeeds without an API key, audio
  device, live API/media session or telephony charge.
- The existing live barrel exports all new models. README topic remains concise
  and collapsible. No version or changelog changes are included.

## Toolkit handoff

The toolkit fetched/reviewed the frozen source, described the fixture contract,
and scaffolded a sent-event preview in dry-run mode. Candidate promotion and
source/manifest verification were isolated in /tmp/openai-issue420-contract.
The adjacent manifest records source receipts and all 20 inventory dispositions;
no canonical package spec, global mappings or exclusions were changed.

The frozen overlay reports implementation 1115 errors, 150 warnings and 293 infos;
consistency zero errors/116 warnings; eight existing export findings. None of the
16 scoped type bindings has an implementation diagnostic. Docs/readme have no
findings, with 56 collapsible usage topics. This is scoped validation, not a claim
of global parity: #427 owns reconciliation of the remaining global diagnostics
and canonical promotion. Public canonical round trips and independent review
also verify contextual scalar constraints and channel aliases that the lexical
scanner cannot fully express.
