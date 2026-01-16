# Changelog

## 0.0.1

Initial release of the OpenResponses Dart client.

### Features

- **Core Client**: `OpenResponsesClient` with configurable base URL and authentication
- **Response Creation**: `responses.create()` for non-streaming requests
- **Streaming**: `responses.createStream()` and `responses.stream()` with builder pattern
- **Multi-provider Support**: Works with OpenAI, Ollama, Hugging Face, OpenRouter, and LM Studio

### Request Features

- String or message item list input
- System instructions via `instructions` parameter
- Multi-turn conversations with `previousResponseId`
- Temperature and max output tokens control
- Service tier selection

### Tools

- `FunctionTool`: Define custom functions with JSON Schema parameters
- `McpTool`: Remote Model Context Protocol server tools
- Tool choice configuration (auto, required, specific function)

### Structured Output

- `TextConfig` with format options
- `JsonSchemaFormat` for structured JSON responses with strict mode
- `TextResponseFormat` and `JsonObjectFormat`

### Reasoning Models

- `ReasoningConfig` with effort levels (low, medium, high)
- Reasoning summary modes (concise, detailed, auto)
- Access to reasoning items via `response.reasoningItems`

### Streaming Events

- Full SSE event parsing with 25+ event types
- Response lifecycle events (created, queued, in_progress, completed, failed)
- Output item and content part events
- Text delta and done events
- Function call argument streaming
- Reasoning delta and summary events
- Error events

### Content Types

- `InputTextContent`: Text input
- `InputImageContent`: Image URLs with detail level
- `InputFileContent`: File references
- `OutputTextContent`: Text output with annotations
- `RefusalContent`: Model refusal messages

### Message Items

- `MessageItem` with role (user, assistant, system, developer)
- Convenience factories: `userText()`, `systemText()`, `assistantText()`
- `FunctionCallItem` and `FunctionCallOutputItem`
- `ItemReference` for referencing previous items

### DX Extensions

- `response.outputText`: Concatenated text from output
- `response.functionCalls`: All function call items
- `response.reasoningItems`: All reasoning items
- `response.hasToolCalls`, `response.isCompleted`, `response.isFailed`
- `event.textDelta`, `event.isFinal`
- `stream.text`, `stream.finalResponse`

### Error Handling

- `OpenResponsesException` sealed class hierarchy
- `ApiException` with error code and details
- `AuthenticationException` for auth failures
- `RateLimitException` with retry-after duration
- `ValidationException` for invalid requests
- `TimeoutException` and `AbortedException`

### Authentication

- `BearerTokenProvider` for API key authentication
- `NoAuthProvider` for local providers (Ollama, LM Studio)
- Extensible `AuthProvider` interface

### Configuration

- `OpenResponsesConfig` with base URL, auth, headers, timeout
- `RetryPolicy` with exponential backoff and jitter
- Custom HTTP client support
