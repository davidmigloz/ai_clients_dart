// ignore_for_file: deprecated_member_use_from_same_package
import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow.dart';
import 'workflow_code_definition.dart';

/// A workflow registration with worker status.
@immutable
class WorkflowRegistrationWithWorkerStatus {
  /// The registration identifier.
  final String id;

  /// The deployment identifier.
  ///
  /// Deprecated: use [deploymentName] instead. Will be removed in a future
  /// release.
  final String? deploymentId;

  /// The name of the deployment this registration belongs to.
  final String? deploymentName;

  /// The task queue.
  ///
  /// Deprecated: this field is deprecated in the API.
  @Deprecated('task_queue is deprecated in the Mistral API')
  final String? taskQueue;

  /// The workflow code definition.
  final WorkflowCodeDefinition definition;

  /// The workflow identifier.
  final String workflowId;

  /// Whether the worker is active.
  final bool active;

  /// Whether compatible with chat assistant.
  final bool compatibleWithChatAssistant;

  /// The associated workflow.
  final Workflow? workflow;

  /// Creates a [WorkflowRegistrationWithWorkerStatus].
  const WorkflowRegistrationWithWorkerStatus({
    required this.id,
    this.deploymentId,
    this.deploymentName,
    @Deprecated('task_queue is deprecated in the Mistral API') this.taskQueue,
    required this.definition,
    required this.workflowId,
    required this.active,
    this.compatibleWithChatAssistant = false,
    this.workflow,
  });

  /// Creates a [WorkflowRegistrationWithWorkerStatus] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing.
  factory WorkflowRegistrationWithWorkerStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    final id = json['id'] as String?;
    if (id == null) {
      throw const FormatException(
        'WorkflowRegistrationWithWorkerStatus: missing required field "id"',
      );
    }
    final workflowId = json['workflow_id'] as String?;
    if (workflowId == null) {
      throw const FormatException(
        'WorkflowRegistrationWithWorkerStatus: missing required field '
        '"workflow_id"',
      );
    }
    final active = json['active'] as bool?;
    if (active == null) {
      throw const FormatException(
        'WorkflowRegistrationWithWorkerStatus: missing required field '
        '"active"',
      );
    }
    return WorkflowRegistrationWithWorkerStatus(
      id: id,
      deploymentId: json['deployment_id'] as String?,
      deploymentName: json['deployment_name'] as String?,
      taskQueue: json['task_queue'] as String?,
      definition: WorkflowCodeDefinition.fromJson(
        json['definition'] as Map<String, dynamic>,
      ),
      workflowId: workflowId,
      active: active,
      compatibleWithChatAssistant:
          json['compatible_with_chat_assistant'] as bool? ?? false,
      workflow: json['workflow'] != null
          ? Workflow.fromJson(json['workflow'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (deploymentId != null) 'deployment_id': deploymentId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (taskQueue != null) 'task_queue': taskQueue,
    'definition': definition.toJson(),
    'workflow_id': workflowId,
    'active': active,
    'compatible_with_chat_assistant': compatibleWithChatAssistant,
    if (workflow != null) 'workflow': workflow?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowRegistrationWithWorkerStatus copyWith({
    String? id,
    Object? deploymentId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? taskQueue = unsetCopyWithValue,
    WorkflowCodeDefinition? definition,
    String? workflowId,
    bool? active,
    bool? compatibleWithChatAssistant,
    Object? workflow = unsetCopyWithValue,
  }) {
    return WorkflowRegistrationWithWorkerStatus(
      id: id ?? this.id,
      deploymentId: deploymentId == unsetCopyWithValue
          ? this.deploymentId
          : deploymentId as String?,
      deploymentName: deploymentName == unsetCopyWithValue
          ? this.deploymentName
          : deploymentName as String?,
      taskQueue: taskQueue == unsetCopyWithValue
          ? this.taskQueue
          : taskQueue as String?,
      definition: definition ?? this.definition,
      workflowId: workflowId ?? this.workflowId,
      active: active ?? this.active,
      compatibleWithChatAssistant:
          compatibleWithChatAssistant ?? this.compatibleWithChatAssistant,
      workflow: workflow == unsetCopyWithValue
          ? this.workflow
          : workflow as Workflow?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowRegistrationWithWorkerStatus) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        deploymentId == other.deploymentId &&
        deploymentName == other.deploymentName &&
        taskQueue == other.taskQueue &&
        definition == other.definition &&
        workflowId == other.workflowId &&
        active == other.active &&
        compatibleWithChatAssistant == other.compatibleWithChatAssistant &&
        workflow == other.workflow;
  }

  @override
  int get hashCode => Object.hash(
    id,
    deploymentId,
    deploymentName,
    taskQueue,
    definition,
    workflowId,
    active,
    compatibleWithChatAssistant,
    workflow,
  );

  @override
  String toString() =>
      'WorkflowRegistrationWithWorkerStatus('
      'id: $id, '
      'deploymentId: $deploymentId, '
      'deploymentName: $deploymentName, '
      'taskQueue: $taskQueue, '
      'definition: $definition, '
      'workflowId: $workflowId, '
      'active: $active, '
      'compatibleWithChatAssistant: $compatibleWithChatAssistant, '
      'workflow: $workflow'
      ')';
}
