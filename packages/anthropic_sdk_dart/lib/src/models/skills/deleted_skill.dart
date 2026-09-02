import 'package:meta/meta.dart';

/// Response returned when a skill is deleted.
@immutable
class DeletedSkill {
  /// Unique identifier for the deleted skill.
  final String id;

  /// Deleted object type. Always `skill_deleted`.
  final String type;

  /// Creates a [DeletedSkill].
  const DeletedSkill({required this.id, this.type = 'skill_deleted'});

  /// Creates a [DeletedSkill] from JSON.
  factory DeletedSkill.fromJson(Map<String, dynamic> json) {
    return DeletedSkill(
      id:
          json['id'] as String? ??
          (throw const FormatException('DeletedSkill: missing required "id"')),
      type: json['type'] as String? ?? 'skill_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedSkill copyWith({String? id, String? type}) {
    return DeletedSkill(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSkill &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedSkill(id: $id, type: $type)';
}

/// Response returned when a skill version is deleted.
@immutable
class DeletedSkillVersion {
  /// Unique identifier for the deleted skill version.
  final String id;

  /// Deleted object type. Always `skill_version_deleted`.
  final String type;

  /// Creates a [DeletedSkillVersion].
  const DeletedSkillVersion({
    required this.id,
    this.type = 'skill_version_deleted',
  });

  /// Creates a [DeletedSkillVersion] from JSON.
  factory DeletedSkillVersion.fromJson(Map<String, dynamic> json) {
    return DeletedSkillVersion(
      id:
          json['id'] as String? ??
          (throw const FormatException(
            'DeletedSkillVersion: missing required "id"',
          )),
      type: json['type'] as String? ?? 'skill_version_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedSkillVersion copyWith({String? id, String? type}) {
    return DeletedSkillVersion(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSkillVersion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedSkillVersion(id: $id, type: $type)';
}
