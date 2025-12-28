---
name: websocket-updater
description: Automates updating googleai_dart when Gemini Live API WebSocket schema changes. Fetches latest schema, compares against current, generates changelogs and prioritized implementation plans. Use for: (1) Checking for Live API updates, (2) Generating implementation plans for WebSocket changes, (3) Creating new message types from schema, (4) Syncing local schema with upstream. Triggers: "update live api", "sync websocket", "new messages", "live api changes", "check for live updates", "update live schema", "websocket version", "fetch live schema", "compare live schema", "what changed in live api", "live implementation plan".
---

# WebSocket Updater (googleai_dart)

Extends [websocket-updater-core](../websocket-updater-core/SKILL.md) with googleai_dart-specific configuration.

Uses verification scripts from [openapi-updater-core](../openapi-updater-core/SKILL.md).

## Prerequisites

- `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY` environment variable set
- Working directory: `packages/googleai_dart`
- Python 3

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `live` | Gemini Live API (real-time audio/video/text streaming) | Yes |

## Workflow

### 1. Fetch Latest Schema

```bash
python3 .claude/skills/websocket-updater-core/scripts/fetch_schema.py \
  --config-dir .claude/skills/websocket-updater/config
```

Output: `/tmp/websocket-updater/latest-live.json`

### 2. Analyze Changes

```bash
python3 .claude/skills/websocket-updater-core/scripts/analyze_changes.py \
  --config-dir .claude/skills/websocket-updater/config \
  live-api-schema.json /tmp/websocket-updater/latest-live.json \
  --format all \
  --changelog-out /tmp/websocket-updater/changelog-live.md \
  --plan-out /tmp/websocket-updater/plan-live.md
```

Generates:
- `changelog-live.md` - Human-readable change summary
- `plan-live.md` - Prioritized implementation plan (P0-P4)

### 3. Implement Changes

Before implementing, read `references/implementation-patterns.md` for:
- Sealed class structure for messages
- WebSocket connection patterns
- JSON serialization for WebSocket messages

Use templates from `../websocket-updater-core/assets/`:
- `sealed_message_template.dart` - Sealed class for WebSocket messages
- `model_template.dart` - Model class structure
- `test_template.dart` - Unit test structure

### 3.5 Update Documentation (MANDATORY)

Before running the review checklist:

1. **README.md** - Add/update Live API section
2. **example/** - Create/update `live_example.dart`
3. **CHANGELOG.md** - Add entry for new features

### 4. Review & Validate (MANDATORY)

```bash
# Pass 2: Barrel file verification (from openapi-updater-core)
python3 .claude/skills/openapi-updater-core/scripts/verify_exports.py \
  --config-dir .claude/skills/websocket-updater/config

# Pass 3: Documentation completeness
python3 .claude/skills/openapi-updater-core/scripts/verify_readme.py \
  --config-dir .claude/skills/websocket-updater/config
python3 .claude/skills/openapi-updater-core/scripts/verify_examples.py \
  --config-dir .claude/skills/websocket-updater/config
python3 .claude/skills/openapi-updater-core/scripts/verify_readme_code.py \
  --config-dir .claude/skills/websocket-updater/config

# Pass 4: Property-level verification
python3 .claude/skills/openapi-updater-core/scripts/verify_model_properties.py \
  --config-dir .claude/skills/websocket-updater/config

# Dart quality checks
dart analyze --fatal-infos && dart format --set-exit-if-changed . && dart test test/unit/
```

### 5. Testing (MANDATORY)

Test locations:
- Config classes: `test/unit/models/live/config/`
- Message types: `test/unit/models/live/messages/`
- Enums: `test/unit/models/live/enums/`

```bash
dart test test/unit/models/live/
```

### 6. Finalize

```bash
cp /tmp/websocket-updater/latest-live.json live-api-schema.json
dart test && dart analyze && dart format --set-exit-if-changed .
```

## WebSocket Endpoints

**Google AI:**
```
wss://generativelanguage.googleapis.com/v1beta/models/{model}:BidiGenerateContent?key={API_KEY}&alt=ws
```

**Vertex AI:**
```
wss://{location}-aiplatform.googleapis.com/ws/google.cloud.aiplatform.v1beta1.PredictionService.BidiGenerateContent
Authorization: Bearer {ACCESS_TOKEN}
```

## Message Types

### Client Messages
- `BidiGenerateContentSetup` - Initial session configuration
- `BidiGenerateContentClientContent` - User content/context
- `BidiGenerateContentRealtimeInput` - Real-time audio/video/text input
- `BidiGenerateContentToolResponse` - Tool execution responses

### Server Messages
- `BidiGenerateContentSetupComplete` - Session ready confirmation
- `BidiGenerateContentServerContent` - Model responses
- `BidiGenerateContentToolCall` - Tool execution requests
- `BidiGenerateContentToolCallCancellation` - Tool call cancellations
- `GoAway` - Session ending notification
- `SessionResumptionUpdate` - Resumption token updates

## Package-Specific References

- [Implementation Patterns](references/implementation-patterns.md) - WebSocket patterns
- [Live API Schema](references/live-api-schema.md) - Schema documentation
- [Review Checklist](references/REVIEW_CHECKLIST.md) - Validation process

## Troubleshooting

- **API key error**: Export `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY`
- **Network errors**: Check connectivity; retry after a few seconds
- **No changes detected**: Summary shows all zeros; no action needed
