import 'package:meta/meta.dart';

import '../content/input_content_block.dart';
import 'message_role.dart';

/// Content for an input message.
///
/// Can be a simple string or a list of content blocks.
sealed class MessageContent {
  const MessageContent();

  /// Creates a text content.
  factory MessageContent.text(String text) = TextMessageContent;

  /// Creates a blocks content.
  factory MessageContent.blocks(List<InputContentBlock> blocks) =
      BlocksMessageContent;

  /// Creates a [MessageContent] from dynamic JSON value.
  factory MessageContent.fromJson(dynamic json) {
    if (json is String) {
      return TextMessageContent(json);
    }
    if (json is List) {
      return BlocksMessageContent(
        json
            .map((e) => InputContentBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid MessageContent: $json');
  }

  /// Converts to JSON.
  dynamic toJson();
}

/// Text content for a message.
@immutable
class TextMessageContent extends MessageContent {
  /// The text content.
  final String text;

  /// Creates a [TextMessageContent].
  const TextMessageContent(this.text);

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessageContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextMessageContent(text: [${text.length} chars])';
}

/// Block content for a message.
@immutable
class BlocksMessageContent extends MessageContent {
  /// The content blocks.
  final List<InputContentBlock> blocks;

  /// Creates a [BlocksMessageContent].
  const BlocksMessageContent(this.blocks);

  @override
  List<Map<String, dynamic>> toJson() => blocks.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocksMessageContent &&
          runtimeType == other.runtimeType &&
          _listsEqual(blocks, other.blocks);

  @override
  int get hashCode => blocks.hashCode;

  @override
  String toString() => 'BlocksMessageContent(blocks: $blocks)';
}

/// A message in the conversation input.
@immutable
class InputMessage {
  /// Role of the message author.
  final MessageRole role;

  /// Content of the message.
  final MessageContent content;

  /// Creates an [InputMessage].
  const InputMessage({required this.role, required this.content});

  /// Creates a user message with text content.
  factory InputMessage.user(String text) =>
      InputMessage(role: MessageRole.user, content: MessageContent.text(text));

  /// Creates a user message with block content.
  factory InputMessage.userBlocks(List<InputContentBlock> blocks) =>
      InputMessage(
        role: MessageRole.user,
        content: MessageContent.blocks(blocks),
      );

  /// Creates an assistant message with text content.
  factory InputMessage.assistant(String text) => InputMessage(
    role: MessageRole.assistant,
    content: MessageContent.text(text),
  );

  /// Creates an assistant message with block content.
  factory InputMessage.assistantBlocks(List<InputContentBlock> blocks) =>
      InputMessage(
        role: MessageRole.assistant,
        content: MessageContent.blocks(blocks),
      );

  /// Creates an [InputMessage] from JSON.
  factory InputMessage.fromJson(Map<String, dynamic> json) {
    return InputMessage(
      role: MessageRole.fromJson(json['role'] as String),
      content: MessageContent.fromJson(json['content']),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'role': role.toJson(),
    'content': content.toJson(),
  };

  /// Creates a copy with replaced values.
  InputMessage copyWith({MessageRole? role, MessageContent? content}) {
    return InputMessage(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'InputMessage(role: $role, content: $content)';
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
