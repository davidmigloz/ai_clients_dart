# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config --checks all --scope all
```

## Package Quality

```bash
cd packages/anthropic_sdk_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages.

### Package-Specific Checks

- [ ] **Built-in tool routing**: New built-in tools are added to `_isBuiltInType` in `tool_definition.dart` (prefix check), `BuiltInTool.fromJson` dispatch, and have a convenience factory on `BuiltInTool`.
- [ ] **Input block pairing**: New response content blocks have a matching `*InputBlock` in `input_content_block.dart` for multi-turn round-tripping. Check `additionalProperties` in the request schema — exclude fields not in the spec.
- [ ] **Enum round-trip fidelity**: Forward-compatible enums that appear in round-trippable content store the raw wire string and derive the typed enum via a getter, so unknown values serialize back unchanged.
- [ ] **Raw JSON fields**: Unknown/fallback types storing `Map<String, dynamic> raw` use `mapsDeepEqual`/`mapDeepHashCode` (not shallow `mapsEqual`/`mapHash`).
- [ ] **Spec promotion**: `pinned_hash` in `config/specs.json` matches the promoted spec URL hash.
- [ ] **Documentation artifacts**: Example file, README (features + examples table), and `llms.txt` are updated (see SKILL.md).
