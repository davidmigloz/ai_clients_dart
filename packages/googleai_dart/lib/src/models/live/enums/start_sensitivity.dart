/// Sensitivity for detecting the start of user speech.
enum StartSensitivity {
  /// High sensitivity - more likely to detect speech start.
  ///
  /// May result in more false positives (detecting non-speech as speech).
  high('START_SENSITIVITY_HIGH'),

  /// Low sensitivity - less likely to detect speech start.
  ///
  /// May result in more false negatives (missing actual speech start).
  low('START_SENSITIVITY_LOW'),

  /// Use the backend's default sensitivity.
  unspecified('START_SENSITIVITY_UNSPECIFIED');

  const StartSensitivity(this.value);

  /// The JSON value.
  final String value;

  /// Parses a wire value or a legacy `HIGH` or `LOW` value.
  static StartSensitivity fromJson(String json) => switch (json) {
    'HIGH' || 'START_SENSITIVITY_HIGH' => high,
    'LOW' || 'START_SENSITIVITY_LOW' => low,
    'START_SENSITIVITY_UNSPECIFIED' => unspecified,
    _ => throw FormatException('Unknown StartSensitivity: $json'),
  };

  /// Converts to JSON value.
  String toJson() => value;
}
