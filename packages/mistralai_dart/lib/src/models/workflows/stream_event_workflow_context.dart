import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Workflow context in a stream event.
@immutable
class StreamEventWorkflowContext {
  /// The namespace.
  final String namespace;

  /// The workflow name.
  final String workflowName;

  /// The workflow execution ID.
  final String workflowExecId;

  /// The root workflow execution ID.
  final String? rootWorkflowExecId;

  /// The parent workflow execution ID.
  final String? parentWorkflowExecId;

  /// Creates a [StreamEventWorkflowContext].
  const StreamEventWorkflowContext({
    required this.namespace,
    required this.workflowName,
    required this.workflowExecId,
    this.rootWorkflowExecId,
    this.parentWorkflowExecId,
  });

  /// Creates a [StreamEventWorkflowContext] from JSON.
  factory StreamEventWorkflowContext.fromJson(Map<String, dynamic> json) =>
      StreamEventWorkflowContext(
        namespace: json['namespace'] as String? ?? '',
        workflowName: json['workflow_name'] as String? ?? '',
        workflowExecId: json['workflow_exec_id'] as String? ?? '',
        rootWorkflowExecId: json['root_workflow_exec_id'] as String?,
        parentWorkflowExecId: json['parent_workflow_exec_id'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'namespace': namespace,
    'workflow_name': workflowName,
    'workflow_exec_id': workflowExecId,
    if (rootWorkflowExecId != null) 'root_workflow_exec_id': rootWorkflowExecId,
    if (parentWorkflowExecId != null)
      'parent_workflow_exec_id': parentWorkflowExecId,
  };

  /// Creates a copy with replaced values.
  StreamEventWorkflowContext copyWith({
    String? namespace,
    String? workflowName,
    String? workflowExecId,
    Object? rootWorkflowExecId = unsetCopyWithValue,
    Object? parentWorkflowExecId = unsetCopyWithValue,
  }) {
    return StreamEventWorkflowContext(
      namespace: namespace ?? this.namespace,
      workflowName: workflowName ?? this.workflowName,
      workflowExecId: workflowExecId ?? this.workflowExecId,
      rootWorkflowExecId: rootWorkflowExecId == unsetCopyWithValue
          ? this.rootWorkflowExecId
          : rootWorkflowExecId as String?,
      parentWorkflowExecId: parentWorkflowExecId == unsetCopyWithValue
          ? this.parentWorkflowExecId
          : parentWorkflowExecId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreamEventWorkflowContext) return false;
    if (runtimeType != other.runtimeType) return false;
    return namespace == other.namespace &&
        workflowName == other.workflowName &&
        workflowExecId == other.workflowExecId &&
        rootWorkflowExecId == other.rootWorkflowExecId &&
        parentWorkflowExecId == other.parentWorkflowExecId;
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    workflowName,
    workflowExecId,
    rootWorkflowExecId,
    parentWorkflowExecId,
  );

  @override
  String toString() =>
      'StreamEventWorkflowContext('
      'namespace: $namespace, '
      'workflowName: $workflowName, '
      'workflowExecId: $workflowExecId, '
      'rootWorkflowExecId: $rootWorkflowExecId, '
      'parentWorkflowExecId: $parentWorkflowExecId'
      ')';
}
