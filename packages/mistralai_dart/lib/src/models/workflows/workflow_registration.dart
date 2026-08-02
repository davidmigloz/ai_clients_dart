// ignore_for_file: deprecated_member_use_from_same_package
import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow.dart';
import 'workflow_code_definition.dart';

/// A workflow registration.
@immutable
class WorkflowRegistration {
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

  /// Whether compatible with chat assistant.
  final bool compatibleWithChatAssistant;

  /// The associated workflow.
  final Workflow? workflow;

  /// Creates a [WorkflowRegistration].
  const WorkflowRegistration({
    required this.id,
    this.deploymentId,
    this.deploymentName,
    @Deprecated('task_queue is deprecated in the Mistral API') this.taskQueue,
    required this.definition,
    required this.workflowId,
    this.compatibleWithChatAssistant = false,
    this.workflow,
  });

  /// Creates a [WorkflowRegistration] from JSON.
  factory WorkflowRegistration.fromJson(Map<String, dynamic> json) =>
      WorkflowRegistration(
        id: json['id'] as String? ?? '',
        deploymentId: json['deployment_id'] as String?,
        deploymentName: json['deployment_name'] as String?,
        taskQueue: json['task_queue'] as String?,
        definition: WorkflowCodeDefinition.fromJson(
          json['definition'] as Map<String, dynamic>,
        ),
        workflowId: json['workflow_id'] as String? ?? '',
        compatibleWithChatAssistant:
            json['compatible_with_chat_assistant'] as bool? ?? false,
        workflow: json['workflow'] != null
            ? Workflow.fromJson(json['workflow'] as Map<String, dynamic>)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (deploymentId != null) 'deployment_id': deploymentId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (taskQueue != null) 'task_queue': taskQueue,
    'definition': definition.toJson(),
    'workflow_id': workflowId,
    'compatible_with_chat_assistant': compatibleWithChatAssistant,
    if (workflow != null) 'workflow': workflow?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowRegistration copyWith({
    String? id,
    Object? deploymentId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? taskQueue = unsetCopyWithValue,
    WorkflowCodeDefinition? definition,
    String? workflowId,
    bool? compatibleWithChatAssistant,
    Object? workflow = unsetCopyWithValue,
  }) {
    return WorkflowRegistration(
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
    if (other is! WorkflowRegistration) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        deploymentId == other.deploymentId &&
        deploymentName == other.deploymentName &&
        taskQueue == other.taskQueue &&
        definition == other.definition &&
        workflowId == other.workflowId &&
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
    compatibleWithChatAssistant,
    workflow,
  );

  @override
  String toString() =>
      'WorkflowRegistration('
      'id: $id, '
      'deploymentId: $deploymentId, '
      'deploymentName: $deploymentName, '
      'taskQueue: $taskQueue, '
      'definition: $definition, '
      'workflowId: $workflowId, '
      'compatibleWithChatAssistant: $compatibleWithChatAssistant, '
      'workflow: $workflow'
      ')';
}
