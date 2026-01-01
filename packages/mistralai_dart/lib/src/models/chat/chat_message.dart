import 'package:meta/meta.dart';

import '../content/content_part.dart';
import '../tools/tool_call.dart';

/// Sealed class for chat messages.
///
/// Messages represent the conversation history between the user, system,
/// assistant, and tools.
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

  /// Creates a system message.
  factory ChatMessage.system(String content) => SystemMessage(content: content);

  /// Creates a user message with text content.
  factory ChatMessage.user(String content) => UserMessage.text(content);

  /// Creates a user message with multimodal content.
  factory ChatMessage.userMultimodal(List<ContentPart> content) =>
      UserMessage.multimodal(content);

  /// Creates an assistant message.
  factory ChatMessage.assistant(
    String? content, {
    List<ToolCall>? toolCalls,
    bool? prefix,
  }) =>
      AssistantMessage(content: content, toolCalls: toolCalls, prefix: prefix);

  /// Creates a tool result message.
  factory ChatMessage.tool({
    required String toolCallId,
    required String content,
    String? name,
  }) => ToolMessage(toolCallId: toolCallId, content: content, name: name);
}

/// System message for setting the behavior of the assistant.
@immutable
class SystemMessage extends ChatMessage {
  @override
  String get role => 'system';

  /// The content of the system message.
  final String content;

  /// Creates a [SystemMessage].
  const SystemMessage({required this.content});

  /// Creates a [SystemMessage] from JSON.
  factory SystemMessage.fromJson(Map<String, dynamic> json) =>
      SystemMessage(content: json['content'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessage &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'SystemMessage(content: $content)';
}

/// User message containing the user's input.
///
/// Supports both text-only and multimodal (text + images) content.
@immutable
class UserMessage extends ChatMessage {
  @override
  String get role => 'user';

  /// The content of the user message.
  ///
  /// Can be either a [String] for text-only content, or a
  /// [List<ContentPart>] for multimodal content.
  final Object content;

  /// Creates a [UserMessage].
  const UserMessage({required this.content});

  /// Creates a text-only user message.
  factory UserMessage.text(String text) => UserMessage(content: text);

  /// Creates a multimodal user message with content parts.
  factory UserMessage.multimodal(List<ContentPart> parts) =>
      UserMessage(content: parts);

  /// Creates a [UserMessage] from JSON.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessage &&
          runtimeType == other.runtimeType &&
          _contentEquals(content, other.content);

  bool _contentEquals(Object a, Object b) {
    if (a is String && b is String) return a == b;
    if (a is List<ContentPart> && b is List<ContentPart>) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'UserMessage(content: $content)';
}

/// Assistant message from the model.
///
/// Can contain text content and/or tool calls.
@immutable
class AssistantMessage extends ChatMessage {
  @override
  String get role => 'assistant';

  /// The text content of the assistant's response.
  final String? content;

  /// Tool calls made by the assistant.
  final List<ToolCall>? toolCalls;

  /// Whether this message is a prefix for the model to continue.
  ///
  /// Used for fill-in-the-middle (FIM) style generation.
  final bool? prefix;

  /// Creates an [AssistantMessage].
  const AssistantMessage({this.content, this.toolCalls, this.prefix});

  /// Creates an [AssistantMessage] from JSON.
  factory AssistantMessage.fromJson(Map<String, dynamic> json) =>
      AssistantMessage(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessage &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          prefix == other.prefix &&
          _toolCallsEqual(toolCalls, other.toolCalls);

  bool _toolCallsEqual(List<ToolCall>? a, List<ToolCall>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(role, content, toolCalls, prefix);

  @override
  String toString() =>
      'AssistantMessage(content: $content, toolCalls: $toolCalls, '
      'prefix: $prefix)';
}

/// Tool result message containing the output of a tool call.
@immutable
class ToolMessage extends ChatMessage {
  @override
  String get role => 'tool';

  /// The ID of the tool call this message is responding to.
  final String toolCallId;

  /// The name of the tool (optional).
  final String? name;

  /// The content/result of the tool call.
  final String content;

  /// Creates a [ToolMessage].
  const ToolMessage({
    required this.toolCallId,
    required this.content,
    this.name,
  });

  /// Creates a [ToolMessage] from JSON.
  factory ToolMessage.fromJson(Map<String, dynamic> json) => ToolMessage(
    toolCallId: json['tool_call_id'] as String? ?? '',
    name: json['name'] as String?,
    content: json['content'] as String? ?? '',
  );

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'tool_call_id': toolCallId,
    if (name != null) 'name': name,
    'content': content,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolMessage &&
          runtimeType == other.runtimeType &&
          toolCallId == other.toolCallId &&
          name == other.name &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, toolCallId, name, content);

  @override
  String toString() =>
      'ToolMessage(toolCallId: $toolCallId, name: $name, content: $content)';
}
