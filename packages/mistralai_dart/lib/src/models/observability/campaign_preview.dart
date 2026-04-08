import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'filter_payload.dart';
import 'judge_preview.dart';

/// Preview of an observability campaign.
@immutable
class CampaignPreview {
  /// Unique identifier.
  final String id;

  /// When the campaign was created.
  final DateTime createdAt;

  /// When the campaign was last updated.
  final DateTime updatedAt;

  /// When the campaign was deleted (null if active).
  final DateTime? deletedAt;

  /// Campaign name.
  final String name;

  /// Owner user ID.
  final String ownerId;

  /// Workspace ID.
  final String workspaceId;

  /// Campaign description.
  final String description;

  /// Maximum number of events to evaluate.
  final int maxNbEvents;

  /// Search parameters for selecting events.
  final FilterPayload searchParams;

  /// The judge used for evaluation.
  final JudgePreview judge;

  /// Creates a [CampaignPreview].
  const CampaignPreview({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.ownerId,
    required this.workspaceId,
    required this.description,
    required this.maxNbEvents,
    required this.searchParams,
    required this.judge,
  });

  /// Creates a [CampaignPreview] from JSON.
  factory CampaignPreview.fromJson(Map<String, dynamic> json) =>
      CampaignPreview(
        id: json['id'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        deletedAt: json['deleted_at'] != null
            ? DateTime.tryParse(json['deleted_at'] as String)
            : null,
        name: json['name'] as String? ?? '',
        ownerId: json['owner_id'] as String? ?? '',
        workspaceId: json['workspace_id'] as String? ?? '',
        description: json['description'] as String? ?? '',
        maxNbEvents: json['max_nb_events'] as int? ?? 0,
        searchParams: FilterPayload.fromJson(
          json['search_params'] as Map<String, dynamic>? ?? {},
        ),
        judge: JudgePreview.fromJson(
          json['judge'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'name': name,
    'owner_id': ownerId,
    'workspace_id': workspaceId,
    'description': description,
    'max_nb_events': maxNbEvents,
    'search_params': searchParams.toJson(),
    'judge': judge.toJson(),
  };

  /// Creates a copy with replaced values.
  CampaignPreview copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? name,
    String? ownerId,
    String? workspaceId,
    String? description,
    int? maxNbEvents,
    FilterPayload? searchParams,
    JudgePreview? judge,
  }) {
    return CampaignPreview(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == unsetCopyWithValue
          ? this.deletedAt
          : deletedAt as DateTime?,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      description: description ?? this.description,
      maxNbEvents: maxNbEvents ?? this.maxNbEvents,
      searchParams: searchParams ?? this.searchParams,
      judge: judge ?? this.judge,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CampaignPreview) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        name == other.name &&
        ownerId == other.ownerId &&
        workspaceId == other.workspaceId &&
        description == other.description &&
        maxNbEvents == other.maxNbEvents &&
        searchParams == other.searchParams &&
        judge == other.judge;
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    ownerId,
    workspaceId,
    description,
    maxNbEvents,
    searchParams,
    judge,
  );

  @override
  String toString() =>
      'CampaignPreview(id: $id, name: $name, '
      'maxNbEvents: $maxNbEvents)';
}
