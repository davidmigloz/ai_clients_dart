import 'package:meta/meta.dart';

/// Run and schedule identifiers attached to workflow events.
@immutable
class WorkflowEventRunContext {
  /// Run that started this chain.
  final String? chainRunId;

  /// Run from which this execution continued.
  final String? continuedRunId;

  /// First run of the workflow execution.
  final String? firstExecutionRunId;

  /// Schedule that started the workflow.
  final String? scheduleId;

  /// Creates an event's run context.
  const WorkflowEventRunContext({
    this.chainRunId,
    this.continuedRunId,
    this.firstExecutionRunId,
    this.scheduleId,
  });

  /// Decodes the run context from a workflow event.
  factory WorkflowEventRunContext.fromJson(Map<String, dynamic> json) =>
      WorkflowEventRunContext(
        chainRunId: json['chain_run_id'] as String?,
        continuedRunId: json['continued_run_id'] as String?,
        firstExecutionRunId: json['first_execution_run_id'] as String?,
        scheduleId: json['schedule_id'] as String?,
      );

  /// Converts to the event's inline run context fields.
  Map<String, dynamic> toJson() => {
    if (chainRunId != null) 'chain_run_id': chainRunId,
    if (continuedRunId != null) 'continued_run_id': continuedRunId,
    if (firstExecutionRunId != null)
      'first_execution_run_id': firstExecutionRunId,
    if (scheduleId != null) 'schedule_id': scheduleId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowEventRunContext &&
          chainRunId == other.chainRunId &&
          continuedRunId == other.continuedRunId &&
          firstExecutionRunId == other.firstExecutionRunId &&
          scheduleId == other.scheduleId;

  @override
  int get hashCode =>
      Object.hash(chainRunId, continuedRunId, firstExecutionRunId, scheduleId);

  @override
  String toString() =>
      'WorkflowEventRunContext(chainRunId: $chainRunId, '
      'continuedRunId: $continuedRunId, firstExecutionRunId: $firstExecutionRunId, '
      'scheduleId: $scheduleId)';
}
