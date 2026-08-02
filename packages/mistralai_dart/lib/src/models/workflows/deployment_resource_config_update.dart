import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Partial resource configuration update (CPU/memory/replicas) for a managed
/// deployment.
///
/// All fields are optional; only the provided fields are updated.
@immutable
class DeploymentResourceConfigUpdate {
  /// The CPU limit (e.g. `1`, `500m`).
  final String? cpuLimit;

  /// The CPU request (e.g. `1`, `500m`).
  final String? cpuRequest;

  /// The memory limit (e.g. `1Gi`, `512Mi`).
  final String? memoryLimit;

  /// The memory request (e.g. `1Gi`, `512Mi`).
  final String? memoryRequest;

  /// The number of replicas.
  final int? replicas;

  /// Creates a [DeploymentResourceConfigUpdate].
  const DeploymentResourceConfigUpdate({
    this.cpuLimit,
    this.cpuRequest,
    this.memoryLimit,
    this.memoryRequest,
    this.replicas,
  });

  /// Creates a [DeploymentResourceConfigUpdate] from JSON.
  factory DeploymentResourceConfigUpdate.fromJson(Map<String, dynamic> json) =>
      DeploymentResourceConfigUpdate(
        cpuLimit: json['cpu_limit'] as String?,
        cpuRequest: json['cpu_request'] as String?,
        memoryLimit: json['memory_limit'] as String?,
        memoryRequest: json['memory_request'] as String?,
        replicas: json['replicas'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (cpuLimit != null) 'cpu_limit': cpuLimit,
    if (cpuRequest != null) 'cpu_request': cpuRequest,
    if (memoryLimit != null) 'memory_limit': memoryLimit,
    if (memoryRequest != null) 'memory_request': memoryRequest,
    if (replicas != null) 'replicas': replicas,
  };

  /// Creates a copy with replaced values.
  DeploymentResourceConfigUpdate copyWith({
    Object? cpuLimit = unsetCopyWithValue,
    Object? cpuRequest = unsetCopyWithValue,
    Object? memoryLimit = unsetCopyWithValue,
    Object? memoryRequest = unsetCopyWithValue,
    Object? replicas = unsetCopyWithValue,
  }) {
    return DeploymentResourceConfigUpdate(
      cpuLimit: cpuLimit == unsetCopyWithValue
          ? this.cpuLimit
          : cpuLimit as String?,
      cpuRequest: cpuRequest == unsetCopyWithValue
          ? this.cpuRequest
          : cpuRequest as String?,
      memoryLimit: memoryLimit == unsetCopyWithValue
          ? this.memoryLimit
          : memoryLimit as String?,
      memoryRequest: memoryRequest == unsetCopyWithValue
          ? this.memoryRequest
          : memoryRequest as String?,
      replicas: replicas == unsetCopyWithValue
          ? this.replicas
          : replicas as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentResourceConfigUpdate) return false;
    if (runtimeType != other.runtimeType) return false;
    return cpuLimit == other.cpuLimit &&
        cpuRequest == other.cpuRequest &&
        memoryLimit == other.memoryLimit &&
        memoryRequest == other.memoryRequest &&
        replicas == other.replicas;
  }

  @override
  int get hashCode =>
      Object.hash(cpuLimit, cpuRequest, memoryLimit, memoryRequest, replicas);

  @override
  String toString() =>
      'DeploymentResourceConfigUpdate('
      'cpuLimit: $cpuLimit, '
      'cpuRequest: $cpuRequest, '
      'memoryLimit: $memoryLimit, '
      'memoryRequest: $memoryRequest, '
      'replicas: $replicas'
      ')';
}
