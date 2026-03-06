# googleai_dart OpenAPI Package Guide

## Core Paths

- Package root: `packages/googleai_dart`
- Skill config: `packages/googleai_dart/.agents/skills/openapi-googleai/config`
- Canonical specs: `packages/googleai_dart/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config --spec-name main
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config --spec-name main --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config --spec-name interactions --checks all --scope all
```

Use exact manifest keys such as `interactions:Tool` when a schema name overlaps across specs.
