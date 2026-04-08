import 'package:meta/meta.dart';

import 'workflow.dart';

/// Response for unarchiving a workflow.
@immutable
class WorkflowUnarchiveResponse {
  /// The workflow.
  final Workflow workflow;

  /// Creates a [WorkflowUnarchiveResponse].
  const WorkflowUnarchiveResponse({required this.workflow});

  /// Creates a [WorkflowUnarchiveResponse] from JSON.
  factory WorkflowUnarchiveResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowUnarchiveResponse(
        workflow: Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow': workflow.toJson()};

  /// Creates a copy with replaced values.
  WorkflowUnarchiveResponse copyWith({Workflow? workflow}) {
    return WorkflowUnarchiveResponse(workflow: workflow ?? this.workflow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowUnarchiveResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflow == other.workflow;
  }

  @override
  int get hashCode => workflow.hashCode;

  @override
  String toString() => 'WorkflowUnarchiveResponse(workflow: $workflow)';
}
