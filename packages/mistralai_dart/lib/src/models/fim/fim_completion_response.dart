import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'fim_choice.dart';

/// Response from a FIM completion request.
@immutable
class FimCompletionResponse {
  /// Unique identifier for the completion.
  final String id;

  /// The object type (always "chat.completion").
  final String object;

  /// Unix timestamp of when the completion was created.
  final int created;

  /// The model used for the completion.
  final String model;

  /// List of completion choices.
  final List<FimChoice> choices;

  /// Token usage information.
  final UsageInfo? usage;

  /// Creates a [FimCompletionResponse].
  const FimCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  /// Creates a [FimCompletionResponse] from JSON.
  factory FimCompletionResponse.fromJson(Map<String, dynamic> json) =>
      FimCompletionResponse(
        id: json['id'] as String? ?? '',
        object: json['object'] as String? ?? 'chat.completion',
        created: json['created'] as int? ?? 0,
        model: json['model'] as String? ?? '',
        choices:
            (json['choices'] as List?)
                ?.map((e) => FimChoice.fromJson(e as Map<String, dynamic>))
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
      other is FimCompletionResponse &&
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
      'FimCompletionResponse(id: $id, model: $model, '
      'choices: ${choices.length})';
}
