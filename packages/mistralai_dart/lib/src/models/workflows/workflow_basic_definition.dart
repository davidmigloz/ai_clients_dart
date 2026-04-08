import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow_metadata.dart';

/// Basic workflow definition.
@immutable
class WorkflowBasicDefinition {
  /// The workflow identifier.
  final String id;

  /// The workflow name.
  final String name;

  /// The display name.
  final String displayName;

  /// Whether the workflow is archived.
  final bool archived;

  /// The workflow description.
  final String? description;

  /// Workflow metadata.
  final WorkflowMetadata? metadata;

  /// Creates a [WorkflowBasicDefinition].
  const WorkflowBasicDefinition({
    required this.id,
    required this.name,
    required this.displayName,
    required this.archived,
    this.description,
    this.metadata,
  });

  /// Creates a [WorkflowBasicDefinition] from JSON.
  factory WorkflowBasicDefinition.fromJson(Map<String, dynamic> json) =>
      WorkflowBasicDefinition(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        archived: json['archived'] as bool? ?? false,
        description: json['description'] as String?,
        metadata: json['metadata'] != null
            ? WorkflowMetadata.fromJson(
                json['metadata'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'display_name': displayName,
    'archived': archived,
    if (description != null) 'description': description,
    if (metadata != null) 'metadata': metadata?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowBasicDefinition copyWith({
    String? id,
    String? name,
    String? displayName,
    bool? archived,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return WorkflowBasicDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      archived: archived ?? this.archived,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as WorkflowMetadata?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBasicDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        name == other.name &&
        displayName == other.displayName &&
        archived == other.archived &&
        description == other.description &&
        metadata == other.metadata;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, displayName, archived, description, metadata);

  @override
  String toString() =>
      'WorkflowBasicDefinition('
      'id: $id, '
      'name: $name, '
      'displayName: $displayName, '
      'archived: $archived, '
      'description: $description, '
      'metadata: $metadata'
      ')';
}
