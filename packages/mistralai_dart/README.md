# Mistral AI Dart Client

[![pub package](https://img.shields.io/pub/v/mistralai_dart.svg)](https://pub.dev/packages/mistralai_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Dart client for the **[Mistral AI API](https://docs.mistral.ai/)** with chat completions, streaming, tool calling, multimodal inputs, TTS, voice management, reasoning effort, embeddings, OCR, and more. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Configuration](#configuration)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Official Documentation](#official-documentation)
- [Sponsor](#sponsor)
- [License](#license)

</details>

## Features

> **Coverage:** This client covers the full Mistral AI API surface. See [API Coverage](#api-coverage) for details.

### Generation and streaming

- Chat completions with streaming, tool calling, vision, JSON mode, and structured output
- Embeddings, FIM code completions, and reasoning effort control
- Model management and discovery

### Tools and media

- Built-in web search, code interpreter, and document library tools
- Audio transcription, text-to-speech, and voice management
- OCR, moderations, and classifications

### Operational APIs

- Files, fine-tuning, and batch processing
- Agents, conversations, and libraries (beta)
- Observability: campaigns, datasets, judges, and chat completion events (beta)
- Workflows: execution, scheduling, deployments, and management (beta)

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Covers the full Mistral AI API surface, including beta agents, conversations, libraries, observability, and workflows.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

```yaml
dependencies:
  mistralai_dart: ^2.1.1
```

```dart
import 'package:mistralai_dart/mistralai_dart.dart';

Future<void> main() async {
  final client = MistralClient.fromEnvironment();

  try {
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.user('Hello! How are you?'),
        ],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

## Configuration

<details>
<summary><b>Configure auth, retries, and custom endpoints</b></summary>

Use `MistralClient.fromEnvironment()` when `MISTRAL_API_KEY` is available. Switch to `MistralConfig` when you need a proxy, custom timeout, or a non-default retry policy.

```dart
// Simple API key authentication
final client = MistralClient.withApiKey('your-api-key');

// From environment variables (reads MISTRAL_API_KEY and optional MISTRAL_BASE_URL)
final client = MistralClient.fromEnvironment();

// Custom base URL (for proxies or self-hosted)
final client = MistralClient.withApiKey(
  'your-api-key',
  baseUrl: 'https://my-proxy.example.com',
);

// Full configuration
final client = MistralClient(
  config: MistralConfig(
    authProvider: ApiKeyProvider('your-api-key'),
    baseUrl: 'https://api.mistral.ai',
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ),
);

// Always close when done
client.close();
```

Environment variables:

- `MISTRAL_API_KEY`
- `MISTRAL_BASE_URL`

Use explicit configuration on web builds where runtime environment variables are not available.

</details>

## Usage

### How do I use chat completions?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.create(...)` to send messages and receive a completion. Set `reasoningEffort` on reasoning-capable models to control how deeply the model thinks.

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

```dart
// Control reasoning depth for reasoning-capable models
final response = await client.chat.create(
  request: ChatCompletionRequest(
    model: 'mistral-large-latest',
    messages: [
      ChatMessage.user('Solve this step by step: what is 23 * 47?'),
    ],
    reasoningEffort: ReasoningEffort.high,
  ),
);

print(response.text);
```

→ [Full example](example/chat_example.dart)

</details>

### How do I stream responses?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.createStream(...)` to receive tokens as they are generated via SSE. Each chunk exposes a `text` extension for easy access.

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

→ [Full example](example/streaming_example.dart)

</details>

### How do I use vision?

<details>
<summary><b>Show example</b></summary>

Pass multimodal content parts (text + image URLs or base64 data URLs) using `ChatMessage.userMultimodal(...)` with a vision-capable model like Pixtral.

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

→ [Full example](example/vision_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Define custom tools with JSON Schema parameters, or use built-in tools like web search, code interpreter, and document library. Send tool results back in a follow-up message turn.

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

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I use structured output?

<details>
<summary><b>Show example</b></summary>

Use `ResponseFormatJsonObject` for simple JSON mode or `ResponseFormatJsonSchema` to enforce a specific schema on the response.

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

→ [Full example](example/json_mode_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Use `client.embeddings.create(...)` with a single text or a batch of texts. The response contains embedding vectors you can use for search, clustering, or classification.

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

→ [Full example](example/embeddings_example.dart)

</details>

### How do I use code completions?

<details>
<summary><b>Show example</b></summary>

Use `client.fim.create(...)` for fill-in-the-middle code completion with Codestral. Provide a `prompt` and optional `suffix` to generate the middle portion.

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

→ [Full example](example/fim_example.dart)

</details>

### How do I list and manage models?

<details>
<summary><b>Show example</b></summary>

Use `client.models` to list, retrieve, and delete models. Use `client.fineTuning.models` to update, archive, and unarchive fine-tuned models.

```dart
// List all models
final models = await client.models.list();
for (final model in models.data) {
  print('${model.id}: ${model.name}');
}

// Get a specific model
final model = await client.models.get('mistral-small-latest');
print('Max context: ${model.maxContextLength}');

// Delete a fine-tuned model
await client.models.delete('ft:mistral-small:my-model:xyz');
```

```dart
// Update a fine-tuned model's metadata
final updated = await client.fineTuning.models.update(
  modelId: 'ft:mistral-small:my-model:xyz',
  name: 'My Improved Model',
  description: 'Fine-tuned for customer support',
);

// Archive a model
final archived = await client.fineTuning.models.archive(
  modelId: 'ft:mistral-small:my-model:xyz',
);

// Unarchive a model
await client.fineTuning.models.unarchive(
  modelId: 'ft:mistral-small:my-model:xyz',
);
```

→ [Full example](example/models_example.dart)

</details>

### How do I manage files?

<details>
<summary><b>Show example</b></summary>

Use `client.files` to upload, list, download, and delete files. File-path uploads are native-only; on web, use byte-based uploads instead.

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

→ [Full example](example/files_example.dart)

</details>

### How do I fine-tune and batch?

<details>
<summary><b>Show example</b></summary>

Use `client.fineTuning.jobs` to create and monitor fine-tuning jobs, and `client.batch.jobs` for batch processing. Both support polling helpers for long-running operations.

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

```dart
// Create batch job
final job = await client.batch.jobs.create(
  request: CreateBatchJobRequest(
    inputFiles: ['file-abc123'],
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

→ [Full example](example/fine_tuning_example.dart)

</details>

### How do I moderate content?

<details>
<summary><b>Show example</b></summary>

Use `client.moderations` for text and chat-aware content moderation, and `client.classifications` for text classification. Both flag content categories automatically.

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

→ [Full example](example/moderation_example.dart)

</details>

### How do I extract text from documents?

<details>
<summary><b>Show example</b></summary>

Use `client.ocr.process(...)` to extract text from documents and images. Supports both URL and base64-encoded inputs, and returns markdown per page.

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

→ [Full example](example/ocr_example.dart)

</details>

### How do I use audio?

<details>
<summary><b>Show example</b></summary>

Use `client.audio.transcriptions` for speech-to-text, `client.audio.speech` for text-to-speech, and `client.audio.voices` to manage custom voices. Both transcription and speech support streaming.

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

```dart
// Generate speech
final response = await client.audio.speech.create(
  request: SpeechRequest(
    input: 'Hello, world!',
    voiceId: 'voice-id',
  ),
);
print('Audio data: ${response.audioData.length} chars');

// Stream speech
final stream = client.audio.speech.createStream(
  request: SpeechRequest(input: 'Hello!'),
);
await for (final event in stream) {
  if (event is SpeechStreamAudioDelta) {
    // Process audio chunk
  }
}
```

```dart
// List voices
final voices = await client.audio.voices.list();
for (final voice in voices.items) {
  print('${voice.name}: ${voice.id}');
}

// Create a custom voice
final voice = await client.audio.voices.create(
  request: VoiceCreateRequest(
    name: 'My Voice',
    sampleAudio: base64EncodedAudio,
  ),
);
print('Created voice: ${voice.id}');
```

→ [Full example](example/audio_example.dart)

</details>

### How do I use agents?

<details>
<summary><b>Show example</b></summary>

Use `client.agents` to create, list, update, and delete agents. Agents can use tools and follow custom instructions. Use `complete(...)` to chat with an agent.

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
print(response.text); // Extension for output text content

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

→ [Full example](example/agents_example.dart)

</details>

### How do I use conversations?

<details>
<summary><b>Show example</b></summary>

Use `client.conversations` to manage stateful multi-turn conversations with agents. The server maintains conversation history so you do not have to resend it.

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

→ [Full example](example/conversations_example.dart)

</details>

### How do I use libraries?

<details>
<summary><b>Show example</b></summary>

Use `client.libraries` to create document libraries for RAG. Upload files first, add them as documents, then reference the library in chat via `Tool.documentLibrary(...)`.

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

→ [Full example](example/libraries_example.dart)

</details>

### How do I use observability?

<details>
<summary><b>Show example</b></summary>

Use `client.observability` to manage campaigns, datasets, dataset records, judges, chat completion events, and chat completion fields. These APIs help you monitor and evaluate your Mistral AI usage.

```dart
// List datasets
final datasetList = await client.observability.datasets.list();
for (final dataset in datasetList.datasets.results) {
  print('${dataset.name}: ${dataset.id}');
}

// Create a dataset
final dataset = await client.observability.datasets.create(
  request: PostDatasetInSchema(
    name: 'My Dataset',
    description: 'A sample dataset',
  ),
);

// Manage dataset records
final records = await client.observability.datasets.listRecords(
  datasetId: dataset.id,
);

// List judges
final judges = await client.observability.judges.list();

// List campaigns
final campaigns = await client.observability.campaigns.list();

// Browse chat completion fields
final fields = await client.observability.chatCompletionFields.list();
```

→ [Full example](example/observability_example.dart)

</details>

### How do I use workflows?

<details>
<summary><b>Show example</b></summary>

Use `client.workflows` to manage and execute workflows via the workflowCore resource, check execution status, list registrations, monitor runs, view metrics, inspect workers, and configure schedules.

```dart
// List registered workflows
final workflows = await client.workflows.core.list();
for (final wf in workflows.workflowRegistrations) {
  print('${wf.workflow?.name}: ${wf.workflowId}');
}

// Execute a workflow
final result = await client.workflows.core.executeAsync(
  workflowIdentifier: 'my-workflow',
  request: WorkflowExecutionRequest(
    input: {'key': 'value'},
  ),
);
print('Execution: ${result.executionId}');

// Get execution status
final execution = await client.workflows.executions.get(
  executionId: result.executionId,
);
print('Status: ${execution.status}');

// List runs and check metrics
final runs = await client.workflows.runs.list();
final metrics = await client.workflows.metrics.get(
  workflowName: 'my-workflow',
);

// Check worker status
final worker = await client.workflows.workers.whoami();

// List registrations
final registrations = await client.workflows.registrations.list();

// List schedules
final schedules = await client.workflows.schedules.list();
```

→ [Full example](example/workflows_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle retries, validation failures, and request aborts</b></summary>

`mistralai_dart` throws typed exceptions so retry logic and validation handling stay explicit. Catch `ApiException` and its subclasses first, then fall back to `MistralException` for other transport or parsing failures.

```dart
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

Future<void> main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [ChatMessage.user('Ping')],
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Mistral API error ${error.statusCode}: ${error.message}');
  } on MistralException catch (error) {
    stderr.writeln('Mistral client error: $error');
  } finally {
    client.close();
  }
}
```

→ [Full example](example/error_handling_example.dart)

</details>

## Examples

See the [example/](example/) directory for complete examples:

| Example | Description |
|---------|-------------|
| [`chat_example.dart`](example/chat_example.dart) | Basic chat completions |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling |
| [`json_mode_example.dart`](example/json_mode_example.dart) | Structured output |
| [`vision_example.dart`](example/vision_example.dart) | Multimodal inputs |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings |
| [`fim_example.dart`](example/fim_example.dart) | Code completion |
| [`files_example.dart`](example/files_example.dart) | File management |
| [`fine_tuning_example.dart`](example/fine_tuning_example.dart) | Model training |
| [`batch_example.dart`](example/batch_example.dart) | Batch processing |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`classification_example.dart`](example/classification_example.dart) | Text classification |
| [`ocr_example.dart`](example/ocr_example.dart) | Document text extraction |
| [`audio_example.dart`](example/audio_example.dart) | Audio transcription and TTS |
| [`agents_example.dart`](example/agents_example.dart) | AI agents (beta) |
| [`conversations_example.dart`](example/conversations_example.dart) | Multi-turn conversations (beta) |
| [`libraries_example.dart`](example/libraries_example.dart) | Document storage (beta) |
| [`observability_example.dart`](example/observability_example.dart) | Observability: datasets, judges, campaigns (beta) |
| [`workflows_example.dart`](example/workflows_example.dart) | Workflow execution and scheduling (beta) |
| [`models_example.dart`](example/models_example.dart) | Model listing |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`config_example.dart`](example/config_example.dart) | Client configuration options |
| [`multi_turn_example.dart`](example/multi_turn_example.dart) | Multi-turn conversation management |
| [`parallel_requests_example.dart`](example/parallel_requests_example.dart) | Parallel and concurrent requests |
| [`rag_example.dart`](example/rag_example.dart) | Retrieval Augmented Generation |
| [`semantic_search_example.dart`](example/semantic_search_example.dart) | Semantic search with embeddings |
| [`system_message_example.dart`](example/system_message_example.dart) | System message patterns |

## API Coverage

| API | Status |
|-----|--------|
| Chat | ✅ Full |
| Embeddings | ✅ Full |
| Models | ✅ Full |
| FIM | ✅ Full |
| Files | ✅ Full |
| Fine-tuning | ✅ Full |
| Batch | ✅ Full |
| Moderations | ✅ Full |
| Classifications | ✅ Full |
| OCR | ✅ Full |
| Audio (Transcription, Speech, Voices) | ✅ Full |
| Agents (Beta) | ✅ Full |
| Conversations (Beta) | ✅ Full |
| Libraries (Beta) | ✅ Full |
| Observability (Beta) | ✅ Full |
| Workflows (Beta) | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/mistralai_dart/latest/)
- [Mistral AI API docs](https://docs.mistral.ai/)
- [Mistral AI Python SDK](https://github.com/mistralai/client-python)
- [Mistral AI JS SDK](https://github.com/mistralai/client-js)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Mistral AI.
