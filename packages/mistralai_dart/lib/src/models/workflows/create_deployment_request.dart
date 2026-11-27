import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_resource_config.dart';
import 'deployment_worker_spec_input.dart';

/// Request body for creating a managed workflow deployment.
@immutable
class CreateDeploymentRequest {
  /// The deployment name.
  final String name;

  /// The worker spec to build and run.
  final DeploymentWorkerSpecInput spec;

  /// Optional worker replica count.
  final DeploymentResourceConfig? resources;

  /// Whether to create the deployment with a separate runtime credential.
  final bool? hardened;

  /// Creates a [CreateDeploymentRequest].
  const CreateDeploymentRequest({
    this.hardened,
    required this.name,
    required this.spec,
    this.resources,
  });

  /// Creates a [CreateDeploymentRequest] from JSON.
  factory CreateDeploymentRequest.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    if (name == null) {
      throw const FormatException(
        'CreateDeploymentRequest: missing required field "name"',
      );
    }
    final specJson = json['spec'] as Map<String, dynamic>?;
    if (specJson == null) {
      throw const FormatException(
        'CreateDeploymentRequest: missing required field "spec"',
      );
    }
    return CreateDeploymentRequest(
      hardened: json['hardened'] as bool?,
      name: name,
      spec: DeploymentWorkerSpecInput.fromJson(specJson),
      resources: json['resources'] != null
          ? DeploymentResourceConfig.fromJson(
              json['resources'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (hardened != null) 'hardened': hardened,
    'name': name,
    'spec': spec.toJson(),
    if (resources != null)
      'resources': {
        if (resources!.replicas != null) 'replicas': resources!.replicas,
      },
  };

  /// Creates a copy with replaced values.
  CreateDeploymentRequest copyWith({
    Object? hardened = unsetCopyWithValue,
    String? name,
    DeploymentWorkerSpecInput? spec,
    Object? resources = unsetCopyWithValue,
  }) {
    return CreateDeploymentRequest(
      hardened: hardened == unsetCopyWithValue
          ? this.hardened
          : hardened as bool?,
      name: name ?? this.name,
      spec: spec ?? this.spec,
      resources: resources == unsetCopyWithValue
          ? this.resources
          : resources as DeploymentResourceConfig?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateDeploymentRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return hardened == other.hardened &&
        name == other.name &&
        spec == other.spec &&
        resources == other.resources;
  }

  @override
  int get hashCode => Object.hashAll([name, spec, resources, hardened]);

  @override
  String toString() =>
      'CreateDeploymentRequest(hardened: $hardened, '
      'name: $name, '
      'spec: $spec, '
      'resources: $resources'
      ')';
}
