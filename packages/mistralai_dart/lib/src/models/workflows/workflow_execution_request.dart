import 'package:meta/meta.dart';

import '../../utils/workflow_call_context.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to execute a workflow.
@immutable
class WorkflowExecutionRequest {
  /// The execution input.
  final Map<String, dynamic>? input;

  /// Extensions.
  final Map<String, dynamic>? extensions;

  /// Optional execution ID.
  final String? executionId;

  /// The deployment name.
  final String? deploymentName;

  /// The task queue name.
  final String? taskQueue;

  /// Timeout in seconds.
  final double? timeoutSeconds;

  /// Whether to wait for the result.
  final bool waitForResult;

  /// Custom tracing attributes.
  final Map<String, dynamic>? customTracingAttributes;

  /// Cleartext technical IDs and flags passed to the workflow. Never include customer content.
  final Map<String, Object>? callContext;

  /// W3C trace context to join, unless forceNewTrace is set.
  final String? traceparent;

  /// Starts a new independent trace instead of joining the caller trace.
  final bool? forceNewTrace;

  /// Creates a [WorkflowExecutionRequest].
  const WorkflowExecutionRequest({
    this.callContext,
    this.traceparent,
    this.forceNewTrace,
    this.input,
    this.extensions,
    this.executionId,
    this.deploymentName,
    this.taskQueue,
    this.timeoutSeconds,
    this.waitForResult = false,
    this.customTracingAttributes,
  });

  /// Creates a [WorkflowExecutionRequest] from JSON.
  factory WorkflowExecutionRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowExecutionRequest(
        callContext: parseWorkflowCallContext(json['call_context']),
        traceparent: json['traceparent'] as String?,
        forceNewTrace: json['force_new_trace'] as bool?,
        input: json['input'] as Map<String, dynamic>?,
        extensions: json['extensions'] as Map<String, dynamic>?,
        executionId: json['execution_id'] as String?,
        deploymentName: json['deployment_name'] as String?,
        taskQueue: json['task_queue'] as String?,
        timeoutSeconds: (json['timeout_seconds'] as num?)?.toDouble(),
        waitForResult: json['wait_for_result'] as bool? ?? false,
        customTracingAttributes:
            json['custom_tracing_attributes'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (callContext != null)
      'call_context': workflowCallContextToJson(callContext!),
    if (traceparent != null) 'traceparent': traceparent,
    if (forceNewTrace != null) 'force_new_trace': forceNewTrace,
    if (input != null) 'input': input,
    if (extensions != null) 'extensions': extensions,
    if (executionId != null) 'execution_id': executionId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (taskQueue != null) 'task_queue': taskQueue,
    if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
    'wait_for_result': waitForResult,
    if (customTracingAttributes != null)
      'custom_tracing_attributes': customTracingAttributes,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionRequest copyWith({
    Object? callContext = unsetCopyWithValue,
    Object? traceparent = unsetCopyWithValue,
    Object? forceNewTrace = unsetCopyWithValue,
    Object? input = unsetCopyWithValue,
    Object? extensions = unsetCopyWithValue,
    Object? executionId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? taskQueue = unsetCopyWithValue,
    Object? timeoutSeconds = unsetCopyWithValue,
    bool? waitForResult,
    Object? customTracingAttributes = unsetCopyWithValue,
  }) {
    return WorkflowExecutionRequest(
      callContext: callContext == unsetCopyWithValue
          ? this.callContext
          : callContext == null
          ? null
          : Map<String, Object>.from(callContext as Map<Object?, Object?>),
      traceparent: traceparent == unsetCopyWithValue
          ? this.traceparent
          : traceparent as String?,
      forceNewTrace: forceNewTrace == unsetCopyWithValue
          ? this.forceNewTrace
          : forceNewTrace as bool?,
      input: input == unsetCopyWithValue
          ? this.input
          : input as Map<String, dynamic>?,
      extensions: extensions == unsetCopyWithValue
          ? this.extensions
          : extensions as Map<String, dynamic>?,
      executionId: executionId == unsetCopyWithValue
          ? this.executionId
          : executionId as String?,
      deploymentName: deploymentName == unsetCopyWithValue
          ? this.deploymentName
          : deploymentName as String?,
      taskQueue: taskQueue == unsetCopyWithValue
          ? this.taskQueue
          : taskQueue as String?,
      timeoutSeconds: timeoutSeconds == unsetCopyWithValue
          ? this.timeoutSeconds
          : timeoutSeconds as double?,
      waitForResult: waitForResult ?? this.waitForResult,
      customTracingAttributes: customTracingAttributes == unsetCopyWithValue
          ? this.customTracingAttributes
          : customTracingAttributes as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(input, other.input)) return false;
    if (!mapsDeepEqual(extensions, other.extensions)) return false;
    if (!mapsDeepEqual(
      customTracingAttributes,
      other.customTracingAttributes,
    )) {
      return false;
    }
    return mapsEqual(callContext, other.callContext) &&
        traceparent == other.traceparent &&
        forceNewTrace == other.forceNewTrace &&
        executionId == other.executionId &&
        deploymentName == other.deploymentName &&
        taskQueue == other.taskQueue &&
        timeoutSeconds == other.timeoutSeconds &&
        waitForResult == other.waitForResult;
  }

  @override
  int get hashCode => Object.hashAll([
    mapDeepHashCode(input),
    mapDeepHashCode(extensions),
    executionId,
    deploymentName,
    taskQueue,
    timeoutSeconds,
    waitForResult,
    mapDeepHashCode(customTracingAttributes),
    mapHash(callContext),
    traceparent,
    forceNewTrace,
  ]);

  @override
  String toString() =>
      'WorkflowExecutionRequest(callContext: ${callContext?.length}, traceparent: $traceparent, forceNewTrace: $forceNewTrace, '
      'input: ${input?.length ?? 'null'}, '
      'extensions: ${extensions?.length ?? 'null'}, '
      'executionId: $executionId, '
      'deploymentName: $deploymentName, '
      'taskQueue: $taskQueue, '
      'timeoutSeconds: $timeoutSeconds, '
      'waitForResult: $waitForResult, '
      'customTracingAttributes: ${customTracingAttributes?.length ?? 'null'}'
      ')';
}
