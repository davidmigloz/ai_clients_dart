# Review Checklist (openai_dart)


## Contents

- [API-Specific Checks](#api-specific-checks)
  - [Authentication](#authentication)
  - [Chat Completions](#chat-completions)
  - [Assistants API (Beta)](#assistants-api-beta)
  - [File Operations](#file-operations)
  - [Audio](#audio)
  - [Images](#images)
  - [Realtime API](#realtime-api)
  - [Error Handling](#error-handling)
  - [Rate Limiting](#rate-limiting)
- [Model Verification](#model-verification)
  - [Critical Models](#critical-models)
  - [Streaming Models](#streaming-models)
  - [Tool Models](#tool-models)
- [Integration Test Coverage](#integration-test-coverage)
  - [Required Tests](#required-tests)
  - [Edge Cases](#edge-cases)
- [Documentation](#documentation)
  - [README Sections](#readme-sections)
  - [Example Files](#example-files)
  - [Migration Guide](#migration-guide)

Extends [REVIEW_CHECKLIST_CORE.md](../../../shared/openapi-toolkit/references/REVIEW_CHECKLIST_CORE.md).

## API-Specific Checks

### Authentication
- [ ] Bearer token authentication works correctly
- [ ] Organization header (`OpenAI-Organization`) is sent when configured
- [ ] Project header (`OpenAI-Project`) is sent when configured
- [ ] Azure authentication uses `api-key` header instead of Bearer
- [ ] API key is never logged or exposed in error messages

### Chat Completions
- [ ] All message roles supported (system, user, assistant, tool, developer)
- [ ] Multimodal content works (text, images, audio)
- [ ] Tool calling flow works correctly
- [ ] Streaming returns proper `ChatStreamEvent` objects
- [ ] `[DONE]` sentinel is handled correctly in streams
- [ ] Response format options work (text, json_object, json_schema)
- [ ] All model parameters are correctly serialized

### Assistants API (Beta)
- [ ] Beta headers are included (`OpenAI-Beta: assistants=v2`)
- [ ] Thread lifecycle works (create, retrieve, update, delete)
- [ ] Message management works correctly
- [ ] Run streaming events are properly typed
- [ ] Tool outputs can be submitted
- [ ] Vector store integration works

### File Operations
- [ ] File upload with multipart/form-data works
- [ ] File purpose is validated
- [ ] Large file uploads use the Uploads API
- [ ] File content retrieval works

### Audio
- [ ] Speech synthesis returns audio bytes
- [ ] Transcription handles file uploads
- [ ] Translation handles file uploads
- [ ] Audio formats are correctly specified

### Images
- [ ] Image generation returns proper URLs or base64
- [ ] Image editing handles mask uploads
- [ ] Image variations work correctly

### Realtime API
- [ ] WebSocket connection establishes correctly
- [ ] Authentication is sent on connect
- [ ] Audio streaming works bidirectionally
- [ ] Session configuration updates work
- [ ] All event types are properly handled
- [ ] Connection cleanup on close

### Error Handling
- [ ] 400 → `BadRequestException`
- [ ] 401 → `AuthenticationException`
- [ ] 403 → `PermissionDeniedException`
- [ ] 404 → `NotFoundException`
- [ ] 422 → `UnprocessableEntityException`
- [ ] 429 → `RateLimitException` with `retryAfter`
- [ ] 500+ → `InternalServerException`
- [ ] Error response body is parsed correctly
- [ ] `error.type`, `error.code`, `error.param` are captured

### Rate Limiting
- [ ] `Retry-After` header is parsed
- [ ] Exponential backoff is implemented
- [ ] Maximum retries are respected
- [ ] Only idempotent requests are retried

## Model Verification

### Critical Models
- [ ] `ChatCompletionCreateRequest` has all spec properties
- [ ] `ChatCompletion` has all spec properties
- [ ] `ChatMessage` sealed class covers all roles
- [ ] `ContentPart` sealed class covers all types
- [ ] `EmbeddingRequest` and `EmbeddingResponse` complete
- [ ] `Assistant`, `Thread`, `Run` models complete

### Streaming Models
- [ ] `ChatStreamEvent` properly typed
- [ ] Delta objects correctly merge
- [ ] Usage information in final chunk

### Tool Models
- [ ] `Tool` with function definition
- [ ] `ToolChoice` with all options
- [ ] `ToolCall` with function details
- [ ] JSON Schema parameters work

## Integration Test Coverage

### Required Tests
- [ ] Chat completion (non-streaming)
- [ ] Chat completion (streaming)
- [ ] Chat with tools
- [ ] Chat with images
- [ ] Embeddings creation
- [ ] Audio transcription
- [ ] Audio speech synthesis
- [ ] Image generation
- [ ] File upload and retrieval
- [ ] Model listing
- [ ] Moderation check
- [ ] Assistant CRUD operations
- [ ] Thread and message operations
- [ ] Run execution with streaming

### Edge Cases
- [ ] Empty messages array rejected
- [ ] Invalid model name error
- [ ] Rate limit handling
- [ ] Network timeout handling
- [ ] Large response handling
- [ ] Unicode content handling

## Documentation

### README Sections
- [ ] Installation instructions
- [ ] Authentication setup
- [ ] Quick start example
- [ ] Chat completions example
- [ ] Streaming example
- [ ] Tool calling example
- [ ] Image generation example
- [ ] Audio examples
- [ ] Assistants API example
- [ ] Error handling guide
- [ ] Azure OpenAI configuration
- [ ] API reference link

### Example Files
- [ ] `chat_example.dart` - Basic chat
- [ ] `streaming_example.dart` - Streaming responses
- [ ] `tools_example.dart` - Function calling
- [ ] `vision_example.dart` - Image input
- [ ] `embeddings_example.dart` - Embeddings
- [ ] `audio_example.dart` - Speech and transcription
- [ ] `images_example.dart` - DALL-E
- [ ] `assistants_example.dart` - Assistants API
- [ ] `files_example.dart` - File operations
- [ ] `realtime_example.dart` - Real-time API

### Migration Guide
- [ ] Breaking changes listed
- [ ] Before/after code examples
- [ ] Model name changes documented
- [ ] Removed features noted
- [ ] New features highlighted
