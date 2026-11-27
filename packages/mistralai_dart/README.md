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

> **Coverage:** See [API Coverage](#api-coverage) for supported resources and availability.

### Generation and streaming

- Chat completions with streaming, tool calling, vision, JSON mode, and structured output
- Stateless Responses with SSE, multimodal input, function tools, and token counting
- Embeddings, FIM code completions, and reasoning effort control
- Model management and discovery

### Tools and media

- Built-in web search, code interpreter, and document library tools
- Audio transcription, text-to-speech, voice management, and realtime WebSockets
- OCR, moderations, and classifications

### Operational APIs

- Files, fine-tuned model management, and batch processing
- Legacy Agents and Conversations (beta), connectors, and libraries
- Prompts and skills: versioned, shareable templates and instructions (beta)
- Observability: campaigns, datasets, judges, and chat completion events (beta)
- Workflows: execution, scheduling, management, and managed deployments (Public Preview)
- Managed Search indexes, document ingestion, and retrieval (Mistral-hosted Public Preview)
- RAG ingestion pipeline configuration (beta)
- Caller identity, user memberships, service accounts, and billing (beta)
- Triggers and webhook event sources for deployed workflows (beta)
- Organization users, groups, workspaces, roles, and SCIM (Admin API Enterprise Preview)

## Why choose this client?

- Pure Dart with no Flutter dependency — works in mobile apps, backends, and CLIs.
- Type-safe request and response models with minimal dependencies (`http`, `logging`, `meta`).
- Streaming, retries, interceptors, and error handling built into the client.
- Resource APIs for inference, media, workflows, document storage, and managed search.
- Strict [semver](https://semver.org/) versioning so downstream packages can depend on stable, predictable version ranges.

## Quickstart

Requires Dart 3.12 or later. See the [Migration Guide](MIGRATION.md) for upgrade instructions.

```yaml
dependencies:
  mistralai_dart: ^8.3.0
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

By default the client does **not** send an `X-Request-ID` header — Mistral's CORS allow-list excludes it, so sending it breaks the preflight in browser targets (Flutter Web / dart2wasm). A request ID is still generated internally for logging and error correlation. Set `MistralConfig(sendRequestIdHeader: true)` to emit the header when talking to an intermediary (e.g. a reverse proxy) you've configured to accept it.

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

On models that support log probabilities, set `logprobs: true` and optionally
`topLogprobs`. Read the generated-token scores from `choice.logprobs?.content`.
Use `promptLogprobs: true` and optionally `topPromptLogprobs` for input-token
scores. These choices appear in both JSON responses and streaming chunks when
the model returns them. Sampling controls such as `minTokens`, `topK`, and
`repetitionPenalty`, and the supported reasoning levels, depend on the model.

Set `serviceTier: RequestedServiceTier.auto` to request Priority Tier when
available. Check `response.usage?.serviceTier` or the final stream chunk's usage
for the actual tier. Priority Tier depends on account entitlement, model, and
region. Omitting the field uses standard capacity.
[Mistral Priority Tier](https://docs.mistral.ai/inference/priority-tier)

Chat and Agent completions accept function, image generation, document library,
and custom connector tools. Mistral accepts legacy `prediction` but ignores it.
Use `guardrails` in new code in place of the deprecated `safePrompt` flag.

Run the example with `--logprobs` to print token scores or `--priority` to
request Priority Tier. Set `MISTRAL_CHAT_MODEL` to a supported model if needed.

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

### How do I use the Responses API?

<details>
<summary><b>Show example</b></summary>

Use `client.responses` to create a stateless response, stream server-sent
events, or count input tokens. Keep conversation state in your app. Send the
ordered history, prior output items and client-executed tool results in the
next request. Requests run in the foreground.

```dart
const request = CreateResponseRequest(
  model: 'mistral-large-latest',
  input: ResponseInput.text('Summarize how Dart streams work.'),
);

final result = await client.responses.create(request: request);
print(result.outputText);

await for (final event in client.responses.createStream(request: request)) {
  if (event is ResponseTextDeltaEvent) {
    print(event.delta);
  }
}
```

Use `ResponseInput.items` for text, image and file messages or tool results,
and `ResponseTextConfig` for structured output. Mistral's API supports JSON
and SSE with the same request. For migration from a stored Responses API,
replay the full history instead of passing a previous response ID.

→ [Full example](example/responses_example.dart)

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

Define custom functions with JSON Schema parameters and send their results
in a follow-up message. Chat Completions also accepts image generation,
document library, and connector tools where available.

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

For multimodal embeddings, pass the model ID available to your account. Mistral Multimodal Embed is in public preview. Supported models accept text and image chunks. The API also defines audio chunks for models that accept audio. [Mistral Multimodal Embed model card](https://docs.mistral.ai/models/mistral-multimodal-embed) · [Embeddings API](https://docs.mistral.ai/api/endpoint/embeddings)

```dart
final response = await client.embeddings.create(
  request: EmbeddingRequest(
    model: multimodalModelId,
    input: const EmbedInput.batch([
      EmbedInputString('A product photo'),
      EmbedInputImage(ImageUrlContentPart('https://example.com/product.png')),
    ]),
    encodingFormat: 'base64',
  ),
);
final encoded = response.data.first.embeddingBase64;
```

Use `EmbeddingData.embedding` for numeric vectors and `embeddingBase64` for encoded vectors. The byte layout depends on `outputDtype`.

Set `MISTRAL_MULTIMODAL_EMBED_MODEL` and `MISTRAL_EMBED_IMAGE_URL` to run the multimodal part of the example.

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

// Audio model cards can report supported modes and formats.
final audio = await client.models.get(audioModelId);
print(audio.audioTranscriptionCapabilities?.modes);
print(audio.audioSpeechCapabilities?.responseFormats);
print(audio.billingModelName);

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

Use `client.files` to upload, list, download, and delete files, or to request
a signed download URL. File paths and input streams require a native platform.
Use bytes with a filename in a browser.

```dart
// Upload a file
final file = await client.files.upload(
  filePath: 'batch_requests.jsonl',
  purpose: FilePurpose.batch,
  visibility: FileVisibility.workspace,
  mimeType: 'application/jsonl',
);

// List files from an upload
final files = await client.files.list(
  purpose: FilePurpose.batch,
  sources: ['upload'],
  pageSize: 20,
);

// Download file content
final content = await client.files.download(fileId: file.id);

final signed = await client.files.getSignedUrl(
  fileId: file.id,
  expiryHours: 1,
);
print(signed.url);
```

→ [Full example](example/files_example.dart)

</details>

### How do I manage fine-tuned models and batch?

<details>
<summary><b>Show example</b></summary>

Mistral retired the fine-tuning jobs API. Version 6 removed job creation
and polling. Use `client.fineTuning.models` to update, archive, or restore
existing fine-tuned models. Use `client.batch.jobs` for batch inference.
[Mistral's legacy fine-tuning notice](https://docs.mistral.ai/resources/deprecated/customization)

```dart
// Update a fine-tuned model's metadata
final updated = await client.fineTuning.models.update(
  modelId: 'ft:mistral-small:my-model:xyz',
  name: 'My Model v2',
);

// Archive / unarchive a fine-tuned model
await client.fineTuning.models.archive(modelId: updated.id);
await client.fineTuning.models.unarchive(modelId: updated.id);

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

final outputFileId = completed.outputFileId;
if (outputFileId != null) {
  final results = await client.files.download(fileId: outputFileId);
  print('Downloaded ${results.length} bytes');
}

// List one page of completed or timed-out jobs.
final page = await client.batch.jobs.list(
  page: 0,
  pageSize: 20,
  statuses: [BatchJobStatus.success, BatchJobStatus.timedOut],
);
print(page.data.length);
```

For jobs with inline results, call `retrieve(jobId: id, inline: true)` and
read `outputs`.

→ [Fine-tuned models](example/fine_tuning_example.dart) · [Batch](example/batch_example.dart)

</details>

### How do I moderate content?

<details>
<summary><b>Show example</b></summary>

Use `client.moderations` for safety flags and scores on text or conversations. Read `categoryScores.scores` for the category names returned by the selected model. Use `ChatModerationRequest.batch` to submit multiple conversations in one request. [Moderation guide](https://docs.mistral.ai/studio/safety-moderation)

```dart
// Text moderation
final result = await client.moderations.create(
  request: ModerationRequest(
    model: 'mistral-moderation-2603',
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
    model: 'mistral-moderation-2603',
    input: [
      ChatMessage.user('Hello'),
      ChatMessage.assistant('Hi there!'),
    ],
  ),
);
```

Use `client.classifications` with the ID of an existing classifier. Each result contains a map of configured targets and their label scores. Mistral lists Classifier Factory as deprecated. [Classifier API](https://docs.mistral.ai/api/endpoint/classifiers) · [Deprecated features](https://docs.mistral.ai/resources/deprecated)

```dart
final classifications = await client.classifications.create(
  request: ClassificationRequest.text(
    model: classifierModelId,
    input: 'Please send me a copy of the invoice.',
  ),
);

for (final result in classifications.results) {
  for (final target in result.targets.entries) {
    print('${target.key}: ${target.value.scores}');
  }
}
```

Set `MISTRAL_CLASSIFIER_MODEL` to run the classifier example.

→ [Moderation example](example/moderation_example.dart) · [Classification example](example/classification_example.dart)

</details>

### How do I extract text from documents?

<details>
<summary><b>Show example</b></summary>

Use `client.ocr.process(...)` to extract Markdown and paragraph-level blocks from URLs, uploaded files, or base64-encoded documents and images. Mistral retired `mistral-ocr-4-0` on September 30, 2026. Use `mistral-ocr-4-1` or `mistral-ocr-latest` for block-level confidence scores. [OCR 4.1 release](https://docs.mistral.ai/resources/release-note/2026-08-31-ocr-4-1-general-availability) · [OCR 4.0 retirement](https://docs.mistral.ai/resources/release-note/2026-09-29-ocr-4-0-deprecation)

```dart
// From URL
final result = await client.ocr.process(
  request: OcrRequest(
    model: 'mistral-ocr-latest',
    document: OcrDocument.url('https://example.com/document.pdf'),
    includeBlocks: true,
    confidenceScoresGranularity: OcrConfidenceScoresGranularity.block,
  ),
);

for (final page in result.pages) {
  print('Page ${page.index}: ${page.markdown}');
  for (final block in page.blocks ?? const <OcrBlock>[]) {
    print('${block.type}: ${block.confidenceScores?.blockTypeConfidenceScore}');
  }
}

// From base64
final result = await client.ocr.process(
  request: OcrRequest(
    model: 'mistral-ocr-latest',
    document: OcrDocument.base64(data: base64Data, mimeType: 'application/pdf'),
  ),
);
```

Pass a local PDF path to the example to request block confidence.

→ [Full example](example/ocr_example.dart)

</details>

### How do I use audio?

<details>
<summary><b>Show example</b></summary>

Use `client.audio.transcriptions` for speech-to-text, `client.audio.speech` for
text-to-speech, and `client.audio.voices` to manage voices. Voxtral 3 models are
in Public Preview. Their HTTP streams return results as they are generated
from a complete recording or text input.

```dart
// Transcribe bytes without uploading them to the Files store.
final bytes = await File('recording.wav').readAsBytes();
final request = TranscriptionRequest(
  model: 'voxtral-mini-transcribe-3-0',
  fileBytes: bytes,
  fileName: 'recording.wav',
  diarize: true,
  timestampGranularityOptions: [TranscriptionTimestampGranularity.segment],
  contextBias: ['Mistral', 'Voxtral'],
);

final result = await client.audio.transcriptions.create(request: request);
print(result.text);
for (final segment in result.segments ?? <TranscriptionSegment>[]) {
  print('${segment.speakerId ?? 'speaker'}: ${segment.text}');
}

// A fileUrl or an uploaded file ID (file) can also identify the recording.
await for (final event in client.audio.transcriptions.createStream(request: request)) {
  if (event.type == 'transcription.text.delta') {
    stdout.write(event.text ?? '');
  }
}
```

Voxtral 3 supports segment timestamps. Keep the legacy word granularity for
models that support it. Speaker reference clips go in
`TranscriptionRequest.speakerReferences` with `diarize: true`.

```dart
// Find preset voices, then download a sample or generate speech.
final page = await client.audio.voices.search(type: 'preset', language: ['en']);
if (page.data.isNotEmpty) {
  final voiceId = page.data.first.id;
  final sample = await client.audio.voices.getSampleAudio(voiceId: voiceId);
  await File('sample.wav').writeAsBytes(sample);

  final response = await client.audio.speech.create(
    request: SpeechRequest(
      model: 'voxtral-mini-tts-3-0',
      voiceId: voiceId,
      input: 'Hello, world!',
      responseFormat: SpeechOutputFormat.wav,
      expressiveness: 1.5,
    ),
  );
  await File('speech.wav').writeAsBytes(base64Decode(response.audioData));
}
```

Use `SpeechRequest.phonemeHints` for pronunciation and `conversationHistory`
with eligible preset PVC voices for contextual delivery. Use
`client.audio.speech.createStream()` to receive audio chunks.

Pass the returned `nextPageToken` as `pageToken` with the same search filters
to retrieve the next page. The offset-based `voices.list()` endpoint is
scheduled to retire on March 31, 2027.

→ [Full example](example/audio_example.dart)

</details>

### How do I use realtime audio?

<details>
<summary><b>Show example</b></summary>

Voxtral 3 realtime transcription and speech run over WebSockets in Public
Preview. Use `client.audio.realtime.transcribeStream()` for incoming audio
and `client.audio.realtimeSpeech.speakStream()` for incoming text. Ending
the input stream lets the server finish and report usage. Cancel the
subscription to stop both the input and the socket.

```dart
// pcmFrames is a Stream<List<int>> of raw 16 kHz signed 16-bit mono PCM.
await for (final event in client.audio.realtime.transcribeStream(
  model: 'voxtral-mini-transcribe-realtime-3-0',
  audio: pcmFrames,
  options: const RealtimeTranscriptionOptions(
    audioFormat: RealtimeAudioFormat(
      encoding: RealtimeAudioEncoding.pcmS16le,
      sampleRate: 16000,
    ),
  ),
)) {
  if (event.type == 'transcription.text.delta') {
    stdout.write(event.text ?? '');
  }
}
```

Use `connect()` to manage session updates, turn detection, intermediate
flushes, or multiple speech generations on one socket. Close a connection
you open directly. Transcription consumes raw mono PCM. When speech uses
`SpeechOutputFormat.pcm`, its base64 chunks decode to raw float32
little-endian mono.

Native Dart clients use bearer credentials for both sockets. Browser
transcription uses a short-lived, model-scoped credential. Use a server-side
API key with `create_client_session` permission to call
`backend.realtime.sessions.create()`, then pass only the secret value
to the authenticated browser. Mistral documents the subprotocol handshake
in its [realtime transcription client authentication guide](https://docs.mistral.ai/studio/audio/deprecated/speech_to_text/realtime_transcription/client_auth).
Mint the token for the exact model your browser connects to. Realtime speech
uses the native bearer path.

```dart
const model = 'voxtral-mini-transcribe-realtime-3-0';
// Backend, using your workspace API key.
final session = await backend.realtime.sessions.create(
  request: const CreateRealtimeClientSessionRequest(model: model),
);
final token = session.clientSecret.value; // Return to the authenticated browser.

// Browser, after retrieving token from your backend.
final connection = await browser.audio.realtime.connect(
  model: model,
  clientToken: token,
);
```

→ [Full example](example/realtime_audio_example.dart)

</details>

### How do I use agents?

<details>
<summary><b>Show example</b></summary>

Use `client.agents` for the legacy Agents API (beta). An agent can follow
custom instructions and use configured tools. Use `complete(...)` for agent
completions and `listPages(...)` for cursor pagination.

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

// List agents. Pass agents.nextPageToken to fetch the next page.
final agents = await client.agents.listPages(pageSize: 20);

// Update agent
await client.agents.update(
  agentId: agent.id,
  request: UpdateAgentRequest(name: 'Updated Name'),
);

// Delete agent
await client.agents.delete(agentId: agent.id);
```

Mistral directs new Managed Agents projects to its separate
`mistralai-agents` Python runtime. See the [Mistral migration guide](https://docs.mistral.ai/studio/agents/getting-started/from-agents-api).

→ [Full example](example/agents_example.dart)

</details>

### How do I use conversations?

<details>
<summary><b>Show example</b></summary>

Use `client.conversations` for the legacy Conversations API (beta). Mistral
keeps state for a stored conversation, allowing requests by conversation ID.

```dart
final conversation = await client.conversations.start(
  request: const StartConversationRequest(
    model: 'mistral-large-latest',
    inputText: 'Describe one way to learn Dart.',
    completionArgs: CompletionArgs(maxTokens: 256),
  ),
);
print(conversation.text);

await for (final event in client.conversations.appendStream(
  conversationId: conversation.conversationId,
  request: const AppendConversationRequest(inputText: 'Give me an example.'),
)) {
  if (event is ConversationMessageDelta) {
    print(event.text);
  }
}

final history = await client.conversations.getHistory(
  conversationId: conversation.conversationId,
);
print(history.entries.length);
```

Use `getMessages` for just message inputs and outputs. `startStream`,
`appendStream`, and `restartStream` return typed events for text, tools,
handoffs, usage, and service errors. Supply an `abortTrigger` or cancel the
subscription to stop a stream.

→ [Full example](example/conversations_example.dart)

</details>

### How do I use libraries?

<details>
<summary><b>Show example</b></summary>

Use `client.libraries` (beta) to create document libraries for retrieval. Upload
document bytes and wait for processing before querying with
`Tool.documentLibrary(...)`.

```dart
// Create a library
final library = await client.libraries.create(
  name: 'Research Papers',
);

// Upload a document directly. This example uses ASCII bytes for "AI notes".
final doc = await client.libraries.documents.upload(
  libraryId: library.id,
  bytes: [65, 73, 32, 110, 111, 116, 101, 115],
  fileName: 'notes.txt',
  mimeType: 'text/plain',
);

final docs = await client.libraries.documents.list(libraryId: library.id);
print(docs.data.firstOrNull?.processingStatus);

// Once the document is processed, use the library with Chat Completions.
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

### How do I use prompts?

<details>
<summary><b>Show example</b></summary>

Use `client.prompts` to manage versioned, shareable prompt templates (Beta). Each prompt has one or more versions; aliases (e.g. `production`) let you point consumers at a specific version without changing their code.

Use `sortBy` and `sortDirection` to order lists. Select the fields you need
with `fields`. For a workspace prompt, set
`workspaceRelation: RegistryShareRelation.reader` to grant read access.
Omitting the relation uses Mistral's writer default.

```dart
// Create a prompt
final prompt = await client.prompts.create(
  request: const CreatePromptRequest(
    name: 'greeting',
    definition: PromptDefinition(content: 'Hello, {{name}}!'),
  ),
);

// List prompts
final prompts = await client.prompts.list(pageSize: 10);

// Create a new version
final version = await client.prompts.createVersion(
  promptId: prompt.id,
  request: const CreatePromptVersionRequest(
    definition: PromptDefinition(content: 'Hi there, {{name}}!'),
  ),
);

// Point an alias at the new version
await client.prompts.updateVersion(
  promptId: prompt.id,
  version: version.version ?? 2,
  request: const UpdatePromptVersionRequest(
    aliases: AliasList(values: ['production']),
  ),
);

// Retrieve by alias
final latest = await client.prompts.retrieve(
  promptId: prompt.id,
  alias: 'production',
);
print(latest.definition?.content);

// Delete the prompt
await client.prompts.delete(promptId: prompt.id);
```

→ [Full example](example/prompts_example.dart)

</details>

### How do I use skills?

<details>
<summary><b>Show example</b></summary>

Use `client.skills` to manage versioned, shareable model instructions with optional file assets (Beta). Skills follow the same version/alias model as prompts.

Skill lists can project `definition.description`. Retrieve an individual
skill to read its body and assets. A workspace skill can grant read access
with `workspaceRelation: RegistryShareRelation.reader`.

```dart
// Create a skill with a text asset
final skill = await client.skills.create(
  request: const CreateSkillRequest(
    name: 'summarizer',
    definition: SkillDefinition(
      description: 'Summarizes long documents.',
      body: 'Summarize the input in three bullet points.',
      assets: {
        'style_guide.txt': SkillAssetContent.text(
          textContent: 'Use concise, plain language.',
        ),
      },
    ),
  ),
);

// List skills
final skills = await client.skills.list(pageSize: 10);

// Create a new version and point an alias at it
final version = await client.skills.createVersion(
  skillId: skill.id,
  request: const CreateSkillVersionRequest(
    definition: SkillDefinition(body: 'Summarize in three short bullets.'),
  ),
);
await client.skills.updateVersion(
  skillId: skill.id,
  version: version.version ?? 2,
  request: const UpdateSkillVersionRequest(
    aliases: AliasList(values: ['production']),
  ),
);

// Delete the skill
await client.skills.delete(skillId: skill.id);
```

→ [Full example](example/skills_example.dart)

</details>

### How do I use connectors?

<details>
<summary><b>Show example</b></summary>

Use `client.connectors` to manage MCP connectors (Beta): create and configure connectors, manage their credentials, activate or deactivate them at the organization, workspace, or user level, share a private connector with the workspace, and list or call their tools.

```dart
// Create an MCP connector
final connector = await client.connectors.create(
  request: const CreateConnectorRequest(
    name: 'my_connector',
    description: 'My MCP connector',
    server: 'https://mcp.example.com',
    visibility: PublicResourceVisibility.sharedOrg,
  ),
);

// Configure user-level credentials
await client.connectors.createOrUpdateUserCredentials(
  connectorIdOrName: connector.id,
  request: const CredentialsCreateOrUpdate(
    name: 'my-cred',
    credentials: ConnectionCredentials(bearerToken: 'secret-token'),
  ),
);

// Activate the connector for the organization
await client.connectors.activateForOrganization(connectorId: connector.id);

// Share a private connector with the current workspace
await client.connectors.share(connectorId: connector.id);

// Remove all user-level credentials for the connector
await client.connectors.deleteAllUserCredentials(
  connectorIdOrName: connector.id,
);

// List and call the connector's tools
final tools = await client.connectors.listTools(
  connectorIdOrName: connector.id,
);
final result = await client.connectors.callTool(
  connectorIdOrName: connector.id,
  toolName: 'search',
  request: const ConnectorCallToolRequest(arguments: {'query': 'mistral'}),
);
```

→ [Full example](example/connectors_example.dart)

</details>

### How do I use observability?

<details>
<summary><b>Show example</b></summary>

Use `client.observability` to manage campaigns, datasets, dataset records, judges, chat completion events, and chat completion fields. You can also explore OpenTelemetry traces, spans, and logs. These APIs help you monitor and evaluate your Mistral AI usage.

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

// Search traces and inspect their spans
final traces = await client.observability.traces.search(
  request: const TracesRequest(searchExpression: 'status_code = "Error"'),
);
final spans = await client.observability.spans.search();

// Search structured logs
final logs = await client.observability.logs.search();
```

→ [Full example](example/observability_example.dart)

</details>

### How do I use Managed Search?

<details>
<summary><b>Show example</b></summary>

Managed Search runs on Mistral-hosted infrastructure in Public Preview. Use
a workspace API key with access to the index. Creating, updating, and
deleting an index initiate asynchronous operations. Use its status to
check when it is ready.

```dart
final index = await client.managedSearchIndexes.get(indexName: 'team-notes');

if (index.status == ManagedSearchIndexStatus.ready) {
  final results = await client.managedSearchIndexes.search(
    indexName: index.name,
    request: const ManagedSearchRequest(
      retriever: KeywordRetriever(query: 'release checklist', topK: 5),
    ),
  );
  for (final hit in results.hits) {
    print(hit.chunk.content);
  }
}
```

Use `client.managedSearchIndexes` for index CRUD, document ingestion, keyword
and vector search, navigation, and streamed summary generation. The old
`client.rag.searchIndexes` wrappers refer to external index registration
routes from an earlier API snapshot. Managed indexes require their own
configuration and ingestion.

→ [Full example](example/managed_search_indexes_example.dart)

</details>

### How do I configure a RAG ingestion pipeline?

<details>
<summary><b>Show example</b></summary>

The beta `client.rag.ingestionPipelineConfigurations` resource registers
pipeline metadata and reports ingestion runs.

```dart
final config = await client.rag.ingestionPipelineConfigurations.register(
  request: const CreateIngestionPipelineConfigurationRequest(
    name: 'My ingestion pipeline',
  ),
);

await client.rag.ingestionPipelineConfigurations.updateRunInfo(
  id: config.id,
  request: UpdateRunInfo(
    executionTime: DateTime.now().toUtc(),
    chunksCount: 128,
  ),
);
```

→ [Full example](example/rag_index_example.dart)

</details>

### How do I use workflows?

<details>
<summary><b>Show example</b></summary>

Use `client.workflows` to manage and execute workflows via the workflow core resource (`client.workflows.core`), check execution status, list registrations, monitor runs, view metrics, inspect workers, and configure schedules.

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

// List workers and continue with workers.nextCursor.
final workers = await client.workflows.deployments.listWorkers(
  name: 'my-deployment',
  workerStatus: 'active',
);

// List registrations
final registrations = await client.workflows.registrations.list();

// List schedules
final schedules = await client.workflows.schedules.list();

// Create, start, and monitor a managed deployment
final deployment = await client.workflows.deployments.create(
  request: const CreateDeploymentRequest(
    name: 'my-deployment',
    spec: DeploymentWorkerSpecInput(
      repositoryUrl: 'https://github.com/my-org/my-worker',
    ),
  ),
);
await client.workflows.deployments.start(name: deployment.name);

final logs = await client.workflows.deployments.getLogs(
  name: deployment.name,
  limit: 50,
);
print('Fetched ${logs.results.length} log record(s)');
await for (final log in client.workflows.deployments.streamLogs(
  name: deployment.name,
)) {
  print('${log.severityText}: ${log.body}');
}
```

Managed Deployments are a Mistral-hosted Public Preview for eligible paid
workspaces and are subject to quotas. To deploy from an archive, request a
signed URL with `deployments.createArchive`, PUT the raw gzipped tar file
using a separate HTTP client and the signed headers, then create or update a
deployment with the returned `archiveId`. Keep signed URLs and headers private.
[Mistral Managed Deployments](https://docs.mistral.ai/resources/release-note/2026-10-09-managed-deployments-public-preview)

Use `workflows.core.executeAsync` or `executeSync` with a workflow identifier
in place of the deprecated registration execution route. Use
`DeploymentLogType.build` in `deployments.getLogs` for managed build output.
Streamed logs expose `eventId` for resuming from `lastEventId`.

[Workflow example](example/workflows_example.dart) ·
[Archive deployment example](example/workflow_deployment_archive_example.dart)

</details>

### How do I identify the authenticated caller?

<details>
<summary><b>Show example</b></summary>

Use `client.users.whoami()` for a human user or service account. Use
`me()` for the legacy human profile, or `listOrganizations` and
`listWorkspaces` for user memberships.

```dart
final identity = await client.users.whoami();
switch (identity.principal) {
  case WhoamiUserPrincipal(:final id):
    print(id);
  case WhoamiServiceAccountPrincipal(:final serviceAccountId):
    print(serviceAccountId);
  case UnknownWhoamiPrincipal():
    break;
}
```

These beta identity routes accept the configured credential as a bearer
token. Pass `authInApiKeyHeader: true` to use the public API key header.
The membership methods accept `offset` and `limit`. Filter workspace
listings by organization when needed.

→ [Full example](example/platform_identity_example.dart)

</details>

### How do I manage workspace service accounts?

<details>
<summary><b>Show example</b></summary>

Use `client.serviceAccounts` to list and manage workspace principals and
their roles. Access depends on the caller's workspace permissions.

```dart
final page = await client.serviceAccounts.list(
  workspaceId: workspaceId,
  limit: 25,
);
final assignable = await client.serviceAccounts.listAssignableRoles(
  workspaceId: workspaceId,
);
print('${page.items.length} accounts and ${assignable.items.length} roles');
```

Use `setRoles` with the complete set of role IDs to replace existing
assignments. See the [Mistral service accounts guide](https://docs.mistral.ai/admin/identity-access/service-accounts).

→ [Full example](example/platform_identity_example.dart)

</details>

### How do I read billing settings?

<details>
<summary><b>Show example</b></summary>

The beta billing resource reads the budget and subscription for the
authenticated dashboard customer. The client sends the configured public
API key in the `x-api-key` header.

```dart
final budget = await client.billing.getBudget();
final plan = await client.billing.getSubscription();
print('${plan.planName}: ${budget.apiBudget.usagePercentage}% API usage');
```

→ [Full example](example/platform_identity_example.dart)

</details>

### How do I start a workflow on a webhook event?

<details>
<summary><b>Show example</b></summary>

Register an inbound event source with `client.webhooks` and link it to a
deployed workflow with `client.triggers`. The webhook and its triggers
share the same owner type. Mistral validates provider-specific signatures
and tracks delivered events.

```dart
final trigger = await client.triggers.create(
  request: CreateTriggerRequest(
    eventSourceId: webhookId,
    handler: TriggerHandler.workflows,
    action: TriggerAction(
      primitiveId: workflowId,
      type: TriggerActionType.startWorkflow,
    ),
    ownerType: TriggerOwnerType.workspace,
    title: 'Start workflow',
  ),
);
final events = await client.triggers.listEvents(triggerId: trigger.id);
print(events.data.length);
```

Workflow triggers receive events from your provider. Voice Agents send
call lifecycle events to your app with an `x-mistral-signature` header.
Use the configured provider signing secret for workflow webhooks. See the
[Mistral triggers and webhooks guide](https://docs.mistral.ai/studio/workflows/building-workflows/triggers-and-webhooks).

→ [Full example](example/workflow_trigger_example.dart)

</details>

### How do I manage an organization with the Admin API?

<details>
<summary><b>Show example</b></summary>

The Admin API is available to Enterprise Preview organizations. Create an
organization Admin API key in the Mistral Admin Panel and keep it server-side.
Use a standalone `MistralAdminClient` to manage Admin users and invitations,
Admin groups and their assignments, and Admin workspaces and their members.
Use Admin roles to look up role IDs and Admin SCIM to manage sync runs.

```dart
final admin = MistralAdminClient.withApiKey(organizationAdminKey);

try {
  final roles = await admin.roles.list();
  final workspaces = await admin.workspaces.list(page: 1, pageSize: 10);
  print(roles.organizationRoles.map((role) => role.name).join(', '));
  print('Workspace count: ${workspaces.total}');
} finally {
  admin.close();
}
```

The Admin client uses the `x-api-key` header specified in the authentication
guide. Configure SAML or SCIM in the Admin Panel before using the SCIM
synchronization endpoints.

[Admin example](example/admin_example.dart) · [Admin authentication](https://docs.mistral.ai/admin/admin-api/authentication)

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
| [`chat_example.dart`](example/chat_example.dart) | Chat completions, token scores, and Priority Tier |
| [`streaming_example.dart`](example/streaming_example.dart) | Streaming responses |
| [`responses_example.dart`](example/responses_example.dart) | Stateless Responses and token counting |
| [`tool_calling_example.dart`](example/tool_calling_example.dart) | Tool calling |
| [`json_mode_example.dart`](example/json_mode_example.dart) | Structured output |
| [`vision_example.dart`](example/vision_example.dart) | Multimodal inputs |
| [`embeddings_example.dart`](example/embeddings_example.dart) | Text and multimodal embeddings |
| [`fim_example.dart`](example/fim_example.dart) | Code completion |
| [`files_example.dart`](example/files_example.dart) | File uploads, filters, and signed URLs |
| [`fine_tuning_example.dart`](example/fine_tuning_example.dart) | Fine-tuned model management |
| [`batch_example.dart`](example/batch_example.dart) | Batch filtering, inline results, and polling |
| [`moderation_example.dart`](example/moderation_example.dart) | Content moderation |
| [`classification_example.dart`](example/classification_example.dart) | Text and chat classification with target scores |
| [`ocr_example.dart`](example/ocr_example.dart) | OCR 4.1 with block confidence |
| [`audio_example.dart`](example/audio_example.dart) | Voxtral file transcription, SSE, speech, voice search, and WAV samples |
| [`realtime_audio_example.dart`](example/realtime_audio_example.dart) | Realtime Voxtral transcription and speech over WebSockets |
| [`agents_example.dart`](example/agents_example.dart) | Legacy Agents (beta), cursor pagination |
| [`conversations_example.dart`](example/conversations_example.dart) | Legacy Conversations (beta), typed streaming |
| [`libraries_example.dart`](example/libraries_example.dart) | Library and document uploads (beta) |
| [`prompts_example.dart`](example/prompts_example.dart) | Versioned prompt templates (beta) |
| [`skills_example.dart`](example/skills_example.dart) | Versioned model instructions and assets (beta) |
| [`connectors_example.dart`](example/connectors_example.dart) | MCP connector management (beta) |
| [`observability_example.dart`](example/observability_example.dart) | Observability: datasets, judges, campaigns (beta) |
| [`workflows_example.dart`](example/workflows_example.dart) | Workflow execution, scheduling, and management |
| [`workflow_deployment_archive_example.dart`](example/workflow_deployment_archive_example.dart) | Signed archive upload and managed deployment (Public Preview) |
| [`managed_search_indexes_example.dart`](example/managed_search_indexes_example.dart) | Mistral-hosted Managed Search |
| [`rag_index_example.dart`](example/rag_index_example.dart) | RAG ingestion pipeline configuration (beta) |
| [`users_example.dart`](example/users_example.dart) | Legacy current user profile |
| [`platform_identity_example.dart`](example/platform_identity_example.dart) | Caller identity, memberships, billing, and workspace roles |
| [`workflow_trigger_example.dart`](example/workflow_trigger_example.dart) | Provider webhook setup and workflow trigger events |
| [`admin_example.dart`](example/admin_example.dart) | Organization roles and workspaces (Enterprise Preview) |
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
| Responses | Stateless generation, streaming and input token counting |
| Embeddings | ✅ Full |
| Models | ✅ Full |
| FIM | ✅ Full |
| Files | ✅ Full |
| Fine-tuned models (management) | ✅ Full |
| Batch | ✅ Full |
| Moderations | ✅ Full |
| Classifications | ✅ Full |
| OCR | ✅ Full |
| Audio (Transcription, Speech, Voices) | ✅ Full |
| Voxtral realtime transcription and speech | Public Preview. Native STT and TTS, browser STT with a scoped token |
| Agents (legacy beta) | Entities, versions, aliases, and completions |
| Conversations (legacy beta) | JSON, typed SSE, history, and messages |
| Libraries (Beta) | ✅ Full |
| Connectors (Beta) | ✅ Full |
| Prompts (Beta) | ✅ Full |
| Skills (Beta) | ✅ Full |
| Observability (Beta) | ✅ Full |
| Workflows | ✅ Supported |
| Managed Search | Mistral-hosted Public Preview |
| RAG (Beta) | Ingestion pipeline configuration and legacy index wrappers |
| Identity and memberships (Beta) | Caller identity, organizations, and workspaces |
| Service accounts (Beta) | Workspace principals and role assignments |
| Billing (Beta) | Dashboard budget and subscription |
| Triggers and webhooks (Beta) | Inbound event sources, trigger rules, and recent events |
| Admin Directory | Enterprise Preview |

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
