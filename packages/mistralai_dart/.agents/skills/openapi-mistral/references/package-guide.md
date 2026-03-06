# mistralai_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/mistralai_dart`
- Skill config: `packages/mistralai_dart/.agents/skills/openapi-mistral/config`
- Canonical specs: `packages/mistralai_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/mistralai_dart/.agents/skills/openapi-mistral/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/mistralai_dart/.agents/skills/openapi-mistral/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/mistralai_dart/.agents/skills/openapi-mistral/config --checks exports --scope all
```
