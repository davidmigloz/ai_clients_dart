# Ollama Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![ollama_dart](https://img.shields.io/pub/v/ollama_dart.svg)](https://pub.dev/packages/ollama_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Ollama API](https://ollama.com/)** — chat, streaming, tool calling, embeddings, System One decisions, model management, and cloud web search. Connect to local, self-hosted, or Ollama Cloud models from Dart and Flutter across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

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
- Cached prompt token metrics and model-defined thinking controls
- System One classification, yes/no probabilities, and ordered scoring

### Local model operations

- Pull, push, copy, create, delete, and inspect models
- Upload binary blobs and import GGUF or Safetensors model files
- List running models and query server version
- Connect to local or remote Ollama instances with optional auth

### Cloud web tools

- Search the web and fetch page content with an Ollama API key
- Explicit cloud configuration using the same authentication and transport settings

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Mirrors the Ollama API closely, including model management endpoints most wrappers skip.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  ollama_dart: ^3.0.0
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

For direct Ollama Cloud inference or hosted web tools, pass the cloud host explicitly:

```dart
final client = OllamaClient.withApiKey(
  apiKey,
  baseUrl: 'https://ollama.com',
);
```

Here `apiKey` is your Ollama API key. Configure the host without an `/api` suffix; resources append their endpoint paths. Web search and fetch use the configured host and require Ollama Cloud or a proxy exposing those endpoints. Local model creation, blob uploads, and System One require a local Ollama server.

By default the client does **not** send an `X-Request-ID` header — Ollama's CORS allow-list excludes it, so sending it breaks the preflight in browser targets (Flutter Web / dart2wasm). A request ID is still generated internally for logging and error correlation. Set `OllamaConfig(sendRequestIdHeader: true)` to emit the header when talking to an intermediary (e.g. a reverse proxy) you've configured to accept it.

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
    format: ResponseFormat.json(),
  ),
);
```

→ [Full example](example/chat_example.dart)

</details>

### How do I discover a model's thinking controls?

`/api/show` advertises supported values and the model default. Keep `think` unset to use that default. Existing `ThinkValue.enabled(...)` and `ThinkValue.level(...)` constructors remain available; use `ThinkValue.string(...)` for names advertised by a model.

```dart
final details = await client.models.show(
  request: const ShowRequest(model: 'gpt-oss'),
);
final thinking = details.thinking;
if (thinking != null) {
  print(thinking.values.map((value) => value.toJson()).toList());
  print('Default: ${thinking.defaultValue.toJson()}');
}

final response = await client.chat.create(
  request: const ChatRequest(
    model: 'gpt-oss',
    messages: [ChatMessage.user('What is 15 * 7?')],
    think: ThinkValue.string('high'),
  ),
);
print('Cached prompt tokens: ${response.promptEvalCachedCount}');
```

Thinking values are model-defined; use a value returned by `thinking.values`. `promptEvalCount` includes cached prompt tokens, while `promptEvalDuration` measures uncached prompt evaluation. The cached count is nullable because older servers omit it.

→ [Full model-inspection example](example/models_example.dart)

### How do I stream local model output?

<details>
<summary><b>Show example</b></summary>

Streaming uses Ollama's NDJSON response format and works well for terminals and live Flutter widgets. This is the fastest way to surface partial output from a local model.

The final event (`done == true`) carries token and timing metrics, including nullable `promptEvalCachedCount`. Chunks can contain multiple tokens; use the final `evalCount` for generated token usage. `promptEvalDuration` measures uncached prompt evaluation.

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

For a follow-up request, replay the assistant's content, thinking, and tool calls together, then identify each tool result with `toolName` and `toolCallId` when the model supplies an ID. See the full example for a complete round trip.

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

### How do I generate images (experimental)?

<details>
<summary><b>Show example</b></summary>

Ollama 0.35.0 rejects image generation with HTTP 400. The feature was [temporarily removed in 0.32.6](https://github.com/ollama/ollama/releases/tag/v0.32.6); upstream identifies 0.32.5 as the last release with support. The client retains the experimental fields for compatible servers.

On a server that supports image generation, pass `width`/`height`/`steps` to `/api/generate`; the response carries a base64 string in `image` (decode it before writing bytes). These fields may change or be removed in a future Ollama release.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

Future<void> main() async {
  final client = OllamaClient();

  try {
    final result = await client.completions.generate(
      request: const GenerateRequest(
        model: 'x/z-image-turbo',
        prompt: 'a sunset over mountains',
        width: 1024,
        height: 768,
        steps: 20,
      ),
    );

    final image = result.image;
    if (image != null) {
      File('generated_image.png').writeAsBytesSync(base64Decode(image));
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/image_generation_example.dart)

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

    print(response.embeddings?.length ?? 0);
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
    print(models.models?.length ?? 0);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/models_example.dart)

</details>

### How do I make System One decisions?

System One requires Ollama **v0.35.0 or later** and a compatible local decision model such as `nimble`. Its single JSON response answers named questions against a shared state; it does not stream. It supports choice questions, yes/no probabilities (`noul`), and scores over ordered criteria.

```dart
final response = await client.systemOne.create(
  request: SystemOneRequest(
    model: 'nimble',
    state: const SystemOneContent.string('The customer asks for a refund.'),
    questions: {
      'intent': SystemOneQuestion.choice(
        instructions: const SystemOneContent.string('Classify the request.'),
        criteria: {
          'refund': 'A request to return money',
          'other': 'Any other request',
        },
      ),
    },
  ),
);
print(response.answers['intent']);
```

State and instructions also accept `SystemOneContent.object(...)` and `SystemOneContent.array(...)`, serialized as JSON text. Send 1–64 named questions; choice and score questions need 2–26 criteria. A `noul` answer is a probability of true. A score is the probability-weighted average of zero-based criterion indices. Confidence measures probability concentration, not calibrated correctness. Questions are evaluated independently against the shared state. Ollama Cloud and MLX/Safetensors runners do not support this endpoint.

→ [Full example with all question types](example/system_one_example.dart)

### How do I upload files to create a model?

Use `client.blobs.exists(digest: ...)` and `client.blobs.create(digest: ..., bytes: ...)` against your local server, then pass original file names and their SHA256 digests through `CreateRequest.files`. Blob methods return no JSON payload; an existing blob is a successful upload, and only a missing blob returns `false` from `exists`.

```dart
import 'package:ollama_dart/ollama_dart.dart';

Future<void> importModelFile({
  required OllamaClient client,
  required String fileName,
  required String digest,
  required List<int> bytes,
  required String modelName,
}) async {
  if (!await client.blobs.exists(digest: digest)) {
    await client.blobs.create(digest: digest, bytes: bytes);
  }
  await client.models.create(
    request: CreateRequest(model: modelName, files: {fileName: digest}),
  );
}
```

Supply the SHA256 digest of the same bytes passed to this function.

Keep split GGUF shard names intact and upload every shard. GGUF weights must be quantized before import; `quantize` and `draftQuantize` apply during Safetensors import. LoRA adapters are no longer supported by current Ollama servers; the existing `adapters` field remains for older-server compatibility.

→ [Full file-upload and model-import example](example/blobs_example.dart)

### How do I search and fetch the web?

Use an explicit cloud client with your Ollama API key. Local Ollama's experimental web proxy paths are outside these methods.

```dart
final client = OllamaClient.withApiKey(
  apiKey,
  baseUrl: 'https://ollama.com',
);
try {
  final results = await client.web.search(
    request: const WebSearchRequest(query: 'Dart isolates', maxResults: 3),
  );
  for (final result in results.results ?? <WebSearchResult>[]) {
    print('${result.title}: ${result.url}');
  }
  final page = await client.web.fetch(
    request: const WebFetchRequest(url: 'https://dart.dev'),
  );
  print(page.content);
} finally {
  client.close();
}
```

Omit `maxResults` to use the service default of 5; the maximum is 10. Web fetch accepts a single URL and returns its title, extracted content, and links.

→ [Full example](example/web_example.dart)

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
| [`system_one_example.dart`](example/system_one_example.dart) | Choice, yes/no, and score decisions |
| [`blobs_example.dart`](example/blobs_example.dart) | Binary upload and file-based model creation |
| [`web_example.dart`](example/web_example.dart) | Hosted web search and page fetch |
| [`image_generation_example.dart`](example/image_generation_example.dart) | Experimental image generation (unavailable in Ollama 0.35.0) |
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
| Blobs | ✅ Existence checks and binary uploads |
| System One | ✅ Local decision API; requires Ollama v0.35.0+ |
| Web search / fetch | ✅ Hosted endpoints with explicit cloud configuration |
| Version | ✅ Full |

Coverage targets Ollama's public native API and hosted web tools. Existing experimental image-generation fields remain available for compatible servers; Ollama 0.35.0 rejects image generation. OpenAI and Anthropic compatibility endpoints can be used through [openai_dart](../openai_dart) and [anthropic_sdk_dart](../anthropic_sdk_dart); experimental server-control routes and debug fields are excluded.

## Official Documentation

- [API reference](https://pub.dev/documentation/ollama_dart/latest/)
- [Ollama API docs](https://docs.ollama.com/api/introduction)
- [System One API](https://docs.ollama.com/api/systemone)
- [Web search and fetch](https://docs.ollama.com/capabilities/web-search)
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
