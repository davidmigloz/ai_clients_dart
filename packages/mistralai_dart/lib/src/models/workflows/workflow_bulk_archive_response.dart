import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow.dart';
import 'workflow_bulk_error.dart';

/// Response for a bulk archive workflows operation.
@immutable
class WorkflowBulkArchiveResponse {
  /// Workflows that were successfully archived or were already archived.
  final List<Workflow> archived;

  /// Workflows that could not be archived and the corresponding errors.
  final List<WorkflowBulkError>? errored;

  /// Creates a [WorkflowBulkArchiveResponse].
  WorkflowBulkArchiveResponse({
    required List<Workflow> archived,
    List<WorkflowBulkError>? errored,
  }) : archived = List.unmodifiable(archived),
       errored = errored != null ? List.unmodifiable(errored) : null;

  /// Creates a [WorkflowBulkArchiveResponse] from JSON.
  factory WorkflowBulkArchiveResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowBulkArchiveResponse(
        archived:
            (json['archived'] as List?)
                ?.map((e) => Workflow.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        errored: (json['errored'] as List?)
            ?.map((e) => WorkflowBulkError.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'archived': archived.map((e) => e.toJson()).toList(),
    if (errored != null) 'errored': errored?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowBulkArchiveResponse copyWith({
    List<Workflow>? archived,
    Object? errored = unsetCopyWithValue,
  }) {
    return WorkflowBulkArchiveResponse(
      archived: archived ?? this.archived,
      errored: errored == unsetCopyWithValue
          ? this.errored
          : errored as List<WorkflowBulkError>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBulkArchiveResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(archived, other.archived) &&
        listsEqual(errored, other.errored);
  }

  @override
  int get hashCode => Object.hash(listHash(archived), listHash(errored));

  @override
  String toString() =>
      'WorkflowBulkArchiveResponse('
      'archived: ${archived.length}, '
      'errored: ${errored?.length ?? 'null'}'
      ')';
}
