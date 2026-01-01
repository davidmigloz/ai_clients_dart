# Mistral AI Dart Client

[![pub package](https://img.shields.io/pub/v/mistralai_dart.svg)](https://pub.dev/packages/mistralai_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive, type-safe Dart client for the [Mistral AI API](https://docs.mistral.ai/). This library provides a resource-based interface to all Mistral AI capabilities, with full support for streaming, tool calling, and multimodal inputs.

## Features

### Stable APIs
- **Chat Completions** - Conversational AI with streaming, tool calling, and JSON mode
- **Embeddings** - Text embeddings for semantic search and clustering
- **Models** - List and retrieve available models
- **FIM** - Fill-in-the-Middle code completions with Codestral
- **Files** - Upload and manage files for fine-tuning and batch processing
- **Fine-tuning** - Train custom models on your data
- **Batch** - Asynchronous large-scale processing
- **Moderations** - Content moderation for safety
- **Classifications** - Text classification (spam, topic, sentiment)
- **OCR** - Extract text from documents and images
- **Audio** - Speech-to-text transcription with streaming

### Beta APIs
- **Agents** - Pre-configured AI assistants with tools and instructions
- **Conversations** - Stateful multi-turn conversations
- **Libraries** - Document storage and retrieval for RAG

### Additional Features
- Full streaming support via Server-Sent Events (SSE)
- Multimodal inputs (text + images)
- Function/tool calling with parallel execution
- JSON schema validation for structured output
- Built-in web search, code interpreter, and document tools
- Extension methods for convenient response access
- Pagination and job polling utilities
- Comprehensive error handling

## Installation

Add `mistralai_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  mistralai_dart: ^1.0.0
```

## Quick Start

```dart
import 'package:mistralai_dart/mistralai_dart.dart';

void main() async {
  // Create client with API key
  final client = MistralClient.withApiKey('your-api-key');

  try {
    // Simple chat completion
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.user('Hello! How are you?'),
        ],
      ),
    );

    print(response.text); // Extension method for easy access
  } finally {
    client.close();
  }
}
```

## Usage

### Client Configuration

```dart
// Simple API key authentication
final client = MistralClient.withApiKey('your-api-key');

// Custom base URL (for proxies or self-hosted)
final client = MistralClient.withBaseUrl(
  apiKey: 'your-api-key',
  baseUrl: 'https://my-proxy.example.com/v1',
);

// Full configuration
final client = MistralClient(
  config: MistralConfig(
    authProvider: ApiKeyProvider('your-api-key'),
    baseUrl: 'https://api.mistral.ai/v1',
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ),
);

// Always close when done
client.close();
```

### Chat Completions

```dart
// Basic chat
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    temperature: 0.7,
    maxTokens: 500,
  ),
);

print(response.text);
```

### Streaming

```dart
final stream = client.chat.createStream(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [
      ChatMessage.user('Tell me a story'),
    ],
  ),
);

await for (final chunk in stream) {
  stdout.write(chunk.textDelta); // Extension method
}
```

### Vision (Multimodal)

```dart
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'pixtral-12b-2409',
    messages: [
      ChatMessage.userMultimodal([
        ContentPart.text('Describe this image'),
        ContentPart.imageUrl('https://example.com/image.jpg'),
        // Or use base64
        // ContentPart.imageBase64(base64Data, mediaType: 'image/png'),
      ]),
    ],
  ),
);
```

### Tool Calling

```dart
// Define tools
final weatherTool = Tool.function(
  name: 'get_weather',
  description: 'Get weather for a location',
  parameters: {
    'type': 'object',
    'properties': {
      'location': {'type': 'string'},
      'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
    },
    'required': ['location'],
  },
);

// Request with tools
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('What is the weather in Paris?')],
    tools: [weatherTool],
    toolChoice: const ToolChoiceAuto(),
  ),
);

// Check for tool calls using extension
if (response.hasToolCalls) {
  for (final toolCall in response.toolCalls) {
    print('Function: ${toolCall.function.name}');
    print('Arguments: ${toolCall.function.arguments}');

    // Execute tool and send result back
    final toolResult = await executeFunction(toolCall);

    // Continue conversation with tool result
    final followUp = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-large-latest',
        messages: [
          ChatMessage.user('What is the weather in Paris?'),
          ChatMessage.assistant(null, toolCalls: response.toolCalls),
          ChatMessage.tool(
            toolCallId: toolCall.id,
            content: toolResult,
          ),
        ],
        tools: [weatherTool],
      ),
    );
  }
}
```

### Built-in Tools

```dart
// Web search tool
final webTool = Tool.webSearch();

// Code interpreter
final codeTool = Tool.codeInterpreter();

// Image generation
final imageTool = Tool.imageGeneration();

// Document library (for RAG)
final docTool = Tool.documentLibrary(libraryIds: ['lib-123']);

final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('Search for latest AI news')],
    tools: [webTool],
    toolChoice: const ToolChoiceAuto(),
  ),
);
```

### JSON Mode and Structured Output

```dart
// Simple JSON mode
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [
      ChatMessage.system('Respond in JSON format.'),
      ChatMessage.user('List 3 programming languages'),
    ],
    responseFormat: const ResponseFormatJsonObject(),
  ),
);

// JSON with schema validation
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-small-latest',
    messages: [ChatMessage.user('Generate a product')],
    responseFormat: ResponseFormatJsonSchema(
      name: 'product',
      schema: {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'price': {'type': 'number'},
          'in_stock': {'type': 'boolean'},
        },
        'required': ['name', 'price'],
      },
    ),
  ),
);
```

### Embeddings

```dart
// Single text
final response = await client.embeddings.create(
  request: EmbeddingRequest.single(
    model: 'mistral-embed',
    input: 'Hello, world!',
  ),
);
print('Dimensions: ${response.data.first.embedding.length}');

// Batch embeddings
final response = await client.embeddings.create(
  request: EmbeddingRequest.batch(
    model: 'mistral-embed',
    input: ['Text 1', 'Text 2', 'Text 3'],
  ),
);
```

### FIM (Fill-in-the-Middle) Code Completion

```dart
final response = await client.fim.create(
  request: FimCompletionRequest(
    model: 'codestral-latest',
    prompt: 'def fibonacci(n):',
    suffix: '\n    return result',
    maxTokens: 100,
  ),
);

print(response.choices.first.message.content);

// Streaming FIM
final stream = client.fim.createStream(
  request: FimCompletionRequest(
    model: 'codestral-latest',
    prompt: 'function add(a, b) {',
    suffix: '}',
  ),
);
```

### Files API

> **Note**: The Files API is only available on native platforms (not web).

```dart
import 'dart:io';

// Upload a file
final file = await client.files.upload(
  file: File('training_data.jsonl'),
  purpose: FilePurpose.fineTune,
);

// List files
final files = await client.files.list();

// Download file content
final content = await client.files.downloadContent(file.id);

// Delete file
await client.files.delete(file.id);
```

### Fine-tuning

```dart
// Create a fine-tuning job
final job = await client.fineTuning.create(
  request: CreateFineTuningJobRequest(
    model: 'mistral-small-latest',
    trainingFiles: [TrainingFile(fileId: 'file-abc123')],
    hyperparameters: Hyperparameters(
      epochs: 3,
      learningRate: 0.0001,
    ),
  ),
);

// Poll for completion
final poller = FineTuningJobPoller(client);
final completedJob = await poller.poll(
  job.id,
  pollInterval: Duration(seconds: 30),
  timeout: Duration(hours: 2),
  onStatusChange: (status) => print('Status: $status'),
);

// List jobs with pagination
final paginator = Paginator<FineTuningJob, FineTuningJobList>(
  fetcher: (page, size) => client.fineTuning.list(page: page, pageSize: size),
  getItems: (response) => response.data,
);

await for (final job in paginator.items()) {
  print('Job: ${job.id} - ${job.status}');
}
```

### Batch Processing

```dart
// Create batch job
final job = await client.batch.create(
  request: CreateBatchJobRequest(
    inputFiles: ['file-abc123'],
    endpoint: '/v1/chat/completions',
    model: 'mistral-small-latest',
  ),
);

// Poll for completion
final poller = BatchJobPoller(client);
final completed = await poller.poll(job.id);

// Download results
final results = await client.files.downloadContent(completed.outputFile!);
```

### Moderations

```dart
// Text moderation
final result = await client.moderations.create(
  request: ModerationRequest(
    model: 'mistral-moderation-latest',
    input: ['Check this content for safety'],
  ),
);

for (final item in result.results) {
  if (item.flagged) {
    print('Content flagged for: ${item.flaggedCategories}');
  }
}

// Chat-aware moderation
final result = await client.moderations.createChat(
  request: ChatModerationRequest(
    model: 'mistral-moderation-latest',
    input: [
      ChatMessage.user('Hello'),
      ChatMessage.assistant('Hi there!'),
    ],
  ),
);
```

### Classifications

```dart
final result = await client.classifications.create(
  request: ClassificationRequest(
    model: 'mistral-moderation-latest',
    input: ['Is this spam?'],
  ),
);

for (final item in result.results) {
  print('Categories: ${item.categories}');
}
```

### OCR (Optical Character Recognition)

```dart
// From URL
final result = await client.ocr.process(
  request: OcrRequest(
    model: 'mistral-ocr-latest',
    document: OcrDocument.fromUrl('https://example.com/document.pdf'),
  ),
);

for (final page in result.pages) {
  print('Page ${page.index}: ${page.markdown}');
}

// From base64
final result = await client.ocr.process(
  request: OcrRequest(
    model: 'mistral-ocr-latest',
    document: OcrDocument.fromBase64(base64Data, type: 'application/pdf'),
  ),
);
```

### Audio Transcription

```dart
import 'dart:io';

// Basic transcription
final result = await client.audio.transcribe(
  request: TranscriptionRequest(
    model: 'mistral-stt-latest',
    file: File('audio.mp3'),
  ),
);

print('Transcription: ${result.text}');

// With word timestamps
final result = await client.audio.transcribe(
  request: TranscriptionRequest(
    model: 'mistral-stt-latest',
    file: File('audio.mp3'),
    timestampGranularities: ['word'],
  ),
);

for (final word in result.words ?? []) {
  print('${word.word} [${word.start} - ${word.end}]');
}

// Streaming transcription
final stream = client.audio.transcribeStream(
  request: TranscriptionRequest(
    model: 'mistral-stt-latest',
    file: File('audio.mp3'),
  ),
);

await for (final event in stream) {
  print(event.text);
}
```

### Agents (Beta)

```dart
// Create an agent
final agent = await client.agents.create(
  request: CreateAgentRequest(
    name: 'Research Assistant',
    model: 'mistral-large-latest',
    instructions: 'You are a helpful research assistant.',
    tools: [Tool.webSearch()],
  ),
);

// Chat with agent
final response = await client.agents.complete(
  agentId: agent.id,
  request: AgentCompletionRequest(
    messages: [ChatMessage.user('Search for latest AI papers')],
  ),
);

// List agents
final agents = await client.agents.list();

// Update agent
await client.agents.update(
  agentId: agent.id,
  request: UpdateAgentRequest(name: 'Updated Name'),
);

// Delete agent
await client.agents.delete(agent.id);
```

### Conversations (Beta)

```dart
// Start a conversation
final conversation = await client.conversations.start(
  request: ConversationRequest(
    agentId: 'agent-123',
    inputs: ChatMessage.user('Hello!'),
  ),
);

print('Assistant: ${conversation.outputs.text}');

// Continue the conversation
final response = await client.conversations.append(
  conversationId: conversation.conversationId,
  request: ConversationRequest(
    agentId: 'agent-123',
    inputs: ChatMessage.user('Tell me more'),
  ),
);

// Stream conversation
final stream = client.conversations.startStream(
  request: ConversationRequest(
    agentId: 'agent-123',
    inputs: ChatMessage.user('Write a poem'),
  ),
);

await for (final chunk in stream) {
  stdout.write(chunk.outputs.textDelta);
}

// Get conversation history
final history = await client.conversations.get(conversationId);
```

### Libraries (Beta)

```dart
// Create a library
final library = await client.libraries.create(
  name: 'Research Papers',
  chunkingStrategy: ChunkingStrategy.semantic,
);

// Upload documents
final doc = await client.libraries.uploadDocument(
  libraryId: library.id,
  file: File('paper.pdf'),
  filename: 'research_paper.pdf',
);

// List documents
final docs = await client.libraries.listDocuments(library.id);

// Use library with chat
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('What does the paper say about AI?')],
    tools: [Tool.documentLibrary(libraryIds: [library.id])],
  ),
);

// Delete library
await client.libraries.delete(library.id);
```

### Models

```dart
// List all models
final models = await client.models.list();

for (final model in models.data) {
  print('${model.id}');
  print('  Description: ${model.description}');
  print('  Context: ${model.maxContextLength} tokens');
  if (model.capabilities != null) {
    print('  Vision: ${model.capabilities!.vision}');
    print('  Function calling: ${model.capabilities!.functionCalling}');
  }
}

// Get specific model
final model = await client.models.get('mistral-large-latest');
```

## Extension Methods

The library provides convenient extension methods for common operations:

```dart
// ChatCompletionResponse extensions
response.text           // First choice message content
response.hasToolCalls   // Check if tool calls present
response.toolCalls      // Get tool calls list

// ChatCompletionStreamResponse extensions
chunk.textDelta         // Delta content from streaming

// AgentCompletionResponse extensions
agentResponse.text      // Output text content

// ConversationResponse extensions
conversation.text       // Output message content
conversation.textDelta  // Delta for streaming
```

## Utility Classes

### Paginator

For iterating through paginated results:

```dart
final paginator = Paginator<Model, ModelList>(
  fetcher: (page, size) => client.models.list(page: page, pageSize: size),
  getItems: (response) => response.data,
  pageSize: 20,
);

// As stream
await for (final model in paginator.items()) {
  print(model.id);
}

// Collect all
final allModels = await paginator.items().toList();
```

### Job Poller

For polling long-running jobs:

```dart
// Fine-tuning
final poller = FineTuningJobPoller(client);
final job = await poller.poll(
  jobId,
  pollInterval: Duration(seconds: 30),
  timeout: Duration(hours: 2),
  onStatusChange: (status) => print('Status: $status'),
);

// Batch
final batchPoller = BatchJobPoller(client);
final batchJob = await batchPoller.poll(jobId);
```

## Error Handling

```dart
try {
  final response = await client.chat.create(...);
} on RateLimitException catch (e) {
  print('Rate limited. Retry after: ${e.retryAfter}');
} on ValidationException catch (e) {
  print('Invalid request: ${e.message}');
  print('Details: ${e.details}');
} on AuthenticationException catch (e) {
  print('Auth failed: ${e.message}');
} on ApiException catch (e) {
  print('API error ${e.code}: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on MistralException catch (e) {
  print('General error: $e');
}
```

## Available Models

| Model | Type | Description |
|-------|------|-------------|
| `mistral-small-latest` | Chat | Fast, cost-effective |
| `mistral-medium-latest` | Chat | Balanced performance |
| `mistral-large-latest` | Chat | Most capable |
| `pixtral-12b-2409` | Vision | Multimodal (text + images) |
| `pixtral-large-latest` | Vision | Large vision model |
| `codestral-latest` | Code | Code generation and FIM |
| `mistral-embed` | Embeddings | Text embeddings |
| `mistral-moderation-latest` | Moderation | Content safety |
| `mistral-ocr-latest` | OCR | Document text extraction |
| `mistral-stt-latest` | Audio | Speech-to-text |

See the [Mistral AI documentation](https://docs.mistral.ai/getting-started/models/) for a complete list.

## Platform Support

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Chat | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Streaming | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Embeddings | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Files API | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Audio | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

> **Note**: File upload and audio APIs require native platform support and are not available on web.

## Examples

See the [example](example/) directory for comprehensive examples:

- [Chat](example/chat_example.dart) - Basic chat completions
- [Streaming](example/streaming_example.dart) - Real-time streaming
- [Tool Calling](example/tool_calling_example.dart) - Function/tool calling
- [JSON Mode](example/json_mode_example.dart) - Structured output
- [Vision](example/vision_example.dart) - Multimodal inputs
- [Embeddings](example/embeddings_example.dart) - Text embeddings
- [Semantic Search](example/semantic_search_example.dart) - Similarity search
- [RAG](example/rag_example.dart) - Retrieval augmented generation
- [FIM](example/fim_example.dart) - Code completion
- [Files](example/files_example.dart) - File management
- [Fine-tuning](example/fine_tuning_example.dart) - Model training
- [Batch](example/batch_example.dart) - Batch processing
- [Moderation](example/moderation_example.dart) - Content safety
- [Classification](example/classification_example.dart) - Text classification
- [OCR](example/ocr_example.dart) - Document extraction
- [Audio](example/audio_example.dart) - Speech-to-text
- [Agents](example/agents_example.dart) - AI assistants
- [Conversations](example/conversations_example.dart) - Multi-turn conversations
- [Libraries](example/libraries_example.dart) - Document storage
- [Models](example/models_example.dart) - Model listing
- [Multi-turn](example/multi_turn_example.dart) - Conversation management
- [System Messages](example/system_message_example.dart) - Persona control
- [Error Handling](example/error_handling_example.dart) - Error patterns
- [Configuration](example/config_example.dart) - Client setup
- [Parallel Requests](example/parallel_requests_example.dart) - Concurrent calls

## Documentation

- [Mistral AI API Documentation](https://docs.mistral.ai/)
- [API Reference](https://pub.dev/documentation/mistralai_dart/latest/)

## Contributing

Contributions are welcome! Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting PRs.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
