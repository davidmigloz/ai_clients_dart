# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/open_responses/.agents/skills/openapi-open-responses/config --checks all --scope all
```

## Package Quality

```bash
cd packages/open_responses
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages.
