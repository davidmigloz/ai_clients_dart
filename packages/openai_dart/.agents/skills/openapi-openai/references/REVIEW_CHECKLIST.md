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

- [ ] **`==`/`hashCode` contract**: Every `@immutable` class that overrides `==` must compare the same fields used in `hashCode`. Never do runtimeType-only `==` with field-based `hashCode`.
- [ ] **Model-variant nullability**: If a field is only returned by a subset of models (e.g., omni-moderation but not text-moderation), make it nullable so responses from all model variants parse without throwing.
- [ ] **Nullable field serialization**: Nullable fields use `if (field != null) 'key': field` in `toJson()` to omit nulls — never emit explicit `null`.
