# Migration Guide

This guide helps you migrate from the old `ollama_dart` client (v0.x) to the new **v1.0.0** (complete rewrite with resource-based organization and improved architecture).

## Overview of Changes

The new client mirrors the Ollama REST API structure with **resource-based APIs**. Instead of calling methods directly on the client, you now use resource objects:

* `client.chat` — Chat completions (multi-turn conversations)
* `client.completions` — Text generation (single-turn)
* `client.embeddings` — Generate text embeddings
* `client.models` — Model management (list, show, pull, push, copy, delete, ps)
* `client.version` — Server version info

**Key improvements:**
- Hand-crafted models (no code generation dependencies)
- Minimal dependencies (`http`, `logging` only)
- Interceptor-driven architecture
- Comprehensive error handling with typed exceptions
- Automatic retry with exponential backoff
- Auth providers for remote Ollama instances

## Quick Reference Table

| Operation | Old API (v0.x) | New API (v1.0.0) |
|-----------|----------------|------------------|
| **Initialize Client** | `OllamaClient(baseUrl: ...)` | `OllamaClient(config: OllamaConfig(...))` |
| **Chat** | `client.generateChatCompletion(request)` | `client.chat.create(request: ...)` |
| **Chat Stream** | `client.generateChatCompletionStream(request)` | `client.chat.createStream(request: ...)` |
| **Generate** | `client.generateCompletion(request)` | `client.completions.generate(request: ...)` |
| **Generate Stream** | `client.generateCompletionStream(request)` | `client.completions.generateStream(request: ...)` |
| **Embeddings** | `client.generateEmbedding(request)` | `client.embeddings.create(request: ...)` |
| **List Models** | `client.listModels()` | `client.models.list()` |
| **Show Model** | `client.showModelInfo(request)` | `client.models.show(request: ...)` |
| **Running Models** | `client.listRunningModels()` | `client.models.ps()` |
| **Pull Model** | `client.pullModel(request)` | `client.models.pull(request: ...)` |
| **Pull Stream** | `client.pullModelStream(request)` | `client.models.pullStream(request: ...)` |
| **Push Model** | `client.pushModel(request)` | `client.models.push(request: ...)` |
| **Push Stream** | `client.pushModelStream(request)` | `client.models.pushStream(request: ...)` |
| **Copy Model** | `client.copyModel(request)` | `client.models.copy(request: ...)` |
| **Delete Model** | `client.deleteModel(request)` | `client.models.delete(request: ...)` |
| **Create Model** | `client.createModel(request)` | `client.models.create(request: ...)` |
| **Create Stream** | `client.createModelStream(request)` | `client.models.createStream(request: ...)` |
| **Version** | `client.getVersion()` | `client.version.get()` |

## 1) Client Initialization

```dart
import 'package:ollama_dart/ollama_dart.dart';

// Before (v0.x)
final old = OllamaClient(
  baseUrl: 'http://localhost:11434/api',
  headers: {'Authorization': 'Bearer token'},
);

// After (v1.0.0)
final client = OllamaClient(
  config: OllamaConfig(
    baseUrl: 'http://localhost:11434',
    authProvider: BearerTokenProvider('token'),
  ),
);
```

### Advanced Configuration

```dart
final client = OllamaClient(
  config: OllamaConfig(
    baseUrl: 'http://localhost:11434',
    authProvider: BearerTokenProvider('token'),
    timeout: Duration(minutes: 5),
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
    defaultHeaders: {'X-Custom-Header': 'value'},
  ),
);
```

## 2) Chat Completions

```dart
import 'package:ollama_dart/ollama_dart.dart';

// Before (v0.x)
final r1 = await old.generateChatCompletion(
  request: GenerateChatCompletionRequest(
    model: 'llama3.1',
    messages: [
      Message(role: MessageRole.user, content: 'Hello!'),
    ],
  ),
);
print(r1.message?.content);

// After (v1.0.0)
final r2 = await client.chat.create(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [
      ChatMessage.user('Hello!'),
    ],
  ),
);
print(r2.message?.content);
```

**Key changes:**
* Access under `client.chat`
* `GenerateChatCompletionRequest` → `ChatRequest`
* `Message` → `ChatMessage`
* Named constructors: `ChatMessage.user()`, `ChatMessage.system()`, `ChatMessage.assistant()`, `ChatMessage.tool()`

### Multi-turn Conversation

```dart
// Before (v0.x)
final old = await client.generateChatCompletion(
  request: GenerateChatCompletionRequest(
    model: 'llama3.1',
    messages: [
      Message(role: MessageRole.system, content: 'You are a helpful assistant.'),
      Message(role: MessageRole.user, content: 'What is 2+2?'),
      Message(role: MessageRole.assistant, content: '4'),
      Message(role: MessageRole.user, content: 'And 3+3?'),
    ],
  ),
);

// After (v1.0.0)
final response = await client.chat.create(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is 2+2?'),
      ChatMessage.assistant('4'),
      ChatMessage.user('And 3+3?'),
    ],
  ),
);
```

## 3) Streaming

```dart
// Before (v0.x)
await for (final chunk in old.generateChatCompletionStream(
  request: GenerateChatCompletionRequest(
    model: 'llama3.1',
    messages: [Message(role: MessageRole.user, content: 'Hello!')],
  ),
)) {
  print(chunk.message?.content);
}

// After (v1.0.0)
await for (final chunk in client.chat.createStream(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [ChatMessage.user('Hello!')],
  ),
)) {
  print(chunk.message?.content);
}
```

## 4) Text Generation (Completions)

```dart
// Before (v0.x)
final r1 = await old.generateCompletion(
  request: GenerateCompletionRequest(
    model: 'llama3.1',
    prompt: 'Complete this: The capital of France is',
  ),
);
print(r1.response);

// After (v1.0.0)
final r2 = await client.completions.generate(
  request: GenerateRequest(
    model: 'llama3.1',
    prompt: 'Complete this: The capital of France is',
  ),
);
print(r2.response);
```

**Key changes:**
* Access under `client.completions`
* `GenerateCompletionRequest` → `GenerateRequest`
* `GenerateCompletionResponse` → `GenerateResponse`

### Streaming Text Generation

```dart
// Before (v0.x)
await for (final chunk in old.generateCompletionStream(
  request: GenerateCompletionRequest(model: 'llama3.1', prompt: 'Hello'),
)) { /* ... */ }

// After (v1.0.0)
await for (final chunk in client.completions.generateStream(
  request: GenerateRequest(model: 'llama3.1', prompt: 'Hello'),
)) { /* ... */ }
```

## 5) Embeddings

```dart
// Before (v0.x)
final e1 = await old.generateEmbedding(
  request: GenerateEmbeddingRequest(
    model: 'nomic-embed-text',
    prompt: 'Hello, world!',
  ),
);
print(e1.embedding);

// After (v1.0.0)
final e2 = await client.embeddings.create(
  request: EmbedRequest(
    model: 'nomic-embed-text',
    input: 'Hello, world!',
  ),
);
print(e2.embeddings);
```

**Key changes:**
* Access under `client.embeddings`
* `GenerateEmbeddingRequest` → `EmbedRequest`
* `prompt` → `input` (supports both string and list of strings)
* Response: `embedding` → `embeddings` (list)

## 6) Model Management

### List Models

```dart
// Before (v0.x)
final models = await old.listModels();

// After (v1.0.0)
final models = await client.models.list();
```

### Show Model Details

```dart
// Before (v0.x)
final info = await old.showModelInfo(
  request: ModelInfoRequest(name: 'llama3.1'),
);

// After (v1.0.0)
final info = await client.models.show(
  request: ShowRequest(model: 'llama3.1'),
);
```

**Key changes:**
* `ModelInfoRequest` → `ShowRequest`
* `name` → `model`

### Running Models

```dart
// Before (v0.x)
final running = await old.listRunningModels();

// After (v1.0.0)
final running = await client.models.ps();
```

### Pull Model with Progress

```dart
// Before (v0.x)
await for (final status in old.pullModelStream(
  request: PullModelRequest(name: 'llama3.1'),
)) {
  print('${status.status}: ${status.completed}/${status.total}');
}

// After (v1.0.0)
await for (final status in client.models.pullStream(
  request: PullRequest(model: 'llama3.1'),
)) {
  print('${status.status}: ${status.completed}/${status.total}');
}
```

**Key changes:**
* `PullModelRequest` → `PullRequest`
* `name` → `model`

### Copy Model

```dart
// Before (v0.x)
await old.copyModel(
  request: CopyModelRequest(source: 'llama3.1', destination: 'my-llama'),
);

// After (v1.0.0)
await client.models.copy(
  request: CopyRequest(source: 'llama3.1', destination: 'my-llama'),
);
```

### Delete Model

```dart
// Before (v0.x)
await old.deleteModel(
  request: DeleteModelRequest(name: 'my-llama'),
);

// After (v1.0.0)
await client.models.delete(
  request: DeleteRequest(model: 'my-llama'),
);
```

## 7) Tool Calling

```dart
// Before (v0.x)
final response = await old.generateChatCompletion(
  request: GenerateChatCompletionRequest(
    model: 'llama3.1',
    messages: [Message(role: MessageRole.user, content: 'What is the weather?')],
    tools: [
      Tool(
        type: ToolType.function,
        function: ToolFunction(
          name: 'get_weather',
          description: 'Get weather for a location',
          parameters: { /* ... */ },
        ),
      ),
    ],
  ),
);

// After (v1.0.0)
final response = await client.chat.create(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [ChatMessage.user('What is the weather?')],
    tools: [
      ToolDefinition(
        type: ToolType.function,
        function: ToolFunction(
          name: 'get_weather',
          description: 'Get weather for a location',
          parameters: { /* ... */ },
        ),
      ),
    ],
  ),
);

// Handle tool calls
if (response.message?.toolCalls != null) {
  for (final toolCall in response.message!.toolCalls!) {
    print('Tool: ${toolCall.function?.name}');
    print('Args: ${toolCall.function?.arguments}');
  }
}
```

**Key changes:**
* `Tool` → `ToolDefinition`

## 8) Exception Handling

```dart
// Before (v0.x)
try {
  await old.generateChatCompletion(/* ... */);
} on OllamaClientException catch (e) {
  print('Error: ${e.message}');
}

// After (v1.0.0)
try {
  await client.chat.create(/* ... */);
} on RateLimitException catch (e) {
  // 429 with retry-after
  print('Rate limited, retry after: ${e.retryAfter}');
} on ValidationException catch (e) {
  // Client-side validation error
  print('Validation error: ${e.message}');
} on ApiException catch (e) {
  // Server error with request/response metadata
  print('API error: ${e.message}, status: ${e.statusCode}');
} on TimeoutException catch (e) {
  // Request timed out
  print('Timeout: ${e.message}');
} on AbortedException catch (e) {
  // Request canceled
  print('Aborted at stage: ${e.stage}');
} on OllamaException catch (e) {
  // Base exception class
  print('Error: ${e.message}');
}
```

**Key changes:**
* `OllamaClientException` → Typed exception hierarchy under `OllamaException`
* New exception types: `RateLimitException`, `ValidationException`, `ApiException`, `TimeoutException`, `AbortedException`

## 9) Server Version

```dart
// Before (v0.x)
final version = await old.getVersion();
print(version.version);

// After (v1.0.0)
final version = await client.version.get();
print(version.version);
```

## 10) New Features in v1.0.0

### Thinking Mode

```dart
final response = await client.chat.create(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [ChatMessage.user('What is 15 * 7?')],
    think: true,
  ),
);
print('Thinking: ${response.thinking}');
print('Answer: ${response.message?.content}');
```

### Log Probabilities

```dart
final response = await client.chat.create(
  request: ChatRequest(
    model: 'llama3.1',
    messages: [ChatMessage.user('Hello!')],
    logprobs: true,
    topLogprobs: 5,
  ),
);
print('Logprobs: ${response.logprobs}');
```

### Retry Policy with Exponential Backoff

```dart
final client = OllamaClient(
  config: OllamaConfig(
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
      maxDelay: Duration(seconds: 30),
      backoffMultiplier: 2.0,
    ),
  ),
);
```

### Auth Providers for Remote Instances

```dart
// Bearer token auth
final client = OllamaClient(
  config: OllamaConfig(
    baseUrl: 'https://my-ollama-server.example.com',
    authProvider: BearerTokenProvider('YOUR_TOKEN'),
  ),
);

// Custom auth provider
class CustomAuthProvider implements AuthProvider {
  @override
  Future<Map<String, String>> getHeaders() async {
    return {'X-Custom-Auth': 'my-token'};
  }
}
```

## Model Class Renames

| Old Class (v0.x) | New Class (v1.0.0) |
|------------------|-------------------|
| `GenerateChatCompletionRequest` | `ChatRequest` |
| `GenerateChatCompletionResponse` | `ChatResponse` |
| `GenerateCompletionRequest` | `GenerateRequest` |
| `GenerateCompletionResponse` | `GenerateResponse` |
| `GenerateEmbeddingRequest` | `EmbedRequest` |
| `GenerateEmbeddingResponse` | `EmbedResponse` |
| `Message` | `ChatMessage` |
| `MessageRole` | `MessageRole` (same) |
| `ModelInfoRequest` | `ShowRequest` |
| `ModelInfo` | `ShowResponse` |
| `ModelsResponse` | `ListResponse` |
| `ProcessResponse` | `PsResponse` |
| `PullModelRequest` | `PullRequest` |
| `PullModelResponse` | `PullResponse` |
| `PushModelRequest` | `PushRequest` |
| `PushModelResponse` | `PushResponse` |
| `CopyModelRequest` | `CopyRequest` |
| `DeleteModelRequest` | `DeleteRequest` |
| `CreateModelRequest` | `CreateRequest` |
| `CreateModelResponse` | `CreateResponse` |
| `Tool` | `ToolDefinition` |
| `RequestOptions` | `ModelOptions` |

## Common Pitfalls

1. **Resource-based access**: Methods are now accessed through resources (`client.chat.create()` not `client.generateChatCompletion()`).

2. **Request class names**: All request classes have been shortened (e.g., `GenerateChatCompletionRequest` → `ChatRequest`).

3. **Named parameters**: Many methods now use named parameters for requests (e.g., `request: ChatRequest(...)` instead of positional).

4. **Message constructors**: Use named constructors like `ChatMessage.user('text')` instead of `Message(role: MessageRole.user, content: 'text')`.

5. **Embedding input**: The `input` parameter in `EmbedRequest` accepts both a single string and a list of strings.

6. **Base URL**: No longer needs `/api` suffix - just use `http://localhost:11434`.

## Getting Help

* Browse the [examples](example/)
* Check the [API docs](https://pub.dev/documentation/ollama_dart/latest/)
* Open an issue: [https://github.com/davidmigloz/ai_clients_dart/issues](https://github.com/davidmigloz/ai_clients_dart/issues)

---

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).
