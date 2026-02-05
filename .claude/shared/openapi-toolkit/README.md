# OpenAPI Toolkit (Shared)

Generic, config-driven OpenAPI toolkit for creating and updating Dart API client packages.

## Design Philosophy

This core toolkit contains **ALL scripts** - they are 100% config-driven. To support a new Dart API client package, you only need to:

1. Create config JSON files (no Python modifications)
2. Create package-specific reference documentation
3. Run the scripts with `--config-dir` pointing to your config

## Directory Structure

```
openapi-toolkit/
├── README.md                   # This file
├── scripts/
│   ├── fetch_spec.py           # Fetch OpenAPI specs from URLs
│   ├── analyze_changes.py      # Compare specs, generate changelog/plan
│   ├── verify_coverage.py      # Check API coverage (spec vs implementation)
│   ├── generate_model.py       # Generate model class from schema
│   ├── generate_enum.py        # Generate enum from schema
│   ├── generate_barrel.py      # Generate barrel file exports
│   ├── verify_exports.py       # Verify barrel file completeness
│   ├── verify_readme.py        # Verify README accuracy
│   ├── verify_examples.py      # Verify example file existence
│   ├── verify_model_properties.py  # Verify model properties vs spec
│   └── verify_readme_code.py   # Detect README code drift
└── assets/
    ├── model_template.dart     # Model class template
    ├── enum_template.dart      # Enum type template
    ├── test_template.dart      # Unit test template
    └── example_template.dart   # Example file template
```

## Prerequisites

- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

**Different scripts have different working directory requirements:**

| Script | Working Directory | Reason |
|--------|-------------------|--------|
| `fetch_spec.py` | Any (repo root recommended) | Uses absolute paths from args |
| `analyze_changes.py` | Any (repo root recommended) | Uses absolute paths from args |
| `verify_coverage.py` | **Package root** | Uses relative paths like `lib/src/resources` |
| `verify_exports.py` | **Package root** | Uses relative paths like `lib/src/models` |
| `verify_model_properties.py` | **Package root** | Uses relative paths from config |
| `verify_readme.py` | **Package root** | Uses relative paths like `README.md` |
| `verify_examples.py` | **Package root** | Uses relative paths like `example/` |
| `verify_readme_code.py` | **Package root** | Uses relative paths |
| `generate_*.py` | **Package root** | Uses relative paths for output |

**Example for package-root scripts:**

```bash
# From repo root - WRONG for verification scripts!
# python3 .claude/shared/openapi-toolkit/scripts/verify_coverage.py ...

# From package root - CORRECT
cd packages/your_package
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --spec /tmp/openapi-your-package/latest-main.json
```

## Required Config Files

Create these in your extension skill's `config/` directory:

| File | Purpose |
|------|---------|
| `package.json` | Package paths and naming conventions |
| `specs.json` | API spec URLs and authentication |
| `schemas.json` | Schema categorization and parent model patterns |
| `models.json` | Critical models for property verification |
| `coverage.json` | API coverage exclusions (intentionally unimplemented) |
| `documentation.json` | README verification rules, drift patterns |

### `package.json` - Package Structure

```json
{
  "name": "your_package_dart",
  "display_name": "Your Package",
  "barrel_file": "lib/your_package_dart.dart",
  "models_dir": "lib/src/models",
  "resources_dir": "lib/src/resources",
  "tests_dir": "test/unit/models",
  "examples_dir": "example",
  "skip_files": ["copy_with_sentinel.dart", "equality_helpers.dart"],
  "internal_barrel_files": [],
  "pr_title_prefix": "feat(your_package_dart)",
  "changelog_title": "Your Package Changelog"
}
```

**Field descriptions:**
- `skip_files`: List of filenames to exclude from export verification. Use this for internal utility files that shouldn't be publicly exported (e.g., `copy_with_sentinel.dart`, `equality_helpers.dart`, `common.dart`). When `verify_exports.py` flags internal files as unexported, add them here rather than exporting them.

### `specs.json` - API Specifications

```json
{
  "specs": {
    "main": {
      "name": "API Name",
      "url": "https://example.com/openapi.json",
      "local_file": "openapi.json",
      "requires_auth": true,
      "auth_env_vars": ["API_KEY"],
      "description": "Main API description"
    }
  },
  "output_dir": "/tmp/openapi-{package}",
  "discovery_patterns": [],
  "discovery_names": []
}
```

### `schemas.json` - Schema Organization

```json
{
  "categories": {
    "category_name": {
      "patterns": ["pattern1", "pattern2"],
      "directory": "target_directory"
    }
  },
  "default_category": "common",
  "parent_model_patterns": {
    "ParentModel": [".*ChildPattern$"]
  }
}
```

### `models.json` - Critical Models

```json
{
  "critical_models": [
    {
      "name": "ModelName",
      "file": "lib/src/models/category/model_name.dart",
      "spec_schema": "SchemaName"
    }
  ],
  "expected_properties": {}
}
```

### `coverage.json` - API Coverage Exclusions

```json
{
  "excluded_paths": [
    "^/organization/.*",
    "^/admin/.*"
  ],
  "excluded_tags": [
    "Administration",
    "Internal"
  ],
  "priority_resources": [
    "responses",
    "chat",
    "embeddings"
  ],
  "notes": {
    "organization": "Admin APIs - not needed for client usage"
  }
}
```

### `documentation.json` - README Verification

```json
{
  "removed_apis": [
    {"api": "removed_api", "reason": "Reason for removal"}
  ],
  "tool_properties": {
    "property": {
      "description": "Description",
      "search_terms": ["search", "terms"]
    }
  },
  "excluded_resources": ["base_resource"],
  "resource_to_example": {"resource": "example"},
  "excluded_from_examples": ["resource"],
  "drift_patterns": [
    {
      "pattern": "regex_pattern",
      "message": "Error message",
      "severity": "error"
    }
  ]
}
```

## Recommended Workflow

When updating an API client, follow this workflow to avoid missing new APIs:

### 1. Fetch Latest Spec (from REPO ROOT)
```bash
# From repository root
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config
```

### 2. Analyze Changes (from REPO ROOT)
Compare old spec vs new spec to find what changed. **Specs are auto-located** from config:

```bash
# From repository root - specs auto-located from specs.json config
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config \
  --format all
```

**Note:** The script auto-locates the old spec from `specs_dir` and the new spec from `output_dir` in specs.json. You can still provide explicit paths if needed.

#### If No Changes Found

If the analysis shows all zeros (no new/modified/removed endpoints or schemas):

1. The spec is unchanged - no implementation work needed
2. Still run verification (Step 3-4) to ensure the package is in sync
3. If verification passes, the package is up-to-date

**Example output when no changes:**
```
==================================================
Analysis Summary
==================================================
  New Endpoints: 0
  Modified Endpoints: 0
  Removed Endpoints: 0
  New Schemas: 0
  Modified Schemas: 0
  Removed Schemas: 0
  Breaking Changes: 0
```

### 3. Check Coverage (CRITICAL - from PACKAGE ROOT)
**Always run coverage check.** This catches APIs that exist in the spec but were never implemented. **Spec is auto-located** if not provided:

```bash
# Change to package directory first
cd packages/{package}
# Spec auto-located from config
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-{shortname}/config --verbose
```

If missing resources are found, prioritize implementing them.

### 4. Implement & Verify (from PACKAGE ROOT)
After implementation, verify completeness. **Barrel files are auto-discovered**:

```bash
# From package directory
cd packages/{package}
# Auto-discovers all library entry points (*.dart files in lib/)
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-{shortname}/config
# Spec auto-located
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-{shortname}/config
```

**Success output:**
- Coverage: `✓ Full API coverage achieved!`
- Exports: `✓ All model files are exported.`

### When Complete

The package is fully up-to-date when all of the following are true:

1. `analyze_changes.py` shows no changes (or all changes have been implemented)
2. `verify_coverage.py` shows 100% coverage
3. `verify_exports.py` shows all model files exported
4. `verify_model_properties.py` shows all critical models complete

At this point, no further implementation work is needed.

## Script Usage

All scripts require `--config-dir` pointing to your config directory.

**Note:** See [Working Directory Requirements](#working-directory-requirements) above for which scripts need repo root vs package root.

### Fetch Specs (REPO ROOT)

```bash
# From repository root
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config --spec main
```

### Analyze Changes (REPO ROOT)

```bash
# From repository root - specs auto-located
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config \
  --format all

# Or with explicit paths (optional)
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/{package}/.claude/skills/openapi-{shortname}/config \
  packages/{package}/specs/openapi.json /tmp/openapi-{package}/latest-main.json \
  --format all
```

### Verification Scripts (PACKAGE ROOT)

```bash
# Change to package directory first
cd packages/{package}

# Check API coverage (spec auto-located from config)
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-{shortname}/config --verbose

# Check all models are exported (barrel files auto-discovered)
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-{shortname}/config

# Check model properties match spec
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-{shortname}/config

# Check README accuracy
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-{shortname}/config

# Check example files exist
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .claude/skills/openapi-{shortname}/config

# Detect README code drift
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_readme_code.py \
  --config-dir .claude/skills/openapi-{shortname}/config
```

### Generation Scripts (PACKAGE ROOT)

```bash
# Change to package directory first
cd packages/{package}

# Generate a single model
python3 ../../.claude/shared/openapi-toolkit/scripts/generate_model.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --schema GenerationConfig --output lib/src/models/config/generation_config.dart

# Generate a single enum
python3 ../../.claude/shared/openapi-toolkit/scripts/generate_enum.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --schema HarmCategory --output lib/src/models/safety/harm_category.dart

# Generate barrel file for a subdirectory
python3 ../../.claude/shared/openapi-toolkit/scripts/generate_barrel.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --subdirectory models/safety

# Batch generate all enums
python3 ../../.claude/shared/openapi-toolkit/scripts/generate_enum.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --batch --output-dir lib/src/models

# Batch generate all models (skip sealed parents)
python3 ../../.claude/shared/openapi-toolkit/scripts/generate_model.py \
  --config-dir .claude/skills/openapi-{shortname}/config \
  --batch --output-dir lib/src/models --skip Part,Content
```

## Creating a New Package Extension

1. **Create config directory**: `packages/{package}/.claude/skills/openapi-{shortname}/config/`
2. **Create config files**: `package.json`, `specs.json`, `schemas.json`, `models.json`, `documentation.json`
3. **Create SKILL.md**: Reference this core toolkit at `packages/{package}/.claude/skills/openapi-{shortname}/SKILL.md`
4. **Create references**: Package-specific patterns and checklists

See `docs/new_dart_api_client.md` for detailed instructions.

## Templates

Use templates from `assets/` for consistent implementation:

- `model_template.dart` - Basic model class with all required methods
- `enum_template.dart` - Enum with fromString/toString conversion
- `test_template.dart` - Comprehensive unit test structure
- `example_template.dart` - Example file structure

Replace placeholders:
- `{ClassName}` → PascalCase class name
- `{description}` → Description from OpenAPI spec
- `{subdirectory}` → Model subdirectory
