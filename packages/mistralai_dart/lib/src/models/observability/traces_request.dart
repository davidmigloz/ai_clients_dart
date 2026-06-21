import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request body for searching traces.
@immutable
class TracesRequest {
  /// Optional search expression to filter results.
  final String? searchExpression;

  /// Creates a [TracesRequest].
  const TracesRequest({this.searchExpression});

  /// Creates a [TracesRequest] from JSON.
  factory TracesRequest.fromJson(Map<String, dynamic> json) =>
      TracesRequest(searchExpression: json['search_expression'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchExpression != null) 'search_expression': searchExpression,
  };

  /// Creates a copy with replaced values.
  TracesRequest copyWith({Object? searchExpression = unsetCopyWithValue}) =>
      TracesRequest(
        searchExpression: searchExpression == unsetCopyWithValue
            ? this.searchExpression
            : searchExpression as String?,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TracesRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return searchExpression == other.searchExpression;
  }

  @override
  int get hashCode => searchExpression.hashCode;

  @override
  String toString() => 'TracesRequest(searchExpression: $searchExpression)';
}
