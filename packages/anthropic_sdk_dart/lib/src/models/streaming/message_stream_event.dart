import 'package:meta/meta.dart';

import '../../errors/exceptions.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../content/content_block.dart';
import '../messages/context_management.dart';
import '../messages/input_transformation.dart';
import '../messages/message.dart';
import 'content_block_delta.dart';
import 'message_delta.dart';

/// Server-sent event for message streaming.
sealed class MessageStreamEvent {
  const MessageStreamEvent();

  /// Creates a [MessageStreamEvent] from JSON.
  factory MessageStreamEvent.fromJson(
    Map<String, dynamic> json, {
    ResponseMetadata? responseMetadata,
  }) {
    final type = json['type'];
    if (json['_event'] == 'error' || type == 'error') {
      return ErrorEvent.fromJson(json, responseMetadata: responseMetadata);
    }
    if (type is! String || type.isEmpty) {
      throw const FormatException('Missing message stream event type');
    }
    return switch (type) {
      'message_start' => MessageStartEvent.fromJson(json),
      'message_delta' => MessageDeltaEvent.fromJson(json),
      'message_stop' => MessageStopEvent.fromJson(json),
      'content_block_start' => ContentBlockStartEvent.fromJson(json),
      'content_block_delta' => ContentBlockDeltaEvent.fromJson(json),
      'content_block_stop' => ContentBlockStopEvent.fromJson(json),
      'ping' => PingEvent.fromJson(json),
      _ => UnknownMessageStreamEvent.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Event indicating the start of message generation.
@immutable
class MessageStartEvent extends MessageStreamEvent {
  /// The event type, always 'message_start'.
  String get type => 'message_start';

  /// The initial message object.
  final Message message;

  /// Creates a [MessageStartEvent].
  const MessageStartEvent({required this.message});

  /// Creates a [MessageStartEvent] from JSON.
  factory MessageStartEvent.fromJson(Map<String, dynamic> json) {
    return MessageStartEvent(
      message: Message.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'message': message.toJson()};

  /// Creates a copy with replaced values.
  MessageStartEvent copyWith({Message? message}) {
    return MessageStartEvent(message: message ?? this.message);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStartEvent &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'MessageStartEvent(message: $message)';
}

/// Event indicating an update to the message.
@immutable
class MessageDeltaEvent extends MessageStreamEvent {
  /// The event type, always 'message_delta'.
  String get type => 'message_delta';

  /// The delta update.
  final MessageDelta delta;

  /// Updated usage information.
  final MessageDeltaUsage usage;

  /// Changes the API made to the request's input before showing it to the
  /// model.
  ///
  /// The array is final in `message_start`; this field carries it again
  /// only when a server-side model fallback happened mid-stream, in which
  /// case it holds the serving model's entries and replaces the one from
  /// `message_start`. Present only with
  /// `anthropic-beta: thinking-binding-controls-2026-08-01`.
  final List<InputTransformation>? inputTransformations;

  /// Context edits applied to this request (beta).
  final ContextManagementResult? contextManagement;

  /// Whether the response carries the context-management field, even if null.
  final bool hasContextManagement;

  /// Creates a [MessageDeltaEvent].
  const MessageDeltaEvent({
    required this.delta,
    required this.usage,
    this.inputTransformations,
    this.contextManagement,
    bool hasContextManagement = false,
  }) : hasContextManagement = hasContextManagement || contextManagement != null;

  /// Creates a [MessageDeltaEvent] from JSON.
  factory MessageDeltaEvent.fromJson(Map<String, dynamic> json) {
    return MessageDeltaEvent(
      delta: MessageDelta.fromJson(json['delta'] as Map<String, dynamic>),
      usage: MessageDeltaUsage.fromJson(json['usage'] as Map<String, dynamic>),
      hasContextManagement: json.containsKey('context_management'),
      contextManagement: json['context_management'] != null
          ? ContextManagementResult.fromJson(
              json['context_management'] as Map<String, dynamic>,
            )
          : null,
      inputTransformations: (json['input_transformations'] as List?)
          ?.map((e) => InputTransformation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta.toJson(),
    'usage': usage.toJson(),
    if (hasContextManagement) 'context_management': contextManagement?.toJson(),
    if (inputTransformations != null)
      'input_transformations': inputTransformations!
          .map((e) => e.toJson())
          .toList(),
  };

  /// Creates a copy with replaced values.
  MessageDeltaEvent copyWith({
    MessageDelta? delta,
    MessageDeltaUsage? usage,
    Object? inputTransformations = unsetCopyWithValue,
    Object? contextManagement = unsetCopyWithValue,
  }) {
    return MessageDeltaEvent(
      delta: delta ?? this.delta,
      usage: usage ?? this.usage,
      inputTransformations: inputTransformations == unsetCopyWithValue
          ? this.inputTransformations
          : copyWithList<InputTransformation>(inputTransformations),
      hasContextManagement: hasContextManagement,
      contextManagement: contextManagement == unsetCopyWithValue
          ? this.contextManagement
          : contextManagement as ContextManagementResult?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          usage == other.usage &&
          listsEqual(inputTransformations, other.inputTransformations) &&
          hasContextManagement == other.hasContextManagement &&
          contextManagement == other.contextManagement;

  @override
  int get hashCode => Object.hash(
    delta,
    usage,
    listHash(inputTransformations),
    contextManagement,
    hasContextManagement,
  );

  @override
  String toString() =>
      'MessageDeltaEvent(delta: $delta, usage: $usage, '
      'inputTransformations: $inputTransformations, '
      'contextManagement: $contextManagement)';
}

/// Event indicating the end of message generation.
@immutable
class MessageStopEvent extends MessageStreamEvent {
  /// The event type, always 'message_stop'.
  String get type => 'message_stop';

  /// Creates a [MessageStopEvent].
  const MessageStopEvent();

  /// Creates a [MessageStopEvent] from JSON.
  factory MessageStopEvent.fromJson(Map<String, dynamic> _) {
    return const MessageStopEvent();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  MessageStopEvent copyWith() {
    return const MessageStopEvent();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStopEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'MessageStopEvent()';
}

/// Event indicating the start of a content block.
@immutable
class ContentBlockStartEvent extends MessageStreamEvent {
  /// The event type, always 'content_block_start'.
  String get type => 'content_block_start';

  /// The index of the content block.
  final int index;

  /// The initial content block.
  final ContentBlock contentBlock;

  /// Creates a [ContentBlockStartEvent].
  const ContentBlockStartEvent({
    required this.index,
    required this.contentBlock,
  });

  /// Creates a [ContentBlockStartEvent] from JSON.
  factory ContentBlockStartEvent.fromJson(Map<String, dynamic> json) {
    return ContentBlockStartEvent(
      index: json['index'] as int,
      contentBlock: ContentBlock.fromJson(
        json['content_block'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'index': index,
    'content_block': contentBlock.toJson(),
  };

  /// Creates a copy with replaced values.
  ContentBlockStartEvent copyWith({int? index, ContentBlock? contentBlock}) {
    return ContentBlockStartEvent(
      index: index ?? this.index,
      contentBlock: contentBlock ?? this.contentBlock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlockStartEvent &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          contentBlock == other.contentBlock;

  @override
  int get hashCode => Object.hash(index, contentBlock);

  @override
  String toString() =>
      'ContentBlockStartEvent(index: $index, contentBlock: $contentBlock)';
}

/// Event indicating an update to a content block.
@immutable
class ContentBlockDeltaEvent extends MessageStreamEvent {
  /// The event type, always 'content_block_delta'.
  String get type => 'content_block_delta';

  /// The index of the content block being updated.
  final int index;

  /// The delta update.
  final ContentBlockDelta delta;

  /// Creates a [ContentBlockDeltaEvent].
  const ContentBlockDeltaEvent({required this.index, required this.delta});

  /// Creates a [ContentBlockDeltaEvent] from JSON.
  factory ContentBlockDeltaEvent.fromJson(Map<String, dynamic> json) {
    return ContentBlockDeltaEvent(
      index: json['index'] as int,
      delta: ContentBlockDelta.fromJson(json['delta'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'index': index,
    'delta': delta.toJson(),
  };

  /// Creates a copy with replaced values.
  ContentBlockDeltaEvent copyWith({int? index, ContentBlockDelta? delta}) {
    return ContentBlockDeltaEvent(
      index: index ?? this.index,
      delta: delta ?? this.delta,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlockDeltaEvent &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(index, delta);

  @override
  String toString() => 'ContentBlockDeltaEvent(index: $index, delta: $delta)';
}

/// Event indicating the end of a content block.
@immutable
class ContentBlockStopEvent extends MessageStreamEvent {
  /// The event type, always 'content_block_stop'.
  String get type => 'content_block_stop';

  /// The index of the content block that finished.
  final int index;

  /// Creates a [ContentBlockStopEvent].
  const ContentBlockStopEvent({required this.index});

  /// Creates a [ContentBlockStopEvent] from JSON.
  factory ContentBlockStopEvent.fromJson(Map<String, dynamic> json) {
    return ContentBlockStopEvent(index: json['index'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'index': index};

  /// Creates a copy with replaced values.
  ContentBlockStopEvent copyWith({int? index}) {
    return ContentBlockStopEvent(index: index ?? this.index);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlockStopEvent &&
          runtimeType == other.runtimeType &&
          index == other.index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'ContentBlockStopEvent(index: $index)';
}

/// Ping event to keep connection alive.
@immutable
class PingEvent extends MessageStreamEvent {
  /// Creates a [PingEvent].
  const PingEvent();

  /// Creates a [PingEvent] from JSON.
  factory PingEvent.fromJson(Map<String, dynamic> _) {
    return const PingEvent();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'ping'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PingEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'PingEvent()';
}

/// Error event during streaming.
@immutable
class ErrorEvent extends MessageStreamEvent {
  /// The error type.
  final String errorType;

  /// The error message.
  final String message;

  /// Safe metadata from the successful HTTP handshake.
  final ResponseMetadata? responseMetadata;

  final Map<String, dynamic>? _raw;

  /// Creates an [ErrorEvent].
  const ErrorEvent({
    required this.errorType,
    required this.message,
    this.responseMetadata,
  }) : _raw = null;

  const ErrorEvent._(
    this.errorType,
    this.message,
    this.responseMetadata,
    this._raw,
  );

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(
    Map<String, dynamic> json, {
    ResponseMetadata? responseMetadata,
  }) {
    final error = json['error'];
    if (json case {
      '_event': 'error',
      '_rawData': final String text,
    } when json.length == 3 && json['type'] == 'error') {
      return ErrorEvent(
        errorType: 'stream_error',
        message: text.isEmpty ? 'Unknown stream error' : text,
        responseMetadata: responseMetadata,
      );
    }
    final errorType = switch (error) {
      {'type': final String type} => type,
      Map() => 'unknown',
      _ => 'stream_error',
    };
    final message = switch (error) {
      {'message': final String text} => text,
      final String text => text,
      _ => switch (json) {
        {'message': final String text} => text,
        _ => 'Unknown stream error',
      },
    };
    final metadata = responseMetadata;
    final bodyRequestId = _bodyRequestId(json);
    return ErrorEvent._(
      errorType,
      message,
      metadata == null || bodyRequestId == null
          ? metadata
          : ResponseMetadata(
              statusCode: metadata.statusCode,
              headers: metadata.headers,
              bodyExcerpt: metadata.bodyExcerpt,
              latency: metadata.latency,
              bodyRequestId: bodyRequestId,
            ),
      deepUnmodifiableMap(Map.of(json)..remove('_event')),
    );
  }

  static String? _bodyRequestId(Map<String, dynamic>? json) => switch (json) {
    {'request_id': final String id} when id.trim().isNotEmpty => id,
    _ => null,
  };

  /// The real provider ID. The HTTP handshake header takes precedence.
  String? get requestId => responseMetadata?.requestId ?? _bodyRequestId(_raw);

  /// Details supplied by the provider, when available.
  Map<String, dynamic>? get details => switch (_raw) {
    {'error': {'details': final Map<String, dynamic> details}} => details,
    _ => null,
  };

  /// Provider error code from the structured details, when available.
  String? get errorCode => switch (details) {
    {'error_code': final String code} => code,
    _ => null,
  };

  @override
  Map<String, dynamic> toJson() =>
      _raw ??
      {
        'type': 'error',
        'error': {'type': errorType, 'message': message},
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          errorType == other.errorType &&
          message == other.message &&
          requestId == other.requestId &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode =>
      Object.hash(errorType, message, requestId, mapDeepHashCode(toJson()));

  @override
  String toString() => 'ErrorEvent(errorType: $errorType, message: $message)';
}

/// Failure raised by stream convenience helpers for an in-band SSE error.
final class MessageStreamFailure extends StateError {
  /// Creates a failure retaining the original provider error event.
  MessageStreamFailure(this.event)
    : super('Message stream failed: ${event.errorType}');

  /// The provider's terminal event, including its error details.
  final ErrorEvent event;

  /// Provider request ID, when available.
  String? get requestId => event.requestId;
}

/// An event type introduced by the server that this version does not model.
@immutable
final class UnknownMessageStreamEvent extends MessageStreamEvent {
  /// The event's original JSON without SSE parser metadata.
  final Map<String, dynamic> raw;

  /// Creates an unknown event from its JSON.
  UnknownMessageStreamEvent.fromJson(Map<String, dynamic> json)
    : raw = deepUnmodifiableMap(Map.of(json)..remove('_event'));

  /// The original wire discriminator.
  String get type => raw['type'] as String;

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      other is UnknownMessageStreamEvent && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);

  @override
  String toString() => 'UnknownMessageStreamEvent(type: $type)';
}
