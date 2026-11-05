# ollama_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/ollama_dart`
- Skill config: `packages/ollama_dart/.agents/skills/openapi-ollama/config`
- Canonical specs: `packages/ollama_dart/specs/`

## Sources and Coverage

- Fetch the configured upstream `docs/openapi.yaml`, but record its Git commit SHA and fetch time: `info.version` may stay unchanged across API additions.
- Supplement the spec with the matching stable Ollama release's `api/types.go`, `server/routes.go`, and public documentation. Some public native fields and hosted web APIs are absent from OpenAPI.
- Baseline: stable v0.40.14; source SHAs and official Python/JavaScript client revisions are recorded in `specs/spec_metadata.json`. System One text starts at v0.35.0, image input at v0.40.0, cloud routing at v0.40.5, and audio translation at v0.40.12.
- Public native coverage includes generation, chat, multimodal embed, model manifest management, blobs, version/heartbeat, and System One. Explicit user scope also includes OpenAI-compatible audio speech/transcription/translation, plus documented read-only balance/usage reporting. Hosted web search/fetch are exposed through a client explicitly configured with `baseUrl: 'https://ollama.com'` and bearer authentication.
- Exclude internal debug fields, experimental server controls/local web proxies, account mutation controls, superseded `/api/embeddings`, and other OpenAI/Anthropic compatibility adapters unless the user explicitly expands scope. Preserve existing experimental image fields and older-server compatibility fields.
- Image generation was temporarily removed in v0.32.6 and remains rejected by v0.40.14 with HTTP 400, even when model metadata advertises the image capability. Keep the fields and example for compatible servers, but document this limitation. Source: [v0.32.6 release notes](https://github.com/ollama/ollama/releases/tag/v0.32.6) and stable `server/routes.go`.

Resources use the configured client base URL. The default local server has no `/api/web_search` or `/api/web_fetch` route; its similarly named proxy routes are experimental and use different paths.

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --checks exports --scope all
```

## Latest API supplement

- Go native types expose runner selectors, `CreateRequest.list` and capabilities,
  show manifest summaries, effective template source, speech voices, and a separate
  all-manifests response. Keep `show` and `showManifests` response shapes distinct.
- Embedding input accepts text, multimodal objects (`text`, base64 `image`/`audio`),
  or mixed batches. Preserve existing string/list factories and batch order.
- Audio compatibility routes are binary speech and multipart transcription/translation.
  Speech streams raw bytes; transcription/translation use SSE rather than NDJSON.
  Stable server validation is narrower than the generic compatibility docs: WAV/PCM
  speech, speed 1, empty instructions, audio stream format; JSON/text/verbose JSON
  transcription. Timestamp granularities are not parsed in v0.40.14.
- Read-only balance/usage use the configured host. Local proxy routes deliberately
  select the server's signed-in account, ignoring caller bearer tokens; explicit
  cloud configuration is needed for API-key account selection.
