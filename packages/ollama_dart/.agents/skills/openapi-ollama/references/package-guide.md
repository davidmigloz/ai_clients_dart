# ollama_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/ollama_dart`
- Skill config: `packages/ollama_dart/.agents/skills/openapi-ollama/config`
- Canonical specs: `packages/ollama_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config --checks exports --scope all
```
