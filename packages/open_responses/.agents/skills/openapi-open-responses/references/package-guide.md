# open_responses OpenAPI Package Guide

## Core Paths

- Package root: `packages/open_responses`
- Skill config: `packages/open_responses/.agents/skills/openapi-open-responses/config`
- Canonical specs: `packages/open_responses/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config --checks exports --scope all
```
