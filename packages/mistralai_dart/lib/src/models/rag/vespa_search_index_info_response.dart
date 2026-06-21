import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'vespa_schema_response.dart';

/// Vespa-specific information about a RAG search index (beta).
@immutable
class VespaSearchIndexInfoResponse {
  /// The discriminator value identifying this index as a Vespa index.
  ///
  /// Always `'vespa'`.
  final String type;

  /// The Kubernetes cluster hosting the Vespa instance.
  final String k8sCluster;

  /// The Kubernetes namespace hosting the Vespa instance.
  final String k8sNamespace;

  /// The name of the Vespa instance.
  final String vespaInstanceName;

  /// The schemas defined within the Vespa index.
  final List<VespaSchemaResponse> schemas;

  /// Creates a [VespaSearchIndexInfoResponse].
  const VespaSearchIndexInfoResponse({
    this.type = 'vespa',
    required this.k8sCluster,
    required this.k8sNamespace,
    required this.vespaInstanceName,
    required this.schemas,
  });

  /// Creates a [VespaSearchIndexInfoResponse] from JSON.
  factory VespaSearchIndexInfoResponse.fromJson(Map<String, dynamic> json) =>
      VespaSearchIndexInfoResponse(
        type: json['type'] as String? ?? 'vespa',
        k8sCluster: json['k8s_cluster'] as String,
        k8sNamespace: json['k8s_namespace'] as String,
        vespaInstanceName: json['vespa_instance_name'] as String,
        schemas: (json['schemas'] as List<dynamic>)
            .map((e) => VespaSchemaResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'k8s_cluster': k8sCluster,
    'k8s_namespace': k8sNamespace,
    'vespa_instance_name': vespaInstanceName,
    'schemas': schemas.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  VespaSearchIndexInfoResponse copyWith({
    String? type,
    String? k8sCluster,
    String? k8sNamespace,
    String? vespaInstanceName,
    List<VespaSchemaResponse>? schemas,
  }) => VespaSearchIndexInfoResponse(
    type: type ?? this.type,
    k8sCluster: k8sCluster ?? this.k8sCluster,
    k8sNamespace: k8sNamespace ?? this.k8sNamespace,
    vespaInstanceName: vespaInstanceName ?? this.vespaInstanceName,
    schemas: schemas ?? this.schemas,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VespaSearchIndexInfoResponse &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          k8sCluster == other.k8sCluster &&
          k8sNamespace == other.k8sNamespace &&
          vespaInstanceName == other.vespaInstanceName &&
          listsEqual(schemas, other.schemas);

  @override
  int get hashCode => Object.hash(
    type,
    k8sCluster,
    k8sNamespace,
    vespaInstanceName,
    listHash(schemas),
  );

  @override
  String toString() =>
      'VespaSearchIndexInfoResponse('
      'type: $type, k8sCluster: $k8sCluster, k8sNamespace: $k8sNamespace, '
      'vespaInstanceName: $vespaInstanceName, '
      'schemas: ${schemas.length} items)';
}
