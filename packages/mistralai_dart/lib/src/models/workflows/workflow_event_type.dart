/// Type of workflow event.
enum WorkflowEventType {
  /// Workflow execution started.
  workflowExecutionStarted('WORKFLOW_EXECUTION_STARTED'),

  /// Workflow execution completed.
  workflowExecutionCompleted('WORKFLOW_EXECUTION_COMPLETED'),

  /// Workflow execution failed.
  workflowExecutionFailed('WORKFLOW_EXECUTION_FAILED'),

  /// Workflow execution canceled.
  workflowExecutionCanceled('WORKFLOW_EXECUTION_CANCELED'),

  /// Workflow execution continued as new.
  workflowExecutionContinuedAsNew('WORKFLOW_EXECUTION_CONTINUED_AS_NEW'),

  /// Workflow task timed out.
  workflowTaskTimedOut('WORKFLOW_TASK_TIMED_OUT'),

  /// Workflow task failed.
  workflowTaskFailed('WORKFLOW_TASK_FAILED'),

  /// Custom task started.
  customTaskStarted('CUSTOM_TASK_STARTED'),

  /// Custom task in progress.
  customTaskInProgress('CUSTOM_TASK_IN_PROGRESS'),

  /// Custom task completed.
  customTaskCompleted('CUSTOM_TASK_COMPLETED'),

  /// Custom task failed.
  customTaskFailed('CUSTOM_TASK_FAILED'),

  /// Custom task timed out.
  customTaskTimedOut('CUSTOM_TASK_TIMED_OUT'),

  /// Custom task canceled.
  customTaskCanceled('CUSTOM_TASK_CANCELED'),

  /// Activity task started.
  activityTaskStarted('ACTIVITY_TASK_STARTED'),

  /// Activity task completed.
  activityTaskCompleted('ACTIVITY_TASK_COMPLETED'),

  /// Activity task retrying.
  activityTaskRetrying('ACTIVITY_TASK_RETRYING'),

  /// Activity task failed.
  activityTaskFailed('ACTIVITY_TASK_FAILED'),

  /// Unknown event type (forward-compatibility fallback).
  unknown('unknown');

  const WorkflowEventType(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [WorkflowEventType] from a JSON string value.
  static WorkflowEventType fromJson(String? value) {
    if (value == null) return WorkflowEventType.unknown;
    return WorkflowEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkflowEventType.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
