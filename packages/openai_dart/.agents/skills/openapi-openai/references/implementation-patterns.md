# Implementation Patterns (openai_dart)


## Contents

- [API-Specific Patterns](#api-specific-patterns)
  - [Authentication](#authentication)
  - [Streaming](#streaming)
  - [Tool Calling](#tool-calling)
  - [Multimodal Content](#multimodal-content)
  - [Response Format / Structured Output](#response-format-structured-output)
  - [Assistants API (Beta)](#assistants-api-beta)
  - [File Uploads](#file-uploads)
  - [Error Handling](#error-handling)
  - [Rate Limiting](#rate-limiting)
  - [Real-time API](#real-time-api)
- [Model Pattern Examples](#model-pattern-examples)
  - [Request Model](#request-model)
  - [Sealed Class for Variants](#sealed-class-for-variants)
  - [Enum with JSON Serialization](#enum-with-json-serialization)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## API-Specific Patterns

### Authentication

OpenAI uses Bearer token authentication with optional organization and project headers:

```dart
class OpenAIConfig {
  final AuthProvider? authProvider;
  final String? organization;  // OpenAI-Organization header
  final String? project;       // OpenAI-Project header
}
```

For Azure OpenAI, use the `api-key` header instead:

```dart
class AzureApiKeyProvider implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {'api-key': apiKey};
}
```

### Streaming

OpenAI uses Server-Sent Events (SSE) for streaming. The response format is:

```
data: {"id":"chatcmpl-...","object":"chat.completion.chunk",...}

data: {"id":"chatcmpl-...","object":"chat.completion.chunk",...}

data: [DONE]
```

Streaming implementation:

```dart
Stream<ChatStreamEvent> createStream(ChatCompletionCreateRequest request) async* {
  final response = await _client.post(
    '/chat/completions',
    body: jsonEncode({...request.toJson(), 'stream': true}),
    headers: {'Accept': 'text/event-stream'},
  );

  await for (final event in _parseSSE(response.stream)) {
    if (event.data == '[DONE]') break;
    yield ChatStreamEvent.fromJson(jsonDecode(event.data));
  }
}
```

### Tool Calling

Tools are defined with JSON Schema for parameters:

```dart
final tool = Tool(
  type: 'function',
  function: FunctionDefinition(
    name: 'get_weather',
    description: 'Get the weather for a location',
    parameters: {
      'type': 'object',
      'properties': {
        'location': {'type': 'string'},
      },
      'required': ['location'],
    },
  ),
);
```

Tool choice options:
- `'auto'` - Let model decide
- `'none'` - Disable tools
- `'required'` - Force tool use
- `{'type': 'function', 'function': {'name': 'tool_name'}}` - Force specific tool

### Multimodal Content

User messages can contain multiple content parts:

```dart
final message = ChatMessage.user([
  ContentPart.text('What is in this image?'),
  ContentPart.imageUrl(
    'https://example.com/image.jpg',
    detail: ImageDetail.high,
  ),
]);
```

For audio input:

```dart
final message = ChatMessage.user([
  ContentPart.text('What do you hear?'),
  ContentPart.inputAudio(
    data: base64AudioData,
    format: AudioFormat.wav,
  ),
]);
```

### Response Format / Structured Output

Request JSON output:

```dart
final request = ChatCompletionCreateRequest(
  model: 'gpt-4o',
  messages: [...],
  responseFormat: ResponseFormat.jsonObject(),
);
```

Request specific JSON schema:

```dart
final request = ChatCompletionCreateRequest(
  model: 'gpt-4o',
  messages: [...],
  responseFormat: ResponseFormat.jsonSchema(
    name: 'person',
    schema: {
      'type': 'object',
      'properties': {
        'name': {'type': 'string'},
        'age': {'type': 'integer'},
      },
    },
  ),
);
```

### Assistants API (Beta)

The Assistants API uses a stateful conversation model:

```dart
// Create an assistant
final assistant = await client.beta.assistants.create(
  AssistantCreateRequest(
    model: 'gpt-4o',
    name: 'Math Tutor',
    instructions: 'You are a helpful math tutor.',
    tools: [Tool.codeInterpreter()],
  ),
);

// Create a thread
final thread = await client.beta.threads.create();

// Add a message
await client.beta.threads.messages.create(
  thread.id,
  MessageCreateRequest(
    role: 'user',
    content: 'Solve x^2 + 2x + 1 = 0',
  ),
);

// Run the assistant
final run = await client.beta.threads.runs.createStream(
  thread.id,
  RunCreateRequest(assistantId: assistant.id),
);

await for (final event in run) {
  // Handle streaming events
}
```

### File Uploads

For large files, use the Uploads API:

```dart
// Create upload
final upload = await client.uploads.create(
  UploadCreateRequest(
    filename: 'large_file.jsonl',
    purpose: 'fine-tune',
    bytes: fileSize,
    mimeType: 'application/jsonl',
  ),
);

// Add parts
for (final chunk in chunks) {
  await client.uploads.addPart(upload.id, chunk);
}

// Complete upload
final file = await client.uploads.complete(
  upload.id,
  UploadCompleteRequest(partIds: partIds),
);
```

### Error Handling

OpenAI returns errors in this format:

```json
{
  "error": {
    "message": "Error message",
    "type": "invalid_request_error",
    "param": "model",
    "code": "model_not_found"
  }
}
```

Map to exceptions:
- `400` → `BadRequestException`
- `401` → `AuthenticationException`
- `403` → `PermissionDeniedException`
- `404` → `NotFoundException`
- `429` → `RateLimitException` (check `Retry-After` header)
- `5xx` → `InternalServerException`

### Rate Limiting

Handle rate limits with exponential backoff:

```dart
try {
  return await client.chat.completions.create(request);
} on RateLimitException catch (e) {
  if (e.retryAfter != null) {
    await Future.delayed(e.retryAfter!);
    return await client.chat.completions.create(request);
  }
  rethrow;
}
```

### Real-time API

The Real-time API uses WebSocket connections:

```dart
final realtime = client.realtime;

// Connect
await realtime.connect(model: 'gpt-4o-realtime-preview');

// Send audio
realtime.sendAudio(audioChunk);

// Handle events
realtime.on('response.audio.delta', (event) {
  playAudio(event.delta);
});

// Update session
await realtime.updateSession(
  SessionConfig(
    voice: Voice.alloy,
    turnDetection: TurnDetection.serverVad(),
  ),
);
```

## Model Pattern Examples

### Request Model

```dart
@immutable
class ChatCompletionCreateRequest {
  const ChatCompletionCreateRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.stream,
  });

  factory ChatCompletionCreateRequest.fromJson(Map<String, dynamic> json) => ...

  final String model;
  final List<ChatMessage> messages;
  final double? temperature;
  final int? maxTokens;
  final List<Tool>? tools;
  final ToolChoice? toolChoice;
  final ResponseFormat? responseFormat;
  final bool? stream;

  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((m) => m.toJson()).toList(),
    if (temperature != null) 'temperature': temperature,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (stream != null) 'stream': stream,
  };
}
```

### Sealed Class for Variants

```dart
sealed class ChatMessage {
  const ChatMessage();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return switch (json['role'] as String) {
      'system' => SystemMessage.fromJson(json),
      'user' => UserMessage.fromJson(json),
      'assistant' => AssistantMessage.fromJson(json),
      'tool' => ToolMessage.fromJson(json),
      'developer' => DeveloperMessage.fromJson(json),
      _ => throw ArgumentError('Unknown role: ${json['role']}'),
    };
  }

  String get role;
  Map<String, dynamic> toJson();

  static ChatMessage system(String content) => SystemMessage(content: content);
  static ChatMessage user(dynamic content) => UserMessage(content: content);
  static ChatMessage assistant({String? content, List<ToolCall>? toolCalls}) =>
      AssistantMessage(content: content, toolCalls: toolCalls);
  static ChatMessage tool({required String toolCallId, required String content}) =>
      ToolMessage(toolCallId: toolCallId, content: content);
}

@immutable
class SystemMessage extends ChatMessage {
  const SystemMessage({required this.content, this.name});

  factory SystemMessage.fromJson(Map<String, dynamic> json) => ...

  final String content;
  final String? name;

  @override
  String get role => 'system';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (name != null) 'name': name,
  };
}
```

### Enum with JSON Serialization

```dart
enum FinishReason {
  stop('stop'),
  length('length'),
  toolCalls('tool_calls'),
  contentFilter('content_filter'),
  functionCall('function_call');

  const FinishReason(this.value);
  final String value;

  static FinishReason fromJson(String json) {
    return FinishReason.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw ArgumentError('Unknown finish reason: $json'),
    );
  }

  String toJson() => value;
}
```
