# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Unofficial Dart client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)** to build with GPT-5.2, Responses API, GPT Image 1.5, Sora, Whisper, Embeddings, and more.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Why choose this client?](#why-choose-this-client)
- [Quickstart](#quickstart)
- [Installation](#installation)
- [Import Structure](#import-structure)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [API Coverage](#api-coverage)
- [License](#license)

</details>

## Features

### Responses API

- Response creation (`responses.create`)
- Streaming support (`responses.createStream`) with SSE
- Built-in tools (web search, file search, code interpreter, computer use)
- Multi-turn conversations with `previousResponseId`
- Structured output and JSON schema
- Background mode and reasoning

### Chat Completions

- Chat completion creation (`chat.completions.create`)
- Streaming support (`chat.completions.createStream`) with SSE
- Multi-turn conversations
- System messages and developer messages
- JSON mode and structured output

### Tool Use

- Custom function/tool calling
- Tool choice modes (auto, none, required, function)
- Parallel tool calls
- Tool call streaming with delta accumulation

### Vision

- Image analysis with vision-capable models
- Base64 images (PNG, JPEG, GIF, WebP)
- URL images
- Multiple images in a single request

### Audio

- Text-to-speech (`audio.speech.create`)
- Speech-to-text (`audio.transcriptions.create`)
- Audio translation (`audio.translations.create`)
- Multiple voices and formats

### Images (GPT Image)

- Image generation (`images.generate`) with GPT Image 1.5
- Image editing with masks (`images.edit`)
- Image variations (`images.createVariation`)
- Multiple sizes and formats

### Embeddings

- Embedding creation (`embeddings.create`)
- Batch embeddings
- Dimension control (for text-embedding-3 models)

### Files & Uploads

- File upload for fine-tuning and assistants
- Large file uploads with multipart support
- File listing and retrieval

### Batches

- Batch request creation
- Batch status monitoring
- Batch result retrieval

### Fine-tuning

- Fine-tuning job creation
- Job monitoring and cancellation
- Checkpoint management

### Moderations

- Content moderation
- Text and image moderation
- Category-specific scores

### Realtime API

- WebSocket-based real-time conversations
- WebRTC support via HTTP SDP signaling (`realtimeSessions.calls`)
- Call management (create, accept, reject, refer, hangup)
- Audio input/output streaming
- Server and client events

### Evals API

- Evaluation creation and management
- Multiple grader types (string check, text similarity, label model, score model, python)
- Run management with data sources (JSONL, completions, responses)
- Output item analysis with pass/fail results
- Status polling helpers

### Videos API (Sora)

- Video generation (`videos.create`)
- Video status polling (`videos.retrieve`)
- Content download (video, thumbnail, spritesheet)
- Video remix (`videos.remix`)

### Conversations API

- Server-side conversation state management
- Long-term storage (no 30-day TTL)
- Integration with Responses API
- Items management (add, list, retrieve, delete)

### Containers API

- Isolated execution environments
- Container file management
- File upload and content retrieval

### ChatKit API (Beta)

- Chat UI toolkit powered by workflows
- Session management with client secrets
- Thread and item management

### Assistants API (Deprecated)

> **Deprecated**: Use the Responses API instead. Import from `package:openai_dart/openai_dart_assistants.dart`.

- Assistant creation and management
- Thread management
- Messages and runs
- Streaming run events
- Tool integration (code interpreter, file search)

### Vector Stores (Deprecated)

> **Deprecated**: Part of Assistants API. Import from `package:openai_dart/openai_dart_assistants.dart`.

- Vector store management
- File batch processing
- File search integration

## Why choose this client?

- Type-safe with sealed classes
- Minimal dependencies (http, logging, meta, web_socket only)
- Works on all compilation targets (native, web, WASM)
- Interceptor-driven architecture
- Comprehensive error handling
- Automatic retry with exponential backoff
- SSE streaming support
- Resource-based API design matching official SDKs

## Quickstart

```dart
import 'package:openai_dart/openai_dart.dart';

void main() async {
  final client = OpenAIClient.withApiKey('YOUR_API_KEY');

  final response = await client.responses.create(
    CreateResponseRequest(
      model: 'gpt-5.2',
      input: ResponseInput.text('What is the capital of France?'),
    ),
  );

  print(response.outputText); // Paris is the capital of France.

  client.close();
}
```

## Installation

```yaml
dependencies:
  openai_dart: ^x.y.z
```

## Platform Support

| Platform | Status |
|----------|--------|
| Dart VM | ✅ Full support |
| Flutter (iOS/Android) | ✅ Full support |
| Flutter Web | ✅ Full support |
| WASM | ✅ Full support |

## Import Structure

The package provides multiple entry points for different APIs:

### Main Entry Point (Recommended)

```dart
import 'package:openai_dart/openai_dart.dart';
```

Includes: Chat Completions, Responses API, Embeddings, Images, Videos, Audio, Files, Batches, Fine-tuning, Moderations, Evals, Conversations, Containers, ChatKit.

### Assistants API (Deprecated)

```dart
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;
```

Includes: Assistants, Threads, Messages, Runs, Vector Stores.

> **Note**: The Assistants API is being deprecated by OpenAI. Use the Responses API instead.

### Realtime API

```dart
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
```

Includes: Real-time conversations via WebSocket (audio streaming) and WebRTC (HTTP-based SDP signaling).

### Handling Name Conflicts

When using multiple entry points, use import prefixes to avoid naming conflicts:

```dart
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

// Responses API types (modern, recommended)
final tool = CodeInterpreterTool();

// Assistants API types (deprecated)
final assistantTool = assistants.CodeInterpreterTool();

// Realtime API types
final rtEvent = realtime.ResponseCreatedEvent(...);
```

## Configuration

<details>
<summary><b>Configuration Options</b></summary>

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
    baseUrl: 'https://api.openai.com/v1', // Default
    timeout: Duration(minutes: 10),
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

### Responses API

<details>
<summary><b>Responses API Example</b></summary>

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-5.2',
    input: ResponseInput.text('What is the capital of France?'),
  ),
);

print('Response: ${response.outputText}');
print('Usage: ${response.usage}');

client.close();
```

</details>

### Basic Chat Completion

<details>
<summary><b>Chat Completion Example</b></summary>

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.2',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    maxTokens: 100,
  ),
);

print('Response: ${response.text}');
print('Finish reason: ${response.choices.first.finishReason}');
print('Usage: ${response.usage?.promptTokens} in, ${response.usage?.completionTokens} out');

client.close();
```

</details>

### Streaming

<details>
<summary><b>Streaming Example</b></summary>

```dart
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-5.2',
    messages: [ChatMessage.user('Tell me a story')],
  ),
);

await for (final event in stream) {
  stdout.write(event.textDelta ?? '');
}
```

</details>

### Tool Calling

<details>
<summary><b>Tool Calling Example</b></summary>

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.2',
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

</details>

### Vision

<details>
<summary><b>Vision Example</b></summary>

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.2',
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

</details>

### Embeddings

<details>
<summary><b>Embeddings Example</b></summary>

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

</details>

### Image Generation

<details>
<summary><b>Image Generation Example</b></summary>

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

</details>

### Audio

<details>
<summary><b>Text-to-Speech Example</b></summary>

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

</details>

<details>
<summary><b>Speech-to-Text Example</b></summary>

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

</details>

### Realtime API

<details>
<summary><b>WebSocket Connection Example</b></summary>

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

</details>

<details>
<summary><b>WebRTC Call Example</b></summary>

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

</details>

### Completions (Legacy)

<details>
<summary><b>Completions Example</b></summary>

```dart
final completion = await client.completions.create(
  CompletionRequest(
    model: 'gpt-3.5-turbo-instruct',
    prompt: CompletionPrompt.text('Say this is a test'),
    maxTokens: 10,
  ),
);
print(completion.text);
```

</details>

### Files

<details>
<summary><b>Files Example</b></summary>

```dart
final file = await client.files.upload(
  bytes: fileBytes,
  filename: 'training.jsonl',
  purpose: FilePurpose.fineTune,
);

final files = await client.files.list();
final content = await client.files.retrieveContent(file.id);
```

</details>

### Uploads

<details>
<summary><b>Uploads Example</b></summary>

```dart
// Create an upload for a large file
final upload = await client.uploads.create(
  CreateUploadRequest(
    filename: 'large-file.jsonl',
    purpose: FilePurpose.fineTune,
    bytes: fileSize,
    mimeType: 'application/jsonl',
  ),
);

// Add parts and complete
final part = await client.uploads.addPart(upload.id, data: chunkBytes);
final completed = await client.uploads.complete(
  upload.id,
  partIds: [part.id],
);
```

</details>

### Batches

<details>
<summary><b>Batches Example</b></summary>

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

</details>

### Models

<details>
<summary><b>Models Example</b></summary>

```dart
final models = await client.models.list();
for (final model in models.data) {
  print(model.id);
}

final gpt4o = await client.models.retrieve('gpt-4o');
```

</details>

### Moderations

<details>
<summary><b>Moderations Example</b></summary>

```dart
final result = await client.moderations.create(
  ModerationRequest(
    input: ModerationInput.text('Check this text'),
  ),
);
print('Flagged: ${result.results.first.flagged}');
```

</details>

### Fine-tuning

<details>
<summary><b>Fine-tuning Example</b></summary>

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

</details>

### Evals

<details>
<summary><b>Evals Example</b></summary>

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

</details>

### Videos (Sora)

<details>
<summary><b>Videos Example</b></summary>

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

</details>

### Conversations

<details>
<summary><b>Conversations Example</b></summary>

```dart
final conversation = await client.conversations.create(
  ConversationCreateRequest(
    items: [MessageItem.userText('Hello!')],
  ),
);

final items = await client.conversations.items.list(conversation.id);
await client.conversations.delete(conversation.id);
```

</details>

### Containers

<details>
<summary><b>Containers Example</b></summary>

```dart
final container = await client.containers.create(
  CreateContainerRequest(name: 'my-container'),
);

final files = await client.containers.files.list(container.id);
await client.containers.delete(container.id);
```

</details>

### ChatKit (Beta)

<details>
<summary><b>ChatKit Example</b></summary>

```dart
final session = await client.chatkit.sessions.create(
  CreateChatSessionRequest(
    workflow: WorkflowParam(id: 'workflow-abc'),
    user: 'user-123',
  ),
);

final threads = await client.chatkit.threads.list();
```

</details>

### Skills

<details>
<summary><b>Skills Example</b></summary>

```dart
final skills = await client.skills.list();
final skill = await client.skills.retrieve('skill-abc123');
final versions = await client.skills.versions.list('skill-abc123');
```

</details>

### Input Tokens

<details>
<summary><b>Input Tokens Example</b></summary>

```dart
final tokenCount = await client.responses.inputTokens.count(
  model: 'gpt-4o',
  input: ResponseInput.text('Hello, how are you?'),
);
print('Input tokens: ${tokenCount.inputTokens}');
```

</details>

## Extension Methods

The package provides convenient extension methods for common operations:

### Stream Extensions

```dart
// Collect all text from a streaming response
final text = await stream.collectText();

// Iterate only text deltas
await for (final delta in stream.textDeltas()) {
  stdout.write(delta);
}

// Accumulate streaming chunks into a complete response
await for (final accumulated in stream.accumulate()) {
  print('Content so far: ${accumulated.content}');
}

// Or use ChatStreamAccumulator directly for full control
final accumulator = ChatStreamAccumulator();
await for (final event in stream) {
  accumulator.add(event);
}
// Build a ChatCompletion from the accumulated stream data
final completion = accumulator.toChatCompletion();
print(completion.text);
```

### Message List Extensions

```dart
// Build message lists fluently
final messages = <ChatMessage>[]
  .withSystemMessage('You are helpful')
  .withUserMessage('Hello!');
```

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
| [`videos_example.dart`](example/videos_example.dart) | Sora video generation |
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
| ChatKit (Beta) | ✅ Full |
| Realtime | ✅ Full (separate import) |
| Assistants (Deprecated) | ✅ Full (separate import) |
| Threads (Deprecated) | ✅ Full (separate import) |
| Messages (Deprecated) | ✅ Full (separate import) |
| Runs (Deprecated) | ✅ Full (separate import) |
| Vector Stores (Deprecated) | ✅ Full (separate import) |
| Completions (Legacy) | ✅ Full |

## Sponsor

If these packages are useful to you or your company, please [sponsor the project](https://github.com/sponsors/davidmigloz). Development and maintenance are provided to the community for free, but integration tests against real APIs and the tooling required to build and verify releases still have real costs. Your support, at any level, helps keep these packages maintained and free for the Dart & Flutter community.

## License

MIT License - see [LICENSE](../../LICENSE) for details.
