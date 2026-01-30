---
name: openapi-mistral
description: Automates updating mistralai_dart when Mistral AI OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (mistralai_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.claude/shared/openapi-toolkit/README.md).

## Prerequisites

- `MISTRAL_API_KEY` environment variable set (for integration tests)
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.claude/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/mistralai_dart`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/mistralai_dart/.claude/skills/openapi-mistral/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/mistralai_dart/.claude/skills/openapi-mistral/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-mistral/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-mistral/config

cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-mistral/config \
  --spec specs/openapi.json

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-mistral/config
```

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official Mistral API Documentation](https://docs.mistral.ai/api/)
- [Official Mistral TypeScript SDK](https://github.com/mistralai/client-ts)
- [Mistral OpenAPI Spec](https://docs.mistral.ai/openapi.yaml)
