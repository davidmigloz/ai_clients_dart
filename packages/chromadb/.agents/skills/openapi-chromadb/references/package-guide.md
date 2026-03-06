# chromadb OpenAPI Package Guide

## Core Paths

- Package root: `packages/chromadb`
- Skill config: `packages/chromadb/.agents/skills/openapi-chromadb/config`
- Canonical specs: `packages/chromadb/specs/`

## Toolkit Commands

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py describe --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py scaffold --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config --target schema --name ExampleSchema --dry-run
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config --checks exports --scope all
```
