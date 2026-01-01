import 'package:meta/meta.dart';

import '../chat/chat_choice.dart';
import '../metadata/usage_info.dart';

/// Response from agent completion.
///
/// Uses the same structure as ChatCompletionResponse.
@immutable
class AgentCompletionResponse {
  /// Unique identifier for this response.
  final String id;

  /// Object type.
  final String object;

  /// Timestamp of when the response was created.
  final int created;

  /// The model used for completion.
  final String model;

  /// The completion choices.
  final List<ChatChoice> choices;

  /// Token usage statistics.
  final UsageInfo? usage;

  /// Creates an [AgentCompletionResponse].
  const AgentCompletionResponse({
    required this.id,
    this.object = 'chat.completion',
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  /// Creates an [AgentCompletionResponse] from JSON.
  factory AgentCompletionResponse.fromJson(Map<String, dynamic> json) =>
      AgentCompletionResponse(
        id: json['id'] as String? ?? '',
        object: json['object'] as String? ?? 'chat.completion',
        created: json['created'] as int? ?? 0,
        model: json['model'] as String? ?? '',
        choices:
            (json['choices'] as List?)
                ?.map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        usage: json['usage'] != null
            ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created': created,
    'model': model,
    'choices': choices.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// The first choice, if any.
  ChatChoice? get firstChoice => choices.isNotEmpty ? choices.first : null;

  /// The text content from the first choice.
  String? get text => firstChoice?.message.content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentCompletionResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AgentCompletionResponse(id: $id, model: $model, choices: ${choices.length})';
}
