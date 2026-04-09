import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'network_encoded_input.dart';

/// Request to execute a workflow.
@immutable
class WorkflowExecutionRequest {
  /// The execution input.
  final Map<String, dynamic>? input;

  /// Encoded input payload.
  final NetworkEncodedInput? encodedInput;

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

  /// Creates a [WorkflowExecutionRequest].
  const WorkflowExecutionRequest({
    this.input,
    this.encodedInput,
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
        input: json['input'] as Map<String, dynamic>?,
        encodedInput: json['encoded_input'] != null
            ? NetworkEncodedInput.fromJson(
                json['encoded_input'] as Map<String, dynamic>,
              )
            : null,
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
    if (input != null) 'input': input,
    if (encodedInput != null) 'encoded_input': encodedInput?.toJson(),
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
    Object? input = unsetCopyWithValue,
    Object? encodedInput = unsetCopyWithValue,
    Object? executionId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? taskQueue = unsetCopyWithValue,
    Object? timeoutSeconds = unsetCopyWithValue,
    bool? waitForResult,
    Object? customTracingAttributes = unsetCopyWithValue,
  }) {
    return WorkflowExecutionRequest(
      input: input == unsetCopyWithValue
          ? this.input
          : input as Map<String, dynamic>?,
      encodedInput: encodedInput == unsetCopyWithValue
          ? this.encodedInput
          : encodedInput as NetworkEncodedInput?,
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
    if (!mapsDeepEqual(
      customTracingAttributes,
      other.customTracingAttributes,
    )) {
      return false;
    }
    return encodedInput == other.encodedInput &&
        executionId == other.executionId &&
        deploymentName == other.deploymentName &&
        taskQueue == other.taskQueue &&
        timeoutSeconds == other.timeoutSeconds &&
        waitForResult == other.waitForResult;
  }

  @override
  int get hashCode => Object.hash(
    mapDeepHashCode(input),
    encodedInput,
    executionId,
    deploymentName,
    taskQueue,
    timeoutSeconds,
    waitForResult,
    mapDeepHashCode(customTracingAttributes),
  );

  @override
  String toString() =>
      'WorkflowExecutionRequest('
      'input: ${input?.length ?? 'null'}, '
      'encodedInput: $encodedInput, '
      'executionId: $executionId, '
      'deploymentName: $deploymentName, '
      'taskQueue: $taskQueue, '
      'timeoutSeconds: $timeoutSeconds, '
      'waitForResult: $waitForResult, '
      'customTracingAttributes: ${customTracingAttributes?.length ?? 'null'}'
      ')';
}
