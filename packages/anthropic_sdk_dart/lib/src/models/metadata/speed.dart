/// Inference speed mode.
enum Speed {
  /// Standard throughput mode.
  standard('standard'),

  /// Fast mode with premium pricing on supported models.
  ///
  /// On the Claude API, Claude Opus 5.5 and Claude Fable 5.2 accept fast mode
  /// without a beta header. Some earlier models require the fast-mode beta.
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
