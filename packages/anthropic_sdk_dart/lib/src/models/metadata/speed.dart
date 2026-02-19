/// Inference speed mode.
enum Speed {
  /// Standard throughput mode.
  standard('standard'),

  /// Fast mode (beta / premium pricing depending on model).
  fast('fast');

  const Speed(this.value);

  /// JSON value for this speed mode.
  final String value;

  /// Parses a [Speed] from JSON.
  static Speed fromJson(String value) => switch (value) {
    'standard' => Speed.standard,
    'fast' => Speed.fast,
    _ => throw FormatException('Unknown Speed: $value'),
  };

  /// Converts this speed mode to JSON.
  String toJson() => value;
}
