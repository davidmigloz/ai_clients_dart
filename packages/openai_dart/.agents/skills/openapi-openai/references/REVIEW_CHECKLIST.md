# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/openai_dart/.agents/skills/openapi-openai/config --checks all --scope all
```

## Package Quality

```bash
cd packages/openai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages. The following items are OpenAI-specific:

- [ ] **Base64 data URL format**: Convenience factories for binary data fields must construct data URLs (`data:<mediaType>;base64,<data>`), not pass raw base64. Verify with an integration test.
- [ ] **Multi-model response shapes**: When OpenAI has multiple model families (e.g., `text-moderation-*` vs `omni-moderation-*`), fields only returned by newer models must be nullable.
- [ ] **Sibling package check**: When modifying shared patterns (e.g., file content, tool choice), check `open_responses` for the same pattern.
