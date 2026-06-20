import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request body for searching span evaluations.
@immutable
class SpanEvaluationsRequest {
  /// Optional search expression to filter results.
  final String? searchExpression;

  /// Creates a [SpanEvaluationsRequest].
  const SpanEvaluationsRequest({this.searchExpression});

  /// Creates a [SpanEvaluationsRequest] from JSON.
  factory SpanEvaluationsRequest.fromJson(Map<String, dynamic> json) =>
      SpanEvaluationsRequest(
        searchExpression: json['search_expression'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchExpression != null) 'search_expression': searchExpression,
  };

  /// Creates a copy with replaced values.
  SpanEvaluationsRequest copyWith({
    Object? searchExpression = unsetCopyWithValue,
  }) => SpanEvaluationsRequest(
    searchExpression: searchExpression == unsetCopyWithValue
        ? this.searchExpression
        : searchExpression as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SpanEvaluationsRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchExpression == other.searchExpression;
  }

  @override
  int get hashCode => searchExpression.hashCode;

  @override
  String toString() =>
      'SpanEvaluationsRequest(searchExpression: $searchExpression)';
}
