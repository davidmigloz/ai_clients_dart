import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Body for batch workflow execution operations.
@immutable
class BatchExecutionBody {
  /// The execution identifiers.
  final List<String> executionIds;

  /// Creates a [BatchExecutionBody].
  BatchExecutionBody({required List<String> executionIds})
    : executionIds = List.unmodifiable(executionIds);

  /// Creates a [BatchExecutionBody] from JSON.
  factory BatchExecutionBody.fromJson(Map<String, dynamic> json) =>
      BatchExecutionBody(
        executionIds: (json['execution_ids'] as List?)?.cast<String>() ?? [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'execution_ids': executionIds};

  /// Creates a copy with replaced values.
  BatchExecutionBody copyWith({List<String>? executionIds}) {
    return BatchExecutionBody(executionIds: executionIds ?? this.executionIds);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BatchExecutionBody) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(executionIds, other.executionIds)) return false;
    return true;
  }

  @override
  int get hashCode => listHash(executionIds);

  @override
  String toString() =>
      'BatchExecutionBody(executionIds: ${executionIds.length})';
}
