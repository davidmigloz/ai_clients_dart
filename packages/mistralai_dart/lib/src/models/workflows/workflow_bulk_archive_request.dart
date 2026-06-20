import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to bulk archive workflows.
@immutable
class WorkflowBulkArchiveRequest {
  /// List of workflow IDs to archive.
  final List<String> workflowIds;

  /// Creates a [WorkflowBulkArchiveRequest].
  WorkflowBulkArchiveRequest({required List<String> workflowIds})
    : workflowIds = List.unmodifiable(workflowIds);

  /// Creates a [WorkflowBulkArchiveRequest] from JSON.
  factory WorkflowBulkArchiveRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowBulkArchiveRequest(
        workflowIds:
            (json['workflow_ids'] as List?)?.cast<String>() ?? const [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow_ids': workflowIds};

  /// Creates a copy with replaced values.
  WorkflowBulkArchiveRequest copyWith({List<String>? workflowIds}) {
    return WorkflowBulkArchiveRequest(
      workflowIds: workflowIds ?? this.workflowIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBulkArchiveRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(workflowIds, other.workflowIds);
  }

  @override
  int get hashCode => listHash(workflowIds);

  @override
  String toString() =>
      'WorkflowBulkArchiveRequest(workflowIds: ${workflowIds.length})';
}
