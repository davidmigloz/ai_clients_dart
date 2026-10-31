# feat(openai_dart): align Realtime references and audio controls

## Outcome

Use current Realtime input references/noise controls and the official Translation WebSocket flow.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- RealtimeResponseInputItem typed item references/messages/function calls; noise_reduction.strength; status_details.error.message.
- Realtime/Translation connect parameters and typed WS lifecycle; transcription response keywords and documented Audio model changes.

## Acceptance criteria

- [ ] Support current response input/reference variants without conflating full conversation items and item references. Cover constructor/parser and public response.create encoding.
- [ ] Add noise reduction strength (0..1) across GA session/transcription/translation creation and updates; omission on update preserves current strength.
- [ ] Preserve error messages in beta and GA response status details, existing DTMF/transcription event fields, and returned transcription keywords.
- [ ] Add or demonstrate typed Realtime Translation WebSocket configuration/events using existing REST session-secret resources. Share transport mechanics with ticket 04 without creating a dependency cycle.
- [ ] Cover old/new wire shapes, local translation setup/events/cancellation and browser transport constraints; provide concise executable examples and model sunset guidance.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/realtime/translations/translations.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/realtime.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/realtime-translation)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/08-realtime-audio.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
