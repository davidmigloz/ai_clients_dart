---
name: openapi-anthropic
description: Update anthropic_sdk_dart from Anthropic OpenAPI changes. Use for spec refresh, change review, scaffolding, and verification.
---

# Anthropic OpenAPI Workflow

## Prerequisites

- Auth: No auth env vars required.
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

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
3. Implement with `scaffold` plus the package references, then promote the spec and update the pin:
   - Copy the candidate into the package: `cp /tmp/openapi-anthropic-dart/latest-main.json packages/anthropic_sdk_dart/specs/openapi.yaml` (the canonical spec is JSON despite the `.yaml` extension).
   - Update `pinned_hash` in `config/specs.json` to the new spec hash (visible in the fetch output's `latest_hash` field). If you skip this, the next `fetch` will still report `outdated: true`.
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

## Documentation Artifacts

After implementation and before opening a PR, update documentation to reflect new types:

1. **Example** — add an `example/<feature>_example.dart` if the change introduces a new tool, content block type, or API surface. Follow the pattern of existing examples (e.g., `web_search_example.dart`). Verify with `dart analyze`.
2. **README** — update `README.md`:
   - Features section: mention the new capability in the relevant bullet.
   - Examples table: add a row for the new example file.
3. **llms.txt** — regenerate with the toolkit so the new example is indexed with its token count:
   ```bash
   python3 .agents/shared/api-toolkit/scripts/api_toolkit.py generate-llms-txt \
     --config-dir packages/anthropic_sdk_dart/.agents/skills/openapi-anthropic/config
   ```

## Separate Dart Quality Steps

```bash
cd packages/anthropic_sdk_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
