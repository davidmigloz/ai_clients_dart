import 'package:meta/meta.dart';

/// A version of a skill in the Anthropic API.
@immutable
class SkillVersion {
  /// Unique identifier for the skill version.
  ///
  /// The format and length of IDs may change over time.
  final String id;

  /// Identifier for the skill that this version belongs to.
  final String skillId;

  /// Version identifier for the skill.
  ///
  /// Each version is identified by a Unix epoch timestamp
  /// (e.g., "1759178010641129").
  final String version;

  /// Human-readable name of the skill version.
  ///
  /// This is extracted from the SKILL.md file in the skill upload.
  final String name;

  /// Description of the skill version.
  ///
  /// This is extracted from the SKILL.md file in the skill upload.
  final String description;

  /// Directory name of the skill version.
  ///
  /// This is the top-level directory name that was extracted from the
  /// uploaded files.
  final String directory;

  /// ISO 8601 timestamp of when the skill version was created.
  final DateTime createdAt;

  /// Object type. Always "skill_version".
  final String type;

  /// Creates a [SkillVersion].
  const SkillVersion({
    required this.id,
    required this.skillId,
    required this.version,
    required this.name,
    required this.description,
    required this.directory,
    required this.createdAt,
    this.type = 'skill_version',
  });

  /// Creates a [SkillVersion] from JSON.
  factory SkillVersion.fromJson(Map<String, dynamic> json) {
    return SkillVersion(
      id: json['id'] as String,
      skillId: json['skill_id'] as String,
      version: json['version'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      directory: json['directory'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String? ?? 'skill_version',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'skill_id': skillId,
    'version': version,
    'name': name,
    'description': description,
    'directory': directory,
    'created_at': createdAt.toUtc().toIso8601String(),
    'type': type,
  };

  /// Creates a copy with replaced values.
  SkillVersion copyWith({
    String? id,
    String? skillId,
    String? version,
    String? name,
    String? description,
    String? directory,
    DateTime? createdAt,
    String? type,
  }) {
    return SkillVersion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      version: version ?? this.version,
      name: name ?? this.name,
      description: description ?? this.description,
      directory: directory ?? this.directory,
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
          version == other.version &&
          name == other.name &&
          description == other.description &&
          directory == other.directory &&
          createdAt == other.createdAt &&
          type == other.type;

  @override
  int get hashCode => Object.hash(
    id,
    skillId,
    version,
    name,
    description,
    directory,
    createdAt,
    type,
  );

  @override
  String toString() =>
      'SkillVersion('
      'id: $id, '
      'skillId: $skillId, '
      'version: $version, '
      'name: $name, '
      'description: $description, '
      'directory: $directory, '
      'createdAt: $createdAt, '
      'type: $type)';
}
