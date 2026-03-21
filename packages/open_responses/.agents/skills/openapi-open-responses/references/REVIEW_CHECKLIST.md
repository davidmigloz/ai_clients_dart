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

## Compliance Test Alignment

- [ ] Check if [openresponses/openresponses](https://github.com/openresponses/openresponses) has added new compliance test templates since last sync (see `src/lib/compliance-tests.ts`). Align our compliance tests in `test/integration/compliance_test.dart` if needed.
- [ ] Run `dart test test/unit/resources/request_compatibility_test.dart` to verify request shape compatibility with the CLI.

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages.
