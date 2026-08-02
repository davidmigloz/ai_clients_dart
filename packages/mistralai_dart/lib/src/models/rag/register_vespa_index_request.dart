import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'register_vespa_schema_request.dart';

/// Vespa-specific information when registering a RAG search index (beta).
@immutable
class RegisterVespaIndexRequest {
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

  /// The version of Vespa running the instance.
  final String vespaVersion;

  /// The schemas to define within the Vespa index.
  final List<RegisterVespaSchemaRequest> schemas;

  /// The query URL of the Vespa instance.
  final String queryUrl;

  /// Creates a [RegisterVespaIndexRequest].
  const RegisterVespaIndexRequest({
    required this.k8sCluster,
    required this.k8sNamespace,
    required this.vespaInstanceName,
    required this.vespaVersion,
    required this.schemas,
    required this.queryUrl,
  });

  /// Creates a [RegisterVespaIndexRequest] from JSON.
  ///
  /// Throws a [FormatException] if `type` is present and not `"vespa"`.
  factory RegisterVespaIndexRequest.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != null && type != 'vespa') {
      throw FormatException(
        'RegisterVespaIndexRequest: expected type "vespa", got "$type"',
      );
    }
    return RegisterVespaIndexRequest(
      k8sCluster: json['k8s_cluster'] as String,
      k8sNamespace: json['k8s_namespace'] as String,
      vespaInstanceName: json['vespa_instance_name'] as String,
      vespaVersion: json['vespa_version'] as String,
      schemas: (json['schemas'] as List<dynamic>)
          .map(
            (e) =>
                RegisterVespaSchemaRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      queryUrl: json['query_url'] as String,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'k8s_cluster': k8sCluster,
    'k8s_namespace': k8sNamespace,
    'vespa_instance_name': vespaInstanceName,
    'vespa_version': vespaVersion,
    'schemas': schemas.map((e) => e.toJson()).toList(),
    'query_url': queryUrl,
  };

  /// Creates a copy with the given fields replaced.
  RegisterVespaIndexRequest copyWith({
    String? k8sCluster,
    String? k8sNamespace,
    String? vespaInstanceName,
    String? vespaVersion,
    List<RegisterVespaSchemaRequest>? schemas,
    String? queryUrl,
  }) => RegisterVespaIndexRequest(
    k8sCluster: k8sCluster ?? this.k8sCluster,
    k8sNamespace: k8sNamespace ?? this.k8sNamespace,
    vespaInstanceName: vespaInstanceName ?? this.vespaInstanceName,
    vespaVersion: vespaVersion ?? this.vespaVersion,
    schemas: schemas ?? this.schemas,
    queryUrl: queryUrl ?? this.queryUrl,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterVespaIndexRequest &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          k8sCluster == other.k8sCluster &&
          k8sNamespace == other.k8sNamespace &&
          vespaInstanceName == other.vespaInstanceName &&
          vespaVersion == other.vespaVersion &&
          listsEqual(schemas, other.schemas) &&
          queryUrl == other.queryUrl;

  @override
  int get hashCode => Object.hash(
    type,
    k8sCluster,
    k8sNamespace,
    vespaInstanceName,
    vespaVersion,
    listHash(schemas),
    queryUrl,
  );

  @override
  String toString() =>
      'RegisterVespaIndexRequest('
      'type: $type, k8sCluster: $k8sCluster, k8sNamespace: $k8sNamespace, '
      'vespaInstanceName: $vespaInstanceName, vespaVersion: $vespaVersion, '
      'schemas: ${schemas.length} items, queryUrl: $queryUrl)';
}
