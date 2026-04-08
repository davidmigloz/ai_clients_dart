import 'package:meta/meta.dart';

import 'workflow.dart';

/// Response for updating a workflow.
@immutable
class WorkflowUpdateResponse {
  /// The workflow.
  final Workflow workflow;

  /// Creates a [WorkflowUpdateResponse].
  const WorkflowUpdateResponse({required this.workflow});

  /// Creates a [WorkflowUpdateResponse] from JSON.
  factory WorkflowUpdateResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowUpdateResponse(
        workflow: Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'workflow': workflow.toJson()};

  /// Creates a copy with replaced values.
  WorkflowUpdateResponse copyWith({Workflow? workflow}) {
    return WorkflowUpdateResponse(workflow: workflow ?? this.workflow);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowUpdateResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflow == other.workflow;
  }

  @override
  int get hashCode => workflow.hashCode;

  @override
  String toString() => 'WorkflowUpdateResponse(workflow: $workflow)';
}
