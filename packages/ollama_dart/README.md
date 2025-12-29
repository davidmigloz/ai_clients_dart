# Ollama Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![ollama_dart](https://img.shields.io/pub/v/ollama_dart.svg)](https://pub.dev/packages/ollama_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Ollama API](https://ollama.com/)** to run LLMs locally (OpenAI gpt-oss, DeepSeek-R1, Gemma 3, Llama 4, and more).

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

### Generation & Streaming

- ✅ Text generation (`generate`)
- ✅ Chat completions (`chat`)
- ✅ Streaming support with NDJSON
- ✅ Tool/function calling
- ✅ Thinking mode (reasoning)
- ✅ Structured output (JSON mode and JSON schema)
- ✅ Multimodal support (images)
- ✅ Context memory for conversation continuity

### Embeddings

- ✅ Generate embeddings (`embed`)

### Model Management

- ✅ List local models (`list`)
- ✅ Show model details (`show`)
- ✅ Pull models from library (`pull`)
- ✅ Push models to library (`push`)
- ✅ Create models from Modelfile (`create`)
- ✅ Copy models (`copy`)
- ✅ Delete models (`delete`)
- ✅ List running models (`ps`)
- ✅ Get server version (`version`)

## Why choose this client?

- ✅ Type-safe with sealed classes
- ✅ Minimal dependencies (http, logging only)
- ✅ Works on all compilation targets (native, web, WASM)
- ✅ Interceptor-driven architecture
- ✅ Comprehensive error handling
- ✅ Automatic retry with exponential backoff
- ✅ NDJSON streaming support

## Quickstart

```dart
import 'package:ollama_dart/ollama_dart.dart';

void main() async {
  final client = OllamaClient();

  // Chat completion
  final response = await client.chat.create(
    request: ChatRequest(
      model: 'gpt-oss',
      messages: [
        ChatMessage.user('Hello, how are you?'),
      ],
    ),
  );

  print(response.message?.content);

  client.close();
}
```

## Installation

```yaml
dependencies:
  ollama_dart: ^1.0.0
```

## Configuration

<details>
<summary><b>Configuration Options</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient(
  config: OllamaConfig(
    baseUrl: 'http://localhost:11434',  // Default Ollama server
    timeout: Duration(minutes: 5),
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
    ),
  ),
);
```

**Authentication (for remote Ollama servers):**

```dart
final client = OllamaClient(
  config: OllamaConfig(
    baseUrl: 'https://my-ollama-server.example.com',
    authProvider: BearerTokenProvider('YOUR_TOKEN'),
  ),
);
```

</details>

## Usage

### Chat Completions

<details>
<summary><b>Chat Completions Example</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

final response = await client.chat.create(
  request: ChatRequest(
    model: 'gpt-oss',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
  ),
);

print(response.message?.content);
client.close();
```

</details>

### Streaming

<details>
<summary><b>Streaming Example</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

final stream = client.chat.createStream(
  request: ChatRequest(
    model: 'gpt-oss',
    messages: [
      ChatMessage.user('Tell me a story.'),
    ],
  ),
);

await for (final chunk in stream) {
  stdout.write(chunk.message?.content ?? '');
}

client.close();
```

</details>

### Tool Calling

<details>
<summary><b>Tool Calling Example</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

final response = await client.chat.create(
  request: ChatRequest(
    model: 'gpt-oss',
    messages: [
      ChatMessage.user('What is the weather in Paris?'),
    ],
    tools: [
      ToolDefinition(
        type: ToolType.function,
        function: ToolFunction(
          name: 'get_weather',
          description: 'Get the current weather for a location',
          parameters: {
            'type': 'object',
            'properties': {
              'location': {'type': 'string', 'description': 'City name'},
            },
            'required': ['location'],
          },
        ),
      ),
    ],
  ),
);

if (response.message?.toolCalls != null) {
  for (final toolCall in response.message!.toolCalls!) {
    print('Tool: ${toolCall.function?.name}');
    print('Args: ${toolCall.function?.arguments}');
  }
}

client.close();
```

</details>

### Text Generation

<details>
<summary><b>Text Generation Example</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

final response = await client.completions.generate(
  request: GenerateRequest(
    model: 'gpt-oss',
    prompt: 'Complete this: The capital of France is',
  ),
);

print(response.response);
client.close();
```

</details>

### Embeddings

<details>
<summary><b>Embeddings Example</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

final response = await client.embeddings.create(
  request: EmbedRequest(
    model: 'nomic-embed-text',
    input: 'The quick brown fox jumps over the lazy dog.',
  ),
);

print(response.embeddings);
client.close();
```

</details>

### Model Management

<details>
<summary><b>Model Management Examples</b></summary>

```dart
import 'package:ollama_dart/ollama_dart.dart';

final client = OllamaClient();

// List models
final models = await client.models.list();
for (final model in models.models ?? []) {
  print('${model.name}: ${model.size}');
}

// Pull a model
await for (final progress in client.models.pullStream(
  request: PullRequest(model: 'gpt-oss'),
)) {
  print('${progress.status}: ${progress.completed}/${progress.total}');
}

// Show model details
final info = await client.models.show(
  request: ShowRequest(model: 'gpt-oss'),
);
print(info.license);

// List running models
final running = await client.models.ps();
for (final model in running.models ?? []) {
  print('Running: ${model.name}');
}

// Get server version
final version = await client.version.get();
print('Ollama version: ${version.version}');

client.close();
```

</details>

## Examples

See the [`example/`](example/) directory for comprehensive examples:

1. **[ollama_dart_example.dart](example/ollama_dart_example.dart)** - Basic usage
2. **[chat_example.dart](example/chat_example.dart)** - Chat completions
3. **[streaming_example.dart](example/streaming_example.dart)** - Streaming responses
4. **[tool_calling_example.dart](example/tool_calling_example.dart)** - Function calling
5. **[embeddings_example.dart](example/embeddings_example.dart)** - Generate embeddings
6. **[models_example.dart](example/models_example.dart)** - Model management

## API Coverage

This client implements **100% of the Ollama REST API**:

### Chat Resource (`client.chat`)

- **create** - Generate a chat completion
- **createStream** - Generate a streaming chat completion

### Completions Resource (`client.completions`)

- **generate** - Generate a text completion
- **generateStream** - Generate a streaming text completion

### Embeddings Resource (`client.embeddings`)

- **create** - Generate embeddings for text

### Models Resource (`client.models`)

- **list** - List local models (`GET /api/tags`)
- **show** - Show model details (`POST /api/show`)
- **create** / **createStream** - Create a model from Modelfile (`POST /api/create`)
- **copy** - Copy a model (`POST /api/copy`)
- **delete** - Delete a model (`DELETE /api/delete`)
- **pull** / **pullStream** - Pull a model from library (`POST /api/pull`)
- **push** / **pushStream** - Push a model to library (`POST /api/push`)
- **ps** - List running models (`GET /api/ps`)

### Version Resource (`client.version`)

- **get** - Get server version (`GET /api/version`)

## License

`ollama_dart` is licensed under the [MIT License](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE).
