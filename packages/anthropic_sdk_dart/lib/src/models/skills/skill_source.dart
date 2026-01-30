/// Source of a skill in the Anthropic API.
///
/// Indicates whether a skill was created by a user or provided by Anthropic.
enum SkillSource {
  /// The skill was created by a user.
  custom('custom'),

  /// The skill was created by Anthropic.
  anthropic('anthropic');

  const SkillSource(this.value);

  /// JSON value for the skill source.
  final String value;

  /// Converts a string to [SkillSource].
  static SkillSource fromJson(String value) => switch (value) {
    'custom' => SkillSource.custom,
    'anthropic' => SkillSource.anthropic,
    _ => throw FormatException('Unknown SkillSource: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
