import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';

/// Evaluation state for a single outcome defined via a `user.define_outcome`
/// event.
@immutable
class OutcomeEvaluation {
  /// Object type. Always 'outcome_evaluation'.
  final String type;

  /// Server-generated `outc_` ID for this outcome.
  final String outcomeId;

  /// What the agent should produce.
  final String description;

  /// Current evaluation state. `pending` before the agent begins work;
  /// `running` while producing or revising; `evaluating` while the grader
  /// scores; `satisfied`/`max_iterations_reached`/`failed`/`interrupted` are
  /// terminal.
  final String result;

  /// 0-indexed revision cycle the outcome is currently on.
  final int iteration;

  /// When the outcome reached a terminal result. Null while
  /// pending/running/evaluating.
  final BetaTimestamp? completedAt;

  /// Grader's verdict text from the most recent evaluation.
  final String? explanation;

  /// Creates an [OutcomeEvaluation].
  const OutcomeEvaluation({
    this.type = 'outcome_evaluation',
    required this.outcomeId,
    required this.description,
    required this.result,
    required this.iteration,
    required this.completedAt,
    required this.explanation,
  });

  /// Creates an [OutcomeEvaluation] from JSON.
  factory OutcomeEvaluation.fromJson(Map<String, dynamic> json) {
    return OutcomeEvaluation(
      type: json['type'] as String? ?? 'outcome_evaluation',
      outcomeId: json['outcome_id'] as String,
      description: json['description'] as String,
      result: json['result'] as String,
      iteration: json['iteration'] as int,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      explanation: json['explanation'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'outcome_id': outcomeId,
    'description': description,
    'result': result,
    'iteration': iteration,
    'completed_at': completedAt?.toUtc().toIso8601String(),
    'explanation': explanation,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([completedAt], [explanation]), pass the sentinel
  /// value [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  OutcomeEvaluation copyWith({
    String? type,
    String? outcomeId,
    String? description,
    String? result,
    int? iteration,
    Object? completedAt = unsetCopyWithValue,
    Object? explanation = unsetCopyWithValue,
  }) {
    return OutcomeEvaluation(
      type: type ?? this.type,
      outcomeId: outcomeId ?? this.outcomeId,
      description: description ?? this.description,
      result: result ?? this.result,
      iteration: iteration ?? this.iteration,
      completedAt: completedAt == unsetCopyWithValue
          ? this.completedAt
          : completedAt as BetaTimestamp?,
      explanation: explanation == unsetCopyWithValue
          ? this.explanation
          : explanation as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutcomeEvaluation &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          outcomeId == other.outcomeId &&
          description == other.description &&
          result == other.result &&
          iteration == other.iteration &&
          completedAt == other.completedAt &&
          explanation == other.explanation;

  @override
  int get hashCode => Object.hash(
    type,
    outcomeId,
    description,
    result,
    iteration,
    completedAt,
    explanation,
  );

  @override
  String toString() =>
      'OutcomeEvaluation('
      'type: $type, '
      'outcomeId: $outcomeId, '
      'description: $description, '
      'result: $result, '
      'iteration: $iteration, '
      'completedAt: $completedAt, '
      'explanation: $explanation)';
}
