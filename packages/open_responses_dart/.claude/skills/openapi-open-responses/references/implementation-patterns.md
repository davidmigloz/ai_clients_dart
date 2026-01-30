# Implementation Patterns (open_responses_dart)

Extends [implementation-patterns-core.md](../../../shared/openapi-toolkit/references/implementation-patterns-core.md).

## Contents

- [Directory Structure](#directory-structure)
- [Model Conventions](#model-conventions)
- [Sealed Class Patterns](#sealed-class-patterns)
- [Enum Conventions](#enum-conventions)
- [Streaming Patterns](#streaming-patterns)
- [Extension Methods](#extension-methods)
- [JSON Serialization](#json-serialization)
- [Test Patterns](#test-patterns)

---

## Directory Structure

Models are organized by feature area:

```
lib/src/models/
├── common/           # Utilities (copy_with_sentinel.dart)
├── content/          # InputContent, OutputContent, Annotation, Logprob
├── items/            # Item, OutputItem (sealed classes)
├── metadata/         # Enums (ResponseStatus, MessageRole, etc.)
├── request/          # CreateResponseRequest, ReasoningConfig, TextConfig
├── response/         # ResponseResource, Usage, ErrorPayload
├── streaming/        # StreamingEvent (sealed, 20+ types)
└── tools/            # Tool, ToolChoice
```

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
  const ModelName({this.fieldName});

  /// Creates a [ModelName] from JSON.
  factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
        fieldName: json['field_name'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        if (fieldName != null) 'field_name': fieldName,
      };

  /// Creates a copy with replaced values.
  ModelName copyWith({Object? fieldName = unsetCopyWithValue}) {
    return ModelName(
      fieldName: fieldName == unsetCopyWithValue
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

---

## Sealed Class Patterns

OpenResponses uses sealed classes for polymorphic types.

### Item (Input Items)

```dart
sealed class Item {
  const Item();

  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageItem.fromJson(json),
      'function_call' => FunctionCallItem.fromJson(json),
      'function_call_output' => FunctionCallOutputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  Map<String, dynamic> toJson();
}
```

### Tool

```dart
sealed class Tool {
  const Tool();

  factory Tool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'function' => FunctionTool.fromJson(json),
      'mcp' => McpTool.fromJson(json),
      _ => throw FormatException('Unknown Tool type: $type'),
    };
  }

  Map<String, dynamic> toJson();
}
```

### StreamingEvent (20+ types)

```dart
sealed class StreamingEvent {
  const StreamingEvent();

  factory StreamingEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      // Response lifecycle events
      'response.created' => ResponseCreatedEvent.fromJson(json),
      'response.queued' => ResponseQueuedEvent.fromJson(json),
      'response.in_progress' => ResponseInProgressEvent.fromJson(json),
      'response.completed' => ResponseCompletedEvent.fromJson(json),
      'response.failed' => ResponseFailedEvent.fromJson(json),
      'response.incomplete' => ResponseIncompleteEvent.fromJson(json),

      // Output item events
      'response.output_item.added' => OutputItemAddedEvent.fromJson(json),
      'response.output_item.done' => OutputItemDoneEvent.fromJson(json),

      // Content part events
      'response.content_part.added' => ContentPartAddedEvent.fromJson(json),
      'response.content_part.done' => ContentPartDoneEvent.fromJson(json),

      // Text events
      'response.output_text.delta' => OutputTextDeltaEvent.fromJson(json),
      'response.output_text.done' => OutputTextDoneEvent.fromJson(json),
      'response.output_text.annotation.added' =>
        OutputTextAnnotationAddedEvent.fromJson(json),

      // Refusal events
      'response.refusal.delta' => RefusalDeltaEvent.fromJson(json),
      'response.refusal.done' => RefusalDoneEvent.fromJson(json),

      // Function call events
      'response.function_call_arguments.delta' =>
        FunctionCallArgumentsDeltaEvent.fromJson(json),
      'response.function_call_arguments.done' =>
        FunctionCallArgumentsDoneEvent.fromJson(json),

      // Reasoning events
      'response.reasoning.delta' => ReasoningDeltaEvent.fromJson(json),
      'response.reasoning.done' => ReasoningDoneEvent.fromJson(json),
      'response.reasoning_summary_part.added' =>
        ReasoningSummaryPartAddedEvent.fromJson(json),
      'response.reasoning_summary_part.done' =>
        ReasoningSummaryPartDoneEvent.fromJson(json),
      'response.reasoning_summary.delta' => ReasoningSummaryDeltaEvent.fromJson(json),
      'response.reasoning_summary.done' => ReasoningSummaryDoneEvent.fromJson(json),
      // Ollama-specific reasoning events (maps to standard events)
      'response.reasoning_summary_text.delta' =>
        ReasoningSummaryDeltaEvent.fromJson(json),
      'response.reasoning_summary_text.done' =>
        ReasoningSummaryDoneEvent.fromJson(json),

      // Error event
      'error' => ErrorEvent.fromJson(json),

      _ => throw FormatException('Unknown StreamingEvent type: $type'),
    };
  }

  Map<String, dynamic> toJson();
}
```

### Sealed Class Subtype Pattern

```dart
/// Event indicating a response was created.
@immutable
class ResponseCreatedEvent extends StreamingEvent {
  /// The created response.
  final ResponseResource response;

  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({required this.response});

  /// Creates a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ResponseCreatedEvent(
      response: ResponseResource.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.created',
    'response': response.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response;

  @override
  int get hashCode => response.hashCode;

  @override
  String toString() => 'ResponseCreatedEvent(response: $response)';
}
```

---

## Enum Conventions

```dart
/// Response status values.
enum ResponseStatus {
  inProgress,
  completed,
  failed,
  incomplete,
  queued,
  unknown;

  factory ResponseStatus.fromJson(String? value) {
    return switch (value) {
      'in_progress' => ResponseStatus.inProgress,
      'completed' => ResponseStatus.completed,
      'failed' => ResponseStatus.failed,
      'incomplete' => ResponseStatus.incomplete,
      'queued' => ResponseStatus.queued,
      _ => ResponseStatus.unknown,
    };
  }

  String toJson() => switch (this) {
        ResponseStatus.inProgress => 'in_progress',
        ResponseStatus.completed => 'completed',
        ResponseStatus.failed => 'failed',
        ResponseStatus.incomplete => 'incomplete',
        ResponseStatus.queued => 'queued',
        ResponseStatus.unknown => 'unknown',
      };
}
```

**Always include `unknown` fallback for forward compatibility.**

---

## Streaming Patterns

### SSE Streaming

OpenResponses uses Server-Sent Events for streaming:

```dart
Stream<StreamingEvent> createStream({
  required CreateResponseRequest request,
  Future<void>? abortTrigger,
}) async* {
  // Auth applied manually (bypasses interceptor chain)
  final credentials = await authProvider.getCredentials();
  var httpRequest = http.Request('POST', url)
    ..headers.addAll(headers)
    ..body = jsonEncode(requestData.toJson());

  // Apply auth
  httpRequest = await _applyAuthentication(httpRequest, credentials);

  final streamedResponse = await httpClient.send(httpRequest);

  // Parse SSE stream
  yield* _parseSSEStream(streamedResponse.stream);
}
```

### Streaming Event Types

| Event Type | Description |
|------------|-------------|
| `response.created` | Response object created |
| `response.queued` | Response queued for processing |
| `response.in_progress` | Generation in progress |
| `response.completed` | Generation completed |
| `response.failed` | Generation failed |
| `response.incomplete` | Generation incomplete |
| `response.output_item.added` | New output item |
| `response.output_item.done` | Output item complete |
| `response.content_part.added` | Content part started |
| `response.content_part.done` | Content part complete |
| `response.output_text.delta` | Text content delta |
| `response.output_text.done` | Text content complete |
| `response.output_text.annotation.added` | Annotation added |
| `response.refusal.delta` | Refusal text delta |
| `response.refusal.done` | Refusal text complete |
| `response.function_call_arguments.delta` | Function args delta |
| `response.function_call_arguments.done` | Function args complete |
| `response.reasoning.delta` | Reasoning delta |
| `response.reasoning.done` | Reasoning complete |
| `response.reasoning_summary_part.added` | Summary part started |
| `response.reasoning_summary_part.done` | Summary part complete |
| `response.reasoning_summary.delta` | Summary text delta |
| `response.reasoning_summary.done` | Summary text complete |
| `error` | Error during streaming |

---

## Extension Methods

### ResponseResourceExtensions

```dart
extension ResponseResourceExtensions on ResponseResource {
  /// Gets concatenated text from all message output items.
  String? get outputText { ... }

  /// Gets all function call output items.
  List<FunctionCallOutputItem> get functionCalls { ... }

  /// Gets all reasoning items.
  List<ReasoningItem> get reasoningItems { ... }

  /// Whether response has tool calls.
  bool get hasToolCalls => functionCalls.isNotEmpty;

  /// Whether response completed successfully.
  bool get isCompleted => status == ResponseStatus.completed;

  /// Whether response failed.
  bool get isFailed => status == ResponseStatus.failed;

  /// Whether response is in progress.
  bool get isInProgress => status == ResponseStatus.inProgress;
}
```

### StreamingEventExtensions

```dart
extension StreamingEventExtensions on StreamingEvent {
  /// Gets text delta if this is an OutputTextDeltaEvent.
  String? get textDelta { ... }

  /// Whether this is a final event.
  bool get isFinal { ... }
}

extension StreamingEventsExtensions on Stream<StreamingEvent> {
  /// Accumulates all text deltas into a single string.
  Future<String> get text { ... }

  /// Gets the final response if stream completes successfully.
  Future<ResponseResource?> get finalResponse { ... }

  /// Stream of text deltas only.
  Stream<String> get textDeltas { ... }
}
```

---

## JSON Serialization

### snake_case Keys

API uses snake_case, Dart uses camelCase:

```dart
// fromJson
maxOutputTokens: json['max_output_tokens'] as int?,
previousResponseId: json['previous_response_id'] as String?,

// toJson
if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
if (previousResponseId != null) 'previous_response_id': previousResponseId,
```

### Union Input Type

CreateResponseRequest.input can be string or list:

```dart
/// Input can be a string or a list of items.
final Object input; // String | List<Item>

// fromJson
input: json['input'] is String
    ? json['input'] as String
    : (json['input'] as List).map((e) => Item.fromJson(e)).toList(),

// toJson
'input': input is String
    ? input
    : (input as List<Item>).map((e) => e.toJson()).toList(),
```

### Helper for List Equality

```dart
bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
```

---

## Test Patterns

### Unit Test Structure

```dart
void main() {
  group('ModelName', () {
    group('fromJson', () {
      test('creates instance with all fields', () { ... });
      test('handles null values', () { ... });
    });

    group('toJson', () {
      test('converts all fields to JSON', () { ... });
      test('omits null values', () { ... });
    });

    test('round-trip preserves data', () { ... });

    group('copyWith', () {
      test('creates copy with changed field', () { ... });
      test('can set field to null', () { ... });
    });

    group('equality', () {
      test('equal instances are equal', () { ... });
      test('different instances are not equal', () { ... });
    });
  });
}
```

### Sealed Class Test Pattern

```dart
void main() {
  group('Item', () {
    group('fromJson', () {
      test('creates MessageItem for type message', () {
        final json = {'type': 'message', 'role': 'user', 'content': []};
        final item = Item.fromJson(json);
        expect(item, isA<MessageItem>());
      });

      test('creates FunctionCallItem for type function_call', () {
        final json = {
          'type': 'function_call',
          'call_id': 'call_123',
          'name': 'get_weather',
          'arguments': '{}',
        };
        final item = Item.fromJson(json);
        expect(item, isA<FunctionCallItem>());
      });

      test('throws for unknown type', () {
        final json = {'type': 'unknown'};
        expect(() => Item.fromJson(json), throwsFormatException);
      });
    });
  });
}
```

---

## Additional Resources

- [spec-core.md](../../../../docs/spec-core.md) - Core implementation principles
- [package-guide.md](./package-guide.md) - Package structure reference
