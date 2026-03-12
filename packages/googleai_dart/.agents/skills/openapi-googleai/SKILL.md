---
name: openapi-googleai
description: Update googleai_dart from Google AI OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Google AI OpenAPI Workflow

## Prerequisites

- Auth: `GEMINI_API_KEY`, `GOOGLE_AI_API_KEY`
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

## Workflow

1. Fetch the spec you are updating:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch \
  --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config \
  --spec-name main
```
Fetch writes the candidate spec to the configured `output_dir` as `latest-<spec>.json`.
2. Review the same spec:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review \
  --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config \
  --spec-name main
```
3. Implement with `scaffold` plus the package references, then promote the candidate spec. The verifier reads `specs_dir/{local_file}` — copy using the exact `local_file` name from [`config/specs.json`](config/specs.json), not the spec-name:
   ```bash
   # For --spec-name main (local_file = "openapi.json"):
   cp /tmp/openapi-googleai-dart/latest-main.json packages/googleai_dart/specs/openapi.json
   # For --spec-name interactions (local_file = "openapi-interactions.json"):
   cp /tmp/openapi-googleai-dart/latest-interactions.json packages/googleai_dart/specs/openapi-interactions.json
   ```
4. Verify:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify \
  --config-dir packages/googleai_dart/.agents/skills/openapi-googleai/config \
  --spec-name main \
  --checks all --scope all
```

## Specs

| Spec | Description |
| --- | --- |
| `main` | Core Gemini API - generation, embeddings, files, models, etc. |
| `interactions` | Server-side state, agents, background execution |

Use `--spec-name interactions` when reviewing or verifying the interactions spec.

## Package References

- [references/package-guide.md](references/package-guide.md)
- [references/implementation-patterns.md](references/implementation-patterns.md)
- [references/REVIEW_CHECKLIST.md](references/REVIEW_CHECKLIST.md)

## Separate Dart Quality Steps

```bash
cd packages/googleai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
