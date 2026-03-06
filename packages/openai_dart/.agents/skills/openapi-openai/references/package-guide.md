# openai_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/openai_dart`
- Skill config: `packages/openai_dart/.agents/skills/openapi-openai/config`
- Canonical specs: `packages/openai_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/openai_dart/.agents/skills/openapi-openai/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/openai_dart/.agents/skills/openapi-openai/config --checks exports --scope all
```
