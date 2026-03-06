---
name: openapi-ollama
description: Update ollama_dart from Ollama OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Ollama OpenAPI Workflow

## Prerequisites

- Auth: No auth env vars required.
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch   --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```
Fetch writes the candidate spec to the configured `output_dir` as `latest-<spec>.json`.
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review   --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```
3. Implement with `scaffold` plus the package references, then promote the reviewed candidate from `output_dir/latest-<spec>.json` into `packages/ollama_dart/specs/` before final verification.
4. Verify:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify   --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config   --checks all --scope all
```

## Specs

| Spec | Description |
| --- | --- |
| `main` | Ollama API for running LLMs locally |

## Package References

- [references/package-guide.md](references/package-guide.md)
- [references/implementation-patterns.md](references/implementation-patterns.md)
- [references/REVIEW_CHECKLIST.md](references/REVIEW_CHECKLIST.md)

## Separate Dart Quality Steps

```bash
cd packages/ollama_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
