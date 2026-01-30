---
name: openapi-ollama
description: Automates updating ollama_dart when Ollama OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (ollama_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.claude/shared/openapi-toolkit/README.md).

## Prerequisites

- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.claude/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/ollama_dart`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/ollama_dart/.claude/skills/openapi-ollama/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/ollama_dart/.claude/skills/openapi-ollama/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/ollama_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-ollama/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/ollama_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-ollama/config

cd "$(git rev-parse --show-toplevel)/packages/ollama_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-ollama/config \
  --spec specs/openapi.json

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/ollama_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-ollama/config
```

## IMPORTANT: Verify Against Official Sources

The Ollama OpenAPI spec may be incomplete or lag behind the actual implementation.
**Always cross-reference with these official sources before finalizing implementation:**

### Primary Sources (Source of Truth)

1. **Ollama Go Types** (definitive API contract):
   https://github.com/ollama/ollama/blob/main/api/types.go

2. **Ollama JS Client** (reference implementation):
   https://github.com/ollama/ollama-js/blob/main/src/interfaces.ts

### Verification Workflow

When updating or creating models:

1. Fetch the OpenAPI spec as usual
2. **Cross-reference each model** with the Go types and JS interfaces
3. If the official sources have parameters not in the OpenAPI spec, add them
4. Update `expected_properties` in `config/models.json` with any new parameters found

### Critical Models to Verify

These models are most likely to have parameters missing from the OpenAPI spec:

| Go Type | JS Type | Dart Class |
|---------|---------|------------|
| `Options` | `Options` | `ModelOptions` |
| `GenerateRequest` | `GenerateRequest` | `GenerateRequest` |
| `GenerateResponse` | `GenerateResponse` | `GenerateResponse` |
| `ChatRequest` | `ChatRequest` | `ChatRequest` |
| `ChatResponse` | `ChatResponse` | `ChatResponse` |
| `EmbedRequest` | `EmbeddingsRequest` | `EmbedRequest` |
| `EmbedResponse` | `EmbeddingsResponse` | `EmbedResponse` |

### Expected Properties Validation

The `config/models.json` file contains an `expected_properties` section that lists
all expected properties for critical models. The verification script will warn
if any expected properties are missing from the implementation.

This serves as a regression prevention mechanism: if a future OpenAPI spec update
inadvertently removes a property that should exist, the verification will catch it.

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Official Ollama JS Client](https://github.com/ollama/ollama-js)
- [Ollama OpenAPI Spec](https://raw.githubusercontent.com/ollama/ollama/refs/heads/main/docs/openapi.yaml)
