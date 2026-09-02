import 'package:meta/meta.dart';

import 'skill_source.dart';

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

  /// Human-readable, single-line label for the skill. Maximum 255
  /// characters. Always set: derived from the `SKILL.md` frontmatter `name`
  /// when omitted at creation. Not unique.
  final String displayName;

  /// ID of the newest skill version — what `latest` references resolve to.
  ///
  /// Always set: a skill holds at least one version.
  final String latestVersionId;

  /// Where the skill comes from.
  final SkillSource source;

  /// ISO 8601 timestamp of when the skill was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the skill was last updated.
  final DateTime updatedAt;

  /// Object type. Always "skill".
  final String type;

  /// Creates a [Skill].
  const Skill({
    required this.id,
    required this.displayName,
    required this.latestVersionId,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.type = 'skill',
  });

  /// Creates a [Skill] from JSON.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id:
          json['id'] as String? ??
          (throw const FormatException('Skill: missing required "id"')),
      displayName:
          json['display_name'] as String? ??
          (throw const FormatException(
            'Skill: missing required "display_name"',
          )),
      latestVersionId:
          json['latest_version_id'] as String? ??
          (throw const FormatException(
            'Skill: missing required "latest_version_id"',
          )),
      source: json['source'] != null
          ? SkillSource.fromJson(json['source'] as Map<String, dynamic>)
          : (throw const FormatException('Skill: missing required "source"')),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (throw const FormatException(
              'Skill: missing required "created_at"',
            )),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (throw const FormatException(
              'Skill: missing required "updated_at"',
            )),
      type: json['type'] as String? ?? 'skill',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'latest_version_id': latestVersionId,
    'source': source.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'type': type,
  };

  /// Creates a copy with replaced values.
  Skill copyWith({
    String? id,
    String? displayName,
    String? latestVersionId,
    SkillSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
  }) {
    return Skill(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      latestVersionId: latestVersionId ?? this.latestVersionId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          latestVersionId == other.latestVersionId &&
          source == other.source &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          type == other.type;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    latestVersionId,
    source,
    createdAt,
    updatedAt,
    type,
  );

  @override
  String toString() =>
      'Skill('
      'id: $id, '
      'displayName: $displayName, '
      'latestVersionId: $latestVersionId, '
      'source: $source, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'type: $type)';
}
