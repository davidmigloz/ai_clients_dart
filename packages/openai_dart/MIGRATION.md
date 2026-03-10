# Migration Guide

This guide helps you migrate from the previous code-generated openai_dart package to the new hand-crafted v1.0.0 client.

## Overview

Version 1.0.0 is a complete rewrite with:
- Hand-crafted models (no freezed/code generation)
- Resource-based API matching official OpenAI SDKs
- Minimal dependencies
- Improved type safety with sealed classes

## Quick Migration Checklist

- [ ] Update `pubspec.yaml` to `openai_dart: ^1.0.0`
- [ ] Update client creation
- [ ] Update chat completion calls
- [ ] Update message creation
- [ ] Update streaming usage
- [ ] Remove freezed-related code

## Quick Reference

| Operation | v0.x | v1.0.0 |
|-----------|------|--------|
| **Client Init** | `OpenAIClient(apiKey: 'KEY')` | `OpenAIClient(config: OpenAIConfig(authProvider: ApiKeyProvider('KEY')))` |
| **From Env** | `OpenAIClient(apiKey: Platform.environment['OPENAI_API_KEY']!)` | `OpenAIClient.fromEnvironment()` |
| **Client Close** | `client.endSession()` | `client.close()` |
| **Chat** | `client.createChatCompletion(request: ...)` | `client.chat.completions.create(...)` |
| **Chat Stream** | `client.createChatCompletionStream(request: ...)` | `client.chat.completions.createStream(...)` |
| **Embeddings** | `client.createEmbedding(request: ...)` | `client.embeddings.create(...)` |
| **Images** | `client.createImage(request: ...)` | `client.images.generate(...)` |
| **Legacy Completions** | `client.createCompletion(request: ...)` | `client.completions.create(...)` |
| **Audio Speech** | `client.createSpeech(request: ...)` | `client.audio.speech.create(...)` |
| **Audio Transcribe** | `client.createTranscription(request: ...)` | `client.audio.transcriptions.create(...)` |
| **Fine-tuning** | `client.createFineTuningJob(request: ...)` | `client.fineTuning.jobs.create(...)` |
| **Files Upload** | `client.uploadFile(...)` | `client.files.upload(...)` |
| **Batches** | `client.createBatch(request: ...)` | `client.batches.create(...)` |
| **Models** | Not available | `client.models.list()` / `client.models.retrieve(...)` |
| **Moderations** | Not available | `client.moderations.create(...)` |
| **Response Text** | `response.choices.first.message.content` | `response.text` |
| **Tool Calls** | Manual check | `response.hasToolCalls` / `response.allToolCalls` |

## Client Creation

### Before (v0.x)

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  apiKey: 'sk-...',
);

// Or with environment
final client = OpenAIClient(
  apiKey: Platform.environment['OPENAI_API_KEY']!,
);
```

### After (v1.0.0)

```dart
import 'package:openai_dart/openai_dart.dart';

final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('sk-...'),
  ),
);

// Or from environment (recommended)
final client = OpenAIClient.fromEnvironment();

// Or with just API key
final client = OpenAIClient.withApiKey('sk-...');
```

### Client Cleanup

```dart
// Before (v0.x)
client.endSession();

// After (v1.0.0)
client.close();
```

### Configuration Changes

The configuration options have changed significantly:

| v0.x | v1.0.0 | Notes |
|------|--------|-------|
| `retries: 3` | `retryPolicy: RetryPolicy(maxRetries: 3)` | Default: 3 retries, 1s initial, 60s max |
| `beta: 'assistants=v2'` | *(removed)* | Handled internally |
| *(not available)* | `timeout` | Request timeout duration |
| *(not available)* | `connectTimeout` | Connection timeout duration |
| *(not available)* | `retryPolicy` | Retry policy (replaces maxRetries, retryDelay, maxRetryDelay) |
| *(not available)* | `logLevel` | Logging verbosity |
| *(not available)* | `apiVersion` | API version header |
| *(not available)* | `project` | OpenAI project ID |

```dart
// Before (v0.x)
final client = OpenAIClient(
  apiKey: 'sk-...',
  retries: 3,
  beta: 'assistants=v2',
);

// After (v1.0.0)
final client = OpenAIClient(
  config: OpenAIConfig(
    authProvider: ApiKeyProvider('sk-...'),
    timeout: Duration(seconds: 60),
    retryPolicy: RetryPolicy(
      maxRetries: 3,
      initialDelay: Duration(milliseconds: 500),
    ),
    logLevel: Level.FINE,
    project: 'proj_...',
  ),
);
```

## Chat Completions

### Before (v0.x)

```dart
final response = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId('gpt-4o'),
    messages: [
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string('Hello'),
      ),
    ],
  ),
);

final text = response.choices.first.message.content;
```

### After (v1.0.0)

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-4o',
    messages: [
      ChatMessage.user('Hello'),
    ],
  ),
);

final text = response.text; // Convenience getter
// Or: response.choices.first.message.content
```

## Messages

### Before (v0.x)

```dart
// System message
ChatCompletionMessage.system(content: 'You are helpful')

// User message with string
ChatCompletionMessage.user(
  content: ChatCompletionUserMessageContent.string('Hello'),
)

// User message with parts
ChatCompletionMessage.user(
  content: ChatCompletionUserMessageContent.parts([
    ChatCompletionMessageContentPart.text(text: 'What is this?'),
    ChatCompletionMessageContentPart.image(
      imageUrl: ChatCompletionMessageImageUrl(url: 'https://...'),
    ),
  ]),
)

// Assistant message
ChatCompletionMessage.assistant(content: 'Hello!')

// Tool message
ChatCompletionMessage.tool(
  toolCallId: 'call_123',
  content: '{"result": 42}',
)
```

### After (v1.0.0)

```dart
// System message
ChatMessage.system('You are helpful')

// User message with string
ChatMessage.user('Hello')

// User message with parts
ChatMessage.user([
  ContentPart.text('What is this?'),
  ContentPart.imageUrl('https://...'),
])

// Assistant message
ChatMessage.assistant(content: 'Hello!')

// Tool message
ChatMessage.tool(
  toolCallId: 'call_123',
  content: '{"result": 42}',
)
```

## Streaming

### Before (v0.x)

```dart
final stream = client.createChatCompletionStream(
  request: CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId('gpt-4o'),
    messages: [...],
  ),
);

await for (final event in stream) {
  final delta = event.choices.first.delta.content;
  if (delta != null) {
    stdout.write(delta);
  }
}
```

### After (v1.0.0)

```dart
final stream = client.chat.completions.createStream(
  ChatCompletionCreateRequest(
    model: 'gpt-4o',
    messages: [...],
  ),
);

await for (final event in stream) {
  stdout.write(event.textDelta ?? '');
}

// Or use extension methods:
final text = await stream.collectText();

// Or iterate text deltas only:
await for (final delta in stream.textDeltas()) {
  stdout.write(delta);
}
```

## Tools / Function Calling

### Before (v0.x)

```dart
final response = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId('gpt-4o'),
    messages: [...],
    tools: [
      ChatCompletionTool(
        type: ChatCompletionToolType.function,
        function: FunctionObject(
          name: 'get_weather',
          description: 'Get weather',
          parameters: {...},
        ),
      ),
    ],
    toolChoice: ChatCompletionToolChoiceOption.tool(
      ChatCompletionNamedToolChoice(
        type: ChatCompletionNamedToolChoiceType.function,
        function: ChatCompletionFunctionCallOption(name: 'get_weather'),
      ),
    ),
  ),
);

if (response.choices.first.message.toolCalls case final calls?) {
  for (final call in calls) {
    final name = call.function.name;
    final args = call.function.arguments;
  }
}
```

### After (v1.0.0)

```dart
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'gpt-4o',
    messages: [...],
    tools: [
      Tool.function(
        name: 'get_weather',
        description: 'Get weather',
        parameters: {...},
      ),
    ],
    toolChoice: ToolChoice.function('get_weather'),
  ),
);

if (response.hasToolCalls) {
  for (final call in response.allToolCalls) {
    final name = call.function.name;
    final args = call.function.arguments;
  }
}
```

## Embeddings

### Before (v0.x)

```dart
final response = await client.createEmbedding(
  request: CreateEmbeddingRequest(
    model: EmbeddingModel.modelId('text-embedding-3-small'),
    input: EmbeddingInput.string('Hello'),
  ),
);

final vector = response.data.first.embedding;
```

### After (v1.0.0)

```dart
final response = await client.embeddings.create(
  EmbeddingRequest(
    model: 'text-embedding-3-small',
    input: EmbeddingInput.text('Hello'),
  ),
);

final vector = response.firstEmbedding;
// Or: response.data.first.embedding
```

## Images

### Before (v0.x)

```dart
final response = await client.createImage(
  request: CreateImageRequest(
    model: CreateImageRequestModel.modelId('dall-e-3'),
    prompt: 'A cat',
    size: ImageSize.v1024x1024,
  ),
);
```

### After (v1.0.0)

```dart
final response = await client.images.generate(
  ImageGenerationRequest(
    model: 'dall-e-3',
    prompt: 'A cat',
    size: ImageSize.size1024x1024,
  ),
);
```

## Error Handling

### Before (v0.x)

```dart
try {
  await client.createChatCompletion(...);
} on OpenAIClientException catch (e) {
  print('Error: ${e.message}');
}
```

### After (v1.0.0)

```dart
try {
  await client.chat.completions.create(...);
} on ApiException catch (e) {
  print('Error ${e.statusCode}: ${e.message}');
  print('Type: ${e.type}');
  print('Request ID: ${e.requestId}');
}

// Or catch specific exceptions:
try {
  await client.chat.completions.create(...);
} on RateLimitException catch (e) {
  print('Rate limited, retry after: ${e.retryAfter}');
} on AuthenticationException catch (e) {
  print('Invalid API key');
} on NotFoundException catch (e) {
  print('Resource not found');
}
```

### Complete Exception Hierarchy

v1.0.0 provides a comprehensive exception hierarchy:

```
OpenAIException (sealed base)
├── ApiException (base for HTTP errors)
│   ├── BadRequestException (400)
│   ├── AuthenticationException (401)
│   ├── PermissionDeniedException (403)
│   ├── NotFoundException (404)
│   ├── ConflictException (409)
│   ├── UnprocessableEntityException (422)
│   ├── RateLimitException (429)
│   └── InternalServerException (5xx)
├── RequestTimeoutException
├── AbortedException
├── ConnectionException
├── ParseException
└── StreamException
```

Each exception provides relevant context:

```dart
try {
  await client.chat.completions.create(...);
} on RateLimitException catch (e) {
  // Access retry information
  print('Rate limited. Retry after: ${e.retryAfter}');
  print('Request ID: ${e.requestId}');
} on ApiException catch (e) {
  // All API errors have these properties
  print('Status: ${e.statusCode}');
  print('Type: ${e.type}');
  print('Code: ${e.code}');
  print('Message: ${e.message}');
  print('Request ID: ${e.requestId}');
} on RequestTimeoutException catch (e) {
  print('Request timed out');
} on ConnectionException catch (e) {
  print('Network error: ${e.message}');
}
```

## Middleware → Interceptors

### Before (v0.x)

In v0.x, customizing request/response handling required overriding the client:

```dart
class MyClient extends OpenAIClient {
  MyClient({required super.apiKey});

  @override
  Future<http.BaseRequest> onRequest(http.BaseRequest request) async {
    // Custom request logic
    request.headers['X-Custom-Header'] = 'value';
    return request;
  }
}
```

### After (v1.0.0)

v1.0.0 uses a composable interceptor pattern:

```dart
// Built-in interceptors (applied automatically):
// - AuthInterceptor: Handles authentication
// - ErrorInterceptor: Converts HTTP errors to typed exceptions
// - LoggingInterceptor: Request/response logging (based on logLevel)

// Custom interceptor example:
class CustomHeaderInterceptor implements Interceptor {
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) async {
    // Modify request before passing it down the chain
    context.request.headers['X-Custom-Header'] = 'value';

    // Call next interceptor
    return next(context);
  }
}
```

## API Resource Access

### Before (v0.x)

All methods were on the client directly:
- `client.createChatCompletion(...)`
- `client.createEmbedding(...)`
- `client.createImage(...)`

### After (v1.0.0)

Methods are organized by resource:
- `client.chat.completions.create(...)`
- `client.embeddings.create(...)`
- `client.images.generate(...)`
- `client.audio.speech.create(...)`
- `client.audio.transcriptions.create(...)`
- `client.models.list()`
- `client.moderations.create(...)`
- `client.files.upload(...)`
- `client.beta.assistants.create(...)`
- `client.beta.threads.create(...)`
- `client.beta.vectorStores.create(...)`

**New in v1.0.0:**
- `client.responses.create(...)` - Responses API (recommended)
- `client.conversations.create(...)` - Conversations
- `client.completions.create(...)` - Legacy completions
- `client.videos.create(...)` - Sora video generation
- `client.evals.create(...)` - Model evaluation
- `client.uploads.create(...)` - Large file uploads
- `client.containers.create(...)` - Code containers
- `client.chatkit.sessions.create(...)` - ChatKit sessions
- `client.realtimeSessions.create(...)` - Realtime sessions (ephemeral keys)
- `client.realtimeSessions.calls.create(...)` - Realtime WebRTC calls

## Removed Features

The following freezed-related features are no longer needed:

- `copyWith()` - Models still have `copyWith()` but implemented manually
- `@freezed` annotations - Not used
- `.when()` / `.map()` pattern matching - Use Dart 3 switch expressions instead

## New Features

v1.0.0 adds several new features:

### Responses API (Recommended)

The Responses API is OpenAI's modern, unified API that combines the best of Chat Completions and Assistants:

```dart
final response = await client.responses.create(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: ResponseInput.text('Hello!'),
  ),
);

// Simple text access
print(response.outputText);

// Streaming
final stream = client.responses.createStream(
  CreateResponseRequest(
    model: 'gpt-4o',
    input: ResponseInput.text('Tell me a story'),
  ),
);

await for (final event in stream) {
  switch (event) {
    case OutputTextDeltaEvent(:final delta):
      stdout.write(delta);
    default:
      break;
  }
}
```

#### Responses API Content & Item Types

The Responses API uses a rich type system for inputs and outputs. Here's how to
work with the various content and item types.

**ResponseInput** — the sealed type for response input:

```dart
// Simple text input
input: ResponseInput.text('Hello!')

// Multi-turn conversation
input: ResponseInput.items([
  MessageItem.userText('What is 2+2?'),
  MessageItem.assistantText('4'),
  MessageItem.userText('What is 3+3?'),
])
```

**Image/file content — factory constructors** — replaced generic constructors
with named factories:

```dart
// Before (v0.x)
InputImageContent(imageUrl: url, detail: detail)
InputFileContent(fileData: data, filename: name)

// After (v1.0.0)
InputImageContent.url(url, detail: detail)
InputImageContent.file(fileId)
InputFileContent.url(url, filename: name)
InputFileContent.file(fileId, filename: name)
InputFileContent.data(data, filename: name)
```

**InputContent convenience factories** — the sealed class provides factories as
the recommended way to create input content:

```dart
InputContent.text('Hello')
InputContent.assistantText('Hello')
InputContent.imageUrl(url, detail: detail)
InputContent.imageFile(fileId)
InputContent.fileUrl(url, filename: name)
InputContent.fileId(fileId)
InputContent.fileData(data, filename: name)
InputContent.video(videoUrl)
```

**OutputContent** — content types for model output:

```dart
OutputContent.text(text: 'Hello')
OutputContent.reasoning('Thinking...')
OutputContent.summary('Summary here')
OutputContent.refusal('Cannot comply')
```

**Item types** — use item constructors for multi-turn conversations:

```dart
// Message items
MessageItem.userText('Hello')
MessageItem.assistantText('Response')
MessageItem.systemText('Instructions')
MessageItem.developerText('Dev instructions')

// Rich content messages
MessageItem.user([
  InputContent.text('Describe this image'),
  InputContent.imageUrl('https://...'),
])

// Function call items
const item = FunctionCallItem(
  callId: 'call_123',
  name: 'get_weather',
  arguments: '{"location":"Paris"}',
);
item.argumentsMap // Parses JSON, throws FormatException if invalid

// Function call output
FunctionCallOutputItem.string(
  callId: 'call_123',
  output: '{"temp": 20}',
)

// Item reference (for continuing conversations)
ItemReference(id: 'item_abc')
```

### Conversations API

For multi-turn conversations with automatic history management:

```dart
final conversation = await client.conversations.create(
  ConversationCreateRequest(
    items: [
      MessageItem.userText('Hello!'),
    ],
  ),
);
```

### Realtime API

`openai_dart` now includes built-in Realtime API support via WebSockets. This
provides a low-level, strongly typed interface for real-time audio conversations.

> **Note:** The separate `openai_realtime_dart` package provides a higher-level
> abstraction with conversation state management, tool handling, and utility
> events. If you need those features, you can continue using it alongside
> `openai_dart`.

```dart
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

// Connect to a realtime session
final session = await client.realtime.connect(
  model: 'gpt-realtime-1.5',
  config: realtime.SessionUpdateConfig(
    voice: realtime.RealtimeVoice.alloy,
    instructions: 'You are a helpful assistant.',
  ),
);

// Listen for events
session.events.listen((event) {
  switch (event) {
    case realtime.SessionCreatedEvent(:final session):
      print('Session created: ${session.id}');
    case realtime.ResponseTextDeltaEvent(:final delta):
      stdout.write(delta);
    case realtime.ErrorEvent(:final error):
      print('Error: ${error.message}');
    default:
      break;
  }
});

// Send audio, create responses, etc.
session.appendAudio(audioBase64);
session.createResponse();

// Close when done
await session.close();
```

#### WebRTC Support

In addition to WebSocket, the Realtime API supports WebRTC via HTTP-based SDP
signaling. Use `client.realtimeSessions.calls` to manage WebRTC calls.

> **Note:** For WebRTC peer connections in Flutter, use the
> [`flutter_webrtc`](https://pub.dev/packages/flutter_webrtc) package.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

// 1. Create a peer connection and generate an SDP offer
final pc = await createPeerConnection({'iceServers': []});
final offer = await pc.createOffer();
await pc.setLocalDescription(offer);

// 2. Send the SDP offer to OpenAI and get the SDP answer
final sdpAnswer = await client.realtimeSessions.calls.create(
  realtime.RealtimeCallCreateRequest(
    sdp: offer.sdp!,
    session: realtime.RealtimeSessionCreateRequest(
      model: 'gpt-realtime-1.5',
      voice: realtime.RealtimeVoice.alloy,
    ),
  ),
);

// 3. Set the SDP answer to complete the WebRTC handshake
await pc.setRemoteDescription(RTCSessionDescription(sdpAnswer, 'answer'));

// Additional call management methods (callId is obtained from your SIP/telephony layer):
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
```

The Realtime API is imported from a separate entry point
(`openai_dart_realtime.dart`) to avoid type conflicts with the Responses API.
See [Import Structure Changes](#import-structure-changes) for details.

### Videos API (Sora)

Generate videos with Sora:

```dart
final video = await client.videos.create(
  CreateVideoRequest(
    prompt: 'A cat playing piano',
    model: 'sora-2',
  ),
);
```

### Evals API

Run model evaluations:

```dart
final eval = await client.evals.create(
  CreateEvalRequest(
    name: 'My Evaluation',
    dataSourceConfig: DataSourceConfig(...),
    testingCriteria: [...],
  ),
);
```

### Uploads API

Handle large file uploads with chunking:

```dart
final upload = await client.uploads.create(
  CreateUploadRequest(
    filename: 'large_file.jsonl',
    purpose: FilePurpose.fineTune,
    bytes: fileSize,
    mimeType: 'application/jsonl',
  ),
);

// Add parts
await client.uploads.addPart(upload.id, UploadPartRequest(data: chunk1));
await client.uploads.addPart(upload.id, UploadPartRequest(data: chunk2));

// Complete the upload
final file = await client.uploads.complete(
  upload.id,
  CompleteUploadRequest(partIds: partIds),
);
```

### Containers API

Create and manage code execution containers:

```dart
final container = await client.containers.create(
  CreateContainerRequest(
    name: 'my-container',
    fileIds: ['file-abc123'],
    expiresAfter: ContainerExpiration(
      anchor: 'last_active_at',
      minutes: 60,
    ),
  ),
);
```

### ChatKit API

Manage chat sessions:

```dart
final session = await client.chatkit.sessions.create(
  CreateChatSessionRequest(
    name: 'Support Chat',
  ),
);
```

### Extension Methods

```dart
// Collect streaming text
final text = await stream.collectText();

// Get text deltas only
await for (final delta in stream.textDeltas()) {
  stdout.write(delta);
}

// Accumulate stream
await for (final acc in stream.accumulate()) {
  print('Content so far: ${acc.content}');
}

// Message list helpers
final messages = <ChatMessage>[]
  .withSystemMessage('You are helpful')
  .withUserMessage('Hello');
```

### Convenience Getters

```dart
// ChatCompletion
response.text           // First choice content
response.hasToolCalls   // Check for tool calls
response.allToolCalls   // Get all tool calls

// ChatChoice
choice.hasToolCalls
choice.stoppedForToolCalls
choice.stoppedForLength

// ChatStreamEvent
event.textDelta         // First choice delta content
event.firstChoice       // First choice

// EmbeddingResponse
response.firstEmbedding // First embedding vector
```

## Import Structure Changes

v1.0.0 introduces separate entry points for deprecated and specialized APIs to avoid naming conflicts.

### Breaking Change: Assistants and Realtime APIs

The Assistants API (including Threads, Runs, Vector Stores) and Realtime API are no longer exported from the main entry point. This change prioritizes the Responses API, which is OpenAI's recommended unified API.

### Before (v0.x)

```dart
import 'package:openai_dart/openai_dart.dart';

// All APIs available from single import
final assistant = await client.beta.assistants.create(...);
final tool = CodeInterpreterTool(); // Assistants version
```

### After (v1.0.0)

```dart
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_assistants.dart' as assistants;

// Responses API types (modern, recommended)
final tool = CodeInterpreterTool(); // Responses version

// Assistants API types (deprecated)
final assistantTool = assistants.CodeInterpreterTool();

// Creating assistants still works the same
final assistant = await client.beta.assistants.create(
  assistants.CreateAssistantRequest(
    model: 'gpt-4o',
    tools: [assistants.CodeInterpreterTool()],
  ),
);
```

### Entry Points

| Entry Point | Contents |
|-------------|----------|
| `openai_dart.dart` | Modern APIs: Chat, Responses, Embeddings, Images, Audio, Files, Batches, Fine-tuning, Moderations, Evals |
| `openai_dart_assistants.dart` | Deprecated: Assistants, Threads, Messages, Runs, Vector Stores |
| `openai_dart_realtime.dart` | Realtime: WebSocket audio conversations and WebRTC call management |

### Conflicting Types

The following types exist in both Responses API and deprecated APIs:

| Type | In Responses API | In Assistants/Realtime |
|------|-----------------|------------------------|
| `CodeInterpreterTool` | Responses tool | Assistants tool |
| `FileSearchTool` | Responses tool | Assistants tool |
| `FunctionTool` | Responses tool | Assistants tool |
| `FileCitation` | Annotation | Message annotation |
| `FilePathAnnotation` | Annotation | Message annotation |
| `IncompleteDetails` | Response details | Message details |
| `ErrorEvent` | Stream event | Realtime event |
| `ResponseCreatedEvent` | Stream event | Realtime event |

Use import prefixes (`as assistants`, `as realtime`) to disambiguate when needed.

## Common Pitfalls

### Model IDs Are Now Strings

```dart
// Before - enum-like
model: ChatCompletionModel.modelId('gpt-4o')

// After - simple string
model: 'gpt-4o'
```

### Response Properties Changed

```dart
// Before - nested access
response.choices.first.message.content

// After - convenience getter
response.text
```

### Assistants API Requires Separate Import

```dart
// Won't work - types not exported from main
import 'package:openai_dart/openai_dart.dart';
final assistant = await client.beta.assistants.create(...); // Error!

// Correct - use separate import
import 'package:openai_dart/openai_dart_assistants.dart';
```

### Close the Client

```dart
// Always close when done
final client = OpenAIClient.fromEnvironment();
try {
  // ... use client
} finally {
  client.close();
}
```

### Streaming Type Checking

```dart
// Use convenience getters for stream events
await for (final event in stream) {
  final content = event.firstChoice?.delta.content;
  if (content != null) {
    stdout.write(content);
  }
}
```

Or, more concisely, use the convenience getter:

```dart
await for (final event in stream) {
  stdout.write(event.textDelta ?? '');
}
```

## Nullable `created` and `ownedBy` Fields

The following fields are now nullable to improve compatibility with OpenAI-compatible
providers (e.g., Cohere, which doesn't return `created` in its models endpoint):

| Class | Field | Old Type | New Type |
|-------|-------|----------|----------|
| `Model` | `created` | `int` | `int?` |
| `Model` | `ownedBy` | `String` | `String?` |
| `Model` | `createdAt` | `DateTime` | `DateTime?` |
| `ChatCompletion` | `created` | `int` | `int?` |
| `ChatCompletion` | `createdAt` | `DateTime` | `DateTime?` |
| `Completion` | `created` | `int` | `int?` |

If your code accesses these fields, add null checks:

```dart
// Before
final timestamp = model.created;
final date = model.createdAt;
final owner = model.ownedBy;

// After
final timestamp = model.created; // int? now
final date = model.createdAt;    // DateTime? now
final owner = model.ownedBy;     // String? now
```

## OpenAI-Compatible APIs

The v1.0.0 client includes improved compatibility with OpenAI-compatible APIs (OpenRouter, Groq, FastChat, TogetherAI, Anyscale, DeepSeek, and more).

### Supported Providers

| Provider | Notes |
|----------|-------|
| OpenAI | Full support (official API) |
| OpenRouter | Full support with provider-specific extensions |
| Groq | Full support (may return events without `choices`) |
| TogetherAI | Full support (may not return `model` in streams, `usage` in embeddings) |
| FastChat | Full support (may not return `object`, `created` in streams) |
| Anyscale | Full support (may return `text_completion` as object type) |
| DeepSeek | Full support with reasoning content extensions |

### Nullable Response Fields

Some response fields are now nullable to handle variations across providers:

```dart
// ChatCompletion
final completion = ChatCompletion.fromJson(json);
// These may be null with some providers:
completion.id           // OpenRouter doesn't always return this
completion.provider     // OpenRouter only - which provider served the request

// ChatChoice
final choice = completion.choices.first;
choice.index            // OpenRouter doesn't always return this

// ChatStreamEvent
final event = ChatStreamEvent.fromJson(json);
event.id                // OpenRouter
event.object            // FastChat
event.created           // FastChat
event.model             // TogetherAI
event.choices           // Groq - may be null!
event.provider          // OpenRouter only

// EmbeddingResponse
final response = EmbeddingResponse.fromJson(json);
response.usage          // TogetherAI doesn't always return this

// Usage
final usage = response.usage;
usage?.completionTokens // Some providers don't return this
```

### Handling Nullable Choices in Streams

Since `choices` may be null in streaming events (e.g., with Groq), use safe access:

```dart
await for (final event in stream) {
  // Safe access for nullable choices
  final content = event.choices?.firstOrNull?.delta.content;
  if (content != null) {
    stdout.write(content);
  }
}

// Or use the convenience getter (handles null safely)
await for (final event in stream) {
  stdout.write(event.textDelta ?? '');
}
```

### OpenRouter-Specific Request Parameters

The client includes OpenRouter-specific parameters that are ignored by standard OpenAI:

```dart
final request = ChatCompletionCreateRequest(
  model: 'openai/gpt-4o',
  messages: [...],

  // Sampling parameters (OpenRouter only)
  topK: 40,                     // Sample from top K tokens
  minP: 0.1,                    // Minimum probability threshold
  topA: 0.5,                    // Dynamic top-p filter
  repetitionPenalty: 1.2,       // Repetition penalty (1.0 = none)

  // Provider routing (OpenRouter only)
  openRouterProvider: OpenRouterProviderPreferences(
    order: ['OpenAI', 'Azure'], // Provider preference order
    allowFallbacks: true,       // Allow fallback to other providers
    dataCollection: 'deny',     // Data collection preference
    zdr: true,                  // Zero Data Retention
    ignore: ['Anthropic'],      // Providers to exclude
    quantizations: ['fp16'],    // Quantization requirements
    sort: 'price',              // Sort by: price, throughput, latency
  ),

  // Fallback models (OpenRouter only)
  models: ['openai/gpt-4o', 'anthropic/claude-3'],
  route: 'fallback',

  // Prompt transforms (OpenRouter only)
  transforms: ['middle-out'],

  // Usage config (OpenRouter only)
  openRouterUsage: OpenRouterUsageConfig(include: true),

  // Reasoning config for reasoning models (OpenRouter only)
  openRouterReasoning: OpenRouterReasoning(
    effort: 'high',       // high, medium, low
    maxTokens: 8000,      // 1024-32000
    exclude: false,       // Exclude reasoning from output
    enabled: true,        // Enable/disable reasoning
  ),
);
```

### Reasoning Content in Responses

When using reasoning models (DeepSeek R1, etc.), responses may include reasoning content:

```dart
final response = await client.chat.completions.create(...);
final message = response.firstChoice?.message;

// DeepSeek R1 / vLLM reasoning content
if (message?.reasoningContent != null) {
  print('Reasoning: ${message.reasoningContent}');
}

// OpenRouter reasoning summary
if (message?.reasoning != null) {
  print('Summary: ${message.reasoning}');
}

// OpenRouter detailed reasoning
if (message?.reasoningDetails != null) {
  for (final detail in message.reasoningDetails!) {
    if (detail.isSummary) {
      print('Summary: ${detail.text}');
    } else if (detail.isEncrypted) {
      print('Encrypted data: ${detail.data}');
    }
  }
}

// Check if message has any reasoning
if (message?.hasReasoningContent ?? false) {
  print('This response includes reasoning');
}
```

### Streaming Reasoning Content

Reasoning content is also available in streaming:

```dart
final accumulator = ChatStreamAccumulator();

await for (final event in stream) {
  accumulator.add(event);

  // Access delta reasoning
  final delta = event.choices?.first.delta;
  if (delta?.reasoningContent != null) {
    stdout.write('[REASONING] ${delta.reasoningContent}');
  }
  if (delta?.content != null) {
    stdout.write(delta.content);
  }
}

// After streaming, access accumulated reasoning
print('Full reasoning: ${accumulator.reasoningContent}');
print('Full content: ${accumulator.content}');

// Build a ChatCompletion from the accumulated stream data
final completion = accumulator.toChatCompletion();
print('Model: ${completion.model}');
print('Text: ${completion.text}');
```

### Sending Messages Back to API

**IMPORTANT:** When sending assistant messages back to the API (e.g., in conversation history), use `toApiJson()` instead of `toJson()` to exclude reasoning fields that would cause 400 errors with some providers:

```dart
// Received from API with reasoning
final assistantMessage = response.firstChoice?.message;

// Later, sending back as history - use toApiJson()
final history = [
  ChatMessage.user('What is 2+2?').toJson(),
  assistantMessage!.toApiJson(), // Excludes reasoning fields
  ChatMessage.user('Now multiply that by 3').toJson(),
];

// toJson() keeps reasoning fields (for debugging/logging)
print(assistantMessage.toJson()); // Includes reasoning_content, etc.

// toApiJson() strips reasoning fields (for API requests)
print(assistantMessage.toApiJson()); // No reasoning fields
```

### Connecting to OpenRouter

```dart
final client = OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'https://openrouter.ai/api/v1',
    authProvider: ApiKeyProvider('sk-or-...'),
  ),
);

// Use OpenRouter model IDs
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'openai/gpt-4o',  // Provider/model format
    messages: [...],
  ),
);

// Access OpenRouter-specific response fields
print('Provider: ${response.provider}');
```

## Getting Help

If you encounter issues migrating:

1. Check the [API documentation](https://platform.openai.com/docs/api-reference)
2. Review the [examples](./example/)
3. Open an issue on [GitHub](https://github.com/davidmigloz/ai_clients_dart/issues)
