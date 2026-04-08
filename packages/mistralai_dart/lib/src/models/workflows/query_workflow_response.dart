import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Response for a workflow query.
@immutable
class QueryWorkflowResponse {
  /// The query name.
  final String queryName;

  /// The query result.
  final Object result;

  /// Creates a [QueryWorkflowResponse].
  const QueryWorkflowResponse({required this.queryName, required this.result});

  /// Creates a [QueryWorkflowResponse] from JSON.
  factory QueryWorkflowResponse.fromJson(Map<String, dynamic> json) =>
      QueryWorkflowResponse(
        queryName: json['query_name'] as String? ?? '',
        result: json['result'] ?? const <String, dynamic>{},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'query_name': queryName, 'result': result};

  /// Creates a copy with replaced values.
  QueryWorkflowResponse copyWith({String? queryName, Object? result}) {
    return QueryWorkflowResponse(
      queryName: queryName ?? this.queryName,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryWorkflowResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return queryName == other.queryName &&
        valuesDeepEqual(result, other.result);
  }

  @override
  int get hashCode => Object.hash(queryName, valueDeepHashCode(result));

  @override
  String toString() =>
      'QueryWorkflowResponse(queryName: $queryName, result: $result)';
}
