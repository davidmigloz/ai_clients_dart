import 'package:meta/meta.dart';

import 'workflow.dart';

/// Response for archiving a workflow.
@immutable
class WorkflowArchiveResponse {
  /// The workflow.
  final Workflow workflow;

  /// Creates a [WorkflowArchiveResponse].
  const WorkflowArchiveResponse({required this.workflow});

  /// Creates a [WorkflowArchiveResponse] from JSON.
  factory WorkflowArchiveResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowArchiveResponse(
        workflow: Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow': workflow.toJson()};

  /// Creates a copy with replaced values.
  WorkflowArchiveResponse copyWith({Workflow? workflow}) {
    return WorkflowArchiveResponse(workflow: workflow ?? this.workflow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowArchiveResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflow == other.workflow;
  }

  @override
  int get hashCode => workflow.hashCode;

  @override
  String toString() => 'WorkflowArchiveResponse(workflow: $workflow)';
}
