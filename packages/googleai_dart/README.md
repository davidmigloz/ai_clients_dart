# Google AI & Vertex AI Gemini API Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![googleai_dart](https://img.shields.io/pub/v/googleai_dart.svg)](https://pub.dev/packages/googleai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[Google AI Gemini Developer API](https://ai.google.dev/gemini-api/docs)** and **[Vertex AI Gemini API](https://cloud.google.com/vertex-ai/generative-ai/docs/overview)** with text generation, image generation, tool calling, grounding tools, Live API WebSocket sessions, service tier routing, and embeddings. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!NOTE]
> The official [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) Dart package has been deprecated in favor of [`firebase_ai`](https://pub.dev/packages/firebase_ai). However, since [`firebase_ai`](https://pub.dev/packages/firebase_ai) is a **Flutter package** rather than a **pure Dart package**, this **unofficial client** bridges the gap by providing a **pure Dart, fully type-safe** API client for both Google AI and Vertex AI.

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

### Core Gemini APIs

- Text generation, image generation, streaming, token counting, and multimodal prompts
- Embeddings, model discovery, and context caching
- Tool calling plus structured outputs through typed schemas
- Service tier selection (`standard`, `flex`, `priority`) per request
- Long-running operations, pagination helpers, and retries

### Grounding and retrieval tools

- Google Search, URL Context, Google Maps, and File Search tools
- Files, cached contents, corpora, file search stores, and batch operations
- Interactions and Live API WebSocket flows with code execution and MCP server integration

### Google AI and Vertex AI support

- Google AI API key workflows for hosted Gemini access
- Vertex AI project and location routing with OAuth auth providers
- Auth tokens and tuned models for ephemeral auth and tuned model workflows
- One Dart client surface for server apps, CLIs, and Flutter codebases

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- One package supports both Google AI and Vertex AI without duplicated abstractions.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

```yaml
dependencies:
  googleai_dart: ^6.0.0
```

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Explain why Dart works well for APIs.')],
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
<summary><b>Configure Google AI, Vertex AI, auth providers, and retries</b></summary>

Use `GoogleAIClient.fromEnvironment()` for the default `GOOGLE_GENAI_API_KEY` workflow. Switch to `GoogleAIConfig.googleAI(...)` or `GoogleAIConfig.vertexAI(...)` when you need alternate auth placement, custom headers, or Vertex-specific project routing.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final googleClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
      timeout: const Duration(minutes: 2),
      retryPolicy: RetryPolicy.defaultPolicy,
    ),
  );

  final vertexClient = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: 'your-project-id',
      location: 'us-central1',
      authProvider: BearerTokenProvider('YOUR_ACCESS_TOKEN'),
    ),
  );

  googleClient.close();
  vertexClient.close();
}
```

Environment variable:

- `GOOGLE_GENAI_API_KEY`

Use explicit configuration on web builds where runtime environment variables are not available.

**API Versions:**

Google AI supports both stable and beta API versions, and `googleai_dart` exposes them through the same config object.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final stableClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1,
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
    ),
  );

  final betaClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1beta,
      authProvider: ApiKeyProvider('YOUR_API_KEY'),
    ),
  );

  stableClient.close();
  betaClient.close();
}
```

- `v1` is the stable choice for production rollouts.
- `v1beta` exposes preview features earlier and is the default for Google AI.

**Vertex AI:**

Use Vertex AI when you need OAuth-based auth, GCP project scoping, or enterprise controls such as regional routing and broader Google Cloud integration.

```dart
import 'package:googleai_dart/googleai_dart.dart';

class MyOAuthProvider implements AuthProvider {
  @override
  Future<AuthCredentials> getCredentials() async {
    return BearerTokenCredentials('YOUR_ACCESS_TOKEN');
  }
}

Future<void> main() async {
  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: 'your-project-id',
      location: 'us-central1',
      authProvider: MyOAuthProvider(),
    ),
  );

  client.close();
}
```

Vertex AI setup requirements:

- A GCP project with Vertex AI enabled
- OAuth 2.0 credentials or a service account flow
- A valid project ID and location such as `us-central1` or `global` (the `global` location uses `aiplatform.googleapis.com` instead of a regional endpoint)

</details>

## Usage

### How do I generate text with Gemini?

<details>
<summary><b>Show example</b></summary>

`client.models.generateContent(...)` is the core entry point for most Gemini use cases. The `response.text` extension keeps simple text generation ergonomic for Dart and Flutter code.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Explain what hot restart does in Flutter.')],
        // Optional: route to a specific service tier (standard, flex, priority)
        serviceTier: ServiceTier.flex,
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/generate_content.dart)

</details>

### How do I stream Gemini output?

<details>
<summary><b>Show example</b></summary>

Streaming uses the same request type as normal generation, so you can switch between buffered and incremental output without changing the rest of your app code.

```dart
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    await for (final chunk in client.models.streamGenerateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Write a short poem about Dart streams.')],
      ),
    )) {
      final text = chunk.text;
      if (text != null) {
        stdout.write(text);
      }
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/streaming_example.dart)

</details>

### How do I generate images?

<details>
<summary><b>Show example</b></summary>

Image generation uses `responseModalities` on the same generation endpoint, which keeps multimodal workflows inside one Gemini client. The `response.data` helper gives access to the generated image bytes.

```dart
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash-image',
      request: GenerateContentRequest(
        contents: [Content.text('A clean geometric poster about Flutter')],
        generationConfig: const GenerationConfig(
          responseModalities: [ResponseModality.text, ResponseModality.image],
        ),
      ),
    );

    final imageData = response.data;
    if (imageData != null) {
      print(base64Decode(imageData).length);
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/image_generation_example.dart)

</details>

### How do I generate speech?

<details>
<summary><b>Show example</b></summary>

Gemini TTS models reuse the same `generateContent` endpoint with `ResponseModality.audio` and a `SpeechConfig`. Use audio tags in square brackets (e.g. `[whispers]`, `[excited]`) to steer delivery. The response carries 24 kHz, 16-bit, mono PCM in `response.data` — wrap it in a WAV header before writing `.wav`.

```dart
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.1-flash-tts-preview',
      request: GenerateContentRequest(
        contents: [
          Content.text('[excited] Welcome to the show! [short pause] Let\'s begin.'),
        ],
        generationConfig: GenerationConfig(
          responseModalities: const [ResponseModality.audio],
          speechConfig: SpeechConfig.withVoice('Kore'),
        ),
      ),
    );

    final pcm = response.data;
    if (pcm != null) {
      print('Received ${base64Decode(pcm).length} bytes of PCM audio');
    }
  } finally {
    client.close();
  }
}
```

→ [Full example](example/tts_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Gemini tool calling uses typed `FunctionDeclaration` definitions inside `Tool` objects. This keeps the tool schema local to the request and easy to share across Dart services.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('What is the weather in Madrid?')],
        tools: [
          Tool(
            functionDeclarations: [
              FunctionDeclaration(
                name: 'get_weather',
                description: 'Get current weather',
                parameters: Schema(
                  type: SchemaType.object,
                  properties: {
                    'location': Schema(type: SchemaType.string),
                  },
                  required: ['location'],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/function_calling_example.dart)

</details>

### How do I ground responses with Google data?

<details>
<summary><b>Show example</b></summary>

Grounding tools let Gemini call Google Search, URL Context, Maps, or File Search without leaving the same client surface. Use these when you need fresher answers or source-aware responses in Dart and Flutter apps.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('What are the latest Dart language updates?')],
        tools: [Tool(googleSearch: GoogleSearch())],
      ),
    );

    print(response.text);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/google_search_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Embeddings are a first-class resource and support multimodal models. This makes retrieval and semantic search pipelines straightforward to build in pure Dart.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final response = await client.models.embedContent(
      model: 'gemini-embedding-2-preview',
      request: EmbedContentRequest(
        content: Content.text('Dart language'),
        taskType: TaskType.retrievalDocument,
      ),
    );

    print(response.embedding.values.length);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I upload files for prompts?

<details>
<summary><b>Show example</b></summary>

The Google AI Files API is useful for large prompts and multimodal workflows. For Vertex AI, use Cloud Storage URIs instead of this resource.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    final file = await client.files.upload(
      filePath: '/path/to/image.jpg',
      mimeType: 'image/jpeg',
      displayName: 'Sample image',
    );

    print(file.uri);
  } finally {
    client.close();
  }
}
```

→ [Full example](example/files_example.dart)

</details>

### How do I use the Live API?

<details>
<summary><b>Show example</b></summary>

The Live API gives you bidirectional WebSocket sessions for text and audio. It supports audio input at 16kHz PCM, audio output at 24kHz PCM, session resumption with resumption tokens, and VAD (voice activity detection). Use `createLiveClient()` when you need realtime interactions beyond regular streaming responses.

```dart
import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();
  final liveClient = client.createLiveClient();

  try {
    final session = await liveClient.connect(
      model: 'gemini-2.0-flash-live-001',
    );

    session.sendText('Hello! Tell me a short joke.');
    await session.close();
  } finally {
    await liveClient.close();
    client.close();
  }
}
```

→ [Full example](example/live_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle API failures, rate limits, canceled requests, and live session errors</b></summary>

`googleai_dart` throws typed exceptions for REST and Live API failures, which keeps retries and fallbacks explicit. Catch `ApiException` and its subclasses first, then fall back to `GoogleAIException` for other client-side failures.

```dart
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    await client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Ping')],
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Gemini API error ${error.statusCode}: ${error.message}');
  } on GoogleAIException catch (error) {
    stderr.writeln('Google AI client error: $error');
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
| [`abort_example.dart`](example/abort_example.dart) | Request cancellation with abort triggers |
| [`api_versions_example.dart`](example/api_versions_example.dart) | API version selection (v1 vs v1beta) |
| [`auth_tokens_example.dart`](example/auth_tokens_example.dart) | Ephemeral token authentication |
| [`batch_example.dart`](example/batch_example.dart) | Batch operations |
| [`batches_example.dart`](example/batches_example.dart) | Batch resource management |
| [`cached_contents_example.dart`](example/cached_contents_example.dart) | Context caching |
| [`caching_example.dart`](example/caching_example.dart) | Context caching API usage |
| [`complete_api_example.dart`](example/complete_api_example.dart) | Complete API coverage demo |
| [`corpora_example.dart`](example/corpora_example.dart) | Corpus management for semantic retrieval |
| [`documents_example.dart`](example/documents_example.dart) | Document management within corpora |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`example.dart`](example/example.dart) | Quick-start usage |
| [`file_search_example.dart`](example/file_search_example.dart) | File search with semantic retrieval |
| [`file_search_stores_example.dart`](example/file_search_stores_example.dart) | File search store management |
| [`files_example.dart`](example/files_example.dart) | File uploads for prompts |
| [`function_calling_example.dart`](example/function_calling_example.dart) | Tool calling |
| [`generate_answer_example.dart`](example/generate_answer_example.dart) | Grounded question answering (RAG) |
| [`generate_content.dart`](example/generate_content.dart) | Basic text generation |
| [`generated_files_example.dart`](example/generated_files_example.dart) | Generated files for video outputs |
| [`google_maps_example.dart`](example/google_maps_example.dart) | Google Maps grounding |
| [`google_search_example.dart`](example/google_search_example.dart) | Grounding with Google Search |
| [`image_generation_example.dart`](example/image_generation_example.dart) | Image generation |
| [`interactions_example.dart`](example/interactions_example.dart) | Server-side conversation state management |
| [`live_example.dart`](example/live_example.dart) | Live API WebSocket sessions |
| [`models_example.dart`](example/models_example.dart) | List and inspect models |
| [`oauth_refresh_example.dart`](example/oauth_refresh_example.dart) | OAuth token refresh during retries |
| [`operations_example.dart`](example/operations_example.dart) | Long-running operations management |
| [`pagination_example.dart`](example/pagination_example.dart) | Paginated list results |
| [`permissions_example.dart`](example/permissions_example.dart) | Permission management for resources |
| [`prediction_example.dart`](example/prediction_example.dart) | Video generation with Veo model |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`tts_example.dart`](example/tts_example.dart) | Text-to-speech with Gemini TTS models |
| [`tuned_model_generation_example.dart`](example/tuned_model_generation_example.dart) | Generate content with tuned models |
| [`tuned_models_example.dart`](example/tuned_models_example.dart) | Tuned model workflows |
| [`url_context_example.dart`](example/url_context_example.dart) | URL content fetching and analysis |
| [`vertex_ai_example.dart`](example/vertex_ai_example.dart) | Vertex AI configuration |

## API Coverage

| API | Status |
|-----|--------|
| Models | ✅ Full |
| Tuned Models | ✅ Full |
| Files | ✅ Full |
| Generated Files | ✅ Full |
| Cached Contents | ✅ Full |
| Batches | ✅ Full |
| Corpora | ✅ Full |
| File Search Stores | ✅ Full |
| Interactions (Experimental) | ✅ Full |
| Auth Tokens | ✅ Full |
| Live API (WebSocket) | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/googleai_dart/latest/)
- [Google AI Gemini API docs](https://ai.google.dev/gemini-api/docs)
- [Vertex AI Gemini API docs](https://cloud.google.com/vertex-ai/generative-ai/docs/overview)
- [Google GenAI Python SDK](https://github.com/googleapis/python-genai)
- [Google GenAI JS/TS SDK](https://github.com/googleapis/js-genai)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by Google.
