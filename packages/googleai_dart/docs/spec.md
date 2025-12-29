# googleai_dart Specification

This specification extends [spec-core.md](../../../docs/spec-core.md) with `googleai_dart`-specific details.

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

---

## Directory Structure

```
lib/src/
├── models/
│   ├── batch/           # Batch processing
│   ├── caching/         # Cached contents
│   ├── content/         # Content, Parts, Candidates
│   ├── corpus/          # Corpus, Documents
│   ├── embeddings/      # Embeddings
│   ├── files/           # File handling
│   ├── generation/      # Generation config
│   ├── live/            # Live API models
│   ├── metadata/        # Grounding, Citations
│   ├── models/          # Model info
│   ├── permissions/     # Permissions
│   ├── safety/          # Safety settings
│   ├── tools/           # Tools, Functions
│   └── copy_with_sentinel.dart
├── resources/           # API resources
└── client/              # Client configuration
```

---

## File Path Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Models | `lib/src/models/{category}/{name}.dart` | `lib/src/models/tools/tool.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` | `lib/src/resources/models_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` | `test/unit/models/tools/tool_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` | `test/integration/generation_test.dart` |
| Examples | `example/{name}_example.dart` | `example/generation_example.dart` |

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

All verification scripts are in `.claude/shared/openapi-updater/scripts/` and require `--config-dir .claude/skills/openapi-updater-googleai/config`:

```bash
# Verify barrel file exports
python3 .claude/shared/openapi-updater/scripts/verify_exports.py \
  --config-dir .claude/skills/openapi-updater-googleai/config

# Verify README completeness
python3 .claude/shared/openapi-updater/scripts/verify_readme.py \
  --config-dir .claude/skills/openapi-updater-googleai/config

# Verify model properties match spec
python3 .claude/shared/openapi-updater/scripts/verify_model_properties.py \
  --config-dir .claude/skills/openapi-updater-googleai/config
```

---

## Related Documentation

- [Implementation Patterns](../../../.claude/skills/openapi-updater-googleai/references/implementation-patterns.md)
- [Review Checklist](../../../.claude/skills/openapi-updater-googleai/references/REVIEW_CHECKLIST.md)
- [OpenAPI Updater Skill](../../../.claude/skills/openapi-updater-googleai/SKILL.md)
