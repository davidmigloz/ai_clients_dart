/// Status of a workflow execution.
enum WorkflowExecutionStatus {
  /// Execution is currently running.
  running('RUNNING'),

  /// Execution completed successfully.
  completed('COMPLETED'),

  /// Execution failed with an error.
  failed('FAILED'),

  /// Execution was canceled.
  canceled('CANCELED'),

  /// Execution was terminated.
  terminated('TERMINATED'),

  /// Execution continued as a new run.
  continuedAsNew('CONTINUED_AS_NEW'),

  /// Execution timed out.
  timedOut('TIMED_OUT'),

  /// Execution is retrying after an error.
  retryingAfterError('RETRYING_AFTER_ERROR'),

  /// Unknown status (forward-compatibility fallback).
  unknown('unknown');

  const WorkflowExecutionStatus(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [WorkflowExecutionStatus] from a JSON string value.
  static WorkflowExecutionStatus fromJson(String? value) {
    if (value == null) return WorkflowExecutionStatus.unknown;
    return WorkflowExecutionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkflowExecutionStatus.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
