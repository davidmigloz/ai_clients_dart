/// How much input is included in a turn.
enum TurnCoverage {
  /// Only detected user activity is included in the turn.
  ///
  /// Silence and non-speech audio are excluded.
  turnIncludesOnlyActivity('TURN_INCLUDES_ONLY_ACTIVITY'),

  /// All input is included in the turn.
  ///
  /// Includes silence and all audio, not just detected speech.
  turnIncludesAllInput('TURN_INCLUDES_ALL_INPUT'),

  /// Use the model's default turn coverage.
  unspecified('TURN_COVERAGE_UNSPECIFIED'),

  /// Include all video and detected audio activity since the last turn.
  ///
  /// When automatic activity detection is enabled, audio excludes silence.
  turnIncludesAudioActivityAndAllVideo(
    'TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO',
  );

  const TurnCoverage(this.value);

  /// The JSON value.
  final String value;

  /// Creates from JSON value.
  static TurnCoverage fromJson(String json) {
    return TurnCoverage.values.firstWhere(
      (e) => e.value == json,
      orElse: () => throw FormatException('Unknown TurnCoverage: $json'),
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
