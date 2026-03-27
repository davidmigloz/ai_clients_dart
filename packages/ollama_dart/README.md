# Ollama Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![ollama_dart](https://img.shields.io/pub/v/ollama_dart.svg)](https://pub.dev/packages/ollama_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Ollama API](https://ollama.com/)** to run local and self-hosted models — chat, streaming, tool calling, embeddings, and model management. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

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

### Generation and streaming

- Chat completions with context memory and multimodal inputs
- Text generation for prompt-style completions
- Embeddings for semantic search and retrieval
- NDJSON streaming for chat and completions
- Tool calling, thinking mode, and structured output

### Local model operations

- Pull, push, copy, create, delete, and inspect models
- List running models and query server version
- Connect to local or remote Ollama instances with optional auth

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Mirrors the Ollama API closely, including model management endpoints most wrappers skip.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

```yaml
dependencies:
  ollama_dart: ^2.0.0
```

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.chat.create(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Explain what Dart isolates do.')],
      ),
    );

    print(response.message?.content);
  } finally {
    client.close();
  }
}
```

## Configuration

<details>
<summary><b>Configure local hosts, remote servers, and retries</b></summary>

Use `OllamaClient()` for the default local daemon at `http://localhost:11434`, or `OllamaClient.fromEnvironment()` to read `OLLAMA_HOST`. Use `OllamaConfig` when you need a remote host, bearer auth, or a different timeout policy.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient(
    config: OllamaConfig(
      baseUrl: 'http://localhost:11434',
      timeout: const Duration(minutes: 5),
      retryPolicy: RetryPolicy(
        maxRetries: 3,
        initialDelay: Duration(seconds: 1),
      ),
    ),
  );

  client.close();
}
```

Environment variable:

- `OLLAMA_HOST`

Use `BearerTokenProvider` when the Ollama server is exposed behind an authenticated reverse proxy or remote deployment.

</details>

## Usage

### How do I run a chat completion?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.create(...)` for conversational flows. The chat response exposes `message?.content`, which keeps simple completions ergonomic in Dart and Flutter UIs.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.chat.create(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: [
          ChatMessage.system('You are a concise assistant.'),
          ChatMessage.user('What is hot reload?'),
        ],
      ),
    );

    print(response.message?.content);
  } finally {
    client.close();
  }
}
```

For structured output, set `format` to constrain the response to valid JSON:

```dart
final response = await client.chat.create(
  request: ChatRequest(
    model: 'gpt-oss',
    messages: [ChatMessage.user('List 3 colors as JSON')],
    format: ResponseFormat.json,
  ),
);
```

→ [Full example](example/chat_example.dart)

</details>

### How do I stream local model output?

<details>
<summary><b>Show example</b></summary>

Streaming uses Ollama's NDJSON response format and works well for terminals and live Flutter widgets. This is the fastest way to surface partial output from a local model.

```dart
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final stream = client.chat.createStream(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Write a haiku about local models.')],
      ),
    );

    await for (final chunk in stream) {
      stdout.write(chunk.message?.content ?? '');
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Tool calling is declared on the request with typed `ToolDefinition` objects. This makes local agent-style workflows possible without switching to another API format.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.chat.create(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('What is the weather in Paris?')],
        tools: [
          ToolDefinition(
            type: ToolType.function,
            function: ToolFunction(
              name: 'get_weather',
              description: 'Get the current weather for a location',
              parameters: {
                'type': 'object',
                'properties': {
                  'location': {'type': 'string'},
                },
                'required': ['location'],
              },
            ),
          ),
        ],
      ),
    );

    print(response.message?.toolCalls?.length ?? 0);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I generate plain text?

<details>
<summary><b>Show example</b></summary>

Use the completions resource when you want prompt-style generation instead of chat messages. This is useful for legacy templates, code infill helpers, or smaller server utilities.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final result = await client.completions.generate(
      request: GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Complete this sentence: Dart is great for',
      ),
    );

    print(result.response);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/completions_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Embeddings are exposed as a first-class resource, so semantic search or retrieval code can stay inside the same Ollama client. This is useful for local RAG pipelines in Dart.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.embeddings.create(
      request: const EmbedRequest(
        model: 'nomic-embed-text',
        input: EmbedInput.list(['Dart', 'Flutter']),
      ),
    );

    print(response.embeddings.length);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I manage local models?

<details>
<summary><b>Show example</b></summary>

Model management is part of the same client, which means pull, inspect, and runtime checks do not require a separate admin tool. That is useful for installers, desktop apps, and local dev tooling.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final models = await client.models.list();
    print(models.models.length);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/models_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle local daemon failures, retries, and streaming issues</b></summary>

`ollama_dart` throws typed exceptions so you can distinguish between API failures, timeouts, aborts, and streaming problems. Catch `ApiException` first for HTTP errors, then fall back to `OllamaException` for everything else.

```dart
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    await client.version.get();
  } on ApiException catch (error) {
    stderr.writeln('Ollama API error ${error.statusCode}: ${error.message}');
  } on OllamaException catch (error) {
    stderr.writeln('Ollama client error: $error');
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
| [`chat_example.dart`](example/chat_example.dart) | Chat completions |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling |
| [`completions_example.dart`](example/completions_example.dart) | Plain text generation |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings |
| [`models_example.dart`](example/models_example.dart) | Model management |
| [`version_example.dart`](example/version_example.dart) | Server version |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`ollama_dart_example.dart`](example/ollama_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Chat | ✅ Full |
| Completions | ✅ Full |
| Embeddings | ✅ Full |
| Models | ✅ Full |
| Version | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/ollama_dart/latest/)
- [Ollama API docs](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Ollama Python SDK](https://github.com/ollama/ollama-python)
- [Ollama JS SDK](https://github.com/ollama/ollama-js)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Ollama.
