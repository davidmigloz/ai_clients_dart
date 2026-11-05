import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '_system_one_helpers.dart';
import 'system_one_answer.dart';
import 'system_one_usage.dart';

/// Typed answers and token usage returned by the System One API.
@immutable
class SystemOneResponse {
  /// Creates a response and copies its answers.
  SystemOneResponse({
    required this.model,
    required Map<String, SystemOneAnswer> answers,
    required this.usage,
    this.promptEvalCachedCount,
  }) : answers = Map.unmodifiable(answers);

  /// Model name supplied in the request.
  final String model;

  /// Answers keyed by their request question names.
  final Map<String, SystemOneAnswer> answers;

  /// Server-reported token usage across all questions.
  final SystemOneUsage usage;

  /// Prompt tokens reused from cache, when reported by the server.
  final int? promptEvalCachedCount;

  /// Creates a response from JSON, validating required field shapes.
  factory SystemOneResponse.fromJson(Map<String, dynamic> json) {
    final answers = systemOneObject(
      json['answers'],
      'SystemOneResponse.answers',
    );
    return SystemOneResponse(
      model: systemOneString(json['model'], 'SystemOneResponse.model'),
      answers: {
        for (final entry in answers.entries)
          entry.key: SystemOneAnswer.fromJson(
            systemOneObject(
              entry.value,
              'SystemOneResponse.answers.${entry.key}',
            ),
          ),
      },
      usage: SystemOneUsage.fromJson(
        systemOneObject(json['usage'], 'SystemOneResponse.usage'),
      ),
      promptEvalCachedCount: json['prompt_eval_cached_count'] == null
          ? null
          : systemOneInt(
              json['prompt_eval_cached_count'],
              'SystemOneResponse.prompt_eval_cached_count',
            ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'answers': {
      for (final entry in answers.entries) entry.key: entry.value.toJson(),
    },
    'usage': usage.toJson(),
    if (promptEvalCachedCount != null)
      'prompt_eval_cached_count': promptEvalCachedCount,
  };

  /// Creates a copy with replaced values.
  SystemOneResponse copyWith({
    String? model,
    Map<String, SystemOneAnswer>? answers,
    SystemOneUsage? usage,
    Object? promptEvalCachedCount = unsetCopyWithValue,
  }) => SystemOneResponse(
    model: model ?? this.model,
    answers: answers ?? this.answers,
    usage: usage ?? this.usage,
    promptEvalCachedCount: identical(promptEvalCachedCount, unsetCopyWithValue)
        ? this.promptEvalCachedCount
        : promptEvalCachedCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOneResponse &&
          model == other.model &&
          mapsEqual(answers, other.answers) &&
          usage == other.usage &&
          promptEvalCachedCount == other.promptEvalCachedCount;

  @override
  int get hashCode =>
      Object.hash(model, mapHash(answers), usage, promptEvalCachedCount);

  @override
  String toString() =>
      'SystemOneResponse(model: $model, answers: ${answers.length} entries, '
      'usage: $usage, promptEvalCachedCount: $promptEvalCachedCount)';
}
