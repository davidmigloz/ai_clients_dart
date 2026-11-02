# feat(openai_dart): create prompt voices and delete saved voices

## Outcome

Create a saved voice from a text description, inspect its metadata, and explicitly delete it.

Parent: #413. Successor to completed #317.

Dependencies: None.

## Scope

- POST /audio/voices JSON prompt branch alongside existing multipart audio-sample creation.
- DELETE /audio/voices/{voice_id}; VoiceResource prompt/type; documented named Live voices.

## Acceptance criteria

- [ ] Expose prompt/name/script_hint/model with exact discriminator and omission behavior, supporting documented JSON and multipart encodings without breaking audio_sample plus consent creation.
- [ ] Decode optional original prompt and prompt/audio_sample type, and implement the deletion response and identifier encoding.
- [ ] Cover input length/blank validation, multipart headers, request encoding, response copies/equality and public prompt/audio-sample create and delete mock fixtures.
- [ ] Audit all nine newly announced named voices against existing Dart support; add only missing names while preserving future/custom voice IDs.
- [ ] Add an explicit create/use/delete example. Document that prompt voices work in Live; do not advertise them for Speech/Chat audio. No voice creation or billed playback is required for default tests.

## Compatibility and validation

Additive where possible; document any targeted breaking correction with before/after migration examples. Default validation uses deterministic unit/local HTTP/SSE/WebSocket fixtures. Add constructor/parser/copy/round-trip/equality coverage where relevant and check exports. Apply the package review checklist; record engineering and requirements review before merge. No full live integration suite, version bump or publication belongs to this issue.

## Sources

- [OpenAPI snapshot](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json)
- [Python 3.42.0](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/resources/audio/voices.py)
- [Node 7.47.0](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/audio/voices.ts)
- [Official guide](https://developers.openai.com/api/docs/guides/custom-voices)
- [Repository ticket](https://github.com/davidmigloz/ai_clients_dart/blob/docs/openai-october-api-alignment/packages/openai_dart/specs/api-alignment-2026-10-31/tickets/05-custom-voices.md)

Frozen source cutoff: October 31, 2026. Later upstream additions do not expand this issue automatically. Record source disagreements and recheck only the affected contract before implementation.
