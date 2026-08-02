import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_resource_config_update.dart';
import 'workflows_worker_spec_update.dart';

/// Request body for partially updating a managed workflow deployment.
///
/// All fields are optional; only the provided fields are updated. Each field
/// distinguishes three states: omit it (and its `clearX` flag) to leave the
/// current value unchanged, pass a value to replace it, or pass
/// `clearX: true` (with the value left `null`) to explicitly reset it to
/// `null` server-side. Passing both a non-null value and its `clearX: true`
/// flag is a contradiction and asserts.
@immutable
class UpdateDeploymentRequest {
  /// The resource configuration fields to update.
  ///
  /// Leave both this and [clearResources] at their defaults to preserve the
  /// current value; set this to replace it; or pass `clearResources: true`
  /// (leaving this `null`) to clear it.
  final DeploymentResourceConfigUpdate? resources;

  /// Whether to emit an explicit JSON `null` for `resources`, clearing it.
  ///
  /// Must not be `true` while [resources] is also non-null.
  final bool clearResources;

  /// The worker spec fields to update.
  ///
  /// Leave both this and [clearSpec] at their defaults to preserve the
  /// current value; set this to replace it; or pass `clearSpec: true`
  /// (leaving this `null`) to clear it.
  final WorkflowsWorkerSpecUpdate? spec;

  /// Whether to emit an explicit JSON `null` for `spec`, clearing it.
  ///
  /// Must not be `true` while [spec] is also non-null.
  final bool clearSpec;

  /// Creates an [UpdateDeploymentRequest].
  ///
  /// Asserts that a `clearX` flag is not `true` while its corresponding
  /// value is also non-null.
  const UpdateDeploymentRequest({
    this.resources,
    this.clearResources = false,
    this.spec,
    this.clearSpec = false,
  }) : assert(
         !(clearResources && resources != null),
         'Cannot set both resources and clearResources: true.',
       ),
       assert(
         !(clearSpec && spec != null),
         'Cannot set both spec and clearSpec: true.',
       );

  /// Creates an [UpdateDeploymentRequest] from JSON.
  factory UpdateDeploymentRequest.fromJson(Map<String, dynamic> json) =>
      UpdateDeploymentRequest(
        resources: json['resources'] != null
            ? DeploymentResourceConfigUpdate.fromJson(
                json['resources'] as Map<String, dynamic>,
              )
            : null,
        clearResources:
            json.containsKey('resources') && json['resources'] == null,
        spec: json['spec'] != null
            ? WorkflowsWorkerSpecUpdate.fromJson(
                json['spec'] as Map<String, dynamic>,
              )
            : null,
        clearSpec: json.containsKey('spec') && json['spec'] == null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (resources != null)
      'resources': resources!.toJson()
    else if (clearResources)
      'resources': null,
    if (spec != null) 'spec': spec!.toJson() else if (clearSpec) 'spec': null,
  };

  /// Creates a copy with replaced values.
  ///
  /// Omit a field to preserve its current value (including whether it is
  /// currently marked for clearing). Pass a value to replace it. Pass the
  /// matching `clearX: true` to clear a field (this also resets the value to
  /// `null` so the result stays internally consistent), or `clearX: false`
  /// to return a cleared field to the omitted / no-change state.
  UpdateDeploymentRequest copyWith({
    Object? resources = unsetCopyWithValue,
    bool? clearResources,
    Object? spec = unsetCopyWithValue,
    bool? clearSpec,
  }) {
    final resourcesSet = resources != unsetCopyWithValue;
    final specSet = spec != unsetCopyWithValue;
    return UpdateDeploymentRequest(
      resources: resourcesSet
          ? resources as DeploymentResourceConfigUpdate?
          : ((clearResources ?? false) ? null : this.resources),
      clearResources:
          clearResources ??
          (resourcesSet ? resources == null : this.clearResources),
      spec: specSet
          ? spec as WorkflowsWorkerSpecUpdate?
          : ((clearSpec ?? false) ? null : this.spec),
      clearSpec: clearSpec ?? (specSet ? spec == null : this.clearSpec),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDeploymentRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return resources == other.resources &&
        clearResources == other.clearResources &&
        spec == other.spec &&
        clearSpec == other.clearSpec;
  }

  @override
  int get hashCode => Object.hash(resources, clearResources, spec, clearSpec);

  @override
  String toString() =>
      'UpdateDeploymentRequest(resources: $resources, '
      'clearResources: $clearResources, spec: $spec, clearSpec: $clearSpec)';
}
