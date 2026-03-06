---
name: websocket-googleai
description: Update googleai_dart from Google AI WebSocket schema changes. Use for live schema refresh, change review, scaffolding, and verification.
---

# Google AI WebSocket Workflow

## Prerequisites

- Auth: No auth env vars required for fetch/review; runtime WebSocket usage still uses Google AI credentials.
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Existing-package commands: run the repo-relative examples from the repository root. If you run them elsewhere, invoke the script via an absolute path and pass an absolute `--config-dir`.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch   --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
```
Fetch writes the candidate spec to the configured `output_dir` as `latest-<spec>.json`.
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review   --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
```
3. Implement with `scaffold` plus the package references, then promote the reviewed candidate from `output_dir/latest-<spec>.json` into `packages/googleai_dart/specs/` before final verification.
4. Verify:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify   --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config   --checks all --scope all
```

## Specs

| Spec | Description |
| --- | --- |
| `live` | Real-time bidirectional audio/video streaming via WebSocket |

## Package References

- [references/package-guide.md](references/package-guide.md)
- [references/implementation-patterns.md](references/implementation-patterns.md)
- [references/REVIEW_CHECKLIST.md](references/REVIEW_CHECKLIST.md)
- [references/live-api-schema.md](references/live-api-schema.md)

## Separate Dart Quality Steps

```bash
cd packages/googleai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```
