import 'package:meta/meta.dart';

/// Response from the indexing status endpoint.
///
/// Provides information about how many operations have been indexed
/// and the progress of indexing.
@immutable
class IndexStatusResponse {
  /// The number of operations that have been indexed.
  final int numIndexedOps;

  /// The number of operations that have not yet been indexed.
  final int numUnindexedOps;

  /// The indexing progress as a fraction (0.0 to 1.0).
  final double opIndexingProgress;

  /// The total number of operations.
  final int totalOps;

  /// Creates an index status response.
  const IndexStatusResponse({
    required this.numIndexedOps,
    required this.numUnindexedOps,
    required this.opIndexingProgress,
    required this.totalOps,
  });

  /// Creates an index status response from JSON.
  factory IndexStatusResponse.fromJson(Map<String, dynamic> json) {
    return IndexStatusResponse(
      numIndexedOps: json['num_indexed_ops'] as int,
      numUnindexedOps: json['num_unindexed_ops'] as int,
      opIndexingProgress: (json['op_indexing_progress'] as num).toDouble(),
      totalOps: json['total_ops'] as int,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'num_indexed_ops': numIndexedOps,
      'num_unindexed_ops': numUnindexedOps,
      'op_indexing_progress': opIndexingProgress,
      'total_ops': totalOps,
    };
  }

  /// Creates a copy with replaced values.
  IndexStatusResponse copyWith({
    int? numIndexedOps,
    int? numUnindexedOps,
    double? opIndexingProgress,
    int? totalOps,
  }) {
    return IndexStatusResponse(
      numIndexedOps: numIndexedOps ?? this.numIndexedOps,
      numUnindexedOps: numUnindexedOps ?? this.numUnindexedOps,
      opIndexingProgress: opIndexingProgress ?? this.opIndexingProgress,
      totalOps: totalOps ?? this.totalOps,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexStatusResponse &&
          runtimeType == other.runtimeType &&
          numIndexedOps == other.numIndexedOps &&
          numUnindexedOps == other.numUnindexedOps &&
          opIndexingProgress == other.opIndexingProgress &&
          totalOps == other.totalOps;

  @override
  int get hashCode =>
      Object.hash(numIndexedOps, numUnindexedOps, opIndexingProgress, totalOps);

  @override
  String toString() =>
      'IndexStatusResponse('
      'numIndexedOps: $numIndexedOps, '
      'numUnindexedOps: $numUnindexedOps, '
      'opIndexingProgress: $opIndexingProgress, '
      'totalOps: $totalOps)';
}
