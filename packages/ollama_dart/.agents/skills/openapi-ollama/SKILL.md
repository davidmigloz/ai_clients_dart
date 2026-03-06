---
name: openapi-ollama
description: Update ollama_dart from Ollama OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Ollama OpenAPI Workflow

## Prerequisites

- Auth: No auth env vars required.
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Commands work from any directory. Use `--config-dir` to resolve the package and repo roots.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch   --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review   --config-dir packages/ollama_dart/.agents/skills/openapi-ollama/config
```
3. Implement with `scaffold`, package references, and the reviewed candidate spec.
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
