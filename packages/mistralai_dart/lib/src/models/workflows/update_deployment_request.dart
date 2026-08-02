import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_resource_config_update.dart';
import 'workflows_worker_spec_update.dart';

/// Request body for partially updating a managed workflow deployment.
///
/// All fields are optional; only the provided fields are updated.
@immutable
class UpdateDeploymentRequest {
  /// The resource configuration fields to update.
  final DeploymentResourceConfigUpdate? resources;

  /// The worker spec fields to update.
  final WorkflowsWorkerSpecUpdate? spec;

  /// Creates an [UpdateDeploymentRequest].
  const UpdateDeploymentRequest({this.resources, this.spec});

  /// Creates an [UpdateDeploymentRequest] from JSON.
  factory UpdateDeploymentRequest.fromJson(Map<String, dynamic> json) =>
      UpdateDeploymentRequest(
        resources: json['resources'] != null
            ? DeploymentResourceConfigUpdate.fromJson(
                json['resources'] as Map<String, dynamic>,
              )
            : null,
        spec: json['spec'] != null
            ? WorkflowsWorkerSpecUpdate.fromJson(
                json['spec'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (resources != null) 'resources': resources!.toJson(),
    if (spec != null) 'spec': spec!.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  UpdateDeploymentRequest copyWith({
    Object? resources = unsetCopyWithValue,
    Object? spec = unsetCopyWithValue,
  }) {
    return UpdateDeploymentRequest(
      resources: resources == unsetCopyWithValue
          ? this.resources
          : resources as DeploymentResourceConfigUpdate?,
      spec: spec == unsetCopyWithValue
          ? this.spec
          : spec as WorkflowsWorkerSpecUpdate?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDeploymentRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return resources == other.resources && spec == other.spec;
  }

  @override
  int get hashCode => Object.hash(resources, spec);

  @override
  String toString() =>
      'UpdateDeploymentRequest(resources: $resources, spec: $spec)';
}
