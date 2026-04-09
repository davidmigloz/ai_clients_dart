import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Response for a batch execution operation.
@immutable
class BatchExecutionResponse {
  /// The results map.
  final Map<String, dynamic>? results;

  /// Creates a [BatchExecutionResponse].
  const BatchExecutionResponse({this.results});

  /// Creates a [BatchExecutionResponse] from JSON.
  factory BatchExecutionResponse.fromJson(Map<String, dynamic> json) =>
      BatchExecutionResponse(results: json['results'] as Map<String, dynamic>?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (results != null) 'results': results};

  /// Creates a copy with replaced values.
  BatchExecutionResponse copyWith({Object? results = unsetCopyWithValue}) {
    return BatchExecutionResponse(
      results: results == unsetCopyWithValue
          ? this.results
          : results as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BatchExecutionResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(results, other.results)) return false;
    return true;
  }

  @override
  int get hashCode => mapDeepHashCode(results);

  @override
  String toString() =>
      'BatchExecutionResponse(results: ${results?.length ?? 'null'})';
}
