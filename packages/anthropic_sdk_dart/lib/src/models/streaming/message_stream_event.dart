import 'package:meta/meta.dart';

import '../content/content_block.dart';
import '../messages/message.dart';
import 'content_block_delta.dart';
import 'message_delta.dart';

/// Server-sent event for message streaming.
sealed class MessageStreamEvent {
  const MessageStreamEvent();

  /// Creates a [MessageStreamEvent] from JSON.
  factory MessageStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message_start' => MessageStartEvent.fromJson(json),
      'message_delta' => MessageDeltaEvent.fromJson(json),
      'message_stop' => MessageStopEvent.fromJson(json),
      'content_block_start' => ContentBlockStartEvent.fromJson(json),
      'content_block_delta' => ContentBlockDeltaEvent.fromJson(json),
      'content_block_stop' => ContentBlockStopEvent.fromJson(json),
      'ping' => PingEvent.fromJson(json),
      'error' => ErrorEvent.fromJson(json),
      _ => throw FormatException('Unknown MessageStreamEvent type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Event indicating the start of message generation.
@immutable
class MessageStartEvent extends MessageStreamEvent {
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
  Map<String, dynamic> toJson() => {
    'type': 'message_start',
    'message': message.toJson(),
  };

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
  /// The delta update.
  final MessageDelta delta;

  /// Updated usage information.
  final MessageDeltaUsage usage;

  /// Creates a [MessageDeltaEvent].
  const MessageDeltaEvent({required this.delta, required this.usage});

  /// Creates a [MessageDeltaEvent] from JSON.
  factory MessageDeltaEvent.fromJson(Map<String, dynamic> json) {
    return MessageDeltaEvent(
      delta: MessageDelta.fromJson(json['delta'] as Map<String, dynamic>),
      usage: MessageDeltaUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message_delta',
    'delta': delta.toJson(),
    'usage': usage.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(delta, usage);

  @override
  String toString() => 'MessageDeltaEvent(delta: $delta, usage: $usage)';
}

/// Event indicating the end of message generation.
@immutable
class MessageStopEvent extends MessageStreamEvent {
  /// Creates a [MessageStopEvent].
  const MessageStopEvent();

  /// Creates a [MessageStopEvent] from JSON.
  factory MessageStopEvent.fromJson(Map<String, dynamic> _) {
    return const MessageStopEvent();
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'message_stop'};

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
    'type': 'content_block_start',
    'index': index,
    'content_block': contentBlock.toJson(),
  };

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
    'type': 'content_block_delta',
    'index': index,
    'delta': delta.toJson(),
  };

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
  /// The index of the content block that finished.
  final int index;

  /// Creates a [ContentBlockStopEvent].
  const ContentBlockStopEvent({required this.index});

  /// Creates a [ContentBlockStopEvent] from JSON.
  factory ContentBlockStopEvent.fromJson(Map<String, dynamic> json) {
    return ContentBlockStopEvent(index: json['index'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'content_block_stop',
    'index': index,
  };

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

  /// Creates an [ErrorEvent].
  const ErrorEvent({required this.errorType, required this.message});

  /// Creates an [ErrorEvent] from JSON.
  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>;
    return ErrorEvent(
      errorType: error['type'] as String,
      message: error['message'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'error',
    'error': {'type': errorType, 'message': message},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          runtimeType == other.runtimeType &&
          errorType == other.errorType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(errorType, message);

  @override
  String toString() => 'ErrorEvent(errorType: $errorType, message: $message)';
}
