import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'fim_choice_delta.dart';

/// A streaming response chunk from a FIM completion request.
@immutable
class FimCompletionStreamResponse {
  /// Unique identifier for the completion.
  final String id;

  /// The object type (always "chat.completion.chunk").
  final String object;

  /// Unix timestamp of when the completion was created.
  final int created;

  /// The model used for the completion.
  final String model;

  /// List of completion choice deltas.
  final List<FimChoiceDelta> choices;

  /// Token usage information (only present in final chunk when requested).
  final UsageInfo? usage;

  /// Creates a [FimCompletionStreamResponse].
  const FimCompletionStreamResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  /// Creates a [FimCompletionStreamResponse] from JSON.
  factory FimCompletionStreamResponse.fromJson(Map<String, dynamic> json) =>
      FimCompletionStreamResponse(
        id: json['id'] as String? ?? '',
        object: json['object'] as String? ?? 'chat.completion.chunk',
        created: json['created'] as int? ?? 0,
        model: json['model'] as String? ?? '',
        choices:
            (json['choices'] as List?)
                ?.map((e) => FimChoiceDelta.fromJson(e as Map<String, dynamic>))
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
      other is FimCompletionStreamResponse &&
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
      'FimCompletionStreamResponse(id: $id, model: $model, '
      'choices: ${choices.length})';
}
