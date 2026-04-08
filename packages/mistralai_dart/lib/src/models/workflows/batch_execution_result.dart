import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Result of a batch execution operation.
@immutable
class BatchExecutionResult {
  /// The result status.
  final String status;

  /// Error message, if any.
  final String? error;

  /// Creates a [BatchExecutionResult].
  const BatchExecutionResult({required this.status, this.error});

  /// Creates a [BatchExecutionResult] from JSON.
  factory BatchExecutionResult.fromJson(Map<String, dynamic> json) =>
      BatchExecutionResult(
        status: json['status'] as String? ?? '',
        error: json['error'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'status': status,
    if (error != null) 'error': error,
  };

  /// Creates a copy with replaced values.
  BatchExecutionResult copyWith({
    String? status,
    Object? error = unsetCopyWithValue,
  }) {
    return BatchExecutionResult(
      status: status ?? this.status,
      error: error == unsetCopyWithValue ? this.error : error as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BatchExecutionResult) return false;
    if (runtimeType != other.runtimeType) return false;
    return status == other.status && error == other.error;
  }

  @override
  int get hashCode => Object.hash(status, error);

  @override
  String toString() => 'BatchExecutionResult(status: $status, error: $error)';
}
