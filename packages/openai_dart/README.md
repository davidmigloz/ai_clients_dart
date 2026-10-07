# OpenAI Dart Client

[![tests](https://img.shields.io/github/actions/workflow/status/davidmigloz/ai_clients_dart/test.yaml?logo=github&label=tests)](https://github.com/davidmigloz/ai_clients_dart/actions/workflows/test.yaml)
[![openai_dart](https://img.shields.io/pub/v/openai_dart.svg)](https://pub.dev/packages/openai_dart)
![Discord](https://img.shields.io/discord/1123158322812555295?label=discord)
[![MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://github.com/davidmigloz/ai_clients_dart/blob/main/LICENSE)

Dart client for the **[OpenAI API](https://platform.openai.com/docs/api-reference)** with Responses API, Decisions API, Chat Completions, images, videos, audio, custom tools, embeddings, evals, realtime, and more. It gives Dart and Flutter applications a pure Dart, type-safe client across iOS, Android, macOS, Windows, Linux, Web, and server-side Dart.

> [!TIP]
> Coding agents: start with [llms.txt](./llms.txt). It links to the package docs, examples, and optional references in a compact format.

<details>
<summary><b>Table of Contents</b></summary>

- [Features](#features)
- [Quickstart](#quickstart)
- [Why choose this client?](#why-choose-this-client)
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

- Responses API with streaming, multi-turn conversations, structured output, background mode, cache prewarming, and typed cache diagnostics
- Decisions API for typed predicate, choice, and score answers from text or inline images
- Chat Completions with tool calling, vision, structured output, detailed usage, audio completion/streaming, and obfuscation controls
- Images, videos, audio (TTS, transcription, translation), and embeddings
- Realtime API via WebSocket and WebRTC with audio streaming
- Input token counting via `inputTokens` for cost estimation

### Tools

- Web search, file search, code interpreter, computer use, and custom tools

### Operational APIs

- Files, uploads, batches, fine-tuning, moderations, evals, and model management
- Conversations, containers, content provenance checks, ChatKit, and skills
- Assistants and vector stores (deprecated — use Responses API instead)

See [API Coverage](#api-coverage) for the full coverage table.

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Supports OpenAI generation, media, operational, and Realtime APIs; see the coverage table for remaining gaps.
- Resource-based API design matching official SDKs.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  openai_dart: ^10.0.1
```

```dart
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-5.5',
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

### How do I classify or score shared input?

The [Decisions API](https://developers.openai.com/api/docs/guides/decisions) returns ordered typed answers to predicate, choice, and score questions. It currently supports `gpt-6-luna` and accepts text or inline images.

```dart
final decision = await client.decisions.create(
  DecisionRequest(
    model: 'gpt-6-luna',
    input: DecisionInput.text('The screen arrived broken.'),
    questions: [
      DecisionQuestion.predicate(
        name: 'damaged',
        instructions: 'Does the customer report a damaged item?',
      ),
    ],
  ),
);

for (final answer in decision.answers) {
  if (answer case PredicateDecisionAnswer(:final probability)) {
    print('Damage probability: $probability');
  } else if (answer case RefusalDecisionAnswer()) {
    print('The question was refused.');
  }
}
```

Use `DecisionInput.messages` with `DecisionContent.parts` for mixed text/image input. `DecisionInputPart.image(imageUrl: ...)` accepts a data URL; `DecisionInputPart.imageBytes(bytes, mediaType: 'image/png')` builds the MIME/base64 data URL. Files, external image URLs, other roles, tools, and audio are unsupported. Unset image detail defaults to `auto` on the server.

Requests support 1–200 questions, 2–255 choices per choice question, 2–10 levels per score question, and up to 128 images across all messages. An optional `safetyIdentifier` is limited to 128 characters. Choice values preserve strings and booleans as distinct types; score answers can be fractional. Refusals can occur alongside successful answers. There is no model-event streaming mode.

→ [Full example](example/decisions_example.dart)

### How do I configure an execution container?

Create a standalone container with a memory tier and network policy, then pass its ID to Code Interpreter:

```dart
final container = await client.containers.create(
  CreateContainerRequest(
    name: 'my-container',
    memoryLimit: ContainerMemoryLimit.gb1,
    networkPolicy: ContainerNetworkPolicy.disabled,
  ),
);

final tool = ResponseTool.codeInterpreter(
  container: CodeInterpreterContainer.id(container.id),
);
// Use tool in a Responses request, then delete the container when finished.
await client.containers.delete(container.id);
```

The current memory tiers are `gb1`, `gb4`, `gb16`, and `gb64`, which emit `1g`, `4g`, `16g`, and `64g`. Automatic containers accept the same configuration through `CodeInterpreterContainer.auto(...)`. An allowlist uses `ContainerNetworkPolicy.allowlist(['api.example.com'], domainSecrets: [...])`, with typed `ContainerNetworkPolicyDomainSecret` entries. Secret values are redacted in model diagnostics.

Standalone creation also supports `ContainerSkill.reference(skillId: ..., version: 'latest')` and inline skills whose `ContainerSkillSource.base64(data: ...)` contains an already encoded ZIP bundle. Returned memory/network settings and expiration members can be absent; check them before use. Filter listing with `client.containers.list(name: 'my-container')`.

See the [migration guide](MIGRATION.md#upcoming-container-configuration-corrections) for changes to integer memory values, `allowedHosts`, required names, response expiration, and const construction.

→ [Full example](example/containers_example.dart)

### How do I create a response?

<details>
<summary><b>Show example</b></summary>

The Responses API is the recommended way to generate text. Pass a model and input, and access the result via `response.outputText`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-5.5',
    input: ResponseInput.text('What is the capital of France?'),
  ),
);

print('Response: ${response.outputText}');
print('Usage: ${response.usage}');

client.close();
```

→ [Full example](example/responses_example.dart)

</details>

### How do I prewarm the prompt cache and inspect diagnostics?

<details>
<summary><b>Show example</b></summary>

On supported GPT-5.6 and later models, Responses uses
`ResponsePromptCacheOptionsParam` for mode/TTL, prewarming, and comparison IDs.
Chat and compaction use the narrower `PromptCacheOptionsParam` with mode/TTL only.
A reusable prefix must meet the model's minimum cacheable length (1,024 tokens
for GPT-5.6 and later). Supply your application's stable context as `stablePrefix`;
keep its content and cache-affecting settings stable.

```dart
final baseline = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: const ResponsePromptCacheOptionsParam(prewarm: true),
  ),
);
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text(stablePrefix),
    promptCacheOptions: ResponsePromptCacheOptionsParam(
      ttl: PromptCacheTtl.minutes30,
      comparisonResponseId: baseline.id,
      prewarm: false,
    ),
  ),
);
if (response.promptCacheDiagnostics case PromptCacheMissDiagnostics(:final reason)) {
  print('Cache miss reason: ${reason.value}');
}
print('Cached tokens: ${response.usage?.inputTokensDetails?.cachedTokens}');
```

Use a recent completed baseline from the same organization. A comparison ID
requests diagnostics; it does not load conversation history or change caching.
Diagnostics can be absent, unavailable, or refer to an expired comparison.
A hit means no miss was detected for the comparison; usage counters measure
actual reuse and billing. Future diagnostic variants and reason strings are
preserved. During streaming, inspect `ResponseCompletedEvent.response`.

The existing retention control is deprecated and expresses a maximum policy;
modern TTL expresses a minimum lifetime. They are independent.
See the [migration guide](MIGRATION.md) for the Responses options type change and
[official diagnostics guide](https://developers.openai.com/api/docs/guides/prompt-caching/diagnostics).

→ [Runnable example with bounded output and cleanup](example/prompt_cache_example.dart)

</details>

### How do I use chat completions?

<details>
<summary><b>Show example</b></summary>

Use `client.chat.completions.create(...)` for multi-turn conversations. The `response.text` convenience getter returns the first choice's message content.

The API's existing `promptCacheRetention` setting is deprecated in favor of `prompt_cache_options.ttl`; cache-options alignment is tracked in [#322](https://github.com/davidmigloz/ai_clients_dart/issues/322). For the existing control, `PromptCacheRetention.h24` emits `24h`, while `inMemory` emits the canonical `in_memory`. GPT-5.5 and newer models support only `h24`; select `inMemory` only for models that support it. Legacy `in-memory` JSON still parses, and reserialization uses `in_memory`.

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient.fromEnvironment();

final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
    messages: [
      ChatMessage.system('You are a helpful assistant.'),
      ChatMessage.user('What is the capital of France?'),
    ],
    maxTokens: 100,
    promptCacheRetention: PromptCacheRetention.h24,
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

### How do I generate, replay, and stream Chat audio?

<details>
<summary><b>Show example</b></summary>

Use an audio-capable Chat model and request audio output. Complete output exposes
its ID, base64 data, transcript, and replay expiry; text can be null.

```dart
final completion = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-audio-1.5',
    messages: [ChatMessage.user('Say only OK.')],
    modalities: const [ChatModality.text, ChatModality.audio],
    audio: const ChatAudioConfig(
      voice: ChatAudioVoice.alloy,
      format: ChatAudioFormat.wav,
    ),
    maxCompletionTokens: 128,
    store: false,
  ),
);
if (completion.audio case final audio?) {
  final bytes = base64Decode(audio.data); // import dart:convert
  await File('reply.wav').writeAsBytes(bytes); // import dart:io
  print(audio.transcript);
  final reference = ChatMessage.assistant(
    audio: ChatAudio.reference(id: audio.id),
  );
  // Add reference to a later request before audio.expiresAt.
}
```

`ChatAudioReference` is ID-only; `ChatCompletionAudio` requires all four output
fields. You can reuse the returned assistant message directly: actual request
serialization projects its audio to `{id}` without sending data/transcript/expiry.
Local response serialization retains the complete output and provider extensions.

Stream with PCM16 output and pass events to `ChatStreamAccumulator`. Each
`ChatDelta.audio` is an independent partial update. `accumulator.audio` and each
`accumulator.choices[i].audio` expose stable `ChatAudioDelta` snapshots with
`isComplete`. Data/transcript fragments append separately; ID and expiry update
when supplied. Decode complete data once after accumulation. Usage-only events
and padding stay separate from audio.

`toChatCompletion()` retains complete audio and throws `StateError` if any choice
has incomplete audio, including after interruption; inspect partial snapshots
instead. Text-only conversion behaves as before. A pure final expiry-only update
can infer `stop` during final conversion when every audio field is present, while
raw event and snapshot finish metadata remain unchanged. Reset clears all audio.

→ [Runnable audio, replay, and streaming example](example/chat_audio_example.dart)

See the [official audio guide](https://developers.openai.com/api/docs/guides/audio-chat-completions)
and [migration guide](MIGRATION.md) for parsing and conversion boundaries.

</details>

### How do I stream responses?

<details>
<summary><b>Show example</b></summary>

Streaming returns content deltas plus metadata as they arrive. Request final usage
with `includeUsage`; its additional chunk has an empty `choices` list. Use
`event.textDelta` to safely handle content and usage-only events.

```dart
final accumulator = ChatStreamAccumulator();
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-6-luna',
    reasoningEffort: ReasoningEffort.none,
    messages: [ChatMessage.user('Tell me a short story')],
    maxCompletionTokens: 64,
    store: false,
    streamOptions: const StreamOptions(
      includeUsage: true,
      includeObfuscation: true,
    ),
  ),
);
await for (final event in stream) {
  accumulator.add(event);
  stdout.write(event.textDelta ?? '');
}
final completion = accumulator.toChatCompletion();
print(completion.usage?.promptTokensDetails?.cacheWriteTokens);
print(completion.usage?.promptTokensDetails?.textTokens);
print(completion.usage?.promptTokensDetails?.imageTokens);
print(completion.usage?.completionTokensDetails?.textTokens);
```

Prompt details preserve audio, cached, unadjusted cache-write, image, and text
counts. Completion details preserve audio, reasoning, prediction, and text counts.
These details also work on ordinary completions; missing counters remain absent,
and zero remains zero. Interrupted streams can end before final usage arrives.

`includeObfuscation` controls server padding that normalizes streamed payload
sizes. Omit it to keep the server default (enabled), or set it to false to reduce
bandwidth when you trust the network links. `ChatStreamEvent.obfuscation` exposes
padding as metadata, including an empty string. It never becomes accumulated
text, refusal, reasoning, or tool arguments; `textDeltas()` and `collectText()`
also yield content only. The shared options model supports the flag on Responses
requests too; `includeUsage` is Chat-specific. See the
[official streaming reference](https://developers.openai.com/api/reference/resources/chat/subresources/completions/streaming-events)
for the wire contract.

→ [Full example](example/streaming_example.dart)

</details>

### How do I use tool calling?

<details>
<summary><b>Show example</b></summary>

Define tools with JSON Schema parameters and pass them in the request. The response indicates when the model wants to call a tool, and you can inspect the function name and arguments.

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-5.5',
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
    model: 'gpt-5.5',
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

### How do I generate and edit images with GPT Image 2.5?

<details>
<summary><b>Show example</b></summary>

Use `ImageModels.gptImage25Flare` for fast generation and editing, or
`ImageModels.gptImage25Sunburst` for precise edits and detailed creative work.
Both models support `low`, `medium`, `high`, `xhigh`, `max`, and `auto` quality,
custom sizes, and transparent backgrounds with PNG or WebP output.

```dart
import 'dart:convert';
import 'dart:io';

final response = await client.images.generate(
  const ImageGenerationRequest(
    model: ImageModels.gptImage25Flare,
    prompt: 'A cute robot holding a flower',
    size: ImageSize.custom('1536x864'),
    quality: ImageQuality.xhigh,
    background: ImageBackground.transparent,
    outputFormat: ImageOutputFormat.webp,
  ),
);

// GPT image models return base64 image data.
final b64 = response.data.first.b64Json;
if (b64 != null) {
  File('robot.webp').writeAsBytesSync(base64Decode(b64));
}

final edited = await client.images.editJson(
  const ImageEditJsonRequest(
    model: ImageModels.gptImage25Sunburst,
    images: [ImageReference.url('https://example.com/source.png')],
    prompt: 'Change only the flower to a sunflower',
    quality: ImageQuality.max,
    size: ImageSize.custom('1536x864'),
  ),
);
```

Use `client.images.edit(...)` to upload image bytes, or `editJson(...)` for
up to 16 image references (URLs, data URLs, or uploaded file IDs). The streaming
variants are `generateStream`, `editStream`, and `editJsonStream`.
Snapshot constants are also available: `gptImage25Sunburst20260908` and
`gptImage25Flare20260908`.

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
  model: 'gpt-realtime-2',
  config: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'You are a helpful assistant.',
  ),
);

// Send a user text message and process events until the response is complete.
// (Use `session.appendAudioBytes(rawPcmBytes)` to stream raw audio instead.)
session.sendUserMessage('Say hello and nothing else.');

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
      model: 'gpt-realtime-2',
      audio: realtime.RealtimeAudioConfig(
        output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
      ),
    ),
  ),
);

// 3. Set the SDP answer to complete the WebRTC handshake
await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

// Call management operations (callId is obtained from your SIP/telephony layer)
const callId = 'call_xxx';

// Accept the call (optionally override the session configuration on accept).
await client.realtimeSessions.calls.accept(
  callId,
  request: const realtime.RealtimeSessionCreateRequest(
    model: 'gpt-realtime-2',
    audio: realtime.RealtimeAudioConfig(
      output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
    ),
    instructions: 'Greet the caller in English.',
  ),
);
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

### How do I check content provenance?

<details>
<summary><b>Show example</b></summary>

Use the content provenance checks API to detect OpenAI C2PA/SynthID signals in an uploaded image or audio file. Results are a sealed union — dispatch on the concrete type to read the fields specific to each signal.

```dart
final check = await client.contentProvenanceChecks.create(
  bytes: File('image.png').readAsBytesSync(),
  filename: 'image.png',
);

for (final result in check.results) {
  switch (result) {
    case C2PAProvenanceResult():
      print('C2PA: ${result.outcome}, trust: ${result.validationState}');
    case SynthIDProvenanceResult():
      print('SynthID: ${result.outcome}');
    case UnknownProvenanceResult():
      print('Unrecognized signal: ${result.type}');
  }
}
```

→ [Full example](example/content_provenance_checks_example.dart)

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
        model: 'gpt-5.5',
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
| [`chat_example.dart`](example/chat_example.dart) | Chat completions, multi-turn conversations, and legacy cache retention |
| [`streaming_example.dart`](example/streaming_example.dart) | Content streaming, detailed final usage, and obfuscation controls |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Function calling with tool definitions |
| [`vision_example.dart`](example/vision_example.dart) | Image analysis with vision models |
| [`responses_example.dart`](example/responses_example.dart) | Responses API with built-in tools |
| [`prompt_cache_example.dart`](example/prompt_cache_example.dart) | Responses prewarming, comparison diagnostics, and narrow Chat cache options |
| [`decisions_example.dart`](example/decisions_example.dart) | Typed Decisions questions, refusals, usage, and inline images |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text embeddings with dimension control |
| [`images_example.dart`](example/images_example.dart) | GPT Image generation |
| [`videos_example.dart`](example/videos_example.dart) | Sora video generation, editing, and extension |
| [`audio_example.dart`](example/audio_example.dart) | Text-to-speech and transcription |
| [`chat_audio_example.dart`](example/chat_audio_example.dart) | Chat audio output, ID-only replay, and partial stream accumulation |
| [`files_example.dart`](example/files_example.dart) | File upload and management |
| [`conversations_example.dart`](example/conversations_example.dart) | Conversations API for state management |
| [`containers_example.dart`](example/containers_example.dart) | Container memory/network configuration, Code Interpreter IDs, and files |
| [`chatkit_example.dart`](example/chatkit_example.dart) | ChatKit sessions and threads |
| [`assistants_example.dart`](example/assistants_example.dart) | Assistants API (deprecated) |
| [`evals_example.dart`](example/evals_example.dart) | Model evaluation and testing |
| [`error_handling_example.dart`](example/error_handling_example.dart) | Exception handling patterns |
| [`models_example.dart`](example/models_example.dart) | Model listing and retrieval |
| [`batches_example.dart`](example/batches_example.dart) | Batch processing for async jobs |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`content_provenance_checks_example.dart`](example/content_provenance_checks_example.dart) | Content provenance (C2PA/SynthID) detection |
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
| Chat Completions | Supported; stored-completion management pending |
| Responses API | Supported; WebSockets and additional tool/configuration details pending |
| Decisions API | ✅ Full |
| Embeddings | ✅ Full |
| Images | ✅ Full |
| Videos (Sora) | ✅ Full |
| Audio (Speech, Transcription, Translation) | Supported; custom voices and some speech options pending |
| Files | ✅ Full |
| Uploads | ✅ Full |
| Batches | ✅ Full |
| Models | ✅ Full |
| Moderations | ✅ Full |
| Fine-tuning | Supported; some job/grader/checkpoint operations pending |
| Evals | ✅ Full |
| Conversations | ✅ Full |
| Containers | Supported with memory, network policies/domain secrets, and skill configuration |
| Content Provenance Checks | ✅ Full |
| ChatKit Beta | ✅ Full |
| Realtime | ✅ Full (separate import) |
| Assistants (Deprecated) | ✅ Full (separate import) |
| Threads (Deprecated) | ✅ Full (separate import) |
| Messages (Deprecated) | ✅ Full (separate import) |
| Runs (Deprecated) | ✅ Full (separate import) |
| Vector Stores (Deprecated) | ✅ Full (separate import) |
| Completions (Legacy) | ✅ Full |

Agents, Live, safety retrieval, webhook management, vaults, and Administration remain part of the [API alignment roadmap](specs/api-alignment/README.md).

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
