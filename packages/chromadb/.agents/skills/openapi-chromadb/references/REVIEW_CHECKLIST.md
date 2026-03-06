# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config --checks all --scope all
```

## Package Quality

```bash
cd packages/chromadb
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
