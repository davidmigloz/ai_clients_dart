/// Sensitivity for detecting the end of user speech.
enum EndSensitivity {
  /// High sensitivity - more likely to detect speech end quickly.
  ///
  /// May cut off speech prematurely.
  high('END_SENSITIVITY_HIGH'),

  /// Low sensitivity - waits longer before detecting speech end.
  ///
  /// May include more silence at the end.
  low('END_SENSITIVITY_LOW'),

  /// Use the backend's default sensitivity.
  unspecified('END_SENSITIVITY_UNSPECIFIED');

  const EndSensitivity(this.value);

  /// The JSON value.
  final String value;

  /// Parses a wire value or a legacy `HIGH` or `LOW` value.
  static EndSensitivity fromJson(String json) => switch (json) {
    'HIGH' || 'END_SENSITIVITY_HIGH' => high,
    'LOW' || 'END_SENSITIVITY_LOW' => low,
    'END_SENSITIVITY_UNSPECIFIED' => unspecified,
    _ => throw FormatException('Unknown EndSensitivity: $json'),
  };

  /// Converts to JSON value.
  String toJson() => value;
}
