---
name: openapi-anthropic
description: Automates updating anthropic_sdk_dart when Anthropic OpenAPI spec changes. Fetches latest spec, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for API updates, (2) Generating implementation plans for spec changes, (3) Creating new models/endpoints from spec, (4) Syncing local spec with upstream. Triggers: "update api", "sync openapi", "new endpoints", "api changes", "check for updates", "update spec", "api version", "fetch spec", "compare spec", "what changed in the api", "implementation plan".
---

# OpenAPI Toolkit (anthropic_sdk_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.claude/shared/openapi-toolkit/README.md).

## Prerequisites

- `ANTHROPIC_API_KEY` environment variable set (for integration tests)
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.claude/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/anthropic_sdk_dart`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/anthropic_sdk_dart/.claude/skills/openapi-anthropic/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .claude/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/anthropic_sdk_dart/.claude/skills/openapi-anthropic/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-anthropic/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-anthropic/config

cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-anthropic/config \
  --spec specs/openapi.yaml

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.claude/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .claude/skills/openapi-anthropic/config
```

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official Anthropic API Documentation](https://docs.anthropic.com/en/api)
- [Official Anthropic TypeScript SDK](https://github.com/anthropics/anthropic-sdk-typescript)
- [Anthropic OpenAPI Spec](https://storage.googleapis.com/stainless-sdk-openapi-specs/anthropic%2Fanthropic-a49e89deec4e00d1da490808099d66e2001531b12d8666a7f5d0b496f760440d.yml)
