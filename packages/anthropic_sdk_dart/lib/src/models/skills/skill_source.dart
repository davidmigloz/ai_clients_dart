import 'package:meta/meta.dart';

/// Where a Skill comes from.
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

/// Where a Skill comes from.
@immutable
class SkillSource {
  /// The kind of source this skill comes from.
  final SkillSourceType type;
  final String? _rawType;

  /// Original source discriminator, including a value the SDK does not know.
  String get rawType => _rawType ?? type.value;

  /// Creates a [SkillSource].
  const SkillSource({required this.type}) : _rawType = null;

  const SkillSource._(this.type, this._rawType);

  /// Creates a [SkillSource] from JSON.
  factory SkillSource.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String;
    final type = SkillSourceType.fromJson(rawType);
    return SkillSource._(
      type,
      type == SkillSourceType.unknown ? rawType : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': rawType};

  /// Creates a copy with replaced values.
  SkillSource copyWith({SkillSourceType? type}) {
    return type == null ? this : SkillSource(type: type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillSource &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType;

  @override
  int get hashCode => rawType.hashCode;

  @override
  String toString() => 'SkillSource(type: $rawType)';
}
