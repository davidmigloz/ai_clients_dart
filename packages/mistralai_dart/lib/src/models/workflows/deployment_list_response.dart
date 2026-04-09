import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'deployment_response.dart';

/// Response containing a list of deployments.
@immutable
class DeploymentListResponse {
  /// The list of deployments.
  final List<DeploymentResponse> deployments;

  /// Creates a [DeploymentListResponse].
  DeploymentListResponse({required List<DeploymentResponse> deployments})
    : deployments = List.unmodifiable(deployments);

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
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'deployments': deployments.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  DeploymentListResponse copyWith({List<DeploymentResponse>? deployments}) {
    return DeploymentListResponse(deployments: deployments ?? this.deployments);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(deployments, other.deployments)) return false;
    return true;
  }

  @override
  int get hashCode => listHash(deployments);

  @override
  String toString() =>
      'DeploymentListResponse(deployments: ${deployments.length})';
}
