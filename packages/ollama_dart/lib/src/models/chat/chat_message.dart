import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../tools/tool_call.dart';

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
    _ => MessageRole.user,
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

/// A chat message.
@immutable
class ChatMessage {
  /// Author of the message.
  final MessageRole role;

  /// Message text content.
  final String content;

  /// Optional list of inline images for multimodal models.
  ///
  /// Images should be base64-encoded.
  final List<String>? images;

  /// Tool call requests produced by the model.
  final List<ToolCall>? toolCalls;

  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.role,
    required this.content,
    this.images,
    this.toolCalls,
  });

  /// Creates a user message.
  const ChatMessage.user(String content, {List<String>? images})
    : this(role: MessageRole.user, content: content, images: images);

  /// Creates a system message.
  const ChatMessage.system(String content)
    : this(role: MessageRole.system, content: content);

  /// Creates an assistant message.
  const ChatMessage.assistant(String content, {List<ToolCall>? toolCalls})
    : this(role: MessageRole.assistant, content: content, toolCalls: toolCalls);

  /// Creates a tool result message.
  const ChatMessage.tool(String content)
    : this(role: MessageRole.tool, content: content);

  /// Creates a [ChatMessage] from JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: messageRoleFromString(json['role'] as String?),
    content: json['content'] as String? ?? '',
    images: (json['images'] as List?)?.cast<String>(),
    toolCalls: (json['tool_calls'] as List?)
        ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'role': messageRoleToString(role),
    'content': content,
    if (images != null) 'images': images,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ChatMessage copyWith({
    MessageRole? role,
    String? content,
    Object? images = unsetCopyWithValue,
    Object? toolCalls = unsetCopyWithValue,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      images: images == unsetCopyWithValue
          ? this.images
          : images as List<String>?,
      toolCalls: toolCalls == unsetCopyWithValue
          ? this.toolCalls
          : toolCalls as List<ToolCall>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content &&
          _listsEqual(images, other.images) &&
          _listsEqual(toolCalls, other.toolCalls);

  @override
  int get hashCode => Object.hash(role, content, images, toolCalls);

  @override
  String toString() =>
      'ChatMessage('
      'role: $role, '
      'content: $content, '
      'images: $images, '
      'toolCalls: $toolCalls)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
