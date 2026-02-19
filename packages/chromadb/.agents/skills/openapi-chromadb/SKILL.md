---
name: openapi-chromadb
description: >-
  Update chromadb from ChromaDB OpenAPI changes. Fetch and compare specs, generate changelogs and prioritized implementation plans, and guide endpoint/model synchronization. Use for update api, sync openapi, compare spec changes, new endpoints, or implementation plan requests.
---


# OpenAPI Toolkit (chromadb)

Uses shared scripts from [openapi-toolkit](../../../../../.agents/shared/openapi-toolkit/README.md).

## Prerequisites

- Python 3.9+ with `pyyaml` installed
  - **Important**: Install for your active Python version: `python3 -m pip install pyyaml --user`
  - Verify: `python3 -c "import yaml; print(yaml.__version__)"`

## Working Directory Requirements

Different scripts require different working directories. See the [shared README](../../../../../.agents/shared/openapi-toolkit/README.md#working-directory-requirements) for details.

| Script | Working Directory |
|--------|-------------------|
| `fetch_spec.py`, `analyze_changes.py` | Repository root |
| `verify_*.py`, `generate_*.py` | **Package root** (`packages/chromadb`) |

## Quick Start

```bash
# === FROM REPOSITORY ROOT ===

# Fetch latest spec
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/fetch_spec.py \
  --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config

# Analyze changes (specs auto-located from config)
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/openapi-toolkit/scripts/analyze_changes.py \
  --config-dir packages/chromadb/.agents/skills/openapi-chromadb/config \
  --format all

# === FROM PACKAGE ROOT ===

# IMPORTANT: Check API coverage (spec auto-located)
cd "$(git rev-parse --show-toplevel)/packages/chromadb" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-chromadb/config --verbose

# Verify implementation (barrel files auto-discovered)
cd "$(git rev-parse --show-toplevel)/packages/chromadb" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/openapi-chromadb/config

cd "$(git rev-parse --show-toplevel)/packages/chromadb" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/openapi-chromadb/config \
  --spec specs/openapi.json

# Re-run coverage to confirm full implementation
cd "$(git rev-parse --show-toplevel)/packages/chromadb" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_coverage.py \
  --config-dir .agents/skills/openapi-chromadb/config
```

## Troubleshooting

- **No changes detected**: Analysis shows all zeros - package is up-to-date, no action needed
- **Unexported files warning**: Add internal utility files to `skip_files` in `config/package.json`
- **Coverage < 100%**: Missing APIs need implementation before other updates

## Package-Specific References

- [Package Guide](references/package-guide.md)
- [Implementation Patterns](references/implementation-patterns.md)
- [Review Checklist](references/REVIEW_CHECKLIST.md)
