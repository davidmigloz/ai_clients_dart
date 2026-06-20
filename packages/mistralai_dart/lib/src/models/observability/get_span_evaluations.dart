import 'package:meta/meta.dart';

import 'feed_result.dart';
import 'get_span_evaluation.dart';

/// Response containing a paginated feed of span evaluations.
@immutable
class GetSpanEvaluations {
  /// The paginated spanEvaluations results.
  final FeedResult<GetSpanEvaluation> spanEvaluations;

  /// Creates a [GetSpanEvaluations].
  const GetSpanEvaluations({required this.spanEvaluations});

  /// Creates a [GetSpanEvaluations] from JSON.
  factory GetSpanEvaluations.fromJson(Map<String, dynamic> json) =>
      GetSpanEvaluations(
        spanEvaluations: FeedResult<GetSpanEvaluation>.fromJson(
          json['span_evaluations'] as Map<String, dynamic>? ?? const {},
          GetSpanEvaluation.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'span_evaluations': spanEvaluations.toJson((e) => e.toJson()),
  };

  /// Creates a copy with replaced values.
  GetSpanEvaluations copyWith({
    FeedResult<GetSpanEvaluation>? spanEvaluations,
  }) => GetSpanEvaluations(
    spanEvaluations: spanEvaluations ?? this.spanEvaluations,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpanEvaluations) return false;
    if (runtimeType != other.runtimeType) return false;
    return spanEvaluations == other.spanEvaluations;
  }

  @override
  int get hashCode => spanEvaluations.hashCode;

  @override
  String toString() => 'GetSpanEvaluations(spanEvaluations: $spanEvaluations)';
}
