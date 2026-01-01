import 'package:meta/meta.dart';

import '../chat/chat_message.dart';

/// Request for chat-based classification.
@immutable
class ChatClassificationRequest {
  /// The model to use for classification.
  final String model;

  /// The chat messages to classify.
  final List<ChatMessage> input;

  /// Creates a [ChatClassificationRequest].
  const ChatClassificationRequest({
    this.model = 'mistral-moderation-latest',
    required this.input,
  });

  /// Creates a [ChatClassificationRequest] from JSON.
  factory ChatClassificationRequest.fromJson(Map<String, dynamic> json) =>
      ChatClassificationRequest(
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
      other is ChatClassificationRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => Object.hash(model, input);

  @override
  String toString() =>
      'ChatClassificationRequest(model: $model, messages: ${input.length})';
}
