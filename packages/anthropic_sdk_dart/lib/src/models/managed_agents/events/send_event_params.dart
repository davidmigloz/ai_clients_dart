import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'session_event.dart';

/// Request parameters for sending events to a session.
@immutable
class SendSessionEventsParams {
  /// Events to send to the session.
  final List<EventParams> events;

  /// Creates a [SendSessionEventsParams].
  const SendSessionEventsParams({required this.events});

  /// Creates a [SendSessionEventsParams] from JSON.
  factory SendSessionEventsParams.fromJson(Map<String, dynamic> json) {
    return SendSessionEventsParams(
      events: (json['events'] as List)
          .map((e) => EventParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'events': events.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  SendSessionEventsParams copyWith({List<EventParams>? events}) {
    return SendSessionEventsParams(events: events ?? this.events);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendSessionEventsParams &&
          runtimeType == other.runtimeType &&
          listsEqual(events, other.events);

  @override
  int get hashCode => listHash(events);

  @override
  String toString() => 'SendSessionEventsParams(events: $events)';
}

/// Union type for event parameters that can be sent to a session.
///
/// Variants:
/// - [UserMessageEventParams] — send a user message.
/// - [UserInterruptEventParams] — send an interrupt.
/// - [UserToolConfirmationEventParams] — confirm or deny a tool execution.
/// - [UserCustomToolResultEventParams] — provide custom tool result.
/// - [UnknownEventParams] — unrecognized event type.
sealed class EventParams {
  const EventParams();

  /// Creates an [EventParams] from JSON.
  factory EventParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'user.message' => UserMessageEventParams.fromJson(json),
      'user.interrupt' => UserInterruptEventParams.fromJson(json),
      'user.tool_confirmation' => UserToolConfirmationEventParams.fromJson(
        json,
      ),
      'user.custom_tool_result' => UserCustomToolResultEventParams.fromJson(
        json,
      ),
      _ => UnknownEventParams(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Parameters for sending a user message.
@immutable
class UserMessageEventParams extends EventParams {
  /// The event type, always 'user.message'.
  String get type => 'user.message';

  /// Array of content blocks for the user message.
  final List<Map<String, dynamic>> content;

  /// Creates a [UserMessageEventParams].
  const UserMessageEventParams({required this.content});

  /// Creates a [UserMessageEventParams] from JSON.
  factory UserMessageEventParams.fromJson(Map<String, dynamic> json) {
    return UserMessageEventParams(
      content: (json['content'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'content': content};

  /// Creates a copy with replaced values.
  UserMessageEventParams copyWith({List<Map<String, dynamic>>? content}) {
    return UserMessageEventParams(content: content ?? this.content);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessageEventParams &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(content, other.content);

  @override
  int get hashCode => listOfMapsHashCode(content);

  @override
  String toString() => 'UserMessageEventParams(content: $content)';
}

/// Parameters for sending an interrupt.
@immutable
class UserInterruptEventParams extends EventParams {
  /// The event type, always 'user.interrupt'.
  String get type => 'user.interrupt';

  /// Creates a [UserInterruptEventParams].
  const UserInterruptEventParams();

  /// Creates a [UserInterruptEventParams] from JSON.
  factory UserInterruptEventParams.fromJson(Map<String, dynamic> _) {
    return const UserInterruptEventParams();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInterruptEventParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UserInterruptEventParams()';
}

/// Parameters for confirming or denying a tool execution request.
@immutable
class UserToolConfirmationEventParams extends EventParams {
  /// The event type, always 'user.tool_confirmation'.
  String get type => 'user.tool_confirmation';

  /// The id of the tool_use or mcp_tool_use event this corresponds to.
  final String toolUseId;

  /// The confirmation result: 'allow' or 'deny'.
  final UserToolConfirmationResult result;

  /// Optional message providing context for a 'deny' decision.
  final String? denyMessage;

  /// Creates a [UserToolConfirmationEventParams].
  const UserToolConfirmationEventParams({
    required this.toolUseId,
    required this.result,
    this.denyMessage,
  });

  /// Creates a [UserToolConfirmationEventParams] from JSON.
  factory UserToolConfirmationEventParams.fromJson(Map<String, dynamic> json) {
    return UserToolConfirmationEventParams(
      toolUseId: json['tool_use_id'] as String,
      result: UserToolConfirmationResult.fromJson(json['result'] as String),
      denyMessage: json['deny_message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'tool_use_id': toolUseId,
    'result': result.toJson(),
    if (denyMessage != null) 'deny_message': denyMessage,
  };

  /// Creates a copy with replaced values.
  UserToolConfirmationEventParams copyWith({
    String? toolUseId,
    UserToolConfirmationResult? result,
    Object? denyMessage = unsetCopyWithValue,
  }) {
    return UserToolConfirmationEventParams(
      toolUseId: toolUseId ?? this.toolUseId,
      result: result ?? this.result,
      denyMessage: denyMessage == unsetCopyWithValue
          ? this.denyMessage
          : denyMessage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserToolConfirmationEventParams &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          result == other.result &&
          denyMessage == other.denyMessage;

  @override
  int get hashCode => Object.hash(toolUseId, result, denyMessage);

  @override
  String toString() =>
      'UserToolConfirmationEventParams(toolUseId: $toolUseId, '
      'result: $result, denyMessage: $denyMessage)';
}

/// Parameters for providing a custom tool execution result.
@immutable
class UserCustomToolResultEventParams extends EventParams {
  /// The event type, always 'user.custom_tool_result'.
  String get type => 'user.custom_tool_result';

  /// The id of the agent.custom_tool_use event this result corresponds to.
  final String customToolUseId;

  /// The result content returned by the tool.
  final List<Map<String, dynamic>>? content;

  /// Whether the tool execution resulted in an error.
  final bool? isError;

  /// Creates a [UserCustomToolResultEventParams].
  const UserCustomToolResultEventParams({
    required this.customToolUseId,
    this.content,
    this.isError,
  });

  /// Creates a [UserCustomToolResultEventParams] from JSON.
  factory UserCustomToolResultEventParams.fromJson(Map<String, dynamic> json) {
    return UserCustomToolResultEventParams(
      customToolUseId: json['custom_tool_use_id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isError: json['is_error'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'custom_tool_use_id': customToolUseId,
    if (content != null) 'content': content,
    if (isError != null) 'is_error': isError,
  };

  /// Creates a copy with replaced values.
  UserCustomToolResultEventParams copyWith({
    String? customToolUseId,
    Object? content = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
  }) {
    return UserCustomToolResultEventParams(
      customToolUseId: customToolUseId ?? this.customToolUseId,
      content: content == unsetCopyWithValue
          ? this.content
          : content as List<Map<String, dynamic>>?,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCustomToolResultEventParams &&
          runtimeType == other.runtimeType &&
          customToolUseId == other.customToolUseId &&
          listOfMapsDeepEqual(content, other.content) &&
          isError == other.isError;

  @override
  int get hashCode =>
      Object.hash(customToolUseId, listOfMapsHashCode(content), isError);

  @override
  String toString() =>
      'UserCustomToolResultEventParams(customToolUseId: $customToolUseId, '
      'content: $content, isError: $isError)';
}

/// Unrecognized event params — preserves raw JSON.
@immutable
class UnknownEventParams extends EventParams {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownEventParams].
  const UnknownEventParams({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownEventParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownEventParams(rawJson: $rawJson)';
}
