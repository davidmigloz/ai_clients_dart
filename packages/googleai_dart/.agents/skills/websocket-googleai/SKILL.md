---
name: websocket-googleai
description: >-
  Update googleai_dart from Gemini Live WebSocket schema changes. Fetch and compare schemas, generate changelogs and prioritized implementation plans, and guide message/model synchronization. Use for update live api, sync websocket schema, compare schema changes, new messages, or implementation plan requests.
---


# WebSocket Toolkit (googleai_dart)

Uses shared scripts from [websocket-toolkit](../../../../../.agents/shared/websocket-toolkit/README.md) with googleai_dart-specific configuration.

Uses verification scripts from [openapi-toolkit](../../../../../.agents/shared/openapi-toolkit/README.md).

## Prerequisites

- `GEMINI_API_KEY` or `GOOGLE_AI_API_KEY` environment variable set
- Working directory: Repository root
- Python 3

## Spec Registry

| Spec | Description | Auth Required |
|------|-------------|---------------|
| `live` | Gemini Live API (real-time audio/video/text streaming) | Yes |

## Workflow

### 1. Fetch Latest Schema

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/websocket-toolkit/scripts/fetch_schema.py \
  --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config
```

Output: `/tmp/websocket-googleai-dart/latest-live.json`

### 2. Analyze Changes

```bash
cd "$(git rev-parse --show-toplevel)" && \
python3 .agents/shared/websocket-toolkit/scripts/analyze_changes.py \
  --config-dir packages/googleai_dart/.agents/skills/websocket-googleai/config \
  packages/googleai_dart/specs/live-api-schema.json /tmp/websocket-googleai-dart/latest-live.json \
  --format all \
  --changelog-out /tmp/websocket-googleai-dart/changelog-live.md \
  --plan-out /tmp/websocket-googleai-dart/plan-live.md
```

Generates:
- `changelog-live.md` - Human-readable change summary
- `plan-live.md` - Prioritized implementation plan (P0-P4)

### 3. Implement Changes

Before implementing, read `references/implementation-patterns.md` for:
- Sealed class structure for messages
- WebSocket connection patterns
- JSON serialization for WebSocket messages

Use templates from `../../shared/websocket-toolkit/assets/`:
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
# Pass 2: Barrel file verification (from shared/openapi-toolkit)
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .agents/skills/websocket-googleai/config

# Pass 3: Documentation completeness
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .agents/skills/websocket-googleai/config

cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_examples.py \
  --config-dir .agents/skills/websocket-googleai/config

cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_readme_code.py \
  --config-dir .agents/skills/websocket-googleai/config

# Pass 4: Property-level verification
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
python3 ../../.agents/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .agents/skills/websocket-googleai/config

# Dart quality checks
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
dart analyze --fatal-infos && dart format --set-exit-if-changed . && dart test test/unit/
```

### 5. Testing (MANDATORY)

Test locations:
- Config classes: `test/unit/models/live/config/`
- Message types: `test/unit/models/live/messages/`
- Enums: `test/unit/models/live/enums/`

```bash
cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
dart test test/unit/models/live/
```

### 6. Finalize

```bash
cd "$(git rev-parse --show-toplevel)" && \
cp /tmp/websocket-googleai-dart/latest-live.json packages/googleai_dart/specs/live-api-schema.json

cd "$(git rev-parse --show-toplevel)/packages/googleai_dart" && \
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
