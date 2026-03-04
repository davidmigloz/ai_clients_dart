import 'package:meta/meta.dart';

import '../responses/common/equality_helpers.dart';

/// A skill resource.
@immutable
class Skill {
  /// Unique identifier for the skill.
  final String id;

  /// Object type, always `skill`.
  final String object;

  /// Skill name.
  final String name;

  /// Skill description.
  final String description;

  /// Unix timestamp for creation.
  final int createdAt;

  /// Default version identifier.
  final String defaultVersion;

  /// Latest version identifier.
  final String latestVersion;

  /// Creates a [Skill].
  const Skill({
    required this.id,
    required this.object,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.defaultVersion,
    required this.latestVersion,
  });

  /// Creates a [Skill] from JSON.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      object: json['object'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] as int,
      defaultVersion: json['default_version'] as String,
      latestVersion: json['latest_version'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'name': name,
    'description': description,
    'created_at': createdAt,
    'default_version': defaultVersion,
    'latest_version': latestVersion,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          defaultVersion == other.defaultVersion &&
          latestVersion == other.latestVersion;

  @override
  int get hashCode => Object.hash(
    id,
    object,
    name,
    description,
    createdAt,
    defaultVersion,
    latestVersion,
  );
}

/// A skill version resource.
@immutable
class SkillVersion {
  /// Object type, always `skill.version`.
  final String object;

  /// Unique version identifier.
  final String id;

  /// Parent skill identifier.
  final String skillId;

  /// Version value.
  final String version;

  /// Unix timestamp for creation.
  final int createdAt;

  /// Version name.
  final String name;

  /// Version description.
  final String description;

  /// Creates a [SkillVersion].
  const SkillVersion({
    required this.object,
    required this.id,
    required this.skillId,
    required this.version,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  /// Creates a [SkillVersion] from JSON.
  factory SkillVersion.fromJson(Map<String, dynamic> json) {
    return SkillVersion(
      object: json['object'] as String,
      id: json['id'] as String,
      skillId: json['skill_id'] as String,
      version: json['version'] as String,
      createdAt: json['created_at'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'id': id,
    'skill_id': skillId,
    'version': version,
    'created_at': createdAt,
    'name': name,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillVersion &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          id == other.id &&
          skillId == other.skillId &&
          version == other.version &&
          createdAt == other.createdAt &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode =>
      Object.hash(object, id, skillId, version, createdAt, name, description);
}

/// Paginated list of [Skill] resources.
@immutable
class SkillList {
  /// Object type, always `list`.
  final String object;

  /// Items in the current page.
  final List<Skill> data;

  /// First item ID in this page.
  final String? firstId;

  /// Last item ID in this page.
  final String? lastId;

  /// Whether there are more results.
  final bool hasMore;

  /// Creates a [SkillList].
  const SkillList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [SkillList] from JSON.
  factory SkillList.fromJson(Map<String, dynamic> json) {
    return SkillList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listsEqual(data, other.data) &&
          firstId == other.firstId &&
          lastId == other.lastId &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      Object.hash(object, Object.hashAll(data), firstId, lastId, hasMore);
}

/// Paginated list of [SkillVersion] resources.
@immutable
class SkillVersionList {
  /// Object type, always `list`.
  final String object;

  /// Items in the current page.
  final List<SkillVersion> data;

  /// First item ID in this page.
  final String? firstId;

  /// Last item ID in this page.
  final String? lastId;

  /// Whether there are more results.
  final bool hasMore;

  /// Creates a [SkillVersionList].
  const SkillVersionList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [SkillVersionList] from JSON.
  factory SkillVersionList.fromJson(Map<String, dynamic> json) {
    return SkillVersionList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => SkillVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    'first_id': firstId,
    'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillVersionList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listsEqual(data, other.data) &&
          firstId == other.firstId &&
          lastId == other.lastId &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      Object.hash(object, Object.hashAll(data), firstId, lastId, hasMore);
}

/// Delete response for a skill.
@immutable
class DeletedSkill {
  /// Object type, always `skill.deleted`.
  final String object;

  /// Whether deletion was successful.
  final bool deleted;

  /// Deleted skill ID.
  final String id;

  /// Creates a [DeletedSkill].
  const DeletedSkill({
    required this.object,
    required this.deleted,
    required this.id,
  });

  /// Creates a [DeletedSkill] from JSON.
  factory DeletedSkill.fromJson(Map<String, dynamic> json) {
    return DeletedSkill(
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
      id: json['id'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'deleted': deleted,
    'id': id,
  };
}

/// Delete response for a skill version.
@immutable
class DeletedSkillVersion {
  /// Object type, always `skill.version.deleted`.
  final String object;

  /// Whether deletion was successful.
  final bool deleted;

  /// Deleted skill ID.
  final String id;

  /// Deleted version value.
  final String version;

  /// Creates a [DeletedSkillVersion].
  const DeletedSkillVersion({
    required this.object,
    required this.deleted,
    required this.id,
    required this.version,
  });

  /// Creates a [DeletedSkillVersion] from JSON.
  factory DeletedSkillVersion.fromJson(Map<String, dynamic> json) {
    return DeletedSkillVersion(
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
      id: json['id'] as String,
      version: json['version'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'deleted': deleted,
    'id': id,
    'version': version,
  };
}

/// Request to update the default skill version.
@immutable
class SetDefaultSkillVersionRequest {
  /// The default version to set.
  final String defaultVersion;

  /// Creates a [SetDefaultSkillVersionRequest].
  const SetDefaultSkillVersionRequest({required this.defaultVersion});

  /// Creates a [SetDefaultSkillVersionRequest] from JSON.
  factory SetDefaultSkillVersionRequest.fromJson(Map<String, dynamic> json) {
    return SetDefaultSkillVersionRequest(
      defaultVersion: json['default_version'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'default_version': defaultVersion};
}

/// Uploadable skill file entry for multipart requests.
@immutable
class SkillUploadFile {
  /// Raw file bytes.
  final List<int> bytes;

  /// Filename to send in multipart upload.
  final String filename;

  /// Creates a [SkillUploadFile].
  const SkillUploadFile({required this.bytes, required this.filename});
}
