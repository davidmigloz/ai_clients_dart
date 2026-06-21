import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A registered ingestion pipeline configuration (beta).
///
/// Ingestion pipeline configurations describe how documents are processed and
/// chunked before being indexed for retrieval.
@immutable
class IngestionPipelineConfiguration {
  /// The unique identifier of the configuration.
  final String id;

  /// The identifier of the author that created the configuration.
  final String authorId;

  /// The human-readable name of the configuration.
  final String name;

  /// When the configuration was created.
  final DateTime createdAt;

  /// When the configuration was last modified.
  final DateTime modifiedAt;

  /// When the pipeline was last run, or `null` if it has never run.
  final DateTime? lastRunTime;

  /// The number of chunks produced by the last run.
  final int lastRunChunksCount;

  /// The total number of chunks produced across all runs.
  final int totalChunksCount;

  /// The composition of the pipeline, mapping stage names to component names.
  final Map<String, String>? pipelineComposition;

  /// Creates an [IngestionPipelineConfiguration].
  const IngestionPipelineConfiguration({
    required this.id,
    required this.authorId,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    required this.lastRunTime,
    required this.lastRunChunksCount,
    required this.totalChunksCount,
    required this.pipelineComposition,
  });

  /// Creates an [IngestionPipelineConfiguration] from JSON.
  factory IngestionPipelineConfiguration.fromJson(Map<String, dynamic> json) =>
      IngestionPipelineConfiguration(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        modifiedAt: DateTime.parse(json['modified_at'] as String),
        lastRunTime: json['last_run_time'] != null
            ? DateTime.parse(json['last_run_time'] as String)
            : null,
        lastRunChunksCount: json['last_run_chunks_count'] as int,
        totalChunksCount: json['total_chunks_count'] as int,
        pipelineComposition:
            (json['pipeline_composition'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String),
            ),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'author_id': authorId,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'modified_at': modifiedAt.toIso8601String(),
    'last_run_time': lastRunTime?.toIso8601String(),
    'last_run_chunks_count': lastRunChunksCount,
    'total_chunks_count': totalChunksCount,
    'pipeline_composition': pipelineComposition,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  IngestionPipelineConfiguration copyWith({
    String? id,
    String? authorId,
    String? name,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Object? lastRunTime = unsetCopyWithValue,
    int? lastRunChunksCount,
    int? totalChunksCount,
    Object? pipelineComposition = unsetCopyWithValue,
  }) => IngestionPipelineConfiguration(
    id: id ?? this.id,
    authorId: authorId ?? this.authorId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    lastRunTime: lastRunTime == unsetCopyWithValue
        ? this.lastRunTime
        : lastRunTime as DateTime?,
    lastRunChunksCount: lastRunChunksCount ?? this.lastRunChunksCount,
    totalChunksCount: totalChunksCount ?? this.totalChunksCount,
    pipelineComposition: pipelineComposition == unsetCopyWithValue
        ? this.pipelineComposition
        : pipelineComposition as Map<String, String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestionPipelineConfiguration &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          authorId == other.authorId &&
          name == other.name &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          lastRunTime == other.lastRunTime &&
          lastRunChunksCount == other.lastRunChunksCount &&
          totalChunksCount == other.totalChunksCount &&
          mapsEqual(pipelineComposition, other.pipelineComposition);

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    name,
    createdAt,
    modifiedAt,
    lastRunTime,
    lastRunChunksCount,
    totalChunksCount,
    mapHash(pipelineComposition),
  );

  @override
  String toString() =>
      'IngestionPipelineConfiguration('
      'id: $id, authorId: $authorId, name: $name, '
      'createdAt: $createdAt, modifiedAt: $modifiedAt, '
      'lastRunTime: $lastRunTime, lastRunChunksCount: $lastRunChunksCount, '
      'totalChunksCount: $totalChunksCount, '
      'pipelineComposition: $pipelineComposition)';
}
