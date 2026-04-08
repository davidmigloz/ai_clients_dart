import 'package:meta/meta.dart';

import 'workflow_registration_with_worker_status.dart';

/// Response for getting a workflow registration.
@immutable
class WorkflowRegistrationGetResponse {
  /// The workflow registration.
  final WorkflowRegistrationWithWorkerStatus workflowRegistration;

  /// The workflow version.
  final WorkflowRegistrationWithWorkerStatus workflowVersion;

  /// Creates a [WorkflowRegistrationGetResponse].
  const WorkflowRegistrationGetResponse({
    required this.workflowRegistration,
    required this.workflowVersion,
  });

  /// Creates a [WorkflowRegistrationGetResponse] from JSON.
  factory WorkflowRegistrationGetResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowRegistrationGetResponse(
        workflowRegistration: WorkflowRegistrationWithWorkerStatus.fromJson(
          json['workflow_registration'] as Map<String, dynamic>,
        ),
        workflowVersion: WorkflowRegistrationWithWorkerStatus.fromJson(
          json['workflow_version'] as Map<String, dynamic>,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow_registration': workflowRegistration.toJson(),
    'workflow_version': workflowVersion.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowRegistrationGetResponse copyWith({
    WorkflowRegistrationWithWorkerStatus? workflowRegistration,
    WorkflowRegistrationWithWorkerStatus? workflowVersion,
  }) {
    return WorkflowRegistrationGetResponse(
      workflowRegistration: workflowRegistration ?? this.workflowRegistration,
      workflowVersion: workflowVersion ?? this.workflowVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowRegistrationGetResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowRegistration == other.workflowRegistration &&
        workflowVersion == other.workflowVersion;
  }

  @override
  int get hashCode => Object.hash(workflowRegistration, workflowVersion);

  @override
  String toString() =>
      'WorkflowRegistrationGetResponse(workflowRegistration: $workflowRegistration, workflowVersion: $workflowVersion)';
}
