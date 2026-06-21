import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow.dart';
import 'workflow_bulk_error.dart';

/// Response for a bulk unarchive workflows operation.
@immutable
class WorkflowBulkUnarchiveResponse {
  /// Workflows that were successfully unarchived or were already unarchived.
  final List<Workflow> unarchived;

  /// Workflows that could not be unarchived and the corresponding errors.
  final List<WorkflowBulkError>? errored;

  /// Creates a [WorkflowBulkUnarchiveResponse].
  WorkflowBulkUnarchiveResponse({
    required List<Workflow> unarchived,
    List<WorkflowBulkError>? errored,
  }) : unarchived = List.unmodifiable(unarchived),
       errored = errored != null ? List.unmodifiable(errored) : null;

  /// Creates a [WorkflowBulkUnarchiveResponse] from JSON.
  factory WorkflowBulkUnarchiveResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowBulkUnarchiveResponse(
        unarchived:
            (json['unarchived'] as List?)
                ?.map((e) => Workflow.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        errored: (json['errored'] as List?)
            ?.map((e) => WorkflowBulkError.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'unarchived': unarchived.map((e) => e.toJson()).toList(),
    if (errored != null) 'errored': errored?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowBulkUnarchiveResponse copyWith({
    List<Workflow>? unarchived,
    Object? errored = unsetCopyWithValue,
  }) {
    return WorkflowBulkUnarchiveResponse(
      unarchived: unarchived ?? this.unarchived,
      errored: errored == unsetCopyWithValue
          ? this.errored
          : errored as List<WorkflowBulkError>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBulkUnarchiveResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(unarchived, other.unarchived) &&
        listsEqual(errored, other.errored);
  }

  @override
  int get hashCode => Object.hash(listHash(unarchived), listHash(errored));

  @override
  String toString() =>
      'WorkflowBulkUnarchiveResponse('
      'unarchived: ${unarchived.length}, '
      'errored: ${errored?.length ?? 'null'}'
      ')';
}
