---
name: openapi-googleai
description: Automates updating googleai_dart when Google AI OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (googleai_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.claude/shared/openapi-toolkit/README.md) with googleai_dart-specific configuration.

## Prerequisites

- `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY` environment variable set
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.claude/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/googleai_dart`) |

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `main` | Core Gemini API (generation, embeddings, files, models, etc.) | Yes |
| `interactions` | Experimental Interactions API (server-side state, agents) | No |

## Workflow

### 1. Fetch Latest Specs (REPO ROOT)

```bash
# From repository root
# Fetch all specs + auto-discover new ones
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/googleai_dart/.claude/skills/openapi-googleai/config

# Fetch specific spec only
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/googleai_dart/.claude/skills/openapi-googleai/config --spec main
```

Output: `/tmp/openapi-googleai-dart/latest-main.json`, `/tmp/openapi-googleai-dart/latest-interactions.json`

### 1.5. Analyze Changes (REPO ROOT)

Compare old spec vs new spec to find what changed. **Specs are auto-located** from config:

```bash
# From repository root - specs auto-located
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/googleai_dart/.claude/skills/openapi-googleai/config \
  --format all
```

### 2. Check API Coverage (CRITICAL - PACKAGE ROOT)

**Always run coverage check.** This catches APIs that exist in the spec but were never implemented. **Spec is auto-located**:

```bash
# From package root
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-googleai/config --verbose
```

If missing resources are found, prioritize implementing them before other updates.

### 3. Implement Changes

Before implementing, read `references/implementation-patterns.md` for:
- Model class structure and conventions
- Enum naming patterns
- JSON serialization patterns
- Test patterns and PR templates

Use templates from `../../shared/openapi-toolkit/assets/`:
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

### 4. Review & Validate (MANDATORY - PACKAGE ROOT)

Perform the four-pass review documented in `references/REVIEW_CHECKLIST.md`:

```bash
# Pass 2: Barrel file verification
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-googleai/config

# Pass 3: Documentation completeness
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-googleai/config

cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-googleai/config

cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_readme_code.py \
  --config-dir .claude/skills/openapi-googleai/config

# Pass 4: Property-level verification
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-googleai/config \
  --spec specs/openapi.json

# Dart quality checks
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
dart analyze --fatal-infos && dart format --set-exit-if-changed . && dart test test/unit/
```

**Pass 4 is critical** - catches missing properties in parent models (e.g., `Tool`, `Candidate`).

### 5. Finalize (REPO ROOT)

```bash
# Copy fetched specs to persisted locations
cd "$(git rev-parse --show-toplevel)" && \
cp /tmp/openapi-googleai-dart/latest-main.json packages/googleai_dart/specs/openapi.json

cd "$(git rev-parse --show-toplevel)" && \
cp /tmp/openapi-googleai-dart/latest-interactions.json packages/googleai_dart/specs/openapi-interactions.json

# Run quality checks
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
dart test && dart analyze && dart format --set-exit-if-changed .
```

## Package-Specific References

- [Package Guide](references/package-guide.md) - Package structure, naming conventions
- [Implementation Patterns](references/implementation-patterns.md) - Model conventions, serialization patterns
- [Review Checklist](references/REVIEW_CHECKLIST.md) - Four-pass validation process

## Troubleshooting

- **API key error**: Export `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY`
- **Network errors**: Check connectivity; retry after a few seconds
- **No changes detected**: Summary shows all zeros; no action needed
- **New specs discovered**: Add them to `config/specs.json` and re-run
