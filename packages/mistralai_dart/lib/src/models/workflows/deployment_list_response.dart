import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'deployment_response.dart';

/// Response containing a list of deployments.
@immutable
class DeploymentListResponse {
  /// The list of deployments.
  final List<DeploymentResponse> deployments;

  /// The cursor for the next page.
  final String? nextCursor;

  /// The workspace identifier.
  final String workspaceId;

  /// Creates a [DeploymentListResponse].
  DeploymentListResponse({
    required List<DeploymentResponse> deployments,
    required this.nextCursor,
    required this.workspaceId,
  }) : deployments = List.unmodifiable(deployments);

  /// Creates a [DeploymentListResponse] from JSON.
  factory DeploymentListResponse.fromJson(Map<String, dynamic> json) =>
      DeploymentListResponse(
        deployments:
            (json['deployments'] as List?)
                ?.map(
                  (e) => DeploymentResponse.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        nextCursor: json['next_cursor'] as String?,
        workspaceId: json['workspace_id'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'deployments': deployments.map((e) => e.toJson()).toList(),
    'next_cursor': nextCursor,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  DeploymentListResponse copyWith({
    List<DeploymentResponse>? deployments,
    Object? nextCursor = unsetCopyWithValue,
    String? workspaceId,
  }) {
    return DeploymentListResponse(
      deployments: deployments ?? this.deployments,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(deployments, other.deployments)) return false;
    return nextCursor == other.nextCursor && workspaceId == other.workspaceId;
  }

  @override
  int get hashCode =>
      Object.hash(listHash(deployments), nextCursor, workspaceId);

  @override
  String toString() =>
      'DeploymentListResponse('
      'deployments: ${deployments.length}, '
      'nextCursor: $nextCursor, '
      'workspaceId: $workspaceId'
      ')';
}
