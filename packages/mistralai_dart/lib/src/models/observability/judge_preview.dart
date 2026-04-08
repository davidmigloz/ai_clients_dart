import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'judge_output_config.dart';

/// Preview of a judge definition.
@immutable
class JudgePreview {
  /// Unique identifier.
  final String id;

  /// When the judge was created.
  final DateTime createdAt;

  /// When the judge was last updated.
  final DateTime updatedAt;

  /// When the judge was deleted (null if active).
  final DateTime? deletedAt;

  /// Owner user ID.
  final String ownerId;

  /// Workspace ID.
  final String workspaceId;

  /// Judge name.
  final String name;

  /// Judge description.
  final String description;

  /// Model name used by the judge.
  final String modelName;

  /// Output configuration (classification or regression).
  final JudgeOutputConfig output;

  /// Evaluation instructions.
  final String instructions;

  /// Tools available to the judge.
  final List<String> tools;

  /// Base revision ID.
  final String? baseRevision;

  /// Up revision ID (newer version).
  final String? upRevision;

  /// Down revision ID (older version).
  final String? downRevision;

  /// Creates a [JudgePreview].
  JudgePreview({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.ownerId,
    required this.workspaceId,
    required this.name,
    required this.description,
    required this.modelName,
    required this.output,
    required this.instructions,
    required List<String> tools,
    this.baseRevision,
    this.upRevision,
    this.downRevision,
  }) : tools = List.unmodifiable(tools);

  /// Creates a [JudgePreview] from JSON.
  factory JudgePreview.fromJson(Map<String, dynamic> json) => JudgePreview(
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
    ownerId: json['owner_id'] as String? ?? '',
    workspaceId: json['workspace_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    modelName: json['model_name'] as String? ?? '',
    output: JudgeOutputConfig.fromJson(
      json['output'] as Map<String, dynamic>? ?? {},
    ),
    instructions: json['instructions'] as String? ?? '',
    tools: (json['tools'] as List?)?.cast<String>() ?? [],
    baseRevision: json['base_revision'] as String?,
    upRevision: json['up_revision'] as String?,
    downRevision: json['down_revision'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'owner_id': ownerId,
    'workspace_id': workspaceId,
    'name': name,
    'description': description,
    'model_name': modelName,
    'output': output.toJson(),
    'instructions': instructions,
    'tools': tools,
    if (baseRevision != null) 'base_revision': baseRevision,
    if (upRevision != null) 'up_revision': upRevision,
    if (downRevision != null) 'down_revision': downRevision,
  };

  /// Creates a copy with replaced values.
  JudgePreview copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? ownerId,
    String? workspaceId,
    String? name,
    String? description,
    String? modelName,
    JudgeOutputConfig? output,
    String? instructions,
    List<String>? tools,
    Object? baseRevision = unsetCopyWithValue,
    Object? upRevision = unsetCopyWithValue,
    Object? downRevision = unsetCopyWithValue,
  }) {
    return JudgePreview(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == unsetCopyWithValue
          ? this.deletedAt
          : deletedAt as DateTime?,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      modelName: modelName ?? this.modelName,
      output: output ?? this.output,
      instructions: instructions ?? this.instructions,
      tools: tools ?? this.tools,
      baseRevision: baseRevision == unsetCopyWithValue
          ? this.baseRevision
          : baseRevision as String?,
      upRevision: upRevision == unsetCopyWithValue
          ? this.upRevision
          : upRevision as String?,
      downRevision: downRevision == unsetCopyWithValue
          ? this.downRevision
          : downRevision as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgePreview) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        ownerId == other.ownerId &&
        workspaceId == other.workspaceId &&
        name == other.name &&
        description == other.description &&
        modelName == other.modelName &&
        output == other.output &&
        instructions == other.instructions &&
        listsEqual(tools, other.tools) &&
        baseRevision == other.baseRevision &&
        upRevision == other.upRevision &&
        downRevision == other.downRevision;
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    workspaceId,
    name,
    description,
    modelName,
    output,
    instructions,
    listHash(tools),
    baseRevision,
    upRevision,
    downRevision,
  );

  @override
  String toString() =>
      'JudgePreview(id: $id, name: $name, modelName: $modelName)';
}
