import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'chat_choice.dart';

/// Response from a chat completion request.
@immutable
class ChatCompletionResponse {
  /// Unique identifier for the completion.
  final String id;

  /// The object type (always "chat.completion").
  final String object;

  /// Unix timestamp of when the completion was created.
  final int created;

  /// The model used for the completion.
  final String model;

  /// List of completion choices.
  final List<ChatChoice> choices;

  /// Token usage information.
  final UsageInfo? usage;

  /// Creates a [ChatCompletionResponse].
  const ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  /// Creates a [ChatCompletionResponse] from JSON.
  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) =>
      ChatCompletionResponse(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletionResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          created == other.created &&
          model == other.model &&
          listEquals(choices, other.choices) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(id, object, created, model, Object.hashAll(choices), usage);

  @override
  String toString() =>
      'ChatCompletionResponse(id: $id, model: $model, '
      'choices: ${choices.length})';
}
