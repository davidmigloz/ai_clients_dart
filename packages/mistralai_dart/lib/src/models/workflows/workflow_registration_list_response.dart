import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_registration.dart';

/// Response containing a list of workflow registrations.
@immutable
class WorkflowRegistrationListResponse {
  /// The list of registrations.
  final List<WorkflowRegistration> workflowRegistrations;

  /// Cursor for the next page.
  final String? nextCursor;

  /// The list of workflow versions.
  final List<WorkflowRegistration> workflowVersions;

  /// Creates a [WorkflowRegistrationListResponse].
  WorkflowRegistrationListResponse({
    required List<WorkflowRegistration> workflowRegistrations,
    required this.nextCursor,
    required List<WorkflowRegistration> workflowVersions,
  }) : workflowRegistrations = List.unmodifiable(workflowRegistrations),
       workflowVersions = List.unmodifiable(workflowVersions);

  /// Creates a [WorkflowRegistrationListResponse] from JSON.
  factory WorkflowRegistrationListResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowRegistrationListResponse(
    workflowRegistrations:
        (json['workflow_registrations'] as List?)
            ?.map(
              (e) => WorkflowRegistration.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    nextCursor: json['next_cursor'] as String?,
    workflowVersions:
        (json['workflow_versions'] as List?)
            ?.map(
              (e) => WorkflowRegistration.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow_registrations': workflowRegistrations
        .map((e) => e.toJson())
        .toList(),
    'next_cursor': nextCursor,
    'workflow_versions': workflowVersions.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowRegistrationListResponse copyWith({
    List<WorkflowRegistration>? workflowRegistrations,
    Object? nextCursor = unsetCopyWithValue,
    List<WorkflowRegistration>? workflowVersions,
  }) {
    return WorkflowRegistrationListResponse(
      workflowRegistrations:
          workflowRegistrations ?? this.workflowRegistrations,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
      workflowVersions: workflowVersions ?? this.workflowVersions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowRegistrationListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(workflowRegistrations, other.workflowRegistrations)) {
      return false;
    }
    if (!listsEqual(workflowVersions, other.workflowVersions)) return false;
    return nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(
    listHash(workflowRegistrations),
    nextCursor,
    listHash(workflowVersions),
  );

  @override
  String toString() =>
      'WorkflowRegistrationListResponse(workflowRegistrations: ${workflowRegistrations.length}, nextCursor: $nextCursor, workflowVersions: ${workflowVersions.length})';
}
