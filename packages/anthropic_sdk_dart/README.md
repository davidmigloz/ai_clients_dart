# Anthropic Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![anthropic_sdk_dart](https://img.shields.io/pub/v/anthropic_sdk_dart.svg)](https://pub.dev/packages/anthropic_sdk_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Unofficial Dart client for the **[Anthropic API](https://docs.anthropic.com/en/api)** to build with Claude (Claude Opus 4, Sonnet 4, and more).

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Development](#development)
- [License](#license)

</details>

## Features

### Messages & Streaming

- ✅ Message creation (`messages.create`)
- ✅ Streaming support (`messages.createStream`) with SSE
- ✅ Request cancellation (via `abortTrigger`)
- ✅ Token counting (`messages.countTokens`)

### Tool Use

- ✅ Custom function/tool calling
- ✅ Tool choice modes (auto, any, tool, none)
- ✅ Built-in tools:
  - Web search (`WebSearchTool`)
  - Text editor (`TextEditorTool`)
  - Bash (`BashTool`)
  - Computer use (`ComputerUseTool`)
  - Code execution (`CodeExecutionTool`)

### Extended Thinking

- ✅ Extended thinking mode (`ThinkingEnabled`)
- ✅ Thinking budget control
- ✅ Streaming thinking blocks

### Multimodal

- ✅ Vision (image analysis)
  - Base64 images (PNG, JPEG, GIF, WebP)
  - URL images
- ✅ Document processing (PDF, text)
  - Base64 documents
  - URL documents
- ✅ Citations support

### Batches

- ✅ Batch message creation
- ✅ Batch management (list, retrieve, cancel, delete)
- ✅ Batch results streaming (JSONL)

### Models

- ✅ List available models
- ✅ Retrieve model details

### Legacy

- ✅ Text completions (deprecated but supported)
- ✅ Streaming completions

## Why choose this client?

- ✅ Type-safe with sealed classes
- ✅ Minimal dependencies (http, logging only)
- ✅ Works on all compilation targets (native, web, WASM)
- ✅ Interceptor-driven architecture
- ✅ Comprehensive error handling
- ✅ Automatic retry with exponential backoff
- ✅ SSE streaming support

## Quickstart

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(
        String.fromEnvironment('ANTHROPIC_API_KEY'),
      ),
    ),
  );

  final response = await client.messages.create(
    MessageCreateRequest(
      model: 'claude-sonnet-4-20250514',
      maxTokens: 1024,
      messages: [
        InputMessage.user('What is the capital of France?'),
      ],
    ),
  );

  print(response.text); // Paris is the capital of France.

  client.close();
}
```

## Installation

```yaml
dependencies:
  anthropic_sdk_dart: ^0.1.0
```

## Configuration

<details>
<summary><b>Configuration Options</b></summary>

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

final client = AnthropicClient(
  config: AnthropicConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.anthropic.com', // Default
    timeout: Duration(minutes: 5),
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ),
);
```

**Custom base URL (for proxies or testing):**

```dart
final client = AnthropicClient(
  config: AnthropicConfig(
    baseUrl: 'https://my-proxy.example.com',
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
  ),
);
```

</details>

## Usage

### Basic Messages

<details>
<summary><b>Basic Message Example</b></summary>

```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

final client = AnthropicClient(
  config: const AnthropicConfig(
    authProvider: ApiKeyProvider(
      String.fromEnvironment('ANTHROPIC_API_KEY'),
    ),
  ),
);

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.user('What is the capital of France?'),
    ],
  ),
);

print('Response: ${response.text}');
print('Stop reason: ${response.stopReason}');
print('Usage: ${response.usage.inputTokens} in, ${response.usage.outputTokens} out');

client.close();
```

</details>

### Multi-turn Conversations

<details>
<summary><b>Multi-turn Conversation Example</b></summary>

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.user('My name is Alice.'),
      InputMessage.assistant('Nice to meet you, Alice!'),
      InputMessage.user('What is my name?'),
    ],
  ),
);

print(response.text); // Your name is Alice.
```

</details>

### System Prompts

<details>
<summary><b>System Prompt Example</b></summary>

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    system: SystemPrompt.text(
      'You are a friendly pirate. Respond in pirate speak.',
    ),
    messages: [
      InputMessage.user('Hello, how are you?'),
    ],
  ),
);

print(response.text); // Ahoy, matey! I be doin' just fine...
```

</details>

### Streaming

<details>
<summary><b>Streaming Example</b></summary>

```dart
import 'dart:io';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

final stream = client.messages.createStream(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 256,
    messages: [
      InputMessage.user('Count from 1 to 10 slowly.'),
    ],
  ),
);

await for (final event in stream) {
  if (event is ContentBlockDeltaEvent) {
    final delta = event.delta;
    if (delta is TextDelta) {
      stdout.write(delta.text);
    }
  }
}
```

</details>

### Tool Calling

<details>
<summary><b>Tool Calling Example</b></summary>

```dart
import 'dart:convert';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

// Define a tool
final weatherTool = Tool(
  name: 'get_weather',
  description: 'Get the current weather for a location.',
  inputSchema: InputSchema(
    properties: {
      'location': {
        'type': 'string',
        'description': 'City and state, e.g. "San Francisco, CA"',
      },
      'unit': {
        'type': 'string',
        'enum': ['celsius', 'fahrenheit'],
        'description': 'Temperature unit',
      },
    },
    required: ['location'],
  ),
);

// Send message with tool
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    tools: [weatherTool.toJson()],
    messages: [
      InputMessage.user('What is the weather in San Francisco?'),
    ],
  ),
);

// Check if Claude wants to use a tool
if (response.hasToolUse) {
  for (final toolUse in response.toolUseBlocks) {
    print('Tool: ${toolUse.name}');
    print('Input: ${jsonEncode(toolUse.input)}');

    // Execute your tool and send results back...
  }
}
```

</details>

### Extended Thinking

<details>
<summary><b>Extended Thinking Example</b></summary>

```dart
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 16000,
    thinking: ThinkingEnabled(budgetTokens: 10000),
    messages: [
      InputMessage.user('Solve this complex math problem step by step...'),
    ],
  ),
);

// Access thinking blocks
for (final block in response.content) {
  if (block is ThinkingBlock) {
    print('Thinking: ${block.thinking}');
  } else if (block is TextBlock) {
    print('Response: ${block.text}');
  }
}
```

</details>

### Vision (Image Analysis)

<details>
<summary><b>Vision Example</b></summary>

```dart
// Using URL image
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        const TextInputBlock('What do you see in this image?'),
        const ImageInputBlock(
          UrlImageSource('https://example.com/image.jpg'),
        ),
      ]),
    ],
  ),
);

// Using base64 image
final base64Image = base64Encode(File('image.png').readAsBytesSync());
final response2 = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        const TextInputBlock('Describe this image.'),
        ImageInputBlock(
          Base64ImageSource(
            mediaType: ImageMediaType.png,
            data: base64Image,
          ),
        ),
      ]),
    ],
  ),
);
```

</details>

### Document Processing

<details>
<summary><b>Document Example</b></summary>

```dart
// Using URL document
final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        const TextInputBlock('Summarize this PDF document.'),
        const DocumentInputBlock(
          UrlDocumentSource('https://example.com/document.pdf'),
        ),
      ]),
    ],
  ),
);

// Using base64 PDF
final base64Pdf = base64Encode(File('document.pdf').readAsBytesSync());
final response2 = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 1024,
    messages: [
      InputMessage.userBlocks([
        const TextInputBlock('What are the key points in this document?'),
        DocumentInputBlock(
          Base64DocumentSource(
            mediaType: DocumentMediaType.pdf,
            data: base64Pdf,
          ),
        ),
      ]),
    ],
  ),
);
```

</details>

### Message Batches

<details>
<summary><b>Batch Example</b></summary>

```dart
// Create a batch
final batch = await client.messages.batches.create(
  MessageBatchCreateRequest(
    requests: [
      BatchRequestItem(
        customId: 'request-1',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Hello!')],
        ),
      ),
      BatchRequestItem(
        customId: 'request-2',
        params: MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('How are you?')],
        ),
      ),
    ],
  ),
);

print('Batch ID: ${batch.id}');
print('Status: ${batch.processingStatus}');

// Check batch status
final status = await client.messages.batches.retrieve(batch.id);
print('Progress: ${status.requestCounts.succeeded}/${status.requestCounts.processing}');

// Get results when complete
if (status.processingStatus == ProcessingStatus.ended) {
  await for (final result in client.messages.batches.results(batch.id)) {
    print('${result.customId}: ${result.result}');
  }
}
```

</details>

### Token Counting

<details>
<summary><b>Token Counting Example</b></summary>

```dart
final response = await client.messages.countTokens(
  TokenCountRequest(
    model: 'claude-sonnet-4-20250514',
    messages: [
      InputMessage.user('Hello, Claude!'),
    ],
  ),
);

print('Input tokens: ${response.inputTokens}');
```

</details>

### Models

<details>
<summary><b>Models Example</b></summary>

```dart
// List all models
final models = await client.models.list();
for (final model in models.data) {
  print('${model.id}: ${model.displayName}');
}

// Get specific model
final model = await client.models.retrieve('claude-sonnet-4-20250514');
print('Model: ${model.displayName}');
print('Created: ${model.createdAt}');
```

</details>

### Error Handling

<details>
<summary><b>Error Handling Example</b></summary>

```dart
try {
  final response = await client.messages.create(request);
  print(response.text);
} on AuthenticationException {
  print('Invalid API key - check your credentials');
} on RateLimitException catch (e) {
  print('Rate limited - try again later: ${e.message}');
} on ApiException catch (e) {
  print('API error ${e.code}: ${e.message}');
} on AnthropicException catch (e) {
  print('Anthropic error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

**Exception Hierarchy:**

- `AnthropicException` - Base exception
  - `ApiException` - API errors with status codes
    - `AuthenticationException` - 401 errors
    - `RateLimitException` - 429 errors
    - `OverloadedException` - 529 errors
  - `AbortedException` - Request was cancelled

</details>

### Request Cancellation

<details>
<summary><b>Cancellation Example</b></summary>

```dart
import 'dart:async';

final abortController = Completer<void>();

// Start request with abort capability
final requestFuture = client.messages.create(
  request,
  abortTrigger: abortController.future,
);

// Cancel after 5 seconds
Future.delayed(Duration(seconds: 5), () {
  abortController.complete();
});

try {
  final response = await requestFuture;
  print(response.text);
} on AbortedException {
  print('Request was cancelled');
}
```

</details>

## Examples

See the [`example/`](example/) directory for comprehensive examples:

| Example | Description |
|---------|-------------|
| [anthropic_sdk_dart_example.dart](example/anthropic_sdk_dart_example.dart) | Quick start example |
| [messages_example.dart](example/messages_example.dart) | Basic message creation |
| [streaming_example.dart](example/streaming_example.dart) | SSE streaming |
| [tool_calling_example.dart](example/tool_calling_example.dart) | Function/tool use |
| [vision_example.dart](example/vision_example.dart) | Image analysis |
| [document_example.dart](example/document_example.dart) | PDF document processing |
| [thinking_example.dart](example/thinking_example.dart) | Extended thinking |
| [token_counting_example.dart](example/token_counting_example.dart) | Token counting |
| [batch_example.dart](example/batch_example.dart) | Batch processing |
| [files_example.dart](example/files_example.dart) | Files API (Beta) |
| [models_example.dart](example/models_example.dart) | Models API |
| [error_handling_example.dart](example/error_handling_example.dart) | Exception handling |
| [abort_example.dart](example/abort_example.dart) | Request cancellation |
| [web_search_example.dart](example/web_search_example.dart) | Web search tool |
| [computer_use_example.dart](example/computer_use_example.dart) | Computer use (Beta) |
| [mcp_example.dart](example/mcp_example.dart) | MCP integration (Beta) |

## API Coverage

This client implements **100% of the Anthropic REST API**:

### Messages Resource (`client.messages`)

- **create** - Create a message
- **createStream** - Create a streaming message (SSE)
- **countTokens** - Count tokens in a message

### Message Batches Resource (`client.messages.batches`)

- **create** - Create a message batch
- **list** - List all batches
- **retrieve** - Get batch status
- **cancel** - Cancel a batch
- **delete** - Delete a batch
- **results** - Stream batch results (JSONL)

### Models Resource (`client.models`)

- **list** - List available models
- **retrieve** - Get model details

### Completions Resource (`client.completions`) - Legacy

- **create** - Create a text completion (deprecated)
- **createStream** - Create a streaming completion (deprecated)

## Development

```bash
# Install dependencies
dart pub get

# Run tests
dart test

# Format code
dart format .

# Analyze
dart analyze
```

## License

`anthropic_sdk_dart` is licensed under the [MIT License](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE).
