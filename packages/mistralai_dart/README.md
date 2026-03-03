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
  mistralai_dart: ^x.y.z
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

// From environment variables (reads MISTRAL_API_KEY and optional MISTRAL_BASE_URL)
final client = MistralClient.fromEnvironment();

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
  if (chunk.text != null) {
    stdout.write(chunk.text); // Extension method
  }
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
        // Or use base64 via data URL
        // ContentPart.imageUrl('data:image/png;base64,$base64Data'),
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

print(response.choices.first.message);

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

> **Note**: File-path based uploads (`filePath`) are only available on native platforms. On web, use byte-based uploads (`bytes`) instead. Other file operations (list, retrieve, download, delete) are supported on all platforms.

```dart
// Upload a file
final file = await client.files.upload(
  filePath: 'training_data.jsonl',
  purpose: FilePurpose.fineTune,
);

// List files
final files = await client.files.list();

// Download file content
final content = await client.files.download(fileId: file.id);

// Delete file
await client.files.delete(fileId: file.id);
```

### Fine-tuning

```dart
// Create a fine-tuning job
final job = await client.fineTuning.jobs.create(
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
final poller = FineTuningJobPoller(
  client: client,
  jobId: job.id,
  pollInterval: Duration(seconds: 30),
  timeout: Duration(hours: 2),
);
final completedJob = await poller.poll();

// List jobs with pagination
final paginator = Paginator<FineTuningJob, FineTuningJobList>(
  fetcher: (page, size) => client.fineTuning.jobs.list(page: page, pageSize: size),
  getItems: (response) => response.data,
);

await for (final job in paginator.items()) {
  print('Job: ${job.id} - ${job.status}');
}
```

### Batch Processing

```dart
// Create batch job
final job = await client.batch.jobs.create(
  request: CreateBatchJobRequest(
    inputFileId: 'file-abc123',
    endpoint: '/v1/chat/completions',
    model: 'mistral-small-latest',
  ),
);

// Poll for completion
final poller = BatchJobPoller(client: client, jobId: job.id);
final completed = await poller.poll();

// Download results
final results = await client.files.download(fileId: completed.outputFile!);
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
    print('Content flagged: ${item.categories}');
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
// Upload audio file first, then transcribe using file ID

// Basic transcription
final result = await client.audio.transcriptions.create(
  request: TranscriptionRequest(
    model: 'mistral-stt-latest',
    file: audioFileId, // ID from client.files.upload()
  ),
);

print('Transcription: ${result.text}');

// Streaming transcription
final stream = client.audio.transcriptions.createStream(
  request: TranscriptionRequest(
    model: 'mistral-stt-latest',
    file: audioFileId,
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
  request: AgentCompletionRequest(
    agentId: agent.id,
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
await client.agents.delete(agentId: agent.id);
```

### Conversations (Beta)

```dart
// Start a conversation
final conversation = await client.conversations.start(
  request: StartConversationRequest(
    agentId: 'agent-123',
    inputs: [MessageInputEntry(content: 'Hello!')],
  ),
);

print('Assistant: ${conversation.text}');

// Continue the conversation
final response = await client.conversations.sendMessage(
  conversationId: conversation.conversationId,
  message: 'Tell me more',
);

// Get conversation details
final details = await client.conversations.retrieve(
  conversationId: conversation.conversationId,
);
```

### Libraries (Beta)

```dart
// Create a library
final library = await client.libraries.create(
  name: 'Research Papers',
);

// Add a document (file must be uploaded first via client.files.upload())
final doc = await client.libraries.documents.create(
  libraryId: library.id,
  fileId: fileId, // ID from client.files.upload()
);

// List documents
final docs = await client.libraries.documents.list(libraryId: library.id);

// Use library with chat
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [ChatMessage.user('What does the paper say about AI?')],
    tools: [Tool.documentLibrary(libraryIds: [library.id])],
  ),
);

// Delete library
await client.libraries.delete(libraryId: library.id);
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
chunk.text              // Delta content from streaming

// AgentCompletionResponse extensions
agentResponse.text      // Output text content

// ConversationResponse extensions
conversation.text       // Output message content
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
final poller = FineTuningJobPoller(
  client: client,
  jobId: jobId,
  pollInterval: Duration(seconds: 30),
  timeout: Duration(hours: 2),
);
final job = await poller.poll();

// Batch
final batchPoller = BatchJobPoller(client: client, jobId: jobId);
final batchJob = await batchPoller.poll();
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
  print('API error ${e.statusCode}: ${e.message}');
} on TimeoutException catch (e) {
  print('Timeout: ${e.message}');
} on AbortedException catch (e) {
  print('Aborted: ${e.message}');
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
| Files API | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Audio | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

> **Note**: On web, file uploads only support byte-based uploads (`bytes` parameter); file-path uploads are native-only. Other file operations (list, retrieve, download, delete) work on all platforms. Audio APIs require native platform support and are not available on web.

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

## API Coverage

This client implements the Mistral AI REST API:

### Chat Resource (`client.chat`)

- **create** - Create a chat completion
- **createStream** - Create a streaming chat completion (SSE)

### Embeddings Resource (`client.embeddings`)

- **create** - Generate embeddings for text

### Models Resource (`client.models`)

- **list** - List available models
- **get** - Retrieve a model by ID
- **delete** - Delete a fine-tuned model

### FIM Resource (`client.fim`)

- **create** - Create a fill-in-the-middle completion
- **createStream** - Create a streaming FIM completion (SSE)

### Files Resource (`client.files`)

- **upload** - Upload a file
- **list** - List files
- **retrieve** - Get file metadata
- **delete** - Delete a file
- **download** - Download file content

### FineTuning Resource (`client.fineTuning`)

- **jobs.create** - Create a fine-tuning job
- **jobs.list** - List fine-tuning jobs
- **jobs.retrieve** - Get job status
- **jobs.cancel** - Cancel a job
- **jobs.start** - Start a job
- **models.archive** - Archive a fine-tuned model
- **models.unarchive** - Unarchive a fine-tuned model
- **models.update** - Update a fine-tuned model

### Batch Resource (`client.batch`)

- **jobs.create** - Create a batch job
- **jobs.list** - List batch jobs
- **jobs.retrieve** - Get job status
- **jobs.cancel** - Cancel a job

### Moderations Resource (`client.moderations`)

- **create** - Moderate text content
- **createChat** - Moderate chat messages

### Classifications Resource (`client.classifications`)

- **create** - Classify text content
- **createChat** - Classify chat messages

### OCR Resource (`client.ocr`)

- **process** - Extract text from documents/images

### Audio Resource (`client.audio`)

- **transcriptions.create** - Transcribe audio to text
- **transcriptions.createStream** - Stream transcription results

### Agents Resource (`client.agents`) - Beta

- **create** - Create an agent
- **list** - List agents
- **retrieve** - Get an agent
- **update** - Update an agent
- **delete** - Delete an agent
- **updateVersion** - Update active version
- **complete** - Generate completion with agent
- **completeStream** - Stream completion with agent

### Conversations Resource (`client.conversations`) - Beta

- **start** - Start a new conversation
- **append** - Append entries to a conversation
- **getEntries** - Get all entries in a conversation
- **restart** - Restart from a specific entry
- **list** - List conversations
- **retrieve** - Get a conversation
- **delete** - Delete a conversation
- **sendMessage** - Send a message (convenience)
- **sendFunctionResult** - Send function result (convenience)

### Libraries Resource (`client.libraries`) - Beta

- **create** - Create a document library
- **list** - List libraries
- **retrieve** - Get a library
- **update** - Update a library
- **delete** - Delete a library
- **documents.create** - Add a document to a library
- **documents.list** - List documents in a library
- **documents.retrieve** - Get document metadata
- **documents.update** - Update document metadata
- **documents.delete** - Delete a document

## Documentation

- [Mistral AI API Documentation](https://docs.mistral.ai/)
- [API Reference](https://pub.dev/documentation/mistralai_dart/latest/)

## Contributing

Contributions are welcome! Please read our [contributing guidelines](../../CONTRIBUTING.md) before submitting PRs.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
