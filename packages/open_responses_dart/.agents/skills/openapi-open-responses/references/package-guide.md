# open_responses_dart Package Guide


## Contents

- [Package Configuration](#package-configuration)
- [Directory Structure](#directory-structure)
- [File Path Patterns](#file-path-patterns)
- [API Resources](#api-resources)
- [Required Headers](#required-headers)
- [Exception Types](#exception-types)
- [Critical Models](#critical-models)
- [Testing](#testing)
  - [Running Tests](#running-tests)
  - [Test Tags](#test-tags)

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `open_responses_dart` |
| API | OpenResponses unified LLM API |
| API Key Env Var | `OPENAI_API_KEY` (for OpenAI provider) |
| Barrel File | `lib/open_responses_dart.dart` |
| Models Directory | `lib/src/models` |
| Resources Directory | `lib/src/resources` |
| Tests Directory | `test/unit/models` |
| Examples Directory | `example` |
| Specs Directory | `specs/` |

## Directory Structure

```
packages/open_responses_dart/
├── lib/
│   ├── open_responses_dart.dart          # Main barrel file
│   └── src/
│       ├── auth/                         # Authentication providers
│       │   └── auth_provider.dart
│       ├── client/                       # Core client infrastructure
│       │   ├── config.dart
│       │   ├── open_responses_client.dart
│       │   ├── interceptor_chain.dart
│       │   ├── request_builder.dart
│       │   ├── response_stream.dart
│       │   └── retry_wrapper.dart
│       ├── errors/                       # Exception hierarchy
│       │   └── exceptions.dart
│       ├── extensions/                   # DX convenience extensions
│       │   ├── response_extensions.dart
│       │   └── streaming_extensions.dart
│       ├── interceptors/                 # HTTP middleware
│       │   ├── auth_interceptor.dart
│       │   ├── error_interceptor.dart
│       │   └── logging_interceptor.dart
│       ├── models/                       # Data models
│       │   ├── common/                   # copy_with_sentinel.dart
│       │   ├── content/                  # InputContent, OutputContent, Annotation, Logprob
│       │   ├── items/                    # Item (sealed), OutputItem (sealed)
│       │   ├── metadata/                 # Enums (10 files)
│       │   ├── request/                  # CreateResponseRequest, ReasoningConfig, TextConfig
│       │   ├── response/                 # ResponseResource, Usage, ErrorPayload
│       │   ├── streaming/                # StreamingEvent (sealed, 20+ types)
│       │   └── tools/                    # Tool (sealed), ToolChoice
│       ├── resources/                    # API resources
│       │   └── responses_resource.dart
│       └── utils/                        # Utilities
│           ├── request_id.dart
│           └── sse_parser.dart
├── test/
│   ├── fixtures/                         # Test data
│   ├── integration/                      # Provider integration tests
│   ├── mocks/                            # Mock HTTP client
│   └── unit/                             # Unit tests
│       ├── extensions/
│       ├── models/
│       └── resources/
├── example/                              # Example files
├── specs/                                # OpenAPI specifications
│   └── openapi.json
└── pubspec.yaml
```

## File Path Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Models | `lib/src/models/{category}/{name}.dart` | `lib/src/models/tools/tool.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` | `lib/src/resources/responses_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` | `test/unit/models/streaming/streaming_event_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` | `test/integration/openai_responses_test.dart` |
| Examples | `example/{name}_example.dart` | `example/responses_example.dart` |

## API Resources

| Resource | Accessor | Path | Description |
|----------|----------|------|-------------|
| `responses` | `client.responses` | `POST /responses` | Create responses (streaming and non-streaming) |

## Required Headers

| Header | Value | Description |
|--------|-------|-------------|
| `Authorization` | `Bearer {api_key}` | Authentication (provider-specific) |
| `Content-Type` | `application/json` | Request body type |

## Exception Types

| Exception | HTTP Status | Description |
|-----------|-------------|-------------|
| `ApiException` | 4xx/5xx | General API error |
| `AuthenticationException` | 401 | Invalid API key |
| `RateLimitException` | 429 | Rate limit exceeded |
| `ValidationException` | 400 | Invalid request |
| `TimeoutException` | - | Request timeout |
| `AbortedException` | - | Request cancelled |

## Critical Models

| Model | File | Purpose |
|-------|------|---------|
| ResponseResource | `lib/src/models/response/response_resource.dart` | Main response object |
| CreateResponseRequest | `lib/src/models/request/create_response_request.dart` | Main request object |
| Item | `lib/src/models/items/item.dart` | Input item types (sealed) |
| OutputItem | `lib/src/models/items/output_item.dart` | Output item types (sealed) |
| Tool | `lib/src/models/tools/tool.dart` | Tool definitions (sealed) |
| StreamingEvent | `lib/src/models/streaming/streaming_event.dart` | SSE events (sealed, 20+ types) |
| InputContent | `lib/src/models/content/input_content.dart` | Input content types (sealed) |
| OutputContent | `lib/src/models/content/output_content.dart` | Output content types (sealed) |

## Testing

### Running Tests

```bash
# Unit tests only
mcp__dart__run_tests(roots: [{root: "file:///path/to/packages/open_responses_dart", paths: ["test/unit"]}])

# Integration tests (requires API key)
OPENAI_API_KEY=your_key dart test test/integration/

# All tests
mcp__dart__run_tests()
```

### Test Tags

- `@Tags(['integration'])` - Requires real API key
- No tag - Unit tests (no network required)
