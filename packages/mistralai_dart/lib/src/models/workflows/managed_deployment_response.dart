import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'deployment_observed_state.dart';
import 'deployment_resource_config.dart';
import 'deployment_worker_spec_response.dart';

/// The live managed service state for a managed workflow deployment.
@immutable
class ManagedDeploymentResponse {
  /// The managed service identifier.
  final String serviceId;

  /// The deployment name.
  final String name;

  /// The worker spec that was deployed.
  final DeploymentWorkerSpecResponse spec;

  /// The resource configuration (CPU/memory/replicas).
  final DeploymentResourceConfig resources;

  /// The observed runtime state.
  final DeploymentObservedState status;

  /// When the deployment was created.
  final String createdAt;

  /// When the deployment was last updated.
  final String updatedAt;

  /// Who created the deployment.
  final String? createdBy;

  /// When the deployment was last (re)deployed.
  final String? deployedAt;

  /// Who last (re)deployed the deployment.
  final String? deployedBy;

  /// The rollout status of the deployment.
  final String? rolloutStatus;

  /// Whether the deployment is stopped.
  final bool stopped;

  /// Who last updated the deployment.
  final String? updatedBy;

  /// Creates a [ManagedDeploymentResponse].
  const ManagedDeploymentResponse({
    required this.serviceId,
    required this.name,
    required this.spec,
    required this.resources,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.deployedAt,
    this.deployedBy,
    this.rolloutStatus,
    this.stopped = false,
    this.updatedBy,
  });

  /// Creates a [ManagedDeploymentResponse] from JSON.
  factory ManagedDeploymentResponse.fromJson(Map<String, dynamic> json) {
    final serviceId = json['service_id'] as String?;
    if (serviceId == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "service_id"',
      );
    }
    final name = json['name'] as String?;
    if (name == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "name"',
      );
    }
    final specJson = json['spec'] as Map<String, dynamic>?;
    if (specJson == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "spec"',
      );
    }
    final resourcesJson = json['resources'] as Map<String, dynamic>?;
    if (resourcesJson == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "resources"',
      );
    }
    final statusJson = json['status'] as Map<String, dynamic>?;
    if (statusJson == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "status"',
      );
    }
    final createdAt = json['created_at'] as String?;
    if (createdAt == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "created_at"',
      );
    }
    final updatedAt = json['updated_at'] as String?;
    if (updatedAt == null) {
      throw const FormatException(
        'ManagedDeploymentResponse: missing required field "updated_at"',
      );
    }
    return ManagedDeploymentResponse(
      serviceId: serviceId,
      name: name,
      spec: DeploymentWorkerSpecResponse.fromJson(specJson),
      resources: DeploymentResourceConfig.fromJson(resourcesJson),
      status: DeploymentObservedState.fromJson(statusJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: json['created_by'] as String?,
      deployedAt: json['deployed_at'] as String?,
      deployedBy: json['deployed_by'] as String?,
      rolloutStatus: json['rollout_status'] as String?,
      stopped: json['stopped'] as bool? ?? false,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'name': name,
    'spec': spec.toJson(),
    'resources': resources.toJson(),
    'status': status.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
    if (createdBy != null) 'created_by': createdBy,
    if (deployedAt != null) 'deployed_at': deployedAt,
    if (deployedBy != null) 'deployed_by': deployedBy,
    if (rolloutStatus != null) 'rollout_status': rolloutStatus,
    'stopped': stopped,
    if (updatedBy != null) 'updated_by': updatedBy,
  };

  /// Creates a copy with replaced values.
  ManagedDeploymentResponse copyWith({
    String? serviceId,
    String? name,
    DeploymentWorkerSpecResponse? spec,
    DeploymentResourceConfig? resources,
    DeploymentObservedState? status,
    String? createdAt,
    String? updatedAt,
    Object? createdBy = unsetCopyWithValue,
    Object? deployedAt = unsetCopyWithValue,
    Object? deployedBy = unsetCopyWithValue,
    Object? rolloutStatus = unsetCopyWithValue,
    bool? stopped,
    Object? updatedBy = unsetCopyWithValue,
  }) {
    return ManagedDeploymentResponse(
      serviceId: serviceId ?? this.serviceId,
      name: name ?? this.name,
      spec: spec ?? this.spec,
      resources: resources ?? this.resources,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy == unsetCopyWithValue
          ? this.createdBy
          : createdBy as String?,
      deployedAt: deployedAt == unsetCopyWithValue
          ? this.deployedAt
          : deployedAt as String?,
      deployedBy: deployedBy == unsetCopyWithValue
          ? this.deployedBy
          : deployedBy as String?,
      rolloutStatus: rolloutStatus == unsetCopyWithValue
          ? this.rolloutStatus
          : rolloutStatus as String?,
      stopped: stopped ?? this.stopped,
      updatedBy: updatedBy == unsetCopyWithValue
          ? this.updatedBy
          : updatedBy as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ManagedDeploymentResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return serviceId == other.serviceId &&
        name == other.name &&
        spec == other.spec &&
        resources == other.resources &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        createdBy == other.createdBy &&
        deployedAt == other.deployedAt &&
        deployedBy == other.deployedBy &&
        rolloutStatus == other.rolloutStatus &&
        stopped == other.stopped &&
        updatedBy == other.updatedBy;
  }

  @override
  int get hashCode => Object.hash(
    serviceId,
    name,
    spec,
    resources,
    status,
    createdAt,
    updatedAt,
    createdBy,
    deployedAt,
    deployedBy,
    Object.hash(rolloutStatus, stopped, updatedBy),
  );

  @override
  String toString() =>
      'ManagedDeploymentResponse('
      'serviceId: $serviceId, '
      'name: $name, '
      'spec: $spec, '
      'resources: $resources, '
      'status: $status, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'createdBy: $createdBy, '
      'deployedAt: $deployedAt, '
      'deployedBy: $deployedBy, '
      'rolloutStatus: $rolloutStatus, '
      'stopped: $stopped, '
      'updatedBy: $updatedBy'
      ')';
}
