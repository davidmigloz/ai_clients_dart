# ollama_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/ollama_dart`
- Skill config: `packages/ollama_dart/.agents/skills/openapi-ollama/config`
- Canonical specs: `packages/ollama_dart/specs/`

## Sources and Coverage

- Fetch the configured upstream `docs/openapi.yaml`, but record its Git commit SHA and fetch time: `info.version` may stay unchanged across API additions.
- Supplement the spec with the matching stable Ollama release's `api/types.go`, `server/routes.go`, and public documentation. Some public native fields and hosted web APIs are absent from OpenAPI.
- System One requires Ollama v0.35.0+. Its documentation first appears on upstream main after the stable release, so an OpenAPI-only stable-tag comparison can miss this released API.
- Public native coverage includes generation, chat, embed, model management, blobs, version, and System One. Hosted web search/fetch are exposed through a client explicitly configured with `baseUrl: 'https://ollama.com'` and bearer authentication.
- Exclude internal debug fields, experimental server controls/local web proxies, account controls, superseded `/api/embeddings`, and OpenAI/Anthropic compatibility adapters unless the user explicitly expands scope. Preserve existing experimental image fields and older-server compatibility fields.
- Image generation was temporarily removed in v0.32.6 and remains rejected by v0.35.0 with HTTP 400, even when model metadata advertises the image capability. Keep the fields and example for compatible servers, but document this limitation. Source: [v0.32.6 release notes](https://github.com/ollama/ollama/releases/tag/v0.32.6) and stable `server/routes.go`.

Resources use the configured client base URL. The default local server has no `/api/web_search` or `/api/web_fetch` route; its similarly named proxy routes are experimental and use different paths.

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --checks exports --scope all
```
