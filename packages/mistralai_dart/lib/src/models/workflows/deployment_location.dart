import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'location_type.dart';

/// Describes where a deployment runs.
@immutable
class DeploymentLocation {
  /// Where the deployment runs: `local` or `k8s`.
  final LocationType locationType;

  /// K8s cluster name, if applicable.
  final String? k8sCluster;

  /// K8s namespace, if applicable.
  final String? k8sNamespace;

  /// Creates a [DeploymentLocation].
  const DeploymentLocation({
    required this.locationType,
    this.k8sCluster,
    this.k8sNamespace,
  });

  /// Creates a [DeploymentLocation] from JSON.
  factory DeploymentLocation.fromJson(Map<String, dynamic> json) =>
      DeploymentLocation(
        locationType: LocationType.fromJson(json['location_type'] as String?),
        k8sCluster: json['k8s_cluster'] as String?,
        k8sNamespace: json['k8s_namespace'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'location_type': locationType.toJson(),
    if (k8sCluster != null) 'k8s_cluster': k8sCluster,
    if (k8sNamespace != null) 'k8s_namespace': k8sNamespace,
  };

  /// Creates a copy with replaced values.
  DeploymentLocation copyWith({
    LocationType? locationType,
    Object? k8sCluster = unsetCopyWithValue,
    Object? k8sNamespace = unsetCopyWithValue,
  }) {
    return DeploymentLocation(
      locationType: locationType ?? this.locationType,
      k8sCluster: k8sCluster == unsetCopyWithValue
          ? this.k8sCluster
          : k8sCluster as String?,
      k8sNamespace: k8sNamespace == unsetCopyWithValue
          ? this.k8sNamespace
          : k8sNamespace as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentLocation) return false;
    if (runtimeType != other.runtimeType) return false;
    return locationType == other.locationType &&
        k8sCluster == other.k8sCluster &&
        k8sNamespace == other.k8sNamespace;
  }

  @override
  int get hashCode => Object.hash(locationType, k8sCluster, k8sNamespace);

  @override
  String toString() =>
      'DeploymentLocation('
      'locationType: $locationType, '
      'k8sCluster: $k8sCluster, '
      'k8sNamespace: $k8sNamespace'
      ')';
}
