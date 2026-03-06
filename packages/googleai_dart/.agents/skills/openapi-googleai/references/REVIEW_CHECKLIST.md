# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config --checks all --scope all
```

## Package Quality

```bash
cd packages/googleai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
