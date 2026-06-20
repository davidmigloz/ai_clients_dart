import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request body for searching logs.
@immutable
class LogsRequest {
  /// Sort order for the results (`asc` or `desc`). Defaults to `desc`.
  final String order;

  /// Optional search expression to filter results.
  final String? searchExpression;

  /// Creates a [LogsRequest].
  const LogsRequest({this.order = 'desc', this.searchExpression});

  /// Creates a [LogsRequest] from JSON.
  factory LogsRequest.fromJson(Map<String, dynamic> json) => LogsRequest(
    order: json['order'] as String? ?? 'desc',
    searchExpression: json['search_expression'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'order': order,
    if (searchExpression != null) 'search_expression': searchExpression,
  };

  /// Creates a copy with replaced values.
  LogsRequest copyWith({
    String? order,
    Object? searchExpression = unsetCopyWithValue,
  }) => LogsRequest(
    order: order ?? this.order,
    searchExpression: searchExpression == unsetCopyWithValue
        ? this.searchExpression
        : searchExpression as String?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LogsRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return order == other.order && searchExpression == other.searchExpression;
  }

  @override
  int get hashCode => Object.hash(order, searchExpression);

  @override
  String toString() =>
      'LogsRequest(order: $order, searchExpression: $searchExpression)';
}
