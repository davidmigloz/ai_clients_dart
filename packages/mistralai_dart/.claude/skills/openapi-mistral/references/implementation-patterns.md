# Implementation Patterns (mistralai_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## Contents

- [Directory Structure](#directory-structure)
- [Model Conventions](#model-conventions)
- [Enum Conventions](#enum-conventions)
- [Sealed Class Patterns](#sealed-class-patterns)
- [Resource Methods](#resource-methods)
- [Streaming Patterns](#streaming-patterns)
- [Mistral-Specific Patterns](#mistral-specific-patterns)
- [JSON Serialization](#json-serialization)
- [Test Patterns](#test-patterns)
- [Export Organization](#export-organization)

---

## Directory Structure

Models are organized by feature area:

```
lib/src/models/
├── chat/            # Chat completion models
├── content/         # Multimodal content parts
├── embeddings/      # Embedding models
├── models/          # Model management models
├── tools/           # Tool/function definitions
├── metadata/        # Usage, response format, etc.
└── common/          # Shared types (sentinel)
```

Tests mirror this structure under `test/unit/models/`.

---

## Model Conventions

### Basic Structure

```dart
import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Description from OpenAPI spec.
@immutable
class ModelName {
  /// Field documentation.
  final String? fieldName;

  /// Creates a [ModelName].
  const ModelName({
    this.fieldName,
  });

  /// Creates a [ModelName] from JSON.
  factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
        fieldName: json['field_name'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        if (fieldName != null) 'field_name': fieldName,
      };

  /// Creates a copy with replaced values.
  ModelName copyWith({
    Object? fieldName = unsetCopyWithValue,
  }) {
    return ModelName(
      fieldName:
          fieldName == unsetCopyWithValue
              ? this.fieldName
              : fieldName as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelName &&
          runtimeType == other.runtimeType &&
          fieldName == other.fieldName;

  @override
  int get hashCode => fieldName.hashCode;

  @override
  String toString() => 'ModelName(fieldName: $fieldName)';
}
```

### Type Mappings

| OpenAPI Type | Dart Type |
|--------------|-----------|
| `string` | `String` |
| `integer` | `int` |
| `number` | `double` |
| `boolean` | `bool` |
| `array` | `List<T>` |
| `object` | `Map<String, dynamic>` or custom class |
| `$ref` | Referenced class name |

---

## Enum Conventions

### Basic Structure

Mistral uses snake_case for enum wire values:

```dart
/// Finish reason for a completion.
enum FinishReason {
  /// Stop sequence reached.
  stop,

  /// Max tokens reached.
  length,

  /// Tool calls generated.
  toolCalls,

  /// Error occurred.
  error,
}

/// Converts string to [FinishReason] enum.
FinishReason? finishReasonFromString(String? value) {
  return switch (value) {
    'stop' => FinishReason.stop,
    'length' => FinishReason.length,
    'tool_calls' => FinishReason.toolCalls,
    'error' => FinishReason.error,
    _ => null,
  };
}

/// Converts [FinishReason] enum to string.
String finishReasonToString(FinishReason value) {
  return switch (value) {
    FinishReason.stop => 'stop',
    FinishReason.length => 'length',
    FinishReason.toolCalls => 'tool_calls',
    FinishReason.error => 'error',
  };
}
```

---

## Sealed Class Patterns

### Message Hierarchy

Mistral uses role-based message discrimination:

```dart
/// Sealed class for chat messages.
sealed class ChatMessage {
  const ChatMessage();

  /// The role of this message.
  String get role;

  /// Creates a [ChatMessage] from JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return switch (json['role']) {
      'system' => SystemMessage.fromJson(json),
      'user' => UserMessage.fromJson(json),
      'assistant' => AssistantMessage.fromJson(json),
      'tool' => ToolMessage.fromJson(json),
      _ => throw FormatException('Unknown role: ${json['role']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  // Convenience constructors
  factory ChatMessage.system(String content) => SystemMessage(content: content);
  factory ChatMessage.user(String content) => UserMessage.text(content);
  factory ChatMessage.assistant(String content, {List<ToolCall>? toolCalls}) =>
      AssistantMessage(content: content, toolCalls: toolCalls);
  factory ChatMessage.tool({required String toolCallId, required String content}) =>
      ToolMessage(toolCallId: toolCallId, content: content);
}
```

### Content Parts (Multimodal)

```dart
/// Sealed class for content parts in user messages.
sealed class ContentPart {
  const ContentPart();

  /// The type of this content part.
  String get type;

  /// Creates a [ContentPart] from JSON.
  factory ContentPart.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => TextContentPart.fromJson(json),
      'image_url' => ImageUrlContentPart.fromJson(json),
      _ => throw FormatException('Unknown content type: ${json['type']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  // Convenience constructors
  factory ContentPart.text(String text) => TextContentPart(text: text);
  factory ContentPart.imageUrl(String url) => ImageUrlContentPart(url: url);
}

/// Text content part.
class TextContentPart extends ContentPart {
  @override
  String get type => 'text';

  final String text;

  const TextContentPart({required this.text});

  factory TextContentPart.fromJson(Map<String, dynamic> json) =>
      TextContentPart(text: json['text'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};
}

/// Image URL content part.
class ImageUrlContentPart extends ContentPart {
  @override
  String get type => 'image_url';

  final String url;

  const ImageUrlContentPart({required this.url});

  factory ImageUrlContentPart.fromJson(Map<String, dynamic> json) =>
      ImageUrlContentPart(url: json['image_url'] as String);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'image_url': url};
}
```

### Tool Choice

```dart
/// Sealed class for tool choice options.
sealed class ToolChoice {
  const ToolChoice();

  /// Creates a [ToolChoice] from JSON.
  factory ToolChoice.fromJson(Object json) {
    if (json is String) {
      return switch (json) {
        'none' => const ToolChoiceNone(),
        'auto' => const ToolChoiceAuto(),
        'any' => const ToolChoiceAny(),
        'required' => const ToolChoiceRequired(),
        _ => throw FormatException('Unknown tool_choice: $json'),
      };
    }
    if (json is Map<String, dynamic>) {
      return ToolChoiceFunction.fromJson(json);
    }
    throw FormatException('Invalid tool_choice type: ${json.runtimeType}');
  }

  /// Converts to JSON.
  Object toJson();

  // Convenience constructors
  static const none = ToolChoiceNone();
  static const auto = ToolChoiceAuto();
  static const any = ToolChoiceAny();
  static const required = ToolChoiceRequired();
  factory ToolChoice.function(String name) =>
      ToolChoiceFunction(name: name);
}
```

---

## Resource Methods

Resources extend `ResourceBase` and follow this pattern:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../client/interceptor_chain.dart';
import '../client/request_builder.dart';
import '../models/chat/chat_completion_request.dart';
import '../models/chat/chat_completion_response.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for chat completions.
class ChatResource extends ResourceBase with StreamingResource {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Creates a chat completion.
  Future<ChatCompletionResponse> create({
    required ChatCompletionRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/chat/completions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);
    return ChatCompletionResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
```

---

## Streaming Patterns

See also: [Streaming Patterns](../../../shared/openapi-toolkit/references/implementation-patterns-core.md#streaming-patterns) in core patterns.

### StreamingResource Mixin

Resources with streaming methods use the `StreamingResource` mixin:

```dart
class ChatResource extends ResourceBase with StreamingResource {
  // Non-streaming methods use interceptorChain as normal
  // Streaming methods use mixin helpers
}
```

### SSE Streaming

Mistral uses Server-Sent Events (SSE) for streaming responses:

```dart
/// Creates a streaming chat completion.
Stream<ChatCompletionStreamResponse> createStream({
  required ChatCompletionRequest request,
}) async* {
  final url = requestBuilder.buildUrl('/v1/chat/completions');
  final headers = requestBuilder.buildHeaders(
    additionalHeaders: {'Content-Type': 'application/json'},
  );

  // Ensure stream is true for streaming
  final requestData = request.copyWith(stream: true);

  var httpRequest = http.Request('POST', url)
    ..headers.addAll(headers)
    ..body = jsonEncode(requestData.toJson());

  // Use mixin methods for streaming request handling
  httpRequest = await prepareStreamingRequest(httpRequest);
  final streamedResponse = await sendStreamingRequest(httpRequest);

  // Parse SSE stream
  await for (final json in parseSSE(streamedResponse.stream)) {
    yield ChatCompletionStreamResponse.fromJson(json);
  }
}
```

### SSE Parser

```dart
Stream<Map<String, dynamic>> parseSSE(Stream<List<int>> stream) async* {
  final buffer = StringBuffer();

  await for (final chunk in stream.transform(utf8.decoder)) {
    buffer.write(chunk);
    final lines = buffer.toString().split('\n');
    buffer.clear();

    // Keep incomplete line in buffer
    if (!chunk.endsWith('\n')) {
      buffer.write(lines.removeLast());
    }

    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') {
          return;
        }
        if (data.isNotEmpty) {
          yield jsonDecode(data) as Map<String, dynamic>;
        }
      }
    }
  }
}
```

---

## Mistral-Specific Patterns

### Multimodal Content (Vision)

User messages can contain text and images:

```dart
/// User message with multimodal content support.
class UserMessage extends ChatMessage {
  @override
  String get role => 'user';

  /// Content can be String or List<ContentPart>.
  final Object content;

  const UserMessage({required this.content});

  /// Convenience constructor for text-only messages.
  factory UserMessage.text(String text) => UserMessage(content: text);

  /// Convenience constructor for multimodal messages.
  factory UserMessage.multimodal(List<ContentPart> parts) =>
      UserMessage(content: parts);

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    if (content is String) {
      return UserMessage(content: content);
    }
    if (content is List) {
      return UserMessage(
        content: content
            .map((e) => ContentPart.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid content type: ${content.runtimeType}');
  }

  @override
  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content is String
            ? content
            : (content as List<ContentPart>).map((e) => e.toJson()).toList(),
      };
}
```

### Tool Calling

```dart
/// Assistant message with tool call support.
class AssistantMessage extends ChatMessage {
  @override
  String get role => 'assistant';

  final String? content;
  final List<ToolCall>? toolCalls;
  final bool? prefix; // For fill-in-middle

  const AssistantMessage({
    this.content,
    this.toolCalls,
    this.prefix,
  });

  factory AssistantMessage.fromJson(Map<String, dynamic> json) => AssistantMessage(
        content: json['content'] as String?,
        toolCalls: (json['tool_calls'] as List?)
            ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
            .toList(),
        prefix: json['prefix'] as bool?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'role': role,
        if (content != null) 'content': content,
        if (toolCalls != null)
          'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
        if (prefix != null) 'prefix': prefix,
      };
}
```

### Response Format (Structured Output)

```dart
/// Sealed class for response format options.
sealed class ResponseFormat {
  const ResponseFormat();

  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => const ResponseFormatText(),
      'json_object' => const ResponseFormatJsonObject(),
      'json_schema' => ResponseFormatJsonSchema.fromJson(json),
      _ => throw FormatException('Unknown response format: ${json['type']}'),
    };
  }

  Map<String, dynamic> toJson();

  static const text = ResponseFormatText();
  static const jsonObject = ResponseFormatJsonObject();
  factory ResponseFormat.jsonSchema({
    required String name,
    required Map<String, dynamic> schema,
    String? description,
    bool? strict,
  }) => ResponseFormatJsonSchema(
        name: name,
        schema: schema,
        description: description,
        strict: strict,
      );
}
```

### Safe Prompt

Mistral has a unique `safe_prompt` parameter:

```dart
/// Whether to inject a safety prompt.
/// When true, Mistral injects a system prompt about responsible AI usage.
final bool? safePrompt;
```

---

## JSON Serialization

### Required Fields

```dart
// In fromJson - throw or use default if truly required
model: json['model'] as String,

// In toJson - always include
'model': model,
```

### Optional Fields

```dart
// In fromJson - allow null
temperature: (json['temperature'] as num?)?.toDouble(),

// In toJson - conditionally include
if (temperature != null) 'temperature': temperature,
```

### Snake Case Conversion

Mistral uses snake_case for JSON keys:

```dart
// Field names use camelCase in Dart
final int? maxTokens;

// JSON keys use snake_case
// In fromJson:
maxTokens: json['max_tokens'] as int?,

// In toJson:
if (maxTokens != null) 'max_tokens': maxTokens,
```

---

## Test Patterns

### Standard Test Groups

```dart
void main() {
  group('ChatMessage', () {
    group('fromJson', () {
      test('creates SystemMessage', () {
        final json = {'role': 'system', 'content': 'You are helpful.'};
        final message = ChatMessage.fromJson(json);
        expect(message, isA<SystemMessage>());
        expect((message as SystemMessage).content, 'You are helpful.');
      });

      test('creates UserMessage with text content', () {
        final json = {'role': 'user', 'content': 'Hello!'};
        final message = ChatMessage.fromJson(json);
        expect(message, isA<UserMessage>());
        expect((message as UserMessage).content, 'Hello!');
      });

      test('creates UserMessage with multimodal content', () {
        final json = {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'What is this?'},
            {'type': 'image_url', 'image_url': 'https://example.com/image.jpg'},
          ],
        };
        final message = ChatMessage.fromJson(json);
        expect(message, isA<UserMessage>());
        final content = (message as UserMessage).content as List<ContentPart>;
        expect(content, hasLength(2));
        expect(content[0], isA<TextContentPart>());
        expect(content[1], isA<ImageUrlContentPart>());
      });
    });

    group('toJson', () {
      test('converts SystemMessage to JSON', () {
        final message = ChatMessage.system('You are helpful.');
        final json = message.toJson();
        expect(json['role'], 'system');
        expect(json['content'], 'You are helpful.');
      });
    });

    test('round-trip preserves data', () {
      final original = ChatMessage.assistant(
        'Hello!',
        toolCalls: [
          ToolCall(
            id: 'call_123',
            function: FunctionCall(name: 'get_weather', arguments: '{}'),
          ),
        ],
      );
      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored, equals(original));
    });
  });
}
```

---

## Export Organization

### Main Barrel File

```dart
/// Dart client for the Mistral AI API.
library;

// Client
export 'src/client/config.dart' show MistralConfig, RetryPolicy;
export 'src/client/mistral_client.dart';

// Auth
export 'src/auth/auth_provider.dart';

// Errors
export 'src/errors/mistral_exception.dart';

// Models - Chat
export 'src/models/chat/chat_message.dart';
export 'src/models/chat/chat_completion_request.dart';
export 'src/models/chat/chat_completion_response.dart';
export 'src/models/chat/chat_completion_stream_response.dart';
export 'src/models/chat/chat_choice.dart';
export 'src/models/chat/chat_choice_delta.dart';

// Models - Content
export 'src/models/content/content_part.dart';

// Models - Embeddings
export 'src/models/embeddings/embedding_request.dart';
export 'src/models/embeddings/embedding_response.dart';
export 'src/models/embeddings/embedding_data.dart';

// Models - Models
export 'src/models/models/model.dart';
export 'src/models/models/model_list.dart';

// Models - Tools
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_call.dart';
export 'src/models/tools/tool_choice.dart';
export 'src/models/tools/function_definition.dart';
export 'src/models/tools/function_call.dart';

// Models - Metadata
export 'src/models/metadata/usage_info.dart';
export 'src/models/metadata/response_format.dart';
export 'src/models/metadata/finish_reason.dart';
```

---

## Related Documentation

- [Package Guide](./package-guide.md)
- [Review Checklist](./REVIEW_CHECKLIST.md)
