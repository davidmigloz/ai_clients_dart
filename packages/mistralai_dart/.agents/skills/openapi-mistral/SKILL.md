---
name: openapi-mistral
description: >-
  Update mistralai_dart from Mistral OpenAPI changes. Fetch and compare specs, generate changelogs and prioritized implementation plans, and guide endpoint/model synchronization. Use for update api, sync openapi, compare spec changes, new endpoints, or implementation plan requests.
---


# OpenAPI Toolkit (mistralai_dart)

Uses shared scripts from [openapi-toolkit](../../../../../.agents/shared/openapi-toolkit/README.md).

## Prerequisites

- `MISTRAL_API_KEY` environment variable set (for integration tests)
- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.agents/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/mistralai_dart`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/mistralai_dart/.agents/skills/openapi-mistral/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/mistralai_dart/.agents/skills/openapi-mistral/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-mistral/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/openapi-mistral/config

cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/openapi-mistral/config \
  --spec specs/openapi.json

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/mistralai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-mistral/config
```

## Troubleshooting

- **No changes detected**: Analysis shows all zeros - package is up-to-date, no action needed
- **Unexported files warning**: Add internal utility files to `skip_files` in `config/package.json`
- **Coverage < 100%**: Missing APIs need implementation before other updates
- **API key error**: Export `MISTRAL_API_KEY` environment variable

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)

## External References

- [Official Mistral API Documentation](https://docs.mistral.ai/api/)
- [Official Mistral TypeScript SDK](https://github.com/mistralai/client-ts)
- [Mistral OpenAPI Spec](https://docs.mistral.ai/openapi.yaml)
