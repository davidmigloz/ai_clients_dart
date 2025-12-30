# ollama_dart Package Guide

This guide provides package-specific details for implementing and updating the `ollama_dart` package.

---

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `ollama_dart` |
| API | Ollama API |
| Default Base URL | `http://localhost:11434` |
| Barrel File | `lib/ollama_dart.dart` |
| Models Directory | `lib/src/models` |
| Resources Directory | `lib/src/resources` |
| Tests Directory | `test/unit/models` |
| Examples Directory | `example` |
| Specs Directory | `specs/` |

---

## Directory Structure

```
packages/ollama_dart/
├── lib/
│   ├── ollama_dart.dart             # Main barrel file
│   └── src/
│       ├── models/
│       │   ├── chat/                # Chat completions
│       │   ├── completions/         # Text generation
│       │   ├── embeddings/          # Embeddings
│       │   ├── models/              # Model management
│       │   ├── tools/               # Tools, Functions
│       │   ├── metadata/            # Version, Options, etc.
│       │   ├── common/              # Shared types (sentinel)
│       │   └── web/                 # Web search (optional)
│       ├── resources/               # API resources
│       ├── client/                  # Client configuration
│       ├── auth/                    # Authentication providers
│       ├── interceptors/            # Request interceptors
│       ├── errors/                  # Exceptions
│       └── utils/                   # Utilities
├── test/
│   ├── unit/models/                 # Unit tests mirroring models/
│   └── integration/                 # Integration tests
├── example/                         # Example files
├── specs/                           # OpenAPI specifications
│   └── openapi.json                 # Main REST API spec
└── pubspec.yaml
```

---

## File Path Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Models | `lib/src/models/{category}/{name}.dart` | `lib/src/models/chat/chat_message.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` | `lib/src/resources/chat_resource.dart` |
| Unit Tests | `test/unit/models/{name}_test.dart` | `test/unit/models/chat_request_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` | `test/integration/chat_test.dart` |
| Examples | `example/{name}_example.dart` | `example/chat_example.dart` |

---

## Naming Conventions

### Model Classes (v1.0.0 Simplified Names)

| OpenAPI Schema | Dart Class | File |
|---------------|------------|------|
| `Message` | `ChatMessage` | `chat/chat_message.dart` |
| `GenerateChatCompletionRequest` | `ChatRequest` | `chat/chat_request.dart` |
| `GenerateChatCompletionResponse` | `ChatResponse` | `chat/chat_response.dart` |
| `GenerateCompletionRequest` | `GenerateRequest` | `completions/generate_request.dart` |
| `GenerateCompletionResponse` | `GenerateResponse` | `completions/generate_response.dart` |
| `GenerateEmbeddingRequest` | `EmbedRequest` | `embeddings/embed_request.dart` |
| `GenerateEmbeddingResponse` | `EmbedResponse` | `embeddings/embed_response.dart` |
| `Tool` | `ToolDefinition` | `tools/tool_definition.dart` |
| `ToolCall` | `ToolCall` | `tools/tool_call.dart` |
| `Model` | `ModelSummary` | `models/model_summary.dart` |
| `ModelInfo` | `ShowResponse` | `models/show_response.dart` |
| `RequestOptions` | `ModelOptions` | `metadata/model_options.dart` |

### Enums
- Enum name: `PascalCase` (e.g., `MessageRole`)
- Enum values: `camelCase` (e.g., `assistant`)
- Wire format: `snake_case` (e.g., `assistant`)
- Converter functions: `{enumName}FromString`, `{enumName}ToString`

### Resources
- Class name: `{Name}Resource` (e.g., `ChatResource`)
- File name: `{name}_resource.dart` (e.g., `chat_resource.dart`)
- Client accessor: `client.{name}` (e.g., `client.chat`)

---

## API Resources

The following resources are exposed via `OllamaClient`:

| Resource | Accessor | Description |
|----------|----------|-------------|
| Chat | `client.chat` | Chat completions |
| Completions | `client.completions` | Text generation |
| Embeddings | `client.embeddings` | Generate embeddings |
| Models | `client.models` | Model management |
| Version | `client.version` | Server version info |

---

## API Endpoints

| Endpoint | Method | Resource | Operation |
|----------|--------|----------|-----------|
| `/api/chat` | POST | Chat | `create`, `createStream` |
| `/api/generate` | POST | Completions | `generate`, `generateStream` |
| `/api/embed` | POST | Embeddings | `create` |
| `/api/tags` | GET | Models | `list` |
| `/api/show` | POST | Models | `show` |
| `/api/create` | POST | Models | `create`, `createStream` |
| `/api/copy` | POST | Models | `copy` |
| `/api/delete` | DELETE | Models | `delete` |
| `/api/pull` | POST | Models | `pull`, `pullStream` |
| `/api/push` | POST | Models | `push`, `pushStream` |
| `/api/ps` | GET | Models | `ps` |
| `/api/version` | GET | Version | `get` |

---

## Critical Models

These models are verified against the OpenAPI spec for property completeness:

| Model | File | Purpose |
|-------|------|---------|
| ChatMessage | `lib/src/models/chat/chat_message.dart` | Chat messages |
| ChatRequest | `lib/src/models/chat/chat_request.dart` | Chat request |
| ChatResponse | `lib/src/models/chat/chat_response.dart` | Chat response |
| GenerateRequest | `lib/src/models/completions/generate_request.dart` | Generate request |
| GenerateResponse | `lib/src/models/completions/generate_response.dart` | Generate response |
| EmbedRequest | `lib/src/models/embeddings/embed_request.dart` | Embeddings request |
| EmbedResponse | `lib/src/models/embeddings/embed_response.dart` | Embeddings response |
| ToolDefinition | `lib/src/models/tools/tool_definition.dart` | Tool definitions |
| ModelSummary | `lib/src/models/models/model_summary.dart` | Model info |
| ShowResponse | `lib/src/models/models/show_response.dart` | Detailed model info |

---

## Exception Types

ollama_dart uses the following exception hierarchy:

```dart
sealed class OllamaException implements Exception {
  String get message;
  StackTrace? get stackTrace;
  Exception? get cause;
}

class ApiException extends OllamaException {
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

class TimeoutException extends OllamaException {
  final Duration timeout;
  final Duration elapsed;
}

class ValidationException extends OllamaException {
  final Map<String, List<String>> fieldErrors;
}

class AbortedException extends OllamaException {
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

# Integration tests (requires running Ollama server)
dart test --tags=integration

# All tests
dart test
```

### Test Tags

- `@Tags(['integration'])` - Requires running Ollama server
- No tag - Unit tests (no network required)

---

## Verification Scripts

All verification scripts are in `.claude/shared/openapi-toolkit/scripts/` and require `--config-dir .claude/skills/openapi-toolkit-ollama-dart/config`:

```bash
# Verify barrel file exports
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-ollama-dart/config

# Verify README completeness
python3 .claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-toolkit-ollama-dart/config

# Verify model properties match spec
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-ollama-dart/config
```

---

## Related Documentation

- [Implementation Patterns](./implementation-patterns.md)
- [Review Checklist](./REVIEW_CHECKLIST.md)
- [OpenAPI Toolkit Skill](../SKILL.md)
