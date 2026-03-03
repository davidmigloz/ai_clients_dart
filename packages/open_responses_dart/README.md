# OpenResponses Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![open_responses_dart](https://img.shields.io/pub/v/open_responses_dart.svg)](https://pub.dev/packages/open_responses_dart)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the [OpenResponses](https://www.openresponses.org/) API specification.

OpenResponses is an open-source specification that provides a unified interface for interacting with multiple LLM providers. This package implements the OpenResponses spec in Dart, enabling you to write code once and deploy across various model providers with minimal changes.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Supported Providers](#supported-providers)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Convenience Extensions](#convenience-extensions)
- [Message Items](#message-items)
- [Error Handling](#error-handling)
- [Configuration](#configuration)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [Platform Support](#platform-support)
- [Development](#development)
- [Documentation](#documentation)
- [License](#license)

</details>

## Features

- **Single Endpoint API**: Simple `POST /v1/responses` for all interactions
- **Streaming Support**: Real-time Server-Sent Events (SSE) streaming
- **Multi-modal Content**: Text, images, files, and video support
- **Tool/Function Calling**: Define and invoke custom functions
- **MCP Tools**: Remote Model Context Protocol tool integration
- **Reasoning Models**: Support for o1 and other reasoning models
- **Structured Output**: JSON Schema response format
- **Multi-turn Conversations**: Context preservation with `previousResponseId`
- **Type-safe API**: Full Dart null safety

## Why choose this client?

- ✅ Type-safe with sealed classes
- ✅ Minimal dependencies (http, logging only)
- ✅ Works on all compilation targets (native, web, WASM)
- ✅ Interceptor-driven architecture
- ✅ Comprehensive error handling
- ✅ Automatic retry with exponential backoff
- ✅ SSE streaming support
- ✅ Multi-provider compatible (OpenAI, Ollama, HuggingFace, etc.)

## Supported Providers

The OpenResponses specification is supported by multiple providers:

| Provider | Base URL | Auth | Features |
|----------|----------|------|----------|
| **OpenAI** | `https://api.openai.com/v1` | Bearer token | Full support including multi-turn |
| **Ollama** | `http://localhost:11434/v1` | None (local) | Local models |
| **Hugging Face** | Custom Space URL | Bearer token | Various models |
| **OpenRouter** | `https://openrouter.ai/api/v1` | Bearer token | Multiple providers |
| **LM Studio** | `http://localhost:1234/v1` | None (local) | Local models |

## Installation

Add `open_responses_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  open_responses_dart: ^x.y.z
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:open_responses_dart/open_responses_dart.dart';

void main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider('your-api-key'),
    ),
  );

  final response = await client.responses.create(
    CreateResponseRequest(
      model: 'gpt-4o',
      input: 'What is the capital of France?',
    ),
  );

  print(response.outputText); // Paris is the capital of France.

  client.close();
}
```

Or use environment variables (`OPENAI_API_KEY` and optionally `OPENAI_BASE_URL`):

```dart
// From environment variables (reads OPENAI_API_KEY and OPENAI_BASE_URL)
final client = OpenResponsesClient.fromEnvironment();
```

## Usage

### Basic Usage

<details>
<summary><b>Basic Usage Example</b></summary>

```dart
import 'package:open_responses_dart/open_responses_dart.dart';

final client = OpenResponsesClient(
  config: OpenResponsesConfig(
    baseUrl: 'https://api.openai.com/v1',
    authProvider: BearerTokenProvider('your-api-key'),
  ),
);

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'What is the capital of France?',
  ),
);

print(response.outputText); // Paris is the capital of France.

client.close();
```

</details>

### Streaming

<details>
<summary><b>Streaming Example</b></summary>

```dart
// Using the builder pattern
final runner = client.responses.stream(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'Write a haiku about programming.',
  ),
)..onTextDelta(stdout.write);

final response = await runner.finalResponse;
print('\nDone!');

// Or iterate events manually
await for (final event in client.responses.createStream(request)) {
  if (event is OutputTextDeltaEvent) {
    stdout.write(event.delta);
  }
}
```

</details>

### Tool Calling

<details>
<summary><b>Tool Calling Example</b></summary>

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'What is the weather in San Francisco?',
    tools: [
      FunctionTool(
        name: 'get_weather',
        description: 'Get the current weather',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {'type': 'string'},
          },
          'required': ['location'],
        },
      ),
    ],
  ),
);

if (response.hasToolCalls) {
  for (final call in response.functionCalls) {
    print('Function: ${call.name}');
    print('Arguments: ${call.arguments}');
  }
}
```

</details>

### Multi-turn Conversations

<details>
<summary><b>Multi-turn Conversation Example</b></summary>

```dart
// First turn
final response1 = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'My name is Alice.',
  ),
);

// Second turn - model remembers context
final response2 = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'What is my name?',
    previousResponseId: response1.id,
  ),
);

print(response2.outputText); // Your name is Alice.
```

</details>

### Structured Output

<details>
<summary><b>Structured Output Example</b></summary>

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: 'List 3 fruits with their colors.',
    text: TextConfig(
      format: JsonSchemaFormat(
        name: 'fruits',
        schema: {
          'type': 'object',
          'properties': {
            'fruits': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'name': {'type': 'string'},
                  'color': {'type': 'string'},
                },
                'required': ['name', 'color'],
              },
            },
          },
          'required': ['fruits'],
        },
        strict: true,
      ),
    ),
  ),
);

final data = jsonDecode(response.outputText!);
```

</details>

### Using with Different Providers

<details>
<summary><b>Multiple Providers Example</b></summary>

```dart
// OpenAI
final openaiClient = OpenResponsesClient(
  config: OpenResponsesConfig(
    baseUrl: 'https://api.openai.com/v1',
    authProvider: BearerTokenProvider(Platform.environment['OPENAI_API_KEY']!),
  ),
);

// Ollama (local)
final ollamaClient = OpenResponsesClient(
  config: const OpenResponsesConfig(
    baseUrl: 'http://localhost:11434/v1',
    // No auth needed for local Ollama
  ),
);

// Hugging Face
final hfClient = OpenResponsesClient(
  config: OpenResponsesConfig(
    baseUrl: 'https://your-space.hf.space/v1',
    authProvider: BearerTokenProvider(Platform.environment['HF_API_KEY']!),
  ),
);
```

</details>

## Convenience Extensions

The client provides useful extension methods on `ResponseResource`:

<details>
<summary><b>Response Extensions</b></summary>

```dart
// Get concatenated text output
response.outputText

// Get all function calls
response.functionCalls

// Get reasoning items (for o1 models)
response.reasoningItems

// Check response status
response.isCompleted
response.isFailed
response.hasToolCalls
```

</details>

<details>
<summary><b>Streaming Extensions</b></summary>

```dart
// Get text delta from event
event.textDelta

// Check if event is terminal
event.isFinal

// Accumulate text from stream
final text = await stream.text;

// Get final response from stream
final response = await stream.finalResponse;
```

</details>

## Message Items

Build complex inputs with message items:

<details>
<summary><b>Message Items Example</b></summary>

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: [
      MessageItem.systemText('You are a helpful assistant.'),
      MessageItem.userText('Hello!'),
      MessageItem.assistantText('Hi there! How can I help?'),
      MessageItem.userText('What can you do?'),
    ],
  ),
);
```

</details>

## Error Handling

<details>
<summary><b>Error Handling Example</b></summary>

```dart
try {
  final response = await client.responses.create(request);
} on AuthenticationException catch (e) {
  print('Authentication failed: ${e.message}');
} on RateLimitException catch (e) {
  print('Rate limited. Retry after: ${e.retryAfter}');
} on ValidationException catch (e) {
  print('Invalid request: ${e.message}');
} on ApiException catch (e) {
  print('API error: ${e.statusCode} - ${e.message}');
}
```

</details>

## Configuration

<details>
<summary><b>Configuration Options</b></summary>

```dart
final client = OpenResponsesClient(
  config: OpenResponsesConfig(
    baseUrl: 'https://api.openai.com/v1',
    authProvider: BearerTokenProvider('your-api-key'),
    timeout: const Duration(seconds: 60),
    defaultHeaders: {'X-Custom-Header': 'value'},
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: const Duration(seconds: 1),
    ),
  ),
);
```

</details>

## Examples

See the [`example/`](example/) directory for comprehensive examples:

| Example | Description |
|---------|-------------|
| [create_response_example.dart](example/create_response_example.dart) | Basic usage |
| [streaming_example.dart](example/streaming_example.dart) | Streaming responses |
| [tool_calling_example.dart](example/tool_calling_example.dart) | Function calling |
| [multi_turn_example.dart](example/multi_turn_example.dart) | Multi-turn conversations |
| [reasoning_example.dart](example/reasoning_example.dart) | Reasoning models |
| [structured_output_example.dart](example/structured_output_example.dart) | JSON Schema output |
| [mcp_tools_example.dart](example/mcp_tools_example.dart) | MCP tools |

## API Coverage

### Responses Resource (`client.responses`)

| Method | Description |
|--------|-------------|
| `create` | Create a response (non-streaming) |
| `createStream` | Create a streaming response (SSE) |
| `stream` | Create streaming response with builder pattern |

## Platform Support

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Basic requests | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Streaming | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tool calling | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

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

## Documentation

- [OpenResponses Specification](https://www.openresponses.org/)
- [API Reference](https://pub.dev/documentation/open_responses_dart/latest/)

## License

`open_responses_dart` is licensed under the [MIT License](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE).
