import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../chat/chat_message.dart';

/// Request for chat-based moderation.
@immutable
class ChatModerationRequest {
  /// The model to use for moderation.
  final String model;

  /// The chat messages to moderate.
  final List<ChatMessage> input;

  /// Creates a [ChatModerationRequest].
  const ChatModerationRequest({
    this.model = 'mistral-moderation-latest',
    required this.input,
  });

  /// Creates a [ChatModerationRequest] from JSON.
  factory ChatModerationRequest.fromJson(Map<String, dynamic> json) =>
      ChatModerationRequest(
        model: json['model'] as String? ?? 'mistral-moderation-latest',
        input:
            (json['input'] as List?)
                ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModerationRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listEquals(input, other.input);

  @override
  int get hashCode => Object.hash(model, Object.hashAll(input));

  @override
  String toString() =>
      'ChatModerationRequest(model: $model, messages: ${input.length})';
}
