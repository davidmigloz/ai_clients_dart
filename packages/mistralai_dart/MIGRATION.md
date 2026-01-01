# Migration Guide

This guide helps you migrate from the old `mistralai_dart` client (v0.x) to the new **v1.0.0** (complete rewrite with resource-based organization and comprehensive API coverage).

## Overview of Changes

The new client mirrors the official REST structure with **resource-based APIs**. Instead of calling methods directly on the client, you now use resource objects:

* `client.chat` — Chat completions with streaming support
* `client.embeddings` — Text embeddings generation
* `client.models` — Model listing and management
* `client.files` — File upload and management
* `client.fim` — Fill-in-the-Middle code completions (Codestral)
* `client.fineTuning` — Fine-tuning job management
* `client.batch` — Batch job processing
* `client.ocr` — OCR text extraction
* `client.audio` — Audio transcription
* `client.classifications` — Text classification
* `client.moderations` — Content moderation
* `client.agents` — AI agents (Beta)
* `client.conversations` — Conversations (Beta)
* `client.libraries` — Document libraries for RAG (Beta)

## Quick Reference Table

| Operation | Old API (v0.x) | New API (v1.0.0) |
| --- | --- | --- |
| **Initialize Client** | `MistralAIClient(apiKey: 'KEY')` | `MistralClient.withApiKey('KEY')` |
| **Chat Completion** | `client.createChatCompletion(request: ...)` | `client.chat.create(request: ...)` |
| **Chat Stream** | `client.createChatCompletionStream(request: ...)` | `client.chat.createStream(request: ...)` |
| **Create Embedding** | `client.createEmbedding(request: ...)` | `client.embeddings.create(request: ...)` |
| **List Models** | `client.listModels()` | `client.models.list()` |
| **Close Client** | `client.endSession()` | `client.close()` |
| **User Message** | `ChatCompletionMessage(role: ChatCompletionMessageRole.user, content: 'text')` | `ChatMessage.user('text')` |
| **System Message** | `ChatCompletionMessage(role: ChatCompletionMessageRole.system, content: 'text')` | `ChatMessage.system('text')` |
| **Model Identifier** | `ChatCompletionModel.model(ChatCompletionModels.mistralSmallLatest)` | `'mistral-small-latest'` (string) |
| **Embedding Model** | `EmbeddingModel.model(EmbeddingModels.mistralEmbed)` | `'mistral-embed'` (string) |

## 1) Client Initialization

```dart
import 'package:mistralai_dart/mistralai_dart.dart';

// Before (v0.x)
final old = MistralAIClient(apiKey: 'YOUR_API_KEY');

// After (v1.0.0) - Simple
final client = MistralClient.withApiKey('YOUR_API_KEY');

// After (v1.0.0) - Full configuration
final client = MistralClient(
  config: MistralConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.mistral.ai', // optional
    timeout: Duration(seconds: 60),    // optional
    retryPolicy: RetryPolicy(maxRetries: 3), // optional
  ),
);
```

### Custom Base URL

```dart
// Before
final client = MistralAIClient(
  apiKey: 'YOUR_API_KEY',
  baseUrl: 'https://my-proxy.com',
);

// After
final client = MistralClient.withBaseUrl(
  apiKey: 'YOUR_API_KEY',
  baseUrl: 'https://my-proxy.com',
);
```

### Closing the Client

```dart
// Before
client.endSession();

// After
client.close();
```

## 2) Chat Completions

```dart
// Before
final response = await client.createChatCompletion(
  request: ChatCompletionRequest(
    model: ChatCompletionModel.model(ChatCompletionModels.mistralSmallLatest),
    messages: const [
      ChatCompletionMessage(
        role: ChatCompletionMessageRole.system,
        content: 'You are a helpful assistant.',
      ),
      ChatCompletionMessage(
        role: ChatCompletionMessageRole.user,
        content: 'Hello!',
      ),
    ],
  ),
);
final text = response.choices.first.message.content;

// After
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('Hello!'),
    ],
  ),
);
final text = response.text; // Convenience extension
```

**Key changes:**

* Access under `client.chat`
* Model is now a plain string instead of `ChatCompletionModel.model(...)`
* Messages use factory constructors: `ChatMessage.user()`, `ChatMessage.system()`, etc.
* Response extensions: `response.text`, `response.hasToolCalls`, `response.toolCalls`

## 3) Streaming

```dart
// Before
final stream = client.createChatCompletionStream(
  request: ChatCompletionRequest(
    model: ChatCompletionModel.model(ChatCompletionModels.mistralSmallLatest),
    messages: const [
      ChatCompletionMessage(
        role: ChatCompletionMessageRole.user,
        content: 'Tell me a story',
      ),
    ],
  ),
);
var text = '';
await for (final chunk in stream) {
  final delta = chunk.choices.first.delta.content;
  if (delta != null) {
    text += delta;
  }
}

// After
final stream = client.chat.createStream(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [ChatMessage.user('Tell me a story')],
  ),
);

// Option 1: Manual iteration
await for (final chunk in stream) {
  final delta = chunk.text; // Convenience extension
  if (delta != null) {
    stdout.write(delta);
  }
}

// Option 2: Stream extension to collect all text
final text = await stream.text;
```

**Stream extensions:**

* `chunk.text` — Get text content from chunk
* `chunk.hasToolCalls` — Check if chunk has tool calls
* `await stream.text` — Collect all text into a single string
* `await stream.allToolCalls` — Collect all tool calls

## 4) Messages

### Creating Messages

```dart
// Before
const userMessage = ChatCompletionMessage(
  role: ChatCompletionMessageRole.user,
  content: 'Hello!',
);

const systemMessage = ChatCompletionMessage(
  role: ChatCompletionMessageRole.system,
  content: 'You are a helpful assistant.',
);

const assistantMessage = ChatCompletionMessage(
  role: ChatCompletionMessageRole.assistant,
  content: 'How can I help?',
);

// After
final userMessage = ChatMessage.user('Hello!');
final systemMessage = ChatMessage.system('You are a helpful assistant.');
final assistantMessage = ChatMessage.assistant('How can I help?');
```

### Multimodal Messages (Images)

```dart
// After (new feature)
final message = ChatMessage.userMultimodal([
  TextContentPart('What is in this image?'),
  ImageUrlContentPart(
    url: 'https://example.com/image.jpg',
    detail: 'auto',
  ),
]);
```

### Tool Messages

```dart
// Before - Tool result message was part of ChatCompletionMessage
// with role: ChatCompletionMessageRole.tool

// After
final toolMessage = ChatMessage.tool(
  toolCallId: 'call_123',
  content: '{"temperature": 22, "unit": "celsius"}',
  name: 'get_weather', // optional
);
```

## 5) Model Specification

The new API uses plain strings for model identifiers instead of union types:

```dart
// Before - Using enum
ChatCompletionModel.model(ChatCompletionModels.mistralSmallLatest)
ChatCompletionModel.model(ChatCompletionModels.mistralLargeLatest)
EmbeddingModel.model(EmbeddingModels.mistralEmbed)

// Before - Using custom model ID
ChatCompletionModel.modelId('my-fine-tuned-model')

// After - Just strings
'mistral-small-latest'
'mistral-large-latest'
'mistral-embed'
'my-fine-tuned-model'
```

## 6) Embeddings

```dart
// Before
final response = await client.createEmbedding(
  request: EmbeddingRequest(
    model: EmbeddingModel.model(EmbeddingModels.mistralEmbed),
    input: ['Hello', 'World'],
    outputDtype: EmbeddingOutputDtype.float,
    encodingFormat: EmbeddingEncodingFormat.float,
  ),
);

// After
final response = await client.embeddings.create(
  request: EmbeddingRequest.batch(
    model: 'mistral-embed',
    input: ['Hello', 'World'],
    outputDtype: EmbeddingDtype.float,
    encodingFormat: 'float', // Now a string
  ),
);

// Or for single input
final response = await client.embeddings.create(
  request: EmbeddingRequest.single(
    model: 'mistral-embed',
    input: 'Hello, world!',
  ),
);
```

**Key changes:**

* Access under `client.embeddings`
* Factory constructors: `EmbeddingRequest.single()` and `EmbeddingRequest.batch()`
* `EmbeddingOutputDtype` → `EmbeddingDtype`
* `EmbeddingEncodingFormat` → plain string (`'float'` or `'base64'`)

## 7) Tools and Function Calling

### Defining Tools

```dart
// Before
const tool = Tool(
  type: ToolType.function,
  function: FunctionDefinition(
    name: 'get_weather',
    description: 'Get the current weather',
    parameters: {
      'type': 'object',
      'properties': {
        'location': {'type': 'string', 'description': 'The city name'},
      },
      'required': ['location'],
    },
  ),
);

// After
final tool = Tool.function(
  name: 'get_weather',
  description: 'Get the current weather',
  parameters: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string', 'description': 'The city name'},
    },
    'required': ['location'],
  },
);
```

### Built-in Tools (New Feature)

The new API supports Mistral's built-in tools:

```dart
// Web search
final webSearch = Tool.webSearch();

// Premium web search (with news agencies)
final webSearchPremium = Tool.webSearchPremium();

// Code interpreter
final codeInterpreter = Tool.codeInterpreter();

// Image generation
final imageGen = Tool.imageGeneration();

// Document library for RAG
final docLib = Tool.documentLibrary(libraryIds: ['lib-123']);
```

### Tool Choice

```dart
// Before
toolChoice: ChatCompletionToolChoice.enumeration(
  ChatCompletionToolChoiceOption.auto,
)
toolChoice: ChatCompletionToolChoice.enumeration(
  ChatCompletionToolChoiceOption.any,
)
toolChoice: ChatCompletionToolChoice.toolChoiceTool(
  ToolChoiceTool(
    type: ToolChoiceToolType.function,
    function: ToolChoiceToolFunction(name: 'get_weather'),
  ),
)

// After - Using constants
toolChoice: ToolChoice.auto
toolChoice: ToolChoice.any
toolChoice: ToolChoice.none
toolChoice: ToolChoice.required

// After - Specific function
toolChoice: ToolChoice.function('get_weather')

// After - Using classes directly
toolChoice: const ToolChoiceAuto()
toolChoice: const ToolChoiceAny()
toolChoice: ToolChoiceFunction(name: 'get_weather')
```

### Handling Tool Calls

```dart
// Before
final toolCalls = response.choices.first.message.toolCalls;
if (toolCalls != null && toolCalls.isNotEmpty) {
  for (final call in toolCalls) {
    final name = call.function?.name;
    final args = call.function?.arguments;
    // ...
  }
}

// After - Using extensions
if (response.hasToolCalls) {
  for (final call in response.toolCalls) {
    final name = call.function.name;  // Never null
    final args = call.function.arguments;  // Never null
    // ...
  }
}
```

**Key changes:**

* `ToolCall.id`, `ToolCall.function` are now required fields (with sensible defaults)
* Use `response.hasToolCalls` and `response.toolCalls` extensions
* `ToolCallType` enum removed; `type` is now just a string

## 8) Response Format

```dart
// Before
responseFormat: ResponseFormat(type: ResponseFormatType.jsonObject)

responseFormat: ResponseFormat(
  type: ResponseFormatType.jsonSchema,
  jsonSchema: JsonSchema(
    name: 'person',
    schema: {'type': 'object', 'properties': {...}},
  ),
)

// After
responseFormat: ResponseFormat.jsonObject

responseFormat: ResponseFormat.text

responseFormat: ResponseFormat.jsonSchema(
  name: 'person',
  schema: {'type': 'object', 'properties': {...}},
  description: 'A person object',  // optional
  strict: true,  // optional
)
```

## 9) Exception Handling

```dart
// Before
try {
  await client.createChatCompletion(request: request);
} on MistralAIClientException catch (e) {
  print('Error: ${e.message}');
  print('Status code: ${e.code}');
}

// After
try {
  await client.chat.create(request: request);
} on RateLimitException catch (e) {
  // 429 - Rate limited
  print('Rate limited, retry after: ${e.retryAfter}');
} on ValidationException catch (e) {
  // 400 - Bad request
  print('Validation error: ${e.message}');
} on AuthenticationException catch (e) {
  // 401 - Invalid API key
  print('Auth error: ${e.message}');
} on ApiException catch (e) {
  // Other API errors
  print('API error: ${e.statusCode} - ${e.message}');
}
```

## 10) New Features in v1.0.0

### Fill-in-the-Middle (FIM) Code Completions

```dart
final response = await client.fim.create(
  request: FimCompletionRequest(
    model: 'codestral-latest',
    prompt: 'def fibonacci(n):',
    suffix: '\n    return result',
  ),
);
```

### Fine-tuning

```dart
// Create a fine-tuning job
final job = await client.fineTuning.jobs.create(
  request: CreateFineTuningJobRequest(
    model: 'mistral-small-latest',
    trainingFiles: [TrainingFile(fileId: 'file-123')],
    hyperparameters: Hyperparameters(epochs: 3),
  ),
);

// List jobs
final jobs = await client.fineTuning.jobs.list();

// Manage models
await client.fineTuning.models.archive(modelId: 'ft:model-123');
await client.fineTuning.models.unarchive(modelId: 'ft:model-123');
```

### Batch Processing

```dart
final job = await client.batch.create(
  request: CreateBatchJobRequest(
    inputFiles: ['file-123'],
    model: 'mistral-small-latest',
    endpoint: '/v1/chat/completions',
  ),
);
```

### OCR

```dart
final response = await client.ocr.process(
  request: OcrRequest(
    model: 'mistral-ocr-latest',
    document: OcrDocument.fromUrl('https://example.com/document.pdf'),
  ),
);
```

### Audio Transcription

```dart
final response = await client.audio.transcribe(
  request: TranscriptionRequest(
    model: 'mistral-audio-latest',
    file: TranscriptionFile.fromPath('/path/to/audio.mp3'),
  ),
);
```

### Agents (Beta)

```dart
final response = await client.agents.complete(
  agentId: 'agent-123',
  request: AgentCompletionRequest(
    messages: [ChatMessage.user('Hello!')],
  ),
);
```

### Libraries (Beta)

```dart
// Create a document library
final library = await client.libraries.create(name: 'My Knowledge Base');

// Upload a document
final doc = await client.libraries.documents.upload(
  libraryId: library.id,
  filePath: '/path/to/document.pdf',
);

// Use in chat with document_library tool
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('What does the document say about X?')],
    tools: [Tool.documentLibrary(libraryIds: [library.id])],
  ),
);
```

### Prediction (Speculative Decoding)

```dart
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-2411',
    messages: [ChatMessage.user('Complete this code...')],
    prediction: Prediction(
      type: 'content',
      content: 'Expected output content here...',
    ),
  ),
);
```

### Prompt Mode (Reasoning)

```dart
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('Solve this problem step by step...')],
    promptMode: MistralPromptMode.reasoning,
  ),
);
```

## Common Pitfalls & Notes

* **Model strings are case-sensitive**: Use `'mistral-small-latest'`, not `'Mistral-Small-Latest'`
* **ToolCall fields are no longer nullable**: Access `toolCall.id` and `toolCall.function.name` directly without null checks
* **Stream extensions collect the entire stream**: `await stream.text` consumes the stream; you can't iterate it again
* **Factory constructors for sealed classes**: Use `ChatMessage.user()` instead of constructing `UserMessage` directly
* **Encoding format changed**: `EmbeddingEncodingFormat.float` is now just the string `'float'`

## Type Mapping Summary

| Old Type | New Type |
| --- | --- |
| `MistralAIClient` | `MistralClient` |
| `MistralAIClientException` | `ApiException`, `RateLimitException`, etc. |
| `ChatCompletionMessage` | `ChatMessage` (sealed class) |
| `ChatCompletionMessageRole` | Factory constructors on `ChatMessage` |
| `ChatCompletionModel` | `String` |
| `ChatCompletionModels` | Plain strings |
| `EmbeddingModel` | `String` |
| `EmbeddingModels` | Plain strings |
| `EmbeddingOutputDtype` | `EmbeddingDtype` |
| `EmbeddingEncodingFormat` | `String` |
| `ChatCompletionToolChoice` | `ToolChoice` (sealed class) |
| `ChatCompletionToolChoiceOption` | `ToolChoiceNone`, `ToolChoiceAuto`, etc. |
| `ResponseFormat` | `ResponseFormat` (sealed class) |
| `ResponseFormatType` | Factory constructors on `ResponseFormat` |
| `ToolCallType` | `String` |
| `AssistantMessageRole` | Removed (assistant message has role built-in) |
| `ChatCompletionFinishReason` | `FinishReason` |
| `ChatCompletionStreamResponse` | `ChatCompletionStreamResponse` |
| `ChatCompletionStreamDelta` | `DeltaMessage` |

## Getting Help

* Browse the [examples](example/)
* Check the [API docs](https://pub.dev/documentation/mistralai_dart/latest/)
* Open an issue: [https://github.com/davidmigloz/ai_clients_dart/issues](https://github.com/davidmigloz/ai_clients_dart/issues)

---

For the complete list of changes, see [CHANGELOG.md](CHANGELOG.md).
