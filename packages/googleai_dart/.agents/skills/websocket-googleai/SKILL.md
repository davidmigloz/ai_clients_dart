---
name: websocket-googleai
description: Update googleai_dart from Google AI WebSocket schema changes. Use for live schema refresh, change review, scaffolding, and verification.
---

# Google AI WebSocket Workflow

## Prerequisites

- Auth: `GEMINI_API_KEY`, `GOOGLE_AI_API_KEY`
- CLI: `python3 .agents/shared/api-toolkit/scripts/api_toolkit.py`
- Use an absolute `--config-dir` when running outside the repo root.

## Workflow

1. Fetch:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch   --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
```
2. Review:
```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review   --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
```
3. Implement with `scaffold`, package references, and the reviewed candidate spec.
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
