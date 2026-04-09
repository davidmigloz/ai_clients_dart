import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_execution_without_result_response.dart';

/// Response containing a list of workflow executions.
@immutable
class WorkflowExecutionListResponse {
  /// The list of executions.
  final List<WorkflowExecutionWithoutResultResponse> executions;

  /// Token for the next page.
  final String? nextPageToken;

  /// Creates a [WorkflowExecutionListResponse].
  WorkflowExecutionListResponse({
    required List<WorkflowExecutionWithoutResultResponse> executions,
    this.nextPageToken,
  }) : executions = List.unmodifiable(executions);

  /// Creates a [WorkflowExecutionListResponse] from JSON.
  factory WorkflowExecutionListResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowExecutionListResponse(
        executions:
            (json['executions'] as List?)
                ?.map(
                  (e) => WorkflowExecutionWithoutResultResponse.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'executions': executions.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionListResponse copyWith({
    List<WorkflowExecutionWithoutResultResponse>? executions,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return WorkflowExecutionListResponse(
      executions: executions ?? this.executions,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(executions, other.executions)) return false;
    return nextPageToken == other.nextPageToken;
  }

  @override
  int get hashCode => Object.hash(listHash(executions), nextPageToken);

  @override
  String toString() =>
      'WorkflowExecutionListResponse(executions: ${executions.length}, nextPageToken: $nextPageToken)';
}
