# Adding a New Dart API Client Package

This guide explains how to create a new Dart API client package (e.g., `openai_dart`, `anthropic_dart`, `mistral_dart`) using the generic toolkit skills.

## Overview

Adding a new package requires **ONLY configuration files** - no Python code modifications. You will:

1. Create the package structure
2. Create config files for the toolkit skills
3. Create the package-specific references
4. Start implementing models

## Prerequisites

- The core skills available at `.claude/shared/openapi-toolkit/` (repository root)
- Access to the API's OpenAPI specification
- API key for testing (if required)
- Python 3 for running verification scripts

---

## Step 1: Create Package Structure

```bash
# Create package directory
mkdir -p packages/your_package_dart

# Create standard Dart package structure
cd packages/your_package_dart
mkdir -p lib/src/{client,models,resources,auth,interceptors,errors}
mkdir -p test/{unit,integration}
mkdir -p example
mkdir -p specs

# Create skill config directory at repository root
cd ../..
mkdir -p .claude/skills/openapi-toolkit-yourpackage-dart/{config,references}
```

**Package Structure:**
```
packages/your_package_dart/
├── lib/
│   ├── your_package_dart.dart      # Main barrel file
│   └── src/
│       ├── client/                  # Client configuration
│       ├── models/                  # Model classes
│       ├── resources/               # API resources
│       ├── auth/                    # Authentication providers
│       ├── interceptors/            # Request interceptors
│       └── errors/                  # Exceptions
├── test/
│   ├── unit/                        # Unit tests
│   └── integration/                 # Integration tests
├── example/                         # Example files
├── specs/                           # OpenAPI specifications
│   └── openapi.json                 # Main API spec
└── pubspec.yaml
```

---

## Step 2: Create Config Files

### 2.1 `.claude/skills/openapi-toolkit-yourpackage-dart/config/package.json` - Package Structure

Defines your package paths and naming conventions.

```json
{
  "name": "your_package_dart",
  "display_name": "Your Package",
  "barrel_file": "lib/your_package_dart.dart",
  "models_dir": "lib/src/models",
  "resources_dir": "lib/src/resources",
  "tests_dir": "test/unit/models",
  "examples_dir": "example",
  "skip_files": [],
  "internal_barrel_files": [],
  "pr_title_prefix": "feat(your_package_dart)",
  "changelog_title": "Your Package API Changelog"
}
```

| Field | Description |
|-------|-------------|
| `name` | Package name (used in pubspec.yaml) |
| `display_name` | Human-readable name (used in generated docs) |
| `barrel_file` | Main export file |
| `models_dir` | Directory containing model classes |
| `resources_dir` | Directory containing API resources |
| `tests_dir` | Directory for unit tests |
| `examples_dir` | Directory for example files |
| `skip_files` | Files to exclude from export verification |
| `internal_barrel_files` | Internal barrel files (not exported at top level) |
| `pr_title_prefix` | Prefix for generated PR titles |
| `changelog_title` | Title for generated changelogs |

### 2.2 `.claude/skills/openapi-toolkit-yourpackage-dart/config/specs.json` - API Specifications

Defines where to fetch the OpenAPI specification.

```json
{
  "specs": {
    "main": {
      "name": "Your API Name",
      "url": "https://api.example.com/openapi.json",
      "local_file": "openapi.json",
      "requires_auth": false,
      "auth_env_vars": ["YOUR_API_KEY"],
      "description": "Main API description"
    }
  },
  "output_dir": "/tmp/openapi-toolkit-yourpackage-dart",
  "discovery_patterns": [],
  "discovery_names": []
}
```

| Field | Description |
|-------|-------------|
| `specs.*.url` | URL to fetch the OpenAPI spec (JSON or YAML) |
| `specs.*.local_file` | Local filename to store the spec |
| `specs.*.requires_auth` | Whether fetching the spec requires authentication |
| `specs.*.auth_env_vars` | Environment variables for API authentication |
| `output_dir` | Directory for temporary output files |
| `discovery_patterns` | URL patterns for auto-discovering additional specs |
| `discovery_names` | Names to try with discovery patterns |

### 2.3 `.claude/skills/openapi-toolkit-yourpackage-dart/config/schemas.json` - Schema Organization

Defines how schemas are organized into directories.

```json
{
  "categories": {
    "chat": {
      "patterns": ["chat", "message", "completion"],
      "directory": "chat"
    },
    "embeddings": {
      "patterns": ["embed"],
      "directory": "embeddings"
    },
    "models": {
      "patterns": ["model"],
      "directory": "models"
    }
  },
  "default_category": "common",
  "parent_model_patterns": {
    "Request": [".*Tool$", ".*Function.*"],
    "Message": [".*Content$", ".*Part$"]
  }
}
```

| Field | Description |
|-------|-------------|
| `categories.*.patterns` | Lowercase substrings to match in schema names |
| `categories.*.directory` | Subdirectory under `models_dir` |
| `default_category` | Category for schemas that don't match any pattern |
| `parent_model_patterns` | Regex patterns for detecting child schemas |

### 2.4 `.claude/skills/openapi-toolkit-yourpackage-dart/config/models.json` - Critical Models

Defines critical models to verify for property completeness.

```json
{
  "critical_models": [
    {
      "name": "Request",
      "file": "lib/src/models/chat/request.dart",
      "spec_schema": "CreateChatRequest"
    },
    {
      "name": "Response",
      "file": "lib/src/models/chat/response.dart",
      "spec_schema": "ChatResponse"
    }
  ],
  "expected_properties": {}
}
```

| Field | Description |
|-------|-------------|
| `critical_models.*.name` | Dart class name |
| `critical_models.*.file` | Path to Dart file |
| `critical_models.*.spec_schema` | Schema name in OpenAPI spec |
| `expected_properties` | Optional explicit property lists |

### 2.5 `.claude/skills/openapi-toolkit-yourpackage-dart/config/documentation.json` - Documentation Verification

Configures README and documentation verification.

```json
{
  "removed_apis": [],
  "tool_properties": {
    "function": {
      "description": "Function calling support",
      "search_terms": ["function calling", "tools"]
    }
  },
  "excluded_resources": ["base_resource"],
  "resource_to_example": {
    "chat": "chat",
    "embeddings": "embeddings"
  },
  "excluded_from_examples": [],
  "drift_patterns": [
    {
      "pattern": "response\\.text\\b",
      "message": "Use response.choices.first.message.content instead",
      "severity": "error"
    }
  ]
}
```

| Field | Description |
|-------|-------------|
| `removed_apis` | APIs that were removed (to detect stale references) |
| `tool_properties` | Properties that should be documented in README |
| `excluded_resources` | Resources to skip in verification |
| `resource_to_example` | Map resource names to example file names |
| `excluded_from_examples` | Resources that don't need examples |
| `drift_patterns` | Patterns to detect outdated code in docs |

---

## Step 3: Create SKILL.md

Create `.claude/skills/openapi-toolkit-yourpackage-dart/SKILL.md`:

```markdown
---
name: openapi-toolkit-yourpackage-dart
description: Automates your_package_dart updates from API OpenAPI spec.
---

# OpenAPI Toolkit (your_package_dart)

Uses shared scripts from [openapi-toolkit](../../shared/openapi-toolkit/README.md).

## Prerequisites

- `YOUR_API_KEY` environment variable set
- Working directory: Repository root

## Quick Start

```bash
# Fetch latest spec
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config

# Analyze changes
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  packages/your_package_dart/specs/openapi.json /tmp/openapi-toolkit-yourpackage-dart/latest-main.json \
  --format all

# Verify implementation
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config

python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config
```

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)
```

---

## Step 3.5: Generate Boilerplate Code

Use the generation scripts to create initial model and enum files:

### Generate Enums

```bash
# Generate a single enum
python3 .claude/shared/openapi-toolkit/scripts/generate_enum.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  --schema FinishReason \
  --output packages/your_package_dart/lib/src/models/metadata/finish_reason.dart

# Or batch generate all enums
python3 .claude/shared/openapi-toolkit/scripts/generate_enum.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  --batch --output-dir packages/your_package_dart/lib/src/models
```

### Generate Models

```bash
# Generate a single model
python3 .claude/shared/openapi-toolkit/scripts/generate_model.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  --schema GenerationConfig \
  --output packages/your_package_dart/lib/src/models/config/generation_config.dart

# Or batch generate all models (skip sealed class parents)
python3 .claude/shared/openapi-toolkit/scripts/generate_model.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  --batch --output-dir packages/your_package_dart/lib/src/models \
  --skip Part,Content
```

### Generate Barrel Files

```bash
# Generate barrel file for a subdirectory
python3 .claude/shared/openapi-toolkit/scripts/generate_barrel.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  --subdirectory models/metadata

# Or generate for all model subdirectories
python3 .claude/shared/openapi-toolkit/scripts/generate_barrel.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config
```

**Note:** Generated code provides a starting point. You may need to:
- Add imports for referenced types
- Implement sealed class parents manually (these are skipped by `--skip`)
- Adjust complex type mappings
- Add custom validation logic

---

## Step 4: Create Reference Documentation

### `.claude/skills/openapi-toolkit-yourpackage-dart/references/package-guide.md`

Package-specific configuration and structure:

```markdown
# your_package_dart Package Guide

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `your_package_dart` |
| API | Your API Name |
| API Key Env Var | `YOUR_API_KEY` |
| Barrel File | `lib/your_package_dart.dart` |
| Specs Directory | `specs/` |

## Directory Structure

\`\`\`
lib/src/
├── models/
│   ├── chat/           # Chat completions
│   ├── embeddings/     # Embeddings
│   └── common/         # Shared types
├── resources/          # API resources
└── client/             # Client config
\`\`\`

## File Path Patterns

| Type | Pattern |
|------|---------|
| Models | `lib/src/models/{category}/{name}.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` |
| Examples | `example/{name}_example.dart` |
```

### `.claude/skills/openapi-toolkit-yourpackage-dart/references/implementation-patterns.md`

Document API-specific implementation patterns:

```markdown
# Implementation Patterns (your_package_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## API-Specific Patterns

### Authentication
[Document how authentication works for this API]

### Streaming
[Document streaming patterns if applicable]

### Error Handling
[Document API-specific error codes and handling]
```

### `.claude/skills/openapi-toolkit-yourpackage-dart/references/REVIEW_CHECKLIST.md`

```markdown
# Review Checklist (your_package_dart)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST-core.md).

## Package-Specific Checks

[Add any API-specific verification steps]
```

---

## Step 5: Verify Setup

```bash
# From repository root

# Fetch the spec
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config

# Check that config is valid (will show errors if misconfigured)
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
  /tmp/openapi-toolkit-yourpackage-dart/latest-main.json \
  /tmp/openapi-toolkit-yourpackage-dart/latest-main.json \
  --format plan
```

---

## Workflow Modes

The toolkit supports two operational modes depending on your task:

### Create Mode (New Package)

Use this when building a new API client package from scratch:

1. **Setup** (Steps 1-4 above)
2. **Fetch spec**: `python3 .../fetch_spec.py --config-dir ...`
3. **Generate implementation plan**:
   ```bash
   python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
     --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
     --mode create /tmp/openapi-toolkit-yourpackage-dart/latest-main.json \
     --plan-out /tmp/implementation-plan.md
   ```
4. **Generate models/enums** using generation scripts (batch mode recommended)
5. **Implement infrastructure** (client, auth, resources) - AI-guided
6. **Run verification scripts**
7. **Copy spec** to `packages/yourpackage_dart/specs/openapi.json`

### Update Mode (Existing Package)

Use this when updating an existing package after API changes:

1. **Fetch latest spec**: `python3 .../fetch_spec.py --config-dir ...`
2. **Analyze changes**:
   ```bash
   python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
     --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config \
     packages/yourpackage_dart/specs/openapi.json \
     /tmp/openapi-toolkit-yourpackage-dart/latest-main.json \
     --format all --changelog-out /tmp/changelog.md --plan-out /tmp/plan.md
   ```
3. **Implement changes** based on the changelog/plan
4. **Update documentation** (README, CHANGELOG, examples)
5. **Run verification scripts**
6. **Copy updated spec** to package

---

## Adding WebSocket Support

If your API has a WebSocket/streaming component, also create at the repository root:

```
.claude/skills/websocket-toolkit-yourpackage-dart/
├── SKILL.md
├── config/
│   ├── package.json      # Can share with openapi-toolkit
│   ├── specs.json        # WebSocket endpoints
│   ├── schema.json       # Message type definitions
│   ├── models.json       # Critical live/streaming models
│   └── documentation.json
└── references/
    ├── live-api-schema.md
    └── REVIEW_CHECKLIST.md
```

---

## Checklist

- [ ] Package directory structure created (`packages/your_package_dart/`)
- [ ] `specs/` directory created for OpenAPI specs
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/config/package.json` - Package paths and names
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/config/specs.json` - API spec URL(s)
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/config/schemas.json` - Category patterns
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/config/models.json` - Critical models list
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/config/documentation.json` - README verification config
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/SKILL.md` - Skill documentation
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/references/package-guide.md` - Package structure
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/references/implementation-patterns.md` - API-specific patterns
- [ ] `.claude/skills/openapi-toolkit-yourpackage-dart/references/REVIEW_CHECKLIST.md` - Verification checklist
- [ ] Fetch spec works: `python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config`
- [ ] Analyze works: `python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py --config-dir .claude/skills/openapi-toolkit-yourpackage-dart/config ...`

---

## Common Customizations

### Different OpenAPI Spec Format

If the spec is YAML instead of JSON:
- The `fetch_spec.py` will handle conversion automatically
- Just use the YAML URL in `specs.json`

### Multiple API Specs

For APIs with multiple specs:
```json
{
  "specs": {
    "main": { "url": "...", "local_file": "openapi.json" },
    "assistants": { "url": "...", "local_file": "openapi-assistants.json" }
  }
}
```

### Private/Authenticated Spec

If the spec requires authentication to fetch:
```json
{
  "specs": {
    "main": {
      "url": "...",
      "requires_auth": true,
      "auth_env_vars": ["API_KEY"],
      "auth_header": "Authorization",
      "auth_format": "Bearer {key}"
    }
  }
}
```

---

## Config File Quick Reference

| File | Purpose | Key Fields |
|------|---------|------------|
| `package.json` | Package structure | `name`, `barrel_file`, `models_dir` |
| `specs.json` | API endpoints | `specs.*.url`, `auth_env_vars` |
| `schemas.json` | Schema organization | `categories`, `parent_model_patterns` |
| `models.json` | Critical models | `critical_models` list |
| `documentation.json` | README verification | `removed_apis`, `drift_patterns` |

---

## Reference Implementation

See `packages/googleai_dart` for a complete reference implementation:
- Package code: `packages/googleai_dart/`
- Package specs: `packages/googleai_dart/specs/`
- Config files: `.claude/skills/openapi-toolkit-googleai-dart/config/`
- Reference docs: `.claude/skills/openapi-toolkit-googleai-dart/references/`
- Core scripts: `.claude/shared/openapi-toolkit/scripts/`
- Core templates: `.claude/shared/openapi-toolkit/assets/`
- Core spec: `docs/spec-core.md`
