import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request body for searching spans.
@immutable
class SpansRequest {
  /// Optional search expression to filter results.
  final String? searchExpression;

  /// Creates a [SpansRequest].
  const SpansRequest({this.searchExpression});

  /// Creates a [SpansRequest] from JSON.
  factory SpansRequest.fromJson(Map<String, dynamic> json) =>
      SpansRequest(searchExpression: json['search_expression'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchExpression != null) 'search_expression': searchExpression,
  };

  /// Creates a copy with replaced values.
  SpansRequest copyWith({Object? searchExpression = unsetCopyWithValue}) =>
      SpansRequest(
        searchExpression: searchExpression == unsetCopyWithValue
            ? this.searchExpression
            : searchExpression as String?,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SpansRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchExpression == other.searchExpression;
  }

  @override
  int get hashCode => searchExpression.hashCode;

  @override
  String toString() => 'SpansRequest(searchExpression: $searchExpression)';
}
