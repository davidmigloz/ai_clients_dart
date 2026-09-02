import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Type of skill loaded in — or requested for — a container.
///
/// Either `anthropic` (built-in) or `custom` (user-defined). Falls back to
/// [unknown] for values not recognized by this version of the SDK.
enum ContainerSkillType {
  /// A built-in Anthropic skill.
  anthropic('anthropic'),

  /// A user-defined custom skill.
  custom('custom'),

  /// Forward-compatible fallback for an unrecognized value.
  unknown('unknown');

  /// The wire value for this skill type.
  final String value;

  const ContainerSkillType(this.value);

  /// Creates a [ContainerSkillType] from its wire value.
  ///
  /// Unrecognized values fall back to [unknown] rather than throwing, since
  /// this is a response-side enum the server may extend.
  factory ContainerSkillType.fromJson(String value) {
    return switch (value) {
      'anthropic' => ContainerSkillType.anthropic,
      'custom' => ContainerSkillType.custom,
      _ => ContainerSkillType.unknown,
    };
  }

  /// Converts to its wire value.
  String toJson() => value;
}

/// A skill to load in a container, as specified on a request.
@immutable
class ContainerSkillParams {
  /// Type of skill - either 'anthropic' (built-in) or 'custom' (user-defined).
  final ContainerSkillType type;

  /// Skill ID (e.g. `'pdf'`).
  final String skillId;

  /// Skill version, or `'latest'` for the most recent version.
  final String? version;

  /// Creates a [ContainerSkillParams].
  const ContainerSkillParams({
    required this.type,
    required this.skillId,
    this.version,
  });

  /// Creates a [ContainerSkillParams] from JSON.
  factory ContainerSkillParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw const FormatException(
        'ContainerSkillParams: missing required "type"',
      );
    }
    final skillId = json['skill_id'] as String?;
    if (skillId == null) {
      throw const FormatException(
        'ContainerSkillParams: missing required "skill_id"',
      );
    }
    return ContainerSkillParams(
      type: ContainerSkillType.fromJson(type),
      skillId: skillId,
      version: json['version'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type.toJson(),
    'skill_id': skillId,
    if (version != null) 'version': version,
  };

  /// Creates a copy with replaced values.
  ContainerSkillParams copyWith({
    ContainerSkillType? type,
    String? skillId,
    Object? version = unsetCopyWithValue,
  }) {
    return ContainerSkillParams(
      type: type ?? this.type,
      skillId: skillId ?? this.skillId,
      version: version == unsetCopyWithValue
          ? this.version
          : version as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerSkillParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, skillId, version);

  @override
  String toString() =>
      'ContainerSkillParams(type: $type, skillId: $skillId, '
      'version: $version)';
}

/// Container parameters with the skills to be loaded.
@immutable
class ContainerParams {
  /// Container id, to reuse an existing container.
  final String? id;

  /// List of skills to load in the container.
  final List<ContainerSkillParams>? skills;

  /// Creates a [ContainerParams].
  const ContainerParams({this.id, this.skills});

  /// Creates a [ContainerParams] from JSON.
  factory ContainerParams.fromJson(Map<String, dynamic> json) {
    return ContainerParams(
      id: json['id'] as String?,
      skills: (json['skills'] as List?)
          ?.map((e) => ContainerSkillParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (skills != null) 'skills': skills!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ContainerParams copyWith({
    Object? id = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
  }) {
    return ContainerParams(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      skills: skills == unsetCopyWithValue
          ? this.skills
          : skills as List<ContainerSkillParams>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => Object.hash(id, listHash(skills));

  @override
  String toString() => 'ContainerParams(id: $id, skills: $skills)';
}

/// The `container` request field: either a plain container identifier
/// string (to reuse an existing container across requests) or a
/// [ContainerParams] object specifying skills to load into a new container.
sealed class ContainerParam {
  const ContainerParam();

  /// Reuse an existing container by id.
  factory ContainerParam.id(String id) = ContainerParamId;

  /// Create (or reuse, via [ContainerParams.id]) a container configured with
  /// the given parameters, such as skills to load.
  factory ContainerParam.config(ContainerParams params) = ContainerParamConfig;

  /// Creates a [ContainerParam] from JSON.
  ///
  /// A JSON string becomes a [ContainerParamId]; a JSON object becomes a
  /// [ContainerParamConfig].
  factory ContainerParam.fromJson(dynamic json) {
    if (json is String) {
      return ContainerParamId(json);
    }
    if (json is Map<String, dynamic>) {
      return ContainerParamConfig(ContainerParams.fromJson(json));
    }
    throw FormatException(
      'ContainerParam: expected a String or a Map, got ${json.runtimeType}',
    );
  }

  /// Converts to JSON.
  dynamic toJson();
}

/// A container referenced by its identifier.
@immutable
class ContainerParamId extends ContainerParam {
  /// The container id.
  final String id;

  /// Creates a [ContainerParamId].
  const ContainerParamId(this.id);

  @override
  String toJson() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerParamId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContainerParamId(id: $id)';
}

/// A container configured with [ContainerParams], such as skills to load.
@immutable
class ContainerParamConfig extends ContainerParam {
  /// The container parameters.
  final ContainerParams params;

  /// Creates a [ContainerParamConfig].
  const ContainerParamConfig(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerParamConfig &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() => 'ContainerParamConfig(params: $params)';
}

/// A skill that was loaded in a container (response model).
@immutable
class ContainerSkill {
  /// Skill ID (e.g. `'pdf'`).
  final String skillId;

  /// Type of skill - either 'anthropic' (built-in) or 'custom' (user-defined).
  final ContainerSkillType type;

  /// The resolved version: a skill version id for custom skills.
  final String version;

  /// Creates a [ContainerSkill].
  const ContainerSkill({
    required this.skillId,
    required this.type,
    required this.version,
  });

  /// Creates a [ContainerSkill] from JSON.
  factory ContainerSkill.fromJson(Map<String, dynamic> json) {
    final skillId = json['skill_id'] as String?;
    if (skillId == null) {
      throw const FormatException(
        'ContainerSkill: missing required "skill_id"',
      );
    }
    final type = json['type'] as String?;
    if (type == null) {
      throw const FormatException('ContainerSkill: missing required "type"');
    }
    final version = json['version'] as String?;
    if (version == null) {
      throw const FormatException('ContainerSkill: missing required "version"');
    }
    return ContainerSkill(
      skillId: skillId,
      type: ContainerSkillType.fromJson(type),
      version: version,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'skill_id': skillId,
    'type': type.toJson(),
    'version': version,
  };

  /// Creates a copy with replaced values.
  ContainerSkill copyWith({
    String? skillId,
    ContainerSkillType? type,
    String? version,
  }) {
    return ContainerSkill(
      skillId: skillId ?? this.skillId,
      type: type ?? this.type,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerSkill &&
          runtimeType == other.runtimeType &&
          skillId == other.skillId &&
          type == other.type &&
          version == other.version;

  @override
  int get hashCode => Object.hash(skillId, type, version);

  @override
  String toString() =>
      'ContainerSkill(skillId: $skillId, type: $type, version: $version)';
}

/// Container information in response (for the code execution tool).
@immutable
class Container {
  /// The container ID.
  final String id;

  /// The expiration time.
  final DateTime expiresAt;

  /// Skills loaded in the container.
  final List<ContainerSkill>? skills;

  /// Creates a [Container].
  const Container({required this.id, required this.expiresAt, this.skills});

  /// Creates a [Container] from JSON.
  factory Container.fromJson(Map<String, dynamic> json) {
    return Container(
      id: json['id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      skills: (json['skills'] as List?)
          ?.map((e) => ContainerSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'skills': skills?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  Container copyWith({
    String? id,
    DateTime? expiresAt,
    Object? skills = unsetCopyWithValue,
  }) {
    return Container(
      id: id ?? this.id,
      expiresAt: expiresAt ?? this.expiresAt,
      skills: skills == unsetCopyWithValue
          ? this.skills
          : skills as List<ContainerSkill>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Container &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          expiresAt == other.expiresAt &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => Object.hash(id, expiresAt, listHash(skills));

  @override
  String toString() =>
      'Container(id: $id, expiresAt: $expiresAt, skills: $skills)';
}
