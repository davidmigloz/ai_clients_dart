---
name: openapi-anthropic
description: Update anthropic_sdk_dart from Anthropic OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Anthropic OpenAPI Workflow

## Prerequisites

- Auth: `ANTHROPIC_API_KEY`
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Commands work from any directory. Use `--config-dir` to resolve the package and repo roots.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch   --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
```
Fetch writes the candidate spec to the configured `output_dir` as `latest-<spec>.json`.
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review   --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
```
3. Implement with `scaffold` plus the package references, then promote the reviewed candidate from `output_dir/latest-<spec>.json` into `packages/anthropic_sdk_dart/specs/` before final verification.
4. Verify:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify   --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config   --checks all --scope all
```

## Specs

| Spec | Description |
| --- | --- |
| `main` | Anthropic API for Claude models |

## Package References

- [references/package-guide.md](references/package-guide.md)
- [references/implementation-patterns.md](references/implementation-patterns.md)
- [references/REVIEW_CHECKLIST.md](references/REVIEW_CHECKLIST.md)

## Separate Dart Quality Steps

```bash
cd packages/anthropic_sdk_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
