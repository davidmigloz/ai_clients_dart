import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A skill in the Anthropic API.
///
/// Skills are reusable components that can be used to extend Claude's
/// capabilities.
@immutable
class Skill {
  /// Unique identifier for the skill.
  ///
  /// The format and length of IDs may change over time.
  final String id;

  /// Display title for the skill.
  ///
  /// This is a human-readable label that is not included in the prompt
  /// sent to the model.
  final String? displayTitle;

  /// ISO 8601 timestamp of when the skill was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the skill was last updated.
  final DateTime updatedAt;

  /// The latest version identifier for the skill.
  ///
  /// This represents the most recent version of the skill that has been
  /// created.
  final String? latestVersion;

  /// Source of the skill.
  ///
  /// This may be one of the following values:
  /// * `"custom"`: the skill was created by a user
  /// * `"anthropic"`: the skill was created by Anthropic
  final String source;

  /// Object type. Always "skill".
  final String type;

  /// Creates a [Skill].
  const Skill({
    required this.id,
    required this.displayTitle,
    required this.createdAt,
    required this.updatedAt,
    required this.latestVersion,
    required this.source,
    this.type = 'skill',
  });

  /// Creates a [Skill] from JSON.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      displayTitle: json['display_title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      latestVersion: json['latest_version'] as String?,
      source: json['source'] as String,
      type: json['type'] as String? ?? 'skill',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'display_title': displayTitle,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'latest_version': latestVersion,
    'source': source,
    'type': type,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([displayTitle], [latestVersion]), pass the sentinel
  /// value [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  Skill copyWith({
    String? id,
    Object? displayTitle = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? latestVersion = unsetCopyWithValue,
    String? source,
    String? type,
  }) {
    return Skill(
      id: id ?? this.id,
      displayTitle: displayTitle == unsetCopyWithValue
          ? this.displayTitle
          : displayTitle as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latestVersion: latestVersion == unsetCopyWithValue
          ? this.latestVersion
          : latestVersion as String?,
      source: source ?? this.source,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayTitle == other.displayTitle &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          latestVersion == other.latestVersion &&
          source == other.source &&
          type == other.type;

  @override
  int get hashCode => Object.hash(
    id,
    displayTitle,
    createdAt,
    updatedAt,
    latestVersion,
    source,
    type,
  );

  @override
  String toString() =>
      'Skill('
      'id: $id, '
      'displayTitle: $displayTitle, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'latestVersion: $latestVersion, '
      'source: $source, '
      'type: $type)';
}
