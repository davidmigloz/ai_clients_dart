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

## Required Config Files

Create these in your extension skill's `config/` directory:

| File | Purpose |
|------|---------|
| `package.json` | Package paths and naming conventions |
| `specs.json` | API spec URLs and authentication |
| `schemas.json` | Schema categorization and parent model patterns |
| `models.json` | Critical models for property verification |
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
  "skip_files": ["copy_with_sentinel.dart"],
  "internal_barrel_files": [],
  "pr_title_prefix": "feat(your_package_dart)",
  "changelog_title": "Your Package Changelog"
}
```

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
  "output_dir": "/tmp/openapi-toolkit-{package}-dart",
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

## Script Usage

All scripts require `--config-dir` pointing to your config directory.

### Fetch Specs

```bash
python3 {core}/scripts/fetch_spec.py --config-dir {ext}/config
python3 {core}/scripts/fetch_spec.py --config-dir {ext}/config --spec main
```

### Analyze Changes

```bash
python3 {core}/scripts/analyze_changes.py --config-dir {ext}/config \
  old.json new.json --format all
```

### Verification Scripts

```bash
python3 {core}/scripts/verify_exports.py --config-dir {ext}/config
python3 {core}/scripts/verify_readme.py --config-dir {ext}/config
python3 {core}/scripts/verify_examples.py --config-dir {ext}/config
python3 {core}/scripts/verify_model_properties.py --config-dir {ext}/config
python3 {core}/scripts/verify_readme_code.py --config-dir {ext}/config
```

### Generation Scripts

```bash
# Generate a single model
python3 {core}/scripts/generate_model.py --config-dir {ext}/config \
  --schema GenerationConfig --output lib/src/models/config/generation_config.dart

# Generate a single enum
python3 {core}/scripts/generate_enum.py --config-dir {ext}/config \
  --schema HarmCategory --output lib/src/models/safety/harm_category.dart

# Generate barrel file for a subdirectory
python3 {core}/scripts/generate_barrel.py --config-dir {ext}/config \
  --subdirectory models/safety

# Batch generate all enums
python3 {core}/scripts/generate_enum.py --config-dir {ext}/config \
  --batch --output-dir lib/src/models

# Batch generate all models (skip sealed parents)
python3 {core}/scripts/generate_model.py --config-dir {ext}/config \
  --batch --output-dir lib/src/models --skip Part,Content
```

## Creating a New Package Extension

1. **Create config directory**: `.claude/skills/openapi-toolkit-{package}-dart/config/`
2. **Create config files**: `package.json`, `specs.json`, `schemas.json`, `models.json`, `documentation.json`
3. **Create SKILL.md**: Reference this core toolkit
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
