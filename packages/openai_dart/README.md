# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)** with Responses API, Chat Completions, images, videos, audio, custom tools, embeddings, evals, realtime, and more. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

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

- Responses API with streaming, multi-turn conversations, structured output, and background mode
- Chat Completions with tool calling, vision, structured output, and streaming
- Images, videos, audio (TTS, transcription, translation), and embeddings
- Realtime API via WebSocket and WebRTC with audio streaming
- Input token counting via `inputTokens` for cost estimation

### Tools

- Web search, file search, code interpreter, computer use, and custom tools

### Operational APIs

- Files, uploads, batches, fine-tuning, moderations, evals, and model management
- Conversations, containers, ChatKit, and skills
- Assistants and vector stores (deprecated — use Responses API instead)

See [API Coverage](#api-coverage) for the full coverage table.

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Covers the full OpenAI API surface, including Responses, Realtime, and legacy Assistants.
- Resource-based API design matching official SDKs
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

```yaml
dependencies:
  openai_dart: ^4.0.0
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.4',
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}
```

### Import structure

The package provides multiple entry points for different APIs:

```dart
// Main entry point (recommended) — includes Chat Completions, Responses API,
// Embeddings, Images, Videos, Audio, Files, Batches, Fine-tuning, and more.
import 'package:openai_dart/openai_dart.dart';

// Assistants API (deprecated — use Responses API instead)
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;

// Realtime API — WebSocket and WebRTC sessions
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
```

## Configuration

<details>
<summary><b>Configure auth, retries, and custom endpoints</b></summary>

Use `OpenAIClient.fromEnvironment()` for the default `OPENAI_API_KEY` workflow. Switch to `OpenAIConfig` when you need a proxy, custom timeout, or a non-default retry policy.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.openai.com/v1', // Default
    timeout: Duration(minutes: 10),
    connectTimeout: Duration(seconds: 30),
    retryPolicy: RetryPolicy(maxRetries: 3),
    organization: 'org-xxx', // Optional
    project: 'proj-xxx', // Optional
  ),
);
```

**From environment variables:**

```dart
final client = OpenAIClient.fromEnvironment();
// Reads OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_ORG_ID, OPENAI_PROJECT_ID
```

**With API key directly:**

```dart
final client = OpenAIClient.withApiKey('sk-...');
```

**Custom base URL (for proxies or Azure):**

```dart
final client = OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'https://my-resource.openai.azure.com/openai/deployments/my-deployment',
    authProvider: AzureApiKeyProvider('YOUR_AZURE_KEY'),
  ),
);
```

</details>

## Usage

### How do I create a response?

<details>
<summary><b>Show example</b></summary>

The Responses API is the recommended way to generate text. Pass a model and input, and access the result via `response.outputText`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-5.4',
    input: ResponseInput.text('What is the capital of France?'),
  ),
);

print('Response: ${response.outputText}');
print('Usage: ${response.usage}');

client.close();
```

→ [Full example](example/responses_example.dart)

</details>

### How do I use chat completions?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.completions.create(...)` for multi-turn conversations. The `response.text` convenience getter returns the first choice's message content.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.4',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    maxTokens: 100,
  ),
);

// response.text is a convenience extension for the first choice's message content
print('Response: ${response.text}');
print('Finish reason: ${response.choices.first.finishReason}');
print('Usage: ${response.usage?.promptTokens} in, ${response.usage?.completionTokens} out');

// Build message lists fluently with extension methods
final messages = <ChatMessage>[]
  .withSystemMessage('You are helpful')
  .withUserMessage('Hello!');

client.close();
```

→ [Full example](example/chat_example.dart)

</details>

### How do I stream responses?

<details>
<summary><b>Show example</b></summary>

Streaming returns token-by-token deltas as they arrive. You can iterate text deltas directly, collect all text at once, or accumulate chunks into a complete response object.

```dart
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-5.4',
    messages: [ChatMessage.user('Tell me a story')],
  ),
);

// Iterate text deltas directly
await for (final delta in stream.textDeltas()) {
  stdout.write(delta);
}

// Or collect all text at once
final text = await stream.collectText();

// Or accumulate chunks into a complete ChatCompletion
final accumulator = ChatStreamAccumulator();
await for (final event in stream) {
  accumulator.add(event);
}
final completion = accumulator.toChatCompletion();
print(completion.text);
```

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Define tools with JSON Schema parameters and pass them in the request. The response indicates when the model wants to call a tool, and you can inspect the function name and arguments.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.4',
    messages: [
      ChatMessage.user("What's the weather in Tokyo?"),
    ],
    tools: [
      Tool.function(
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
    ],
  ),
);

if (response.hasToolCalls) {
  for (final toolCall in response.allToolCalls) {
    print('Function: ${toolCall.function.name}');
    print('Arguments: ${toolCall.function.arguments}');
  }
}
```

→ [Full example](example/tool_calling_example.dart)

</details>

### How do I analyze images?

<details>
<summary><b>Show example</b></summary>

Pass image URLs or base64-encoded images as content parts alongside text in a user message.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.4',
    messages: [
      ChatMessage.user([
        ContentPart.text('What is in this image?'),
        ContentPart.imageUrl('https://example.com/image.jpg'),
      ]),
    ],
  ),
);

print(response.text);
```

→ [Full example](example/vision_example.dart)

</details>

### How do I create embeddings?

<details>
<summary><b>Show example</b></summary>

Use `client.embeddings.create(...)` to generate vector representations of text. You can optionally reduce dimensions for smaller storage.

```dart
final response = await client.embeddings.create(
  EmbeddingRequest(
    model: 'text-embedding-3-small',
    input: EmbeddingInput.text('Hello, world!'),
    dimensions: 256, // Optional: reduce dimensions
  ),
);

final vector = response.firstEmbedding;
print('Embedding dimensions: ${vector.length}');
```

→ [Full example](example/embeddings_example.dart)

</details>

### How do I generate images?

<details>
<summary><b>Show example</b></summary>

Use `client.images.generate(...)` to create images from text prompts. Configure size, quality, and other options as needed.

```dart
final response = await client.images.generate(
  ImageGenerationRequest(
    model: 'gpt-image-1.5',
    prompt: 'A white cat wearing a top hat',
    size: ImageSize.size1024x1024,
    quality: ImageQuality.hd,
  ),
);

print('Image URL: ${response.data.first.url}');
```

→ [Full example](example/images_example.dart)

</details>

### How do I use audio?

<details>
<summary><b>Show example</b></summary>

The audio API supports both text-to-speech and speech-to-text. Use `client.audio.speech.create(...)` for TTS and `client.audio.transcriptions.create(...)` for transcription.

**Text-to-Speech:**

```dart
final audioBytes = await client.audio.speech.create(
  SpeechRequest(
    model: 'tts-1',
    input: 'Hello! How are you today?',
    voice: SpeechVoice.nova,
  ),
);

File('output.mp3').writeAsBytesSync(audioBytes);
```

**Speech-to-Text:**

```dart
final response = await client.audio.transcriptions.create(
  TranscriptionRequest(
    file: File('audio.mp3').readAsBytesSync(),
    filename: 'audio.mp3',
    model: 'whisper-1',
  ),
);

print('Transcription: ${response.text}');
```

→ [Full example](example/audio_example.dart)

</details>

### How do I use the Realtime API?

<details>
<summary><b>Show example</b></summary>

The Realtime API supports two transports: WebSocket for persistent bidirectional streaming, and WebRTC for browser-friendly audio sessions.

**WebSocket:**

```dart
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// Connect to a realtime session via WebSocket
final session = await client.realtime.connect(
  model: 'gpt-realtime-1.5',
  config: const realtime.SessionUpdateConfig(
    voice: realtime.RealtimeVoice.alloy,
    instructions: 'You are a helpful assistant.',
  ),
);

// Send a request and process events until the response is complete
session.createResponse();

await for (final event in session.events) {
  switch (event) {
    case realtime.SessionCreatedEvent(:final session):
      print('Session created: ${session.id}');
    case realtime.ResponseTextDeltaEvent(:final delta):
      stdout.write(delta);
    case realtime.ResponseDoneEvent():
      await session.close();
    case realtime.ErrorEvent(:final error):
      print('Error: ${error.message}');
      await session.close();
    default:
      break;
  }
}

client.close();
```

**WebRTC:**

> **Note:** For WebRTC peer connections in Flutter, use the
> [`flutter_webrtc`](https://pub.dev/packages/flutter_webrtc) package.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

final client = OpenAIClient.fromEnvironment();

// 1. Create a peer connection and generate an SDP offer
final pc = await createPeerConnection({'iceServers': []});
final offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// 2. Send the SDP offer to OpenAI and get the SDP answer
final sdpAnswer = await client.realtimeSessions.calls.create(
  realtime.RealtimeCallCreateRequest(
    sdp: offer.sdp!,
    session: const realtime.RealtimeSessionCreateRequest(
      model: 'gpt-realtime-1.5',
      voice: realtime.RealtimeVoice.alloy,
    ),
  ),
);

// 3. Set the SDP answer to complete the WebRTC handshake
await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

// Call management operations (callId is obtained from your SIP/telephony layer)
const callId = 'call_xxx';
await client.realtimeSessions.calls.accept(callId);
await client.realtimeSessions.calls.hangup(callId);
await client.realtimeSessions.calls.refer(
  callId,
  realtime.RealtimeCallReferRequest(targetUri: 'tel:+14155550123'),
);
await client.realtimeSessions.calls.reject(
  callId,
  request: realtime.RealtimeCallRejectRequest(statusCode: 486),
);

client.close();
```

→ [Full example](example/realtime_example.dart)

</details>

### How do I generate videos?

<details>
<summary><b>Show example</b></summary>

Use `client.videos.create(...)` to generate videos from text prompts with Sora. Poll with `retrieve` until the video is complete, then download the content.

```dart
final video = await client.videos.create(
  CreateVideoRequest(
    prompt: 'A cat playing piano in a jazz club',
    model: 'sora-2',
    size: VideoSize.size1280x720,
    seconds: VideoSeconds.s8,
  ),
);

final status = await client.videos.retrieve(video.id);
if (status.isCompleted) {
  final content = await client.videos.retrieveContent(video.id);
}
```

→ [Full example](example/videos_example.dart)

</details>

### How do I manage files?

<details>
<summary><b>Show example</b></summary>

Use the files API to upload, list, and retrieve file content. Files are used for fine-tuning, batches, and other workflows.

```dart
final file = await client.files.upload(
  bytes: fileBytes,
  filename: 'training.jsonl',
  purpose: FilePurpose.fineTune,
);

final files = await client.files.list();
final content = await client.files.retrieveContent(file.id);
```

→ [Full example](example/files_example.dart)

</details>

### How do I fine-tune a model?

<details>
<summary><b>Show example</b></summary>

Create a fine-tuning job by specifying a base model and a training file. Poll the job status to monitor progress and retrieve the fine-tuned model name when complete.

```dart
final job = await client.fineTuning.jobs.create(
  CreateFineTuningJobRequest(
    model: 'gpt-4o-mini-2024-07-18',
    trainingFile: 'file-abc123',
  ),
);

final status = await client.fineTuning.jobs.retrieve(job.id);
print('Fine-tuned model: ${status.fineTunedModel}');
```

→ [Full example](example/fine_tuning_example.dart)

</details>

### How do I use batch processing?

<details>
<summary><b>Show example</b></summary>

Batches let you queue many requests for asynchronous processing at lower cost. Create a batch from an input file and poll for completion.

```dart
final batch = await client.batches.create(
  CreateBatchRequest(
    inputFileId: 'file-abc123',
    endpoint: BatchEndpoint.chatCompletions,
    completionWindow: CompletionWindow.hours24,
  ),
);

final status = await client.batches.retrieve(batch.id);
print('Status: ${status.status}');
```

→ [Full example](example/batches_example.dart)

</details>

### How do I evaluate models?

<details>
<summary><b>Show example</b></summary>

Use the evals API to create evaluation definitions with grading criteria, then run them against test data to measure model performance.

```dart
final eval = await client.evals.create(
  CreateEvalRequest(
    name: 'My Evaluation',
    dataSourceConfig: EvalDataSourceConfig.custom(
      itemSchema: {
        'type': 'object',
        'properties': {
          'prompt': {'type': 'string'},
          'expected': {'type': 'string'},
        },
      },
    ),
    testingCriteria: [
      EvalGrader.stringCheck(
        name: 'matches_expected',
        input: '{{sample.output_text}}',
        operation: StringCheckOperation.ilike,
        reference: '%{{item.expected}}%',
      ),
    ],
  ),
);

final run = await client.evals.runs.create(
  eval.id,
  CreateEvalRunRequest(
    dataSource: EvalRunDataSource.jsonlContent([
      {'prompt': 'Say hello', 'expected': 'hello'},
    ]),
  ),
);
```

→ [Full example](example/evals_example.dart)

</details>

### How do I moderate content?

<details>
<summary><b>Show example</b></summary>

Use the moderations API to check whether text violates content policies. The result indicates whether the input was flagged.

```dart
final result = await client.moderations.create(
  ModerationRequest(
    input: ModerationInput.text('Check this text'),
  ),
);
print('Flagged: ${result.results.first.flagged}');
```

→ [Full example](example/moderation_example.dart)

</details>

## Error Handling

<details>
<summary><b>Handle retries, validation failures, and request aborts</b></summary>

`openai_dart` throws typed exceptions so retry logic and validation handling stay explicit. Catch `ApiException` and its subclasses first, then fall back to `OpenAIException` for other transport or parsing failures.

```dart
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.4',
        input: ResponseInput.text('Ping'),
      ),
    );
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('OpenAI API error ${error.statusCode}: ${error.message}');
  } on OpenAIException catch (error) {
    stderr.writeln('OpenAI client error: $error');
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
| [`chat_example.dart`](example/chat_example.dart) | Basic chat completions with multi-turn conversations |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses with text deltas |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Function calling with tool definitions |
| [`vision_example.dart`](example/vision_example.dart) | Image analysis with vision models |
| [`responses_example.dart`](example/responses_example.dart) | Responses API with built-in tools |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings with dimension control |
| [`images_example.dart`](example/images_example.dart) | GPT Image generation |
| [`videos_example.dart`](example/videos_example.dart) | Sora video generation, editing, and extension |
| [`audio_example.dart`](example/audio_example.dart) | Text-to-speech and transcription |
| [`files_example.dart`](example/files_example.dart) | File upload and management |
| [`conversations_example.dart`](example/conversations_example.dart) | Conversations API for state management |
| [`containers_example.dart`](example/containers_example.dart) | Containers for isolated execution |
| [`chatkit_example.dart`](example/chatkit_example.dart) | ChatKit sessions and threads |
| [`assistants_example.dart`](example/assistants_example.dart) | Assistants API (deprecated) |
| [`evals_example.dart`](example/evals_example.dart) | Model evaluation and testing |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`models_example.dart`](example/models_example.dart) | Model listing and retrieval |
| [`batches_example.dart`](example/batches_example.dart) | Batch processing for async jobs |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`web_search_example.dart`](example/web_search_example.dart) | Web search with Responses API |
| [`realtime_example.dart`](example/realtime_example.dart) | Realtime API (WebSocket and WebRTC) |
| [`fine_tuning_example.dart`](example/fine_tuning_example.dart) | Fine-tuning job management |
| [`completions_example.dart`](example/completions_example.dart) | Legacy completions API |
| [`uploads_example.dart`](example/uploads_example.dart) | Large file multipart uploads |
| [`skills_example.dart`](example/skills_example.dart) | Skills management |
| [`input_tokens_example.dart`](example/input_tokens_example.dart) | Input token counting |
| [`openai_dart_example.dart`](example/openai_dart_example.dart) | Quick-start overview |

## API Coverage

| API | Status |
|-----|--------|
| Chat Completions | ✅ Full |
| Responses API | ✅ Full |
| Embeddings | ✅ Full |
| Images | ✅ Full |
| Videos (Sora) | ✅ Full |
| Audio (Speech, Transcription, Translation) | ✅ Full |
| Files | ✅ Full |
| Uploads | ✅ Full |
| Batches | ✅ Full |
| Models | ✅ Full |
| Moderations | ✅ Full |
| Fine-tuning | ✅ Full |
| Evals | ✅ Full |
| Conversations | ✅ Full |
| Containers | ✅ Full |
| ChatKit Beta | ✅ Full |
| Realtime | ✅ Full (separate import) |
| Assistants (Deprecated) | ✅ Full (separate import) |
| Threads (Deprecated) | ✅ Full (separate import) |
| Messages (Deprecated) | ✅ Full (separate import) |
| Runs (Deprecated) | ✅ Full (separate import) |
| Vector Stores (Deprecated) | ✅ Full (separate import) |
| Completions (Legacy) | ✅ Full |

## Official Documentation

- [API reference](https://pub.dev/documentation/openai_dart/latest/)
- [OpenAI API docs](https://platform.openai.com/docs/api-reference)
- [OpenAI Python SDK](https://github.com/openai/openai-python)
- [OpenAI Node.js SDK](https://github.com/openai/openai-node)

## Sponsor

If these packages are useful to you or your company, please consider [sponsoring the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

<p align="center">
  <a href="https://github.com/sponsors/davidmigloz">
    <img src='https://raw.githubusercontent.com/davidmigloz/sponsors/main/sponsors.svg'/>
  </a>
</p>

## License

This package is licensed under the [MIT License](LICENSE).

This is a community-maintained package and is not affiliated with or endorsed by OpenAI.
