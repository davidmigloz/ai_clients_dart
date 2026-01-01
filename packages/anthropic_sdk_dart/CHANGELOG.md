# Changelog

## 1.0.0

> Note: This release has breaking changes.

**TL;DR**: Complete reimplementation with a new architecture, minimal dependencies, resource-based API, and improved developer experience. Hand-crafted models (no code generation), interceptor-driven architecture, comprehensive error handling, and full Anthropic API coverage.

### What's new

- **Resource-based API organization**:
  - `client.messages` — Message creation, streaming, token counting
  - `client.messages.batches` — Batch message processing
  - `client.models` — Model listing and retrieval
  - `client.files` — File upload/management (Beta)
  - `client.skills` — Custom skills management (Beta)
  - `client.completions` — Legacy text completions
- **Architecture**:
  - Interceptor chain (Auth → Logging → Error → Transport with Retry wrapper).
  - **Authentication**: API key or custom via `AuthProvider` interface.
  - **Retry** with exponential backoff + jitter (only for idempotent methods on 429, 5xx, timeouts).
  - **Abortable** requests via `abortTrigger` parameter.
  - **SSE** streaming parser for real-time responses.
  - Central `AnthropicConfig` (timeouts, retry policy, log level, baseUrl, auth).
- **Hand-crafted models**:
  - No code generation dependencies (no freezed, json_serializable).
  - Minimal runtime dependencies (`http`, `logging`, `meta` only).
  - Immutable models with `copyWith` using sentinel pattern.
  - Full type safety with sealed exception hierarchy.
- **Improved DX**:
  - Simplified message creation (e.g., `InputMessage.user()`, `InputMessage.assistant()`).
  - Explicit streaming methods (`createStream()` vs `create()`).
  - Response helpers (`.text`, `.hasToolUse`, `.toolUseBlocks`, `.thinkingBlock`).
  - Rich logging with field redaction for sensitive data.
- **Full API coverage**:
  - Messages with tool calling, vision, documents, and citations.
  - Extended thinking with budget control.
  - Built-in tools (web search, bash, text editor, computer use, code execution, MCP).
  - Message batches with JSONL results streaming.
  - Files and Skills APIs (Beta).

### Breaking Changes

- **Resource-based API**: Methods reorganized under strongly-typed resources:
  - `client.createMessage()` → `client.messages.create()`
  - `client.createMessageStream()` → `client.messages.createStream()`
  - `client.countMessageTokens()` → `client.messages.countTokens()`
  - `client.createMessageBatch()` → `client.messages.batches.create()`
  - `client.listMessageBatches()` → `client.messages.batches.list()`
  - `client.listModels()` → `client.models.list()`
  - `client.retrieveModel()` → `client.models.retrieve()`
- **Model class renames**:
  - `CreateMessageRequest` → `MessageCreateRequest`
  - `Message` → `InputMessage`
  - `MessageContent.text()` → `InputMessage.user()` / `InputMessage.assistant()`
  - `Block.text()` → `TextInputBlock`
  - `Block.image()` → `ImageInputBlock`
  - `Block.toolResult()` → `InputContentBlock.toolResult()`
  - `Model.model(Models.xxx)` → String model ID (e.g., `'claude-sonnet-4-20250514'`)
- **Configuration**: New `AnthropicConfig` with `AuthProvider` pattern:
  - `AnthropicClient(apiKey: 'KEY')` → `AnthropicClient(config: AnthropicConfig(authProvider: ApiKeyProvider('KEY')))`
  - Or use `AnthropicClient.fromEnvironment()` to read `ANTHROPIC_API_KEY`.
- **Exceptions**: Replaced `AnthropicClientException` with typed hierarchy:
  - `ApiException`, `AuthenticationException`, `RateLimitException`, `ValidationException`, `TimeoutException`, `AbortedException`.
- **Streaming**: Pattern matching replaces `.map()` callbacks:
  - `event.map(contentBlockDelta: (e) => ...)` → `if (event is ContentBlockDeltaEvent) ...`
- **Session cleanup**: `endSession()` → `close()`.
- **Dependencies**: Removed `freezed`, `json_serializable`; now minimal (`http`, `logging`, `meta`).

See **[MIGRATION.md](MIGRATION.md)** for step-by-step examples and mapping tables.
