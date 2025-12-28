---
name: openapi-updater
description: Automates updating googleai_dart when Google AI OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Updater (googleai_dart)

Extends [openapi-updater-core](../openapi-updater-core/SKILL.md) with googleai_dart-specific configuration.

## Prerequisites

- `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY` environment variable set
- Working directory: `packages/googleai_dart`
- Python 3

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `main` | Core Gemini API (generation, embeddings, files, models, etc.) | Yes |
| `interactions` | Experimental Interactions API (server-side state, agents) | No |

## Workflow

### 1. Fetch Latest Specs

```bash
# Fetch all specs + auto-discover new ones
python3 .claude/skills/openapi-updater-core/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-updater/config

# Fetch specific spec only
python3 .claude/skills/openapi-updater-core/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-updater/config --spec main
```

Output: `/tmp/openapi-updater/latest-main.json`, `/tmp/openapi-updater/latest-interactions.json`

### 2. Analyze Changes

```bash
python3 .claude/skills/openapi-updater-core/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-updater/config \
  openapi.json /tmp/openapi-updater/latest-main.json \
  --format all \
  --changelog-out /tmp/openapi-updater/changelog-main.md \
  --plan-out /tmp/openapi-updater/plan-main.md
```

Generates:
- `changelog-main.md` - Human-readable change summary
- `plan-main.md` - Prioritized implementation plan (P0-P4)

### 3. Implement Changes

Before implementing, read `references/implementation-patterns.md` for:
- Model class structure and conventions
- Enum naming patterns
- JSON serialization patterns
- Test patterns and PR templates

Use templates from `../openapi-updater-core/assets/`:
- `model_template.dart` - Model class structure
- `enum_template.dart` - Enum type structure
- `test_template.dart` - Unit test structure
- `example_template.dart` - Example file structure

### 3.5 Update Documentation (MANDATORY)

Before running the review checklist, update all documentation:

1. **README.md** - Add/update:
   - New resources to Features section
   - New resources to API Coverage section
   - New example references in Examples section

2. **example/** - Create/update:
   - `{feature}_example.dart` for each new resource

3. **CHANGELOG.md** - Add entry for new features/changes

### 4. Review & Validate (MANDATORY)

Perform the four-pass review documented in `references/REVIEW_CHECKLIST.md`:

```bash
# Pass 2: Barrel file verification
python3 .claude/skills/openapi-updater-core/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-updater/config

# Pass 3: Documentation completeness
python3 .claude/skills/openapi-updater-core/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-updater/config
python3 .claude/skills/openapi-updater-core/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-updater/config
python3 .claude/skills/openapi-updater-core/scripts/verify_readme_code.py \
  --config-dir .claude/skills/openapi-updater/config

# Pass 4: Property-level verification
python3 .claude/skills/openapi-updater-core/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-updater/config

# Dart quality checks
dart analyze --fatal-infos && dart format --set-exit-if-changed . && dart test test/unit/
```

**Pass 4 is critical** - catches missing properties in parent models (e.g., `Tool`, `Candidate`).

### 5. Finalize

```bash
# Copy fetched specs to persisted locations
cp /tmp/openapi-updater/latest-main.json openapi.json
cp /tmp/openapi-updater/latest-interactions.json openapi-interactions.json

# Run quality checks
dart test && dart analyze && dart format --set-exit-if-changed .
```

## Package-Specific References

- [Implementation Patterns](references/implementation-patterns.md) - Model conventions, serialization patterns
- [Review Checklist](references/REVIEW_CHECKLIST.md) - Four-pass validation process

## Troubleshooting

- **API key error**: Export `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY`
- **Network errors**: Check connectivity; retry after a few seconds
- **No changes detected**: Summary shows all zeros; no action needed
- **New specs discovered**: Add them to `config/specs.json` and re-run
