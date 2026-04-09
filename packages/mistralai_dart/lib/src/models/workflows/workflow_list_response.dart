import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_basic_definition.dart';

/// Response containing a list of workflows.
@immutable
class WorkflowListResponse {
  /// The list of workflows.
  final List<WorkflowBasicDefinition>? workflows;

  /// Cursor for the next page.
  final String? nextCursor;

  /// Creates a [WorkflowListResponse].
  WorkflowListResponse({
    List<WorkflowBasicDefinition>? workflows,
    required this.nextCursor,
  }) : workflows = workflows != null ? List.unmodifiable(workflows) : null;

  /// Creates a [WorkflowListResponse] from JSON.
  factory WorkflowListResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowListResponse(
        workflows: (json['workflows'] as List?)
            ?.map(
              (e) =>
                  WorkflowBasicDefinition.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (workflows != null)
      'workflows': workflows?.map((e) => e.toJson()).toList(),
    'next_cursor': nextCursor,
  };

  /// Creates a copy with replaced values.
  WorkflowListResponse copyWith({
    Object? workflows = unsetCopyWithValue,
    Object? nextCursor = unsetCopyWithValue,
  }) {
    return WorkflowListResponse(
      workflows: workflows == unsetCopyWithValue
          ? this.workflows
          : workflows as List<WorkflowBasicDefinition>?,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(workflows, other.workflows)) return false;
    return nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(listHash(workflows), nextCursor);

  @override
  String toString() =>
      'WorkflowListResponse(workflows: ${workflows?.length ?? 'null'}, nextCursor: $nextCursor)';
}
