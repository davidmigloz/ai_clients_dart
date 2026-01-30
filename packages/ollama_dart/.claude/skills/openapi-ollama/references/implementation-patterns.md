# Implementation Patterns (ollama_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## Contents

- [Directory Structure](#directory-structure)
- [Model Conventions](#model-conventions)
- [Enum Conventions](#enum-conventions)
- [Resource Methods](#resource-methods)
- [Streaming Patterns](#streaming-patterns)
- [Ollama-Specific Patterns](#ollama-specific-patterns)
- [JSON Serialization](#json-serialization)
- [Test Patterns](#test-patterns)
- [Export Organization](#export-organization)

---

## Directory Structure

Models are organized by feature area:

```
lib/src/models/
├── chat/            # Chat completion models
├── completions/     # Text generation models
├── embeddings/      # Embedding models
├── models/          # Model management models
├── tools/           # Tool/function definitions
├── metadata/        # Version, options, capabilities
├── common/          # Shared types
└── copy_with_sentinel.dart  # Shared sentinel value
```

Tests mirror this structure under `test/unit/models/`.

---

## Model Conventions

### Basic Structure

```dart
import '../copy_with_sentinel.dart';

/// Description from OpenAPI spec.
class ModelName {
  /// Field documentation.
  final String? fieldName;

  /// Creates a [ModelName].
  const ModelName({
    this.fieldName,
  });

  /// Creates a [ModelName] from JSON.
  factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
        fieldName: json['fieldName'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        if (fieldName != null) 'fieldName': fieldName,
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

Ollama uses lowercase snake_case for enum wire values:

```dart
/// Message role.
enum MessageRole {
  /// System message.
  system,

  /// User message.
  user,

  /// Assistant message.
  assistant,

  /// Tool result message.
  tool,
}

/// Converts string to [MessageRole] enum.
MessageRole messageRoleFromString(String? value) {
  return switch (value) {
    'system' => MessageRole.system,
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    'tool' => MessageRole.tool,
    _ => MessageRole.user,  // Default fallback
  };
}

/// Converts [MessageRole] enum to string.
String messageRoleToString(MessageRole value) {
  return switch (value) {
    MessageRole.system => 'system',
    MessageRole.user => 'user',
    MessageRole.assistant => 'assistant',
    MessageRole.tool => 'tool',
  };
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
import '../models/chat/generate_chat_completion_request.dart';
import '../models/chat/generate_chat_completion_response.dart';
import 'base_resource.dart';

/// Resource for chat completions.
class ChatResource extends ResourceBase {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Creates a chat completion.
  Future<GenerateChatCompletionResponse> create({
    required String model,
    required List<Message> messages,
    List<Tool>? tools,
    bool? think,
    Object? format,
    String? keepAlive,
    RequestOptions? options,
  }) async {
    final request = GenerateChatCompletionRequest(
      model: model,
      messages: messages,
      tools: tools,
      think: think,
      format: format,
      keepAlive: keepAlive,
      options: options,
      stream: false,
    );

    final url = requestBuilder.buildUrl('/api/chat');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    return GenerateChatCompletionResponse.fromJson(
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

### NDJSON Streaming

Ollama uses NDJSON (newline-delimited JSON) for streaming responses:

```dart
/// Creates a streaming chat completion.
Stream<ChatStreamEvent> createStream({required ChatRequest request}) async* {
  final url = requestBuilder.buildUrl('/api/chat');
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

  // Parse NDJSON stream
  await for (final json in parseNDJSON(streamedResponse.stream)) {
    yield ChatStreamEvent.fromJson(json);
  }
}
```

### Auth Handling

The `StreamingResource` mixin handles two credential types for ollama_dart:

- `BearerTokenCredentials` - adds `Authorization: Bearer <token>` header
- `NoAuthCredentials` - no authentication applied

---

## Ollama-Specific Patterns

### Duration Strings

Ollama accepts duration strings like "5m", "1h30m":

```dart
/// Parses Ollama duration string to Duration.
Duration? parseDuration(String? value) {
  if (value == null) return null;

  final regex = RegExp(r'(\d+)(ms|s|m|h)');
  var total = Duration.zero;

  for (final match in regex.allMatches(value)) {
    final amount = int.parse(match.group(1)!);
    final unit = match.group(2)!;
    total += switch (unit) {
      'ms' => Duration(milliseconds: amount),
      's' => Duration(seconds: amount),
      'm' => Duration(minutes: amount),
      'h' => Duration(hours: amount),
      _ => Duration.zero,
    };
  }

  return total;
}

/// Formats Duration to Ollama duration string.
String formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return minutes > 0 ? '${hours}h${minutes}m' : '${hours}h';
  }
  if (duration.inMinutes > 0) {
    return '${duration.inMinutes}m';
  }
  return '${duration.inSeconds}s';
}
```

### Thinking Mode

Support for `think` parameter:

```dart
/// Thinking mode can be:
/// - `true` (default thinking)
/// - `false` (disabled)
/// - `"high"`, `"medium"`, `"low"` (thinking levels)
Object? think;

// In toJson
if (think != null) 'think': think,

// In fromJson
think: json['think'],  // Keep as Object?
```

### Context Memory

For text generation, context tokens can be passed back:

```dart
/// Context tokens from previous generation.
/// Pass this back to continue the conversation.
final List<int>? context;

// Usage
final response = await client.completions.create(
  model: 'llama3.2',
  prompt: 'Tell me more',
  context: previousResponse.context,  // Continue conversation
);
```

### Format Options

Ollama supports JSON mode and JSON schema:

```dart
/// Response format.
/// - `'json'` for JSON mode
/// - JSON Schema object for structured output
Object? format;

// In toJson
if (format != null) {
  if (format is String) {
    toJson['format'] = format;
  } else if (format is Map<String, dynamic>) {
    toJson['format'] = format;
  }
}
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
system: json['system'] as String?,

// In toJson - conditionally include
if (system != null) 'system': system,
```

### Image Handling

Ollama accepts base64-encoded images:

```dart
/// Images as base64 strings.
final List<String>? images;

// In fromJson
images: (json['images'] as List?)?.cast<String>(),

// In toJson
if (images != null) 'images': images,
```

---

## Test Patterns

### Standard Test Groups

```dart
void main() {
  group('Message', () {
    group('fromJson', () {
      test('creates instance with all fields', () {
        final json = {
          'role': 'assistant',
          'content': 'Hello!',
          'thinking': 'Let me think...',
        };
        final message = Message.fromJson(json);
        expect(message.role, MessageRole.assistant);
        expect(message.content, 'Hello!');
        expect(message.thinking, 'Let me think...');
      });

      test('handles null optional values', () {
        final json = {'role': 'user', 'content': 'Hi'};
        final message = Message.fromJson(json);
        expect(message.thinking, isNull);
        expect(message.images, isNull);
      });
    });

    group('toJson', () {
      test('converts all fields to JSON', () {
        final message = Message(
          role: MessageRole.assistant,
          content: 'Hello!',
        );
        final json = message.toJson();
        expect(json['role'], 'assistant');
        expect(json['content'], 'Hello!');
      });

      test('omits null values', () {
        final message = Message(role: MessageRole.user, content: 'Hi');
        final json = message.toJson();
        expect(json.containsKey('thinking'), isFalse);
      });
    });

    test('round-trip preserves data', () {
      final original = Message(
        role: MessageRole.assistant,
        content: 'Test',
        thinking: 'Reasoning',
      );
      final json = original.toJson();
      final restored = Message.fromJson(json);
      expect(restored, equals(original));
    });
  });
}
```

---

## Export Organization

### Main Barrel File

```dart
/// Dart client for the Ollama API.
library;

// Client
export 'src/client/config.dart';
export 'src/client/ollama_client.dart';

// Auth
export 'src/auth/auth_provider.dart';

// Errors
export 'src/errors/exceptions.dart';

// Models - Chat
export 'src/models/chat/message.dart';
export 'src/models/chat/generate_chat_completion_request.dart';
export 'src/models/chat/generate_chat_completion_response.dart';

// Models - Completions
export 'src/models/completions/generate_completion_request.dart';
export 'src/models/completions/generate_completion_response.dart';

// Models - Embeddings
export 'src/models/embeddings/generate_embedding_request.dart';
export 'src/models/embeddings/generate_embedding_response.dart';

// Models - Tools
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_call.dart';

// ... etc
```

---

## Related Documentation

- [Package Guide](./package-guide.md)
- [Review Checklist](./REVIEW_CHECKLIST.md)
