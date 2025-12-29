# googleai_dart Package Guide

This guide provides package-specific details for implementing and updating the `googleai_dart` package.

---

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `googleai_dart` |
| API | Google AI (Gemini) API |
| API Key Env Vars | `GEMINI_API_KEY`, `GOOGLE_AI_API_KEY` |
| Barrel File | `lib/googleai_dart.dart` |
| Models Directory | `lib/src/models` |
| Resources Directory | `lib/src/resources` |
| Tests Directory | `test/unit/models` |
| Examples Directory | `example` |
| Specs Directory | `specs/` |

---

## Directory Structure

```
packages/googleai_dart/
├── lib/
│   ├── googleai_dart.dart           # Main barrel file
│   └── src/
│       ├── models/
│       │   ├── batch/               # Batch processing
│       │   ├── caching/             # Cached contents
│       │   ├── content/             # Content, Parts, Candidates
│       │   ├── corpus/              # Corpus, Documents
│       │   ├── embeddings/          # Embeddings
│       │   ├── files/               # File handling
│       │   ├── generation/          # Generation config
│       │   ├── live/                # Live API models
│       │   ├── metadata/            # Grounding, Citations
│       │   ├── models/              # Model info
│       │   ├── permissions/         # Permissions
│       │   ├── safety/              # Safety settings
│       │   ├── tools/               # Tools, Functions
│       │   └── copy_with_sentinel.dart
│       ├── resources/               # API resources
│       ├── client/                  # Client configuration
│       ├── auth/                    # Authentication providers
│       ├── interceptors/            # Request interceptors
│       └── errors/                  # Exceptions
├── test/
│   ├── unit/models/                 # Unit tests mirroring models/
│   └── integration/                 # Integration tests
├── example/                         # Example files
├── specs/                           # OpenAPI specifications
│   ├── openapi.json                 # Main REST API spec
│   ├── openapi-interactions.json    # Interactions API spec
│   └── live-api-schema.json         # WebSocket schema (Live API)
└── pubspec.yaml
```

---

## File Path Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Models | `lib/src/models/{category}/{name}.dart` | `lib/src/models/tools/tool.dart` |
| Category Barrel | `lib/src/models/{category}/{category}.dart` | `lib/src/models/tools/tools.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` | `lib/src/resources/models_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` | `test/unit/models/tools/tool_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` | `test/integration/generation_test.dart` |
| Examples | `example/{name}_example.dart` | `example/generation_example.dart` |

---

## Naming Conventions

### Model Classes
- Class name: `PascalCase` (e.g., `GenerationConfig`)
- File name: `snake_case` (e.g., `generation_config.dart`)
- Match OpenAPI schema name exactly

### Enums
- Enum name: `PascalCase` (e.g., `HarmCategory`)
- Enum values: `camelCase` (e.g., `hateSpeech`)
- Wire format: `SCREAMING_SNAKE_CASE` (e.g., `HARM_CATEGORY_HATE_SPEECH`)
- Converter functions: `{enumName}FromString`, `{enumName}ToString`

### Resources
- Class name: `{Name}Resource` (e.g., `ModelsResource`)
- File name: `{name}_resource.dart` (e.g., `models_resource.dart`)
- Client accessor: `client.{names}` (e.g., `client.models`)

---

## API Resources

The following resources are exposed via `GoogleAIClient`:

| Resource | Accessor | Description |
|----------|----------|-------------|
| Models | `client.models` | Content generation, embeddings |
| Files | `client.files` | File upload and management |
| Cached Contents | `client.cachedContents` | Content caching |
| Tuned Models | `client.tunedModels` | Fine-tuned models |
| Corpora | `client.corpora` | Semantic retrieval corpora |
| File Search Stores | `client.fileSearchStores` | File search stores |
| Batches | `client.batches` | Batch processing |
| Interactions | `client.interactions` | Agent interactions (experimental) |

---

## Critical Models

These models are verified against the OpenAPI spec for property completeness:

| Model | File | Purpose |
|-------|------|---------|
| Tool | `lib/src/models/tools/tool.dart` | Tool definitions |
| Candidate | `lib/src/models/content/candidate.dart` | Generation candidates |
| Content | `lib/src/models/content/content.dart` | Message content |
| Part | `lib/src/models/content/part.dart` | Content parts |
| GenerationConfig | `lib/src/models/generation/generation_config.dart` | Generation parameters |
| ToolConfig | `lib/src/models/tools/tool_config.dart` | Tool configuration |
| GroundingMetadata | `lib/src/models/metadata/grounding_metadata.dart` | Grounding info |
| GroundingChunk | `lib/src/models/metadata/grounding_chunk.dart` | Grounding chunks |
| FunctionCall | `lib/src/models/tools/function_call.dart` | Function calls |
| FunctionResponse | `lib/src/models/tools/function_response.dart` | Function responses |

---

## Exception Types

googleai_dart uses the following exception hierarchy:

```dart
sealed class GoogleAIException implements Exception {
  String get message;
  StackTrace? get stackTrace;
  Exception? get cause;
}

class ApiException extends GoogleAIException {
  final int code;                      // HTTP status code
  final String message;
  final List<Object> details;          // Server error details
  final RequestMetadata? requestMetadata;
  final ResponseMetadata? responseMetadata;
  final Exception? cause;
}

class RateLimitException extends ApiException {
  final DateTime? retryAfter;
}

class TimeoutException extends GoogleAIException {
  final Duration timeout;
  final Duration elapsed;
}

class ValidationException extends GoogleAIException {
  final Map<String, List<String>> fieldErrors;
}

class AbortedException extends GoogleAIException {
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

# Integration tests (requires API key)
GEMINI_API_KEY=your_key dart test test/integration/

# All tests
dart test
```

### Test Tags

- `@Tags(['integration'])` - Requires real API key
- `@Tags(['live'])` - Live/WebSocket tests
- No tag - Unit tests (no network required)

---

## Verification Scripts

All verification scripts are in `.claude/shared/openapi-toolkit/scripts/` and require `--config-dir .claude/skills/openapi-toolkit-googleai-dart/config`:

```bash
# Verify barrel file exports
python3 .claude/shared/openapi-toolkit/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-toolkit-googleai-dart/config

# Verify README completeness
python3 .claude/shared/openapi-toolkit/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-toolkit-googleai-dart/config

# Verify model properties match spec
python3 .claude/shared/openapi-toolkit/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-toolkit-googleai-dart/config
```

---

## Related Documentation

- [Implementation Patterns](./implementation-patterns.md)
- [Review Checklist](./REVIEW_CHECKLIST.md)
- [OpenAPI Toolkit Skill](../SKILL.md)
