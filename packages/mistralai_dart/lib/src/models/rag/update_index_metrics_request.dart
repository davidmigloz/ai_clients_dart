import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'schema_metrics.dart';

/// Sealed class for the request body when updating a RAG search index's
/// metrics (beta).
///
/// Subtypes:
/// - [UpdateIndexMetricsOnlineRequest]: sets document counts while the index
///   is online.
/// - [UpdateIndexMetricsOfflineRequest]: clears (or leaves) metrics while the
///   index is offline.
sealed class UpdateIndexMetricsRequest {
  const UpdateIndexMetricsRequest();

  /// The status discriminator of this request.
  String get status;

  /// Creates an [UpdateIndexMetricsRequest] from JSON.
  factory UpdateIndexMetricsRequest.fromJson(Map<String, dynamic> json) {
    return switch (json['status']) {
      'online' => UpdateIndexMetricsOnlineRequest.fromJson(json),
      'offline' => UpdateIndexMetricsOfflineRequest.fromJson(json),
      _ => throw FormatException('Unknown status: ${json['status']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Sets document metrics for a RAG search index while it is online.
@immutable
class UpdateIndexMetricsOnlineRequest extends UpdateIndexMetricsRequest {
  @override
  String get status => 'online';

  /// The total number of documents across all schemas.
  final int documentCount;

  /// Per-schema document metrics.
  final List<SchemaMetrics> schemaMetrics;

  /// Creates an [UpdateIndexMetricsOnlineRequest].
  const UpdateIndexMetricsOnlineRequest({
    required this.documentCount,
    required this.schemaMetrics,
  });

  /// Creates an [UpdateIndexMetricsOnlineRequest] from JSON.
  factory UpdateIndexMetricsOnlineRequest.fromJson(Map<String, dynamic> json) =>
      UpdateIndexMetricsOnlineRequest(
        documentCount: json['document_count'] as int,
        schemaMetrics: (json['schema_metrics'] as List<dynamic>)
            .map((e) => SchemaMetrics.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'status': status,
    'document_count': documentCount,
    'schema_metrics': schemaMetrics.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  UpdateIndexMetricsOnlineRequest copyWith({
    int? documentCount,
    List<SchemaMetrics>? schemaMetrics,
  }) => UpdateIndexMetricsOnlineRequest(
    documentCount: documentCount ?? this.documentCount,
    schemaMetrics: schemaMetrics ?? this.schemaMetrics,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateIndexMetricsOnlineRequest &&
          runtimeType == other.runtimeType &&
          documentCount == other.documentCount &&
          listsEqual(schemaMetrics, other.schemaMetrics);

  @override
  int get hashCode =>
      Object.hash(status, documentCount, listHash(schemaMetrics));

  @override
  String toString() =>
      'UpdateIndexMetricsOnlineRequest('
      'documentCount: $documentCount, '
      'schemaMetrics: ${schemaMetrics.length} items)';
}

/// Sets (or clears) metrics for a RAG search index while it is offline.
@immutable
class UpdateIndexMetricsOfflineRequest extends UpdateIndexMetricsRequest {
  @override
  String get status => 'offline';

  /// Whether to clear the existing metrics.
  ///
  /// Defaults to `false`.
  final bool clearMetrics;

  /// Creates an [UpdateIndexMetricsOfflineRequest].
  const UpdateIndexMetricsOfflineRequest({this.clearMetrics = false});

  /// Creates an [UpdateIndexMetricsOfflineRequest] from JSON.
  factory UpdateIndexMetricsOfflineRequest.fromJson(
    Map<String, dynamic> json,
  ) => UpdateIndexMetricsOfflineRequest(
    clearMetrics: json['clear_metrics'] as bool? ?? false,
  );

  @override
  Map<String, dynamic> toJson() => {
    'status': status,
    'clear_metrics': clearMetrics,
  };

  /// Creates a copy with the given fields replaced.
  UpdateIndexMetricsOfflineRequest copyWith({bool? clearMetrics}) =>
      UpdateIndexMetricsOfflineRequest(
        clearMetrics: clearMetrics ?? this.clearMetrics,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateIndexMetricsOfflineRequest &&
          runtimeType == other.runtimeType &&
          clearMetrics == other.clearMetrics;

  @override
  int get hashCode => Object.hash(status, clearMetrics);

  @override
  String toString() =>
      'UpdateIndexMetricsOfflineRequest(clearMetrics: $clearMetrics)';
}
