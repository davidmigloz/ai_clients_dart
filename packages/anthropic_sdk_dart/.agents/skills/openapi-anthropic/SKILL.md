---
name: openapi-anthropic
description: >-
  Update anthropic_sdk_dart from Anthropic OpenAPI changes. Fetch and compare specs, generate changelogs and prioritized implementation plans, and guide endpoint/model synchronization. Use for update api, sync openapi, compare spec changes, new endpoints, or implementation plan requests.
---


# OpenAPI Toolkit (anthropic_sdk_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.agents/shared/openapi-toolkit/README.md).

## Prerequisites

- `ANTHROPIC_API_KEY` environment variable set (for integration tests)
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.agents/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/anthropic_sdk_dart`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-anthropic/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/openapi-anthropic/config

cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/openapi-anthropic/config \
  --spec specs/openapi.yaml

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/anthropic_sdk_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-anthropic/config
```

## Troubleshooting

- **No changes detected**: Analysis shows all zeros - package is up-to-date, no action needed
- **Unexported files warning**: Add internal utility files to `skip_files` in `config/package.json`
- **Coverage < 100%**: Missing APIs need implementation before other updates
- **API key error**: Export `ANTHROPIC_API_KEY` environment variable

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official Anthropic API Documentation](https://docs.anthropic.com/en/api)
- [Official Anthropic TypeScript SDK](https://github.com/anthropics/anthropic-sdk-typescript)
- [Anthropic OpenAPI Spec](https://storage.googleapis.com/stainless-sdk-openapi-specs/anthropic%2Fanthropic-a49e89deec4e00d1da490808099d66e2001531b12d8666a7f5d0b496f760440d.yml)
