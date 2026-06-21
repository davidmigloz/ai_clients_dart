import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_basic_definition.dart';

/// Response listing workflows.
@immutable
class WorkflowListResponse {
  /// The workflows.
  final List<WorkflowBasicDefinition> workflows;

  /// The cursor for the next page, if any.
  final String? nextCursor;

  /// Creates a [WorkflowListResponse].
  WorkflowListResponse({
    required List<WorkflowBasicDefinition> workflows,
    required this.nextCursor,
  }) : workflows = List.unmodifiable(workflows);

  /// Creates a [WorkflowListResponse] from JSON.
  factory WorkflowListResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowListResponse(
        workflows:
            (json['workflows'] as List?)
                ?.map(
                  (e) => WorkflowBasicDefinition.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflows': workflows.map((e) => e.toJson()).toList(),
    'next_cursor': nextCursor,
  };

  /// Creates a copy with replaced values.
  WorkflowListResponse copyWith({
    List<WorkflowBasicDefinition>? workflows,
    Object? nextCursor = unsetCopyWithValue,
  }) {
    return WorkflowListResponse(
      workflows: workflows ?? this.workflows,
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
    return listsEqual(workflows, other.workflows) &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(listHash(workflows), nextCursor);

  @override
  String toString() =>
      'WorkflowListResponse('
      'workflows: ${workflows.length}, '
      'nextCursor: $nextCursor'
      ')';
}
