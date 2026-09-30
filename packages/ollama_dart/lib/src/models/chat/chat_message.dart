import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
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
///
/// Returns [MessageRole.user] for unknown or null values.
MessageRole messageRoleFromString(String? value) {
  return switch (value) {
    'system' => MessageRole.system,
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    'tool' => MessageRole.tool,
    _ => MessageRole.user,
  };
}

/// Converts string to [MessageRole] enum.
///
/// Returns `null` for unknown or null values.
MessageRole? messageRoleFromNullableString(String? value) {
  return switch (value) {
    'system' => MessageRole.system,
    'user' => MessageRole.user,
    'assistant' => MessageRole.assistant,
    'tool' => MessageRole.tool,
    _ => null,
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

  /// Deliberate thinking trace to replay for an assistant message.
  final String? thinking;

  /// Optional list of inline images for multimodal models.
  ///
  /// Images should be base64-encoded.
  final List<String>? images;

  /// Tool call requests produced by the model.
  final List<ToolCall>? toolCalls;

  /// Name of the tool whose result this message contains.
  final String? toolName;

  /// Identifier of the tool call associated with this result message.
  final String? toolCallId;

  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.role,
    required this.content,
    this.thinking,
    this.images,
    this.toolCalls,
    this.toolName,
    this.toolCallId,
  });

  /// Creates a user message.
  const ChatMessage.user(String content, {List<String>? images})
    : this(role: MessageRole.user, content: content, images: images);

  /// Creates a system message.
  const ChatMessage.system(String content)
    : this(role: MessageRole.system, content: content);

  /// Creates an assistant message.
  const ChatMessage.assistant(
    String content, {
    String? thinking,
    List<ToolCall>? toolCalls,
  }) : this(
         role: MessageRole.assistant,
         content: content,
         thinking: thinking,
         toolCalls: toolCalls,
       );

  /// Creates a tool result message.
  const ChatMessage.tool(String content, {String? toolName, String? toolCallId})
    : this(
        role: MessageRole.tool,
        content: content,
        toolName: toolName,
        toolCallId: toolCallId,
      );

  /// Creates a [ChatMessage] from JSON.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    toolName: json['tool_name'] as String?,
    toolCallId: json['tool_call_id'] as String?,
    role: messageRoleFromString(json['role'] as String?),
    content: json['content'] as String? ?? '',
    thinking: json['thinking'] as String?,
    images: (json['images'] as List?)?.cast<String>(),
    toolCalls: (json['tool_calls'] as List?)
        ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (toolName != null) 'tool_name': toolName,
    if (toolCallId != null) 'tool_call_id': toolCallId,
    'role': messageRoleToString(role),
    'content': content,
    if (thinking != null) 'thinking': thinking,
    if (images != null) 'images': images,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ChatMessage copyWith({
    Object? toolName = unsetCopyWithValue,
    Object? toolCallId = unsetCopyWithValue,
    MessageRole? role,
    String? content,
    Object? thinking = unsetCopyWithValue,
    Object? images = unsetCopyWithValue,
    Object? toolCalls = unsetCopyWithValue,
  }) {
    return ChatMessage(
      toolName: identical(toolName, unsetCopyWithValue)
          ? this.toolName
          : toolName as String?,
      toolCallId: identical(toolCallId, unsetCopyWithValue)
          ? this.toolCallId
          : toolCallId as String?,
      role: role ?? this.role,
      content: content ?? this.content,
      thinking: thinking == unsetCopyWithValue
          ? this.thinking
          : thinking as String?,
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
          thinking == other.thinking &&
          listsEqual(images, other.images) &&
          listsEqual(toolCalls, other.toolCalls) &&
          toolName == other.toolName &&
          toolCallId == other.toolCallId;

  @override
  int get hashCode => Object.hashAll([
    role,
    content,
    thinking,
    listHash(images),
    listHash(toolCalls),
    toolName,
    toolCallId,
  ]);

  @override
  String toString() =>
      'ChatMessage('
      'role: $role, '
      'content: $content, '
      'thinking: $thinking, '
      'images: $images, '
      'toolCalls: $toolCalls, '
      'toolName: $toolName, '
      'toolCallId: $toolCallId)';
}
