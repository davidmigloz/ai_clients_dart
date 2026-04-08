import 'package:meta/meta.dart';

import 'workflow_with_worker_status.dart';

/// Response for getting a workflow.
@immutable
class WorkflowGetResponse {
  /// The workflow.
  final WorkflowWithWorkerStatus workflow;

  /// Creates a [WorkflowGetResponse].
  const WorkflowGetResponse({required this.workflow});

  /// Creates a [WorkflowGetResponse] from JSON.
  factory WorkflowGetResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowGetResponse(
        workflow: WorkflowWithWorkerStatus.fromJson(
          json['workflow'] as Map<String, dynamic>,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow': workflow.toJson()};

  /// Creates a copy with replaced values.
  WorkflowGetResponse copyWith({WorkflowWithWorkerStatus? workflow}) {
    return WorkflowGetResponse(workflow: workflow ?? this.workflow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowGetResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflow == other.workflow;
  }

  @override
  int get hashCode => workflow.hashCode;

  @override
  String toString() => 'WorkflowGetResponse(workflow: $workflow)';
}
