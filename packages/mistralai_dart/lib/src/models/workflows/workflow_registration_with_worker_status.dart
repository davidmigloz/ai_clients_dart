import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow.dart';
import 'workflow_code_definition.dart';

/// A workflow registration with worker status.
@immutable
class WorkflowRegistrationWithWorkerStatus {
  /// The registration identifier.
  final String id;

  /// The task queue name.
  final String taskQueue;

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
    required this.taskQueue,
    required this.definition,
    required this.workflowId,
    required this.active,
    this.compatibleWithChatAssistant = false,
    this.workflow,
  });

  /// Creates a [WorkflowRegistrationWithWorkerStatus] from JSON.
  factory WorkflowRegistrationWithWorkerStatus.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowRegistrationWithWorkerStatus(
    id: json['id'] as String? ?? '',
    taskQueue: json['task_queue'] as String? ?? '',
    definition: WorkflowCodeDefinition.fromJson(
      json['definition'] as Map<String, dynamic>,
    ),
    workflowId: json['workflow_id'] as String? ?? '',
    active: json['active'] as bool? ?? false,
    compatibleWithChatAssistant:
        json['compatible_with_chat_assistant'] as bool? ?? false,
    workflow: json['workflow'] != null
        ? Workflow.fromJson(json['workflow'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'task_queue': taskQueue,
    'definition': definition.toJson(),
    'workflow_id': workflowId,
    'active': active,
    'compatible_with_chat_assistant': compatibleWithChatAssistant,
    if (workflow != null) 'workflow': workflow?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowRegistrationWithWorkerStatus copyWith({
    String? id,
    String? taskQueue,
    WorkflowCodeDefinition? definition,
    String? workflowId,
    bool? active,
    bool? compatibleWithChatAssistant,
    Object? workflow = unsetCopyWithValue,
  }) {
    return WorkflowRegistrationWithWorkerStatus(
      id: id ?? this.id,
      taskQueue: taskQueue ?? this.taskQueue,
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
      'taskQueue: $taskQueue, '
      'definition: $definition, '
      'workflowId: $workflowId, '
      'active: $active, '
      'compatibleWithChatAssistant: $compatibleWithChatAssistant, '
      'workflow: $workflow'
      ')';
}
