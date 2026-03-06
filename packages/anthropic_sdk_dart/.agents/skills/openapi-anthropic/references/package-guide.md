# anthropic_sdk_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/anthropic_sdk_dart`
- Skill config: `packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config`
- Canonical specs: `packages/anthropic_sdk_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config --checks exports --scope all
```
