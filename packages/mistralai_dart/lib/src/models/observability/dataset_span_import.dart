import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// The ImportDatasetFromSpansRequest wire payload.
@immutable
class ImportDatasetFromSpansRequest {
  /// Creates a [ImportDatasetFromSpansRequest].
  const ImportDatasetFromSpansRequest({
    required this.mappingContract,
    required this.spanReferences,
  });

  /// Versioned rules for mapping span or resource attributes into top-level payload keys.
  final SpanDatasetMappingContract mappingContract;

  /// Spans to attempt to import; unavailable references are skipped, and trace and span IDs are attached as record properties automatically.
  final List<TelemetrySpanReference> spanReferences;

  /// Parses a [ImportDatasetFromSpansRequest] from JSON.
  factory ImportDatasetFromSpansRequest.fromJson(Map<String, dynamic> json) {
    if (json['mapping_contract'] == null) {
      throw const FormatException(
        'ImportDatasetFromSpansRequest: missing mapping_contract',
      );
    }
    if (json['span_references'] == null) {
      throw const FormatException(
        'ImportDatasetFromSpansRequest: missing span_references',
      );
    }
    return ImportDatasetFromSpansRequest(
      mappingContract: SpanDatasetMappingContract.fromJson(
        json['mapping_contract'] as Map<String, dynamic>,
      ),
      spanReferences: (json['span_references'] as List<Object?>)
          .map(
            (item) =>
                TelemetrySpanReference.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'mapping_contract': mappingContract.toJson(),
    'span_references': spanReferences.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ImportDatasetFromSpansRequest copyWith({
    SpanDatasetMappingContract? mappingContract,
    List<TelemetrySpanReference>? spanReferences,
  }) => ImportDatasetFromSpansRequest(
    mappingContract: mappingContract ?? this.mappingContract,
    spanReferences: spanReferences ?? this.spanReferences,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportDatasetFromSpansRequest &&
          runtimeType == other.runtimeType &&
          mappingContract == other.mappingContract &&
          valuesDeepEqual(spanReferences, other.spanReferences);

  @override
  int get hashCode =>
      Object.hashAll([mappingContract, valueDeepHashCode(spanReferences)]);

  @override
  String toString() =>
      'ImportDatasetFromSpansRequest('
      'mappingContract: $mappingContract, '
      'spanReferences: ${spanReferences.length})';
}

/// The SpanDatasetMapping wire payload.
@immutable
class SpanDatasetMapping {
  /// Creates a [SpanDatasetMapping].
  const SpanDatasetMapping({
    required this.sourceField,
    required this.targetField,
  });

  /// The source_field field.
  final SpanDatasetSourceReference sourceField;

  /// Literal top-level key to create in the dataset record payload.
  final String targetField;

  /// Parses a [SpanDatasetMapping] from JSON.
  factory SpanDatasetMapping.fromJson(Map<String, dynamic> json) {
    if (json['source_field'] == null) {
      throw const FormatException('SpanDatasetMapping: missing source_field');
    }
    if (json['target_field'] == null) {
      throw const FormatException('SpanDatasetMapping: missing target_field');
    }
    return SpanDatasetMapping(
      sourceField: SpanDatasetSourceReference.fromJson(
        json['source_field'] as Map<String, dynamic>,
      ),
      targetField: json['target_field'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'source_field': sourceField.toJson(),
    'target_field': targetField,
  };

  /// Creates a copy with the given fields replaced.
  SpanDatasetMapping copyWith({
    SpanDatasetSourceReference? sourceField,
    String? targetField,
  }) => SpanDatasetMapping(
    sourceField: sourceField ?? this.sourceField,
    targetField: targetField ?? this.targetField,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanDatasetMapping &&
          runtimeType == other.runtimeType &&
          sourceField == other.sourceField &&
          targetField == other.targetField;

  @override
  int get hashCode => Object.hashAll([sourceField, targetField]);

  @override
  String toString() =>
      'SpanDatasetMapping('
      'sourceField: $sourceField, '
      'targetField: $targetField)';
}

/// Mapping rules applied independently to every requested telemetry span. Version 1 mappings are optional per span: a missing, null, blank-string, or empty-array source omits the target key. JSON object and array strings become structured values; scalar-looking and malformed JSON strings remain strings.
@immutable
class SpanDatasetMappingContract {
  /// Creates a [SpanDatasetMappingContract].
  const SpanDatasetMappingContract({required this.mappings});

  /// The fixed version discriminator.
  int get version => 1;

  /// The mappings field.
  final List<SpanDatasetMapping> mappings;

  /// Parses a [SpanDatasetMappingContract] from JSON.
  factory SpanDatasetMappingContract.fromJson(Map<String, dynamic> json) {
    if (json['version'] case final value? when value != 1) {
      throw FormatException(
        'SpanDatasetMappingContract: unexpected version $value',
      );
    }
    if (json['mappings'] == null) {
      throw const FormatException(
        'SpanDatasetMappingContract: missing mappings',
      );
    }
    return SpanDatasetMappingContract(
      mappings: (json['mappings'] as List<Object?>)
          .map(
            (item) =>
                SpanDatasetMapping.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'version': version,
    'mappings': mappings.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SpanDatasetMappingContract copyWith({List<SpanDatasetMapping>? mappings}) =>
      SpanDatasetMappingContract(mappings: mappings ?? this.mappings);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanDatasetMappingContract &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(mappings, other.mappings);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(mappings)]);

  @override
  String toString() =>
      'SpanDatasetMappingContract('
      'mappings: ${mappings.length})';
}

/// Values for SpanDatasetSourceNamespace.
enum SpanDatasetSourceNamespace {
  /// Represents span_attributes.
  spanAttributes('span_attributes'),

  /// Represents resource_attributes.
  resourceAttributes('resource_attributes'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SpanDatasetSourceNamespace(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SpanDatasetSourceNamespace fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The SpanDatasetSourceReference wire payload.
@immutable
class SpanDatasetSourceReference {
  /// Creates a [SpanDatasetSourceReference].
  const SpanDatasetSourceReference({
    required this.key,
    required this.namespace,
  });

  /// Literal attribute dictionary key; dots do not denote a nested path.
  final String key;

  /// The namespace field.
  final SpanDatasetSourceNamespace namespace;

  /// Parses a [SpanDatasetSourceReference] from JSON.
  factory SpanDatasetSourceReference.fromJson(Map<String, dynamic> json) {
    if (json['key'] == null) {
      throw const FormatException('SpanDatasetSourceReference: missing key');
    }
    if (json['namespace'] == null) {
      throw const FormatException(
        'SpanDatasetSourceReference: missing namespace',
      );
    }
    return SpanDatasetSourceReference(
      key: json['key'] as String,
      namespace: SpanDatasetSourceNamespace.fromJson(
        json['namespace'] as String,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'key': key,
    'namespace': namespace.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  SpanDatasetSourceReference copyWith({
    String? key,
    SpanDatasetSourceNamespace? namespace,
  }) => SpanDatasetSourceReference(
    key: key ?? this.key,
    namespace: namespace ?? this.namespace,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanDatasetSourceReference &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          namespace == other.namespace;

  @override
  int get hashCode => Object.hashAll([key, namespace]);

  @override
  String toString() =>
      'SpanDatasetSourceReference('
      'key: $key, '
      'namespace: $namespace)';
}

/// Immutable provenance used to identify a telemetry span.
@immutable
class TelemetrySpanReference {
  /// Creates a [TelemetrySpanReference].
  const TelemetrySpanReference({required this.spanId, required this.traceId});

  /// The span_id field.
  final String spanId;

  /// The trace_id field.
  final String traceId;

  /// Parses a [TelemetrySpanReference] from JSON.
  factory TelemetrySpanReference.fromJson(Map<String, dynamic> json) {
    if (json['span_id'] == null) {
      throw const FormatException('TelemetrySpanReference: missing span_id');
    }
    if (json['trace_id'] == null) {
      throw const FormatException('TelemetrySpanReference: missing trace_id');
    }
    return TelemetrySpanReference(
      spanId: json['span_id'] as String,
      traceId: json['trace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'span_id': spanId, 'trace_id': traceId};

  /// Creates a copy with the given fields replaced.
  TelemetrySpanReference copyWith({String? spanId, String? traceId}) =>
      TelemetrySpanReference(
        spanId: spanId ?? this.spanId,
        traceId: traceId ?? this.traceId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetrySpanReference &&
          runtimeType == other.runtimeType &&
          spanId == other.spanId &&
          traceId == other.traceId;

  @override
  int get hashCode => Object.hashAll([spanId, traceId]);

  @override
  String toString() =>
      'TelemetrySpanReference('
      'spanId: $spanId, '
      'traceId: $traceId)';
}
