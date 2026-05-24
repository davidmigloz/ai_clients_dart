# Review Checklist

## Toolkit Workflow

```bash
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py fetch --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py review --config-dir packages/openai_dart/.agents/skills/openapi-openai/config
python3 .agents/shared/api-toolkit/scripts/api_toolkit.py verify --config-dir packages/openai_dart/.agents/skills/openapi-openai/config --checks all --scope all
```

## Package Quality

```bash
cd packages/openai_dart
dart analyze --fatal-infos
dart format --set-exit-if-changed .
dart test test/unit/
```

## Implementation Review

Read and apply the [core review checklist](../../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md) — it contains the full implementation review checklist applicable to all packages. The following items are OpenAI-specific:

- [ ] **Base64 data URL format**: Convenience factories for binary data fields must construct data URLs (`data:<mediaType>;base64,<data>`), not pass raw base64. Verify with an integration test.
- [ ] **Multi-model response shapes**: When OpenAI has multiple model families (e.g., `text-moderation-*` vs `omni-moderation-*`), fields only returned by newer models must be nullable.
- [ ] **Sibling package check**: When modifying shared patterns (e.g., file content, tool choice), check `open_responses` for the same pattern.
- [ ] **Web WebSocket header limitation**: Browser WebSockets cannot set `Authorization` (or any custom) headers. The web connector must reject *any* non-empty `headers` map unconditionally (an `headers.isNotEmpty` check, not just the exact `Authorization` key — browsers drop every header, including lowercase `authorization` and `OpenAI-Project`) with an actionable error that lists the provided keys and points at the WebRTC flow (`realtimeSessions.calls.create(...)`) or a server-side proxy. Docs, examples, and exception messages must not suggest authenticating a browser WebSocket by passing an ephemeral secret as a bearer token. See [implementation-patterns.md](implementation-patterns.md#web-websocket-authentication).
