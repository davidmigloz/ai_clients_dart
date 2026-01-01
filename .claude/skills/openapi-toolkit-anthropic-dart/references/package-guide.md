# anthropic_sdk_dart Package Guide

## Package Configuration

| Setting | Value |
|---------|-------|
| Package Name | `anthropic_sdk_dart` |
| API | Anthropic API (Claude) |
| API Key Env Var | `ANTHROPIC_API_KEY` |
| Barrel File | `lib/anthropic_sdk_dart.dart` |
| Specs Directory | `specs/` |
| Base URL | `https://api.anthropic.com` |

## Directory Structure

```
lib/src/
├── auth/                    # Authentication providers
│   └── auth_provider.dart   # ApiKeyProvider, AuthCredentials
├── client/                  # Core client infrastructure
│   ├── anthropic_client.dart
│   ├── config.dart          # AnthropicConfig, RetryPolicy
│   ├── interceptor_chain.dart
│   ├── request_builder.dart
│   └── retry_wrapper.dart
├── errors/                  # Exception hierarchy
│   └── exceptions.dart      # AnthropicException, ApiException, etc.
├── extensions/              # DX convenience extensions
│   └── message_extensions.dart
├── interceptors/            # HTTP middleware
│   ├── auth_interceptor.dart
│   ├── error_interceptor.dart
│   └── logging_interceptor.dart
├── models/                  # Data models
│   ├── messages/            # Message, ContentBlock, etc.
│   ├── models/              # Model info
│   ├── batches/             # Batch processing
│   ├── tools/               # Tool use, function calling
│   ├── metadata/            # Usage, stop reasons
│   └── common/              # copy_with_sentinel.dart
├── resources/               # API resources
│   ├── base_resource.dart
│   ├── streaming_resource.dart
│   ├── messages_resource.dart
│   ├── message_batches_resource.dart
│   ├── models_resource.dart
│   ├── beta_resource.dart
│   ├── beta_messages_resource.dart
│   └── beta_files_resource.dart
└── utils/                   # Utilities
    ├── streaming_parser.dart  # SSE parsing
    └── request_id.dart        # Correlation IDs
```

## File Path Patterns

| Type | Pattern |
|------|---------|
| Models | `lib/src/models/{category}/{name}.dart` |
| Resources | `lib/src/resources/{name}_resource.dart` |
| Unit Tests | `test/unit/models/{category}/{name}_test.dart` |
| Integration Tests | `test/integration/{name}_test.dart` |
| Examples | `example/{name}_example.dart` |

## API Resources

| Resource | Path | Description |
|----------|------|-------------|
| `messages` | `/v1/messages` | Create messages |
| `messages.batches` | `/v1/messages/batches` | Batch message processing |
| `models` | `/v1/models` | List available models |
| `beta.files` | `/v1/files` | File uploads (beta) |
| `beta.messages` | `/v1/messages` | Beta message features |

## Required Headers

| Header | Value | Description |
|--------|-------|-------------|
| `x-api-key` | API key | Authentication |
| `anthropic-version` | `2023-06-01` | API version |
| `anthropic-beta` | Feature flags | Beta feature activation |
| `content-type` | `application/json` | Request body type |

## Exception Types

| Exception | HTTP Status | Description |
|-----------|-------------|-------------|
| `ApiException` | 4xx/5xx | General API error |
| `AuthenticationException` | 401 | Invalid API key |
| `RateLimitException` | 429 | Rate limit exceeded |
| `ValidationException` | 400 | Invalid request |
| `TimeoutException` | - | Request timeout |
| `AbortedException` | - | Request cancelled |

## Testing

### Unit Tests
- Model serialization round-trips
- Enum conversions with fallback values
- copyWith with sentinel pattern
- Equality and hash code

### Integration Tests
- Gated by `ANTHROPIC_API_KEY` environment variable
- Tagged with `@Tags(['integration'])`
- Test streaming, cancellation, error handling
