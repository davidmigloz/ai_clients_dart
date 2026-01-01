# mistralai_dart Package Guide

This guide provides package-specific details for implementing and updating the `mistralai_dart` package.

---

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `mistralai_dart` |
| API | Mistral AI API |
| Default Base URL | `https://api.mistral.ai` |
| Barrel File | `lib/mistralai_dart.dart` |
| Models Directory | `lib/src/models` |
| Resources Directory | `lib/src/resources` |
| Tests Directory | `test/unit/models` |
| Examples Directory | `example` |
| Specs Directory | `specs/` |

---

## Directory Structure

```
packages/mistralai_dart/
├── lib/
│   ├── mistralai_dart.dart             # Main barrel file
│   └── src/
│       ├── models/
│       │   ├── chat/                   # Chat completions
│       │   ├── content/                # Multimodal content parts
│       │   ├── embeddings/             # Embeddings
│       │   ├── models/                 # Model management
│       │   ├── tools/                  # Tool/function definitions
│       │   ├── metadata/               # Usage, response format, etc.
│       │   └── common/                 # Shared types (sentinel)
│       ├── resources/                  # API resources
│       ├── client/                     # Client configuration
│       ├── auth/                       # Authentication providers
│       ├── interceptors/               # Request interceptors
│       ├── errors/                     # Exceptions
│       └── utils/                      # Utilities
├── test/
│   ├── unit/models/                    # Unit tests mirroring models/
│   └── integration/                    # Integration tests
├── example/                            # Example files
├── specs/                              # OpenAPI specifications
│   └── openapi.json                    # Main REST API spec
└── pubspec.yaml
```

---

## File Path Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Models | `lib/src/models/{category}/{name}.dart` | `lib/src/models/chat/chat_message.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` | `lib/src/resources/chat_resource.dart` |
| Unit Tests | `test/unit/models/{name}_test.dart` | `test/unit/models/chat_message_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` | `test/integration/chat_test.dart` |
| Examples | `example/{name}_example.dart` | `example/chat_example.dart` |

---

## Naming Conventions

### Model Classes

| OpenAPI Schema | Dart Class | File |
|---------------|------------|------|
| `ChatCompletionRequest` | `ChatCompletionRequest` | `chat/chat_completion_request.dart` |
| `ChatCompletionResponse` | `ChatCompletionResponse` | `chat/chat_completion_response.dart` |
| `Messages` (union) | `ChatMessage` (sealed) | `chat/chat_message.dart` |
| `SystemMessage` | `SystemMessage` | `chat/system_message.dart` |
| `UserMessage` | `UserMessage` | `chat/user_message.dart` |
| `AssistantMessage` | `AssistantMessage` | `chat/assistant_message.dart` |
| `ToolMessage` | `ToolMessage` | `chat/tool_message.dart` |
| `Tool` | `Tool` | `tools/tool.dart` |
| `ToolCall` | `ToolCall` | `tools/tool_call.dart` |
| `EmbeddingRequest` | `EmbeddingRequest` | `embeddings/embedding_request.dart` |
| `EmbeddingResponse` | `EmbeddingResponse` | `embeddings/embedding_response.dart` |
| `ModelCard` | `Model` | `models/model.dart` |

### Enums
- Enum name: `PascalCase` (e.g., `FinishReason`)
- Enum values: `camelCase` (e.g., `toolCalls`)
- Wire format: `snake_case` (e.g., `tool_calls`)
- Converter functions: `{enumName}FromString`, `{enumName}ToString`

### Resources
- Class name: `{Name}Resource` (e.g., `ChatResource`)
- File name: `{name}_resource.dart` (e.g., `chat_resource.dart`)
- Client accessor: `client.{name}` (e.g., `client.chat`)

---

## API Resources

The following resources are exposed via `MistralClient`:

| Resource | Accessor | Description |
|----------|----------|-------------|
| Chat | `client.chat` | Chat completions |
| Embeddings | `client.embeddings` | Generate embeddings |
| Models | `client.models` | Model management |

---

## API Endpoints

| Endpoint | Method | Resource | Operation |
|----------|--------|----------|-----------|
| `/v1/chat/completions` | POST | Chat | `create`, `createStream` |
| `/v1/embeddings` | POST | Embeddings | `create` |
| `/v1/models` | GET | Models | `list` |
| `/v1/models/{id}` | GET | Models | `get` |
| `/v1/models/{id}` | DELETE | Models | `delete` |

---

## Critical Models

These models are verified against the OpenAPI spec for property completeness:

| Model | File | Purpose |
|-------|------|---------|
| ChatMessage | `lib/src/models/chat/chat_message.dart` | Chat messages (sealed) |
| ChatCompletionRequest | `lib/src/models/chat/chat_completion_request.dart` | Chat request |
| ChatCompletionResponse | `lib/src/models/chat/chat_completion_response.dart` | Chat response |
| EmbeddingRequest | `lib/src/models/embeddings/embedding_request.dart` | Embeddings request |
| EmbeddingResponse | `lib/src/models/embeddings/embedding_response.dart` | Embeddings response |
| Tool | `lib/src/models/tools/tool.dart` | Tool definitions |
| Model | `lib/src/models/models/model.dart` | Model info |

---

## Exception Types

mistralai_dart uses the following exception hierarchy:

```dart
sealed class MistralException implements Exception {
  String get message;
  StackTrace? get stackTrace;
  Exception? get cause;
}

class ApiException extends MistralException {
  final int code;                      // HTTP status code
  final String message;
  final List<Object> details;          // Server error details
  final RequestMetadata? requestMetadata;
  final ResponseMetadata? responseMetadata;
  final Exception? cause;
}

class RateLimitException extends ApiException {
  final DateTime? retryAfter;          // From Retry-After header
}

class TimeoutException extends MistralException {
  final Duration timeout;
  final Duration elapsed;
}

class ValidationException extends MistralException {
  final Map<String, List<String>> fieldErrors;
}

class AbortedException extends MistralException {
  final String correlationId;
  final DateTime timestamp;
  final AbortionStage stage;
}
```

---

## Testing

### Running Tests

```bash
# Unit tests only
dart test test/unit/

# Integration tests (requires MISTRAL_API_KEY)
dart test --tags=integration

# All tests
dart test
```

### Test Tags

- `@Tags(['integration'])` - Requires MISTRAL_API_KEY
- No tag - Unit tests (no network required)

---

## Verification Scripts

All verification scripts are in `.claude/shared/openapi-toolkit/scripts/` and require `--config-dir .claude/skills/openapi-toolkit-mistralai-dart/config`:

```bash
# Verify barrel file exports
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config

# Verify README completeness
python3 .claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config

# Verify model properties match spec
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-mistralai-dart/config
```

---

## Related Documentation

- [Implementation Patterns](./implementation-patterns.md)
- [Review Checklist](./REVIEW_CHECKLIST.md)
- [OpenAPI Toolkit Skill](../SKILL.md)
