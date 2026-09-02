import 'package:meta/meta.dart';

/// Where a [Skill] comes from.
enum SkillSourceType {
  /// Authored by the platform user; private to their workspace.
  custom('custom'),

  /// Published by Anthropic; shared and read-only.
  anthropic('anthropic'),

  /// Anthropic-published sample skill.
  anthropicExample('anthropic_example'),

  /// Resolved from an installed plugin.
  plugin('plugin'),

  /// Unknown source — fallback for forward compatibility.
  unknown('unknown');

  const SkillSourceType(this.value);

  /// JSON value for this source type.
  final String value;

  /// Parses a [SkillSourceType] from JSON.
  static SkillSourceType fromJson(String value) => switch (value) {
    'custom' => SkillSourceType.custom,
    'anthropic' => SkillSourceType.anthropic,
    'anthropic_example' => SkillSourceType.anthropicExample,
    'plugin' => SkillSourceType.plugin,
    _ => SkillSourceType.unknown,
  };

  /// Converts this source type to JSON.
  String toJson() => value;
}

/// Where a [Skill] comes from.
@immutable
class SkillSource {
  /// The kind of source this skill comes from.
  final SkillSourceType type;

  /// Creates a [SkillSource].
  const SkillSource({required this.type});

  /// Creates a [SkillSource] from JSON.
  factory SkillSource.fromJson(Map<String, dynamic> json) {
    return SkillSource(type: SkillSourceType.fromJson(json['type'] as String));
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type.toJson()};

  /// Creates a copy with replaced values.
  SkillSource copyWith({SkillSourceType? type}) {
    return SkillSource(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillSource &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'SkillSource(type: $type)';
}
