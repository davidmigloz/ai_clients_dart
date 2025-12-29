# Adding a New Dart API Client Package

This guide explains how to create a new Dart API client package (e.g., `openai_dart`, `anthropic_dart`, `mistral_dart`) using the generic updater skills.

## Overview

After the refactoring of the updater skills, adding a new package requires **ONLY configuration files** - no Python code modifications. You will:

1. Create the package structure
2. Create config files for the updater skills
3. Create the package-specific spec
4. Start implementing models

## Prerequisites

- The core skills available at `.claude/shared/openapi-updater/` (repository root)
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
mkdir -p lib/src/{client,models,resources}
mkdir -p test/{unit,integration}
mkdir -p example
mkdir -p docs

# Create skill config directory at repository root
cd ../..
mkdir -p .claude/skills/openapi-updater-yourpackage/{config,references}
```

---

## Step 2: Create Config Files

### 2.1 `.claude/skills/openapi-updater-yourpackage/config/package.json` - Package Structure

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

### 2.2 `.claude/skills/openapi-updater-yourpackage/config/specs.json` - API Specifications

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
  "output_dir": "/tmp/openapi-updater-your-package",
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

### 2.3 `.claude/skills/openapi-updater-yourpackage/config/schemas.json` - Schema Organization

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

### 2.4 `.claude/skills/openapi-updater-yourpackage/config/models.json` - Critical Models

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

### 2.5 `.claude/skills/openapi-updater-yourpackage/config/documentation.json` - Documentation Verification

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

Create `.claude/skills/openapi-updater-yourpackage/SKILL.md`:

```markdown
---
name: openapi-updater-yourpackage
description: Automates your_package_dart updates from API OpenAPI spec.
---

# OpenAPI Updater (your_package_dart)

Uses shared scripts from [openapi-updater](../../shared/openapi-updater/README.md).

## Prerequisites

- `YOUR_API_KEY` environment variable set
- Working directory: Repository root

## Quick Start

```bash
# Fetch latest spec
python3 .claude/shared/openapi-updater/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config

# Analyze changes
python3 .claude/shared/openapi-updater/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config \
  packages/your_package_dart/openapi.json /tmp/openapi-updater-your-package/latest-main.json \
  --format all

# Verify implementation
python3 .claude/shared/openapi-updater/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config

python3 .claude/shared/openapi-updater/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config
```

## Package-Specific References

- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)
```

---

## Step 4: Create Package Specification

Create `packages/your_package_dart/docs/spec.md`:

```markdown
# your_package_dart Specification

This specification extends [spec-core.md](../../../docs/spec-core.md) with package-specific details.

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `your_package_dart` |
| API | Your API Name |
| API Key Env Var | `YOUR_API_KEY` |
| Barrel File | `lib/your_package_dart.dart` |

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

---

## Step 5: Create Reference Documentation

### `.claude/skills/openapi-updater-yourpackage/references/implementation-patterns.md`

Document API-specific implementation patterns:

```markdown
# Implementation Patterns (your_package_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-updater/references/implementation-patterns-core.md).

## API-Specific Patterns

### Authentication
[Document how authentication works for this API]

### Streaming
[Document streaming patterns if applicable]

### Error Handling
[Document API-specific error codes and handling]
```

### `.claude/skills/openapi-updater-yourpackage/references/REVIEW_CHECKLIST.md`

```markdown
# Review Checklist (your_package_dart)

Extends [REVIEW_CHECKLIST-core.md](../../../shared/openapi-updater/references/REVIEW_CHECKLIST-core.md).

## Package-Specific Checks

[Add any API-specific verification steps]
```

---

## Step 6: Verify Setup

```bash
# From repository root

# Fetch the spec
python3 .claude/shared/openapi-updater/scripts/fetch_spec.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config

# Check that config is valid (will show errors if misconfigured)
python3 .claude/shared/openapi-updater/scripts/analyze_changes.py \
  --config-dir .claude/skills/openapi-updater-yourpackage/config \
  /tmp/openapi-updater-your-package/latest-main.json \
  /tmp/openapi-updater-your-package/latest-main.json \
  --format plan
```

---

## Adding WebSocket Support

If your API has a WebSocket/streaming component, also create at the repository root:

```
.claude/skills/websocket-updater-yourpackage/
├── SKILL.md
├── config/
│   ├── package.json      # Can share with openapi-updater
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
- [ ] `.claude/skills/openapi-updater-yourpackage/config/package.json` - Package paths and names
- [ ] `.claude/skills/openapi-updater-yourpackage/config/specs.json` - API spec URL(s)
- [ ] `.claude/skills/openapi-updater-yourpackage/config/schemas.json` - Category patterns
- [ ] `.claude/skills/openapi-updater-yourpackage/config/models.json` - Critical models list
- [ ] `.claude/skills/openapi-updater-yourpackage/config/documentation.json` - README verification config
- [ ] `.claude/skills/openapi-updater-yourpackage/SKILL.md` - Skill documentation
- [ ] `packages/your_package_dart/docs/spec.md` - Package specification
- [ ] `.claude/skills/openapi-updater-yourpackage/references/implementation-patterns.md` - API-specific patterns
- [ ] `.claude/skills/openapi-updater-yourpackage/references/REVIEW_CHECKLIST.md` - Verification checklist
- [ ] Fetch spec works: `python3 .claude/shared/openapi-updater/scripts/fetch_spec.py --config-dir .claude/skills/openapi-updater-yourpackage/config`
- [ ] Analyze works: `python3 .claude/shared/openapi-updater/scripts/analyze_changes.py --config-dir .claude/skills/openapi-updater-yourpackage/config ...`

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
- Package spec: `packages/googleai_dart/docs/spec.md`
- Config files: `.claude/skills/openapi-updater-googleai/config/`
- Reference docs: `.claude/skills/openapi-updater-googleai/references/`
- Core scripts: `.claude/shared/openapi-updater/scripts/`
- Core templates: `.claude/shared/openapi-updater/assets/`
- Core spec: `docs/spec-core.md`
