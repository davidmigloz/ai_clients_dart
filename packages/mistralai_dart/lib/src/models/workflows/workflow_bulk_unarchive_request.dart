import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to bulk unarchive workflows.
@immutable
class WorkflowBulkUnarchiveRequest {
  /// List of workflow IDs to unarchive.
  final List<String> workflowIds;

  /// Creates a [WorkflowBulkUnarchiveRequest].
  WorkflowBulkUnarchiveRequest({required List<String> workflowIds})
    : workflowIds = List.unmodifiable(workflowIds);

  /// Creates a [WorkflowBulkUnarchiveRequest] from JSON.
  factory WorkflowBulkUnarchiveRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowBulkUnarchiveRequest(
        workflowIds:
            (json['workflow_ids'] as List?)?.cast<String>() ?? const [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow_ids': workflowIds};

  /// Creates a copy with replaced values.
  WorkflowBulkUnarchiveRequest copyWith({List<String>? workflowIds}) {
    return WorkflowBulkUnarchiveRequest(
      workflowIds: workflowIds ?? this.workflowIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBulkUnarchiveRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(workflowIds, other.workflowIds);
  }

  @override
  int get hashCode => listHash(workflowIds);

  @override
  String toString() =>
      'WorkflowBulkUnarchiveRequest(workflowIds: ${workflowIds.length})';
}
