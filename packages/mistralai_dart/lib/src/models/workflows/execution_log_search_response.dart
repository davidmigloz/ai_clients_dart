import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'execution_log_record.dart';

/// Response containing a page of workflow execution log records.
@immutable
class ExecutionLogSearchResponse {
  /// The matching log records.
  final List<ExecutionLogRecord> results;

  /// Pagination cursor for the next page of results, if any.
  final String? nextCursor;

  /// Creates an [ExecutionLogSearchResponse].
  ExecutionLogSearchResponse({
    required List<ExecutionLogRecord> results,
    this.nextCursor,
  }) : results = List.unmodifiable(results);

  /// Creates an [ExecutionLogSearchResponse] from JSON.
  factory ExecutionLogSearchResponse.fromJson(Map<String, dynamic> json) =>
      ExecutionLogSearchResponse(
        results:
            (json['results'] as List?)
                ?.map(
                  (e) => ExecutionLogRecord.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'results': results.map((e) => e.toJson()).toList(),
    if (nextCursor != null) 'next_cursor': nextCursor,
  };

  /// Creates a copy with replaced values.
  ExecutionLogSearchResponse copyWith({
    List<ExecutionLogRecord>? results,
    Object? nextCursor = unsetCopyWithValue,
  }) {
    return ExecutionLogSearchResponse(
      results: results ?? this.results,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExecutionLogSearchResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(results, other.results) && nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(listHash(results), nextCursor);

  @override
  String toString() =>
      'ExecutionLogSearchResponse('
      'results: ${results.length}, '
      'nextCursor: $nextCursor'
      ')';
}
