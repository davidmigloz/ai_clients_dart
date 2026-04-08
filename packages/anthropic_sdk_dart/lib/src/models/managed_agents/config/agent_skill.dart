import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Resolved skill as returned in API responses.
///
/// Variants:
/// - [AnthropicSkill] — an Anthropic-managed skill.
/// - [CustomSkill] — a user-created custom skill.
/// - [UnknownAgentSkill] — unrecognised skill type (preserves raw JSON).
sealed class AgentSkill {
  const AgentSkill();

  /// Creates an [AgentSkill] from JSON.
  factory AgentSkill.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'anthropic' => AnthropicSkill.fromJson(json),
      'custom' => CustomSkill.fromJson(json),
      _ => UnknownAgentSkill._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A resolved Anthropic-managed skill.
@immutable
class AnthropicSkill extends AgentSkill {
  /// The type discriminator. Always `anthropic`.
  final String type;

  /// Identifier of the Anthropic skill (e.g., "xlsx").
  final String skillId;

  /// Version of the skill.
  final String version;

  /// Creates an [AnthropicSkill].
  const AnthropicSkill({
    this.type = 'anthropic',
    required this.skillId,
    required this.version,
  });

  /// Creates an [AnthropicSkill] from JSON.
  factory AnthropicSkill.fromJson(Map<String, dynamic> json) {
    return AnthropicSkill(
      type: json['type'] as String? ?? 'anthropic',
      skillId: json['skill_id'] as String,
      version: json['version'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'skill_id': skillId,
    'version': version,
  };

  /// Creates a copy with replaced values.
  AnthropicSkill copyWith({String? type, String? skillId, String? version}) {
    return AnthropicSkill(
      type: type ?? this.type,
      skillId: skillId ?? this.skillId,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnthropicSkill &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, skillId, version);

  @override
  String toString() =>
      'AnthropicSkill(type: $type, skillId: $skillId, version: $version)';
}

/// A resolved user-created custom skill.
@immutable
class CustomSkill extends AgentSkill {
  /// The type discriminator. Always `custom`.
  final String type;

  /// Identifier of the custom skill.
  final String skillId;

  /// Version of the skill.
  final String version;

  /// Creates a [CustomSkill].
  const CustomSkill({
    this.type = 'custom',
    required this.skillId,
    required this.version,
  });

  /// Creates a [CustomSkill] from JSON.
  factory CustomSkill.fromJson(Map<String, dynamic> json) {
    return CustomSkill(
      type: json['type'] as String? ?? 'custom',
      skillId: json['skill_id'] as String,
      version: json['version'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'skill_id': skillId,
    'version': version,
  };

  /// Creates a copy with replaced values.
  CustomSkill copyWith({String? type, String? skillId, String? version}) {
    return CustomSkill(
      type: type ?? this.type,
      skillId: skillId ?? this.skillId,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomSkill &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, skillId, version);

  @override
  String toString() =>
      'CustomSkill(type: $type, skillId: $skillId, version: $version)';
}

/// Unrecognised skill type — preserves the raw JSON.
@immutable
class UnknownAgentSkill extends AgentSkill {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentSkill._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentSkill &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownAgentSkill(type: $type, raw: $raw)';
}

/// Skill parameter for create/update requests.
///
/// Variants:
/// - [AnthropicSkillParams] — an Anthropic-managed skill.
/// - [CustomSkillParams] — a user-created custom skill.
/// - [UnknownAgentSkillParams] — unrecognised skill type (preserves raw JSON).
sealed class AgentSkillParams {
  const AgentSkillParams();

  /// Creates an [AgentSkillParams] from JSON.
  factory AgentSkillParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'anthropic' => AnthropicSkillParams.fromJson(json),
      'custom' => CustomSkillParams.fromJson(json),
      _ => UnknownAgentSkillParams._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An Anthropic-managed skill parameter.
@immutable
class AnthropicSkillParams extends AgentSkillParams {
  /// The type discriminator. Always `anthropic`.
  final String type;

  /// Identifier of the Anthropic skill (e.g., "xlsx").
  final String skillId;

  /// Version to pin. Defaults to latest if omitted.
  final String? version;

  /// Creates an [AnthropicSkillParams].
  const AnthropicSkillParams({
    this.type = 'anthropic',
    required this.skillId,
    this.version,
  });

  /// Creates an [AnthropicSkillParams] from JSON.
  factory AnthropicSkillParams.fromJson(Map<String, dynamic> json) {
    return AnthropicSkillParams(
      type: json['type'] as String? ?? 'anthropic',
      skillId: json['skill_id'] as String,
      version: json['version'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'skill_id': skillId,
    if (version != null) 'version': version,
  };

  /// Creates a copy with replaced values.
  AnthropicSkillParams copyWith({
    String? type,
    String? skillId,
    Object? version = unsetCopyWithValue,
  }) {
    return AnthropicSkillParams(
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
      other is AnthropicSkillParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, skillId, version);

  @override
  String toString() =>
      'AnthropicSkillParams(type: $type, skillId: $skillId, version: $version)';
}

/// A user-created custom skill parameter.
@immutable
class CustomSkillParams extends AgentSkillParams {
  /// The type discriminator. Always `custom`.
  final String type;

  /// Identifier of the custom skill.
  final String skillId;

  /// Version to pin. Defaults to latest if omitted.
  final String? version;

  /// Creates a [CustomSkillParams].
  const CustomSkillParams({
    this.type = 'custom',
    required this.skillId,
    this.version,
  });

  /// Creates a [CustomSkillParams] from JSON.
  factory CustomSkillParams.fromJson(Map<String, dynamic> json) {
    return CustomSkillParams(
      type: json['type'] as String? ?? 'custom',
      skillId: json['skill_id'] as String,
      version: json['version'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'skill_id': skillId,
    if (version != null) 'version': version,
  };

  /// Creates a copy with replaced values.
  CustomSkillParams copyWith({
    String? type,
    String? skillId,
    Object? version = unsetCopyWithValue,
  }) {
    return CustomSkillParams(
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
      other is CustomSkillParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(type, skillId, version);

  @override
  String toString() =>
      'CustomSkillParams(type: $type, skillId: $skillId, version: $version)';
}

/// Unrecognised skill params type — preserves the raw JSON.
@immutable
class UnknownAgentSkillParams extends AgentSkillParams {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentSkillParams._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentSkillParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownAgentSkillParams(type: $type, raw: $raw)';
}
