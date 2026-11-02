# feat(openai_dart): align Live audio fixtures and SIP DTMF

## Outcome

Play a bounded audio fixture and distinguish SIP DTMF commands from delivery notifications.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- session.output_audio.fixture.play/playing/played and changed mute/unmute/append behavior.
- Replace receive-only transport.dtmf.send with transport.dtmf.sent; add sideband transport.dtmf.send command and received events.

## Acceptance criteria

- [ ] Validate raw mono PCM16 little-endian 24kHz fixture payloads and the 30-second/encoded-size limit before send; no WAV headers or session-format assumptions.
- [ ] Model acceptance versus mixer drain, correlation IDs and independent mute state. Document dropped input during playback and append restrictions without claiming exact media delivery boundaries.
- [ ] Expose SIP-only sideband DTMF command with optional event_id, required single-key validation, and distinct sent/received notifications and error correlation.
- [ ] Update primary/sideband/fork event admission accurately; provide a migration for the removed server event shape while retaining finite unknown-event handling.
- [ ] Local fixtures and an offline example prove each direction and event sequence, disposal and error cases; default tests incur no telephony or audio charges.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/live/sideband.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/live/sideband.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/voice-sip)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/07-live-media.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
