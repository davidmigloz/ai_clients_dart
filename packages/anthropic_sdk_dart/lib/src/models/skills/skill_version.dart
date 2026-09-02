import 'package:meta/meta.dart';

/// A version of a skill in the Anthropic API.
@immutable
class SkillVersion {
  /// Unique identifier for this skill version. The id addresses the version
  /// in paths and pins it in references.
  final String id;

  /// Identifier for the skill that this version belongs to.
  final String skillId;

  /// The skill's immutable kebab-case slug, set at creation from the first
  /// upload's `SKILL.md` frontmatter `name` (or its enclosing directory).
  ///
  /// Every later upload must resolve to the same value. Also the top-level
  /// directory of the skill's mounted files and the base name of a
  /// downloaded archive.
  final String name;

  /// Description of the skill version.
  ///
  /// This is extracted from the `SKILL.md` file in the skill upload.
  final String description;

  /// ISO 8601 timestamp of when the skill version was created.
  final DateTime createdAt;

  /// Object type. Always "skill_version".
  final String type;

  /// Creates a [SkillVersion].
  const SkillVersion({
    required this.id,
    required this.skillId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.type = 'skill_version',
  });

  /// Creates a [SkillVersion] from JSON.
  factory SkillVersion.fromJson(Map<String, dynamic> json) {
    return SkillVersion(
      id:
          json['id'] as String? ??
          (throw const FormatException('SkillVersion: missing required "id"')),
      skillId:
          json['skill_id'] as String? ??
          (throw const FormatException(
            'SkillVersion: missing required "skill_id"',
          )),
      name:
          json['name'] as String? ??
          (throw const FormatException(
            'SkillVersion: missing required "name"',
          )),
      description:
          json['description'] as String? ??
          (throw const FormatException(
            'SkillVersion: missing required "description"',
          )),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (throw const FormatException(
              'SkillVersion: missing required "created_at"',
            )),
      type: json['type'] as String? ?? 'skill_version',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'skill_id': skillId,
    'name': name,
    'description': description,
    'created_at': createdAt.toUtc().toIso8601String(),
    'type': type,
  };

  /// Creates a copy with replaced values.
  SkillVersion copyWith({
    String? id,
    String? skillId,
    String? name,
    String? description,
    DateTime? createdAt,
    String? type,
  }) {
    return SkillVersion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillVersion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          skillId == other.skillId &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          type == other.type;

  @override
  int get hashCode =>
      Object.hash(id, skillId, name, description, createdAt, type);

  @override
  String toString() =>
      'SkillVersion('
      'id: $id, '
      'skillId: $skillId, '
      'name: $name, '
      'description: $description, '
      'createdAt: $createdAt, '
      'type: $type)';
}
