import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_log_record.dart';

/// A page of deployment log search results.
@immutable
class DeploymentLogSearchResponse {
  /// The matching log records.
  final List<DeploymentLogRecord> results;

  /// The cursor for the next page, if any.
  final String? nextCursor;

  /// Creates a [DeploymentLogSearchResponse].
  DeploymentLogSearchResponse({
    required List<DeploymentLogRecord> results,
    this.nextCursor,
  }) : results = List.unmodifiable(results);

  /// Creates a [DeploymentLogSearchResponse] from JSON.
  factory DeploymentLogSearchResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentLogSearchResponse(
        results:
            (json['results'] as List?)
                ?.map(
                  (e) =>
                      DeploymentLogRecord.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'results': results.map((e) => e.toJson()).toList(),
    if (nextCursor != null) 'next_cursor': nextCursor,
  };

  /// Creates a copy with replaced values.
  DeploymentLogSearchResponse copyWith({
    List<DeploymentLogRecord>? results,
    Object? nextCursor = unsetCopyWithValue,
  }) {
    return DeploymentLogSearchResponse(
      results: results ?? this.results,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentLogSearchResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(results, other.results) && nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(listHash(results), nextCursor);

  @override
  String toString() =>
      'DeploymentLogSearchResponse('
      'results: ${results.length}, '
      'nextCursor: $nextCursor'
      ')';
}
