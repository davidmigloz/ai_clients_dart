import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to moderate one or more conversations.
@immutable
class ChatModerationRequest {
  /// The model to use for this request.
  final String model;

  /// Messages for a single conversation. Empty on a batched request.
  final List<ChatMessage> input;

  /// Conversations in batch order, or null for a single conversation.
  final List<List<ChatMessage>>? conversations;

  /// Creates a request for one conversation.
  const ChatModerationRequest({
    this.model = 'mistral-moderation-2603',
    required this.input,
  }) : conversations = null;

  /// Creates a request for a batch of conversations.
  const ChatModerationRequest.batch({
    this.model = 'mistral-moderation-2603',
    required List<List<ChatMessage>> this.conversations,
  }) : input = const [];

  /// Creates a [ChatModerationRequest] from JSON.
  factory ChatModerationRequest.fromJson(Map<String, dynamic> json) {
    final model = json['model'] as String? ?? 'mistral-moderation-2603';
    final input = json['input'];
    if (input is! List<Object?>) {
      throw const FormatException('Expected conversation input');
    }
    if (input.isNotEmpty && input.first is List<Object?>) {
      return ChatModerationRequest.batch(
        model: model,
        conversations: input.map(_parseMessages).toList(),
      );
    }
    return ChatModerationRequest(model: model, input: _parseMessages(input));
  }

  static List<ChatMessage> _parseMessages(Object? json) {
    if (json is! List<Object?>) {
      throw const FormatException('Expected a list of chat messages');
    }
    return json.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Expected a chat message object');
      }
      return ChatMessage.fromJson(value);
    }).toList();
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    final List<List<ChatMessage>>? batch = conversations;
    if (batch == null) {
      final conversation = input.map((message) => message.toJson()).toList();
      return {'model': model, 'input': conversation};
    }
    return {
      'model': model,
      'input': batch.map((conversation) {
        final messages = conversation
            .map((message) => message.toJson())
            .toList();
        return messages;
      }).toList(),
    };
  }

  /// Creates a copy with replaced values.
  ///
  /// Passing [input] switches to a single conversation. Passing an explicit
  /// batch replaces [conversations], including an empty batch.
  ChatModerationRequest copyWith({
    String? model,
    List<ChatMessage>? input,
    Object? conversations = unsetCopyWithValue,
  }) {
    if (input != null &&
        conversations != unsetCopyWithValue &&
        conversations != null) {
      throw ArgumentError('Provide either input or conversations');
    }
    if (input != null) {
      return ChatModerationRequest(model: model ?? this.model, input: input);
    }
    final batch = switch (conversations) {
      unsetCopyWithValue => this.conversations,
      null => null,
      final Iterable<Object?> value =>
        value
            .map((item) => List<ChatMessage>.from(item! as Iterable<Object?>))
            .toList(),
      _ => throw ArgumentError('Expected a batch of conversations'),
    };
    return batch == null
        ? ChatModerationRequest(model: model ?? this.model, input: this.input)
        : ChatModerationRequest.batch(
            model: model ?? this.model,
            conversations: batch,
          );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModerationRequest &&
          model == other.model &&
          listsEqual(input, other.input) &&
          valuesDeepEqual(conversations, other.conversations);

  @override
  int get hashCode =>
      Object.hash(model, listHash(input), valueDeepHashCode(conversations));

  @override
  String toString() =>
      'ChatModerationRequest(model: $model, messages: ${input.length}, '
      'conversations: ${conversations?.length})';
}
