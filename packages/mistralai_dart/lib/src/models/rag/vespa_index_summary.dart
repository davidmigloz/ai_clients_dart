import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'vespa_schema_summary.dart';

/// Summary of the Vespa-specific information for a RAG search index (beta).
@immutable
class VespaIndexSummary {
  /// The discriminator value identifying this index as a Vespa index.
  ///
  /// Always `'vespa'`.
  String get type => 'vespa';

  /// The Kubernetes cluster hosting the Vespa instance.
  final String k8sCluster;

  /// The Kubernetes namespace hosting the Vespa instance.
  final String k8sNamespace;

  /// The name of the Vespa instance.
  final String vespaInstanceName;

  /// Summary information about the schemas defined within the index.
  final List<VespaSchemaSummary> schemas;

  /// Creates a [VespaIndexSummary].
  const VespaIndexSummary({
    required this.k8sCluster,
    required this.k8sNamespace,
    required this.vespaInstanceName,
    required this.schemas,
  });

  /// Creates a [VespaIndexSummary] from JSON.
  ///
  /// Throws a [FormatException] if `type` is present and not `"vespa"`.
  factory VespaIndexSummary.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null && type != 'vespa') {
      throw FormatException(
        'VespaIndexSummary: expected type "vespa", got "$type"',
      );
    }
    return VespaIndexSummary(
      k8sCluster: json['k8s_cluster'] as String,
      k8sNamespace: json['k8s_namespace'] as String,
      vespaInstanceName: json['vespa_instance_name'] as String,
      schemas: (json['schemas'] as List<dynamic>)
          .map((e) => VespaSchemaSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'k8s_cluster': k8sCluster,
    'k8s_namespace': k8sNamespace,
    'vespa_instance_name': vespaInstanceName,
    'schemas': schemas.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  VespaIndexSummary copyWith({
    String? k8sCluster,
    String? k8sNamespace,
    String? vespaInstanceName,
    List<VespaSchemaSummary>? schemas,
  }) => VespaIndexSummary(
    k8sCluster: k8sCluster ?? this.k8sCluster,
    k8sNamespace: k8sNamespace ?? this.k8sNamespace,
    vespaInstanceName: vespaInstanceName ?? this.vespaInstanceName,
    schemas: schemas ?? this.schemas,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VespaIndexSummary &&
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
      'VespaIndexSummary('
      'type: $type, k8sCluster: $k8sCluster, k8sNamespace: $k8sNamespace, '
      'vespaInstanceName: $vespaInstanceName, '
      'schemas: ${schemas.length} items)';
}
