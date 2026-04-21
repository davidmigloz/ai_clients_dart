/// Shared enums for the images API (generate / edit / edit-json).
///
/// GPT image models (e.g. `gpt-image-2`) accept a richer set of parameters
/// than the legacy DALL-E models. These enums cover the full spec surface;
/// individual parameter docs call out which values apply to which model.
library;

/// Image quality options.
///
/// `standard` and `hd` apply to DALL-E 3. `low`, `medium`, `high`, and `auto`
/// apply to GPT image models (including `gpt-image-2`).
enum ImageQuality {
  /// Standard DALL-E 3 quality.
  standard._('standard'),

  /// HD (higher detail) DALL-E 3 quality.
  hd._('hd'),

  /// Low quality output for GPT image models.
  low._('low'),

  /// Medium quality output for GPT image models.
  medium._('medium'),

  /// High quality output for GPT image models.
  high._('high'),

  /// Let the server pick the quality (GPT image default).
  auto._('auto');

  const ImageQuality._(this._value);

  /// Creates from JSON string.
  factory ImageQuality.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown quality: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Image size options.
///
/// DALL-E 2 supports `256x256`, `512x512`, `1024x1024`. DALL-E 3 supports
/// `1024x1024`, `1792x1024`, `1024x1792`. GPT image models (including
/// `gpt-image-2`) support `auto`, `1024x1024`, `1536x1024`, `1024x1536`.
enum ImageSize {
  /// 256×256 (DALL-E 2 only).
  size256x256._('256x256'),

  /// 512×512 (DALL-E 2 only).
  size512x512._('512x512'),

  /// 1024×1024 square output.
  size1024x1024._('1024x1024'),

  /// 1792×1024 landscape (DALL-E 3 only).
  size1792x1024._('1792x1024'),

  /// 1024×1792 portrait (DALL-E 3 only).
  size1024x1792._('1024x1792'),

  /// 1536×1024 landscape (GPT image models).
  size1536x1024._('1536x1024'),

  /// 1024×1536 portrait (GPT image models).
  size1024x1536._('1024x1536'),

  /// Automatically choose the output size (GPT image models).
  auto._('auto');

  const ImageSize._(this._value);

  /// Creates from JSON string.
  factory ImageSize.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown size: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Output format options for GPT image models.
enum ImageOutputFormat {
  /// PNG lossless output.
  png._('png'),

  /// JPEG lossy output.
  jpeg._('jpeg'),

  /// WebP output.
  webp._('webp');

  const ImageOutputFormat._(this._value);
  final String _value;

  /// Creates from JSON string.
  factory ImageOutputFormat.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => throw FormatException('Unknown output format: $json'),
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Moderation level for GPT image models.
enum ImageModerationLevel {
  /// Low moderation; fewer content restrictions applied.
  low._('low'),

  /// Let the server pick the moderation level (default).
  auto._('auto');

  const ImageModerationLevel._(this._value);
  final String _value;

  /// Creates from JSON string.
  factory ImageModerationLevel.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => throw FormatException('Unknown moderation: $json'),
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Background handling for GPT image models.
enum ImageBackground {
  /// Transparent background.
  transparent._('transparent'),

  /// Opaque (solid) background.
  opaque._('opaque'),

  /// Let the server pick the background (default).
  auto._('auto');

  const ImageBackground._(this._value);
  final String _value;

  /// Creates from JSON string.
  factory ImageBackground.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => throw FormatException('Unknown background: $json'),
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Input fidelity for GPT image edits.
///
/// Controls how closely the edit follows the input image.
enum ImageInputFidelity {
  /// High fidelity; closely follows the input image.
  high._('high'),

  /// Low fidelity; allows more creative deviation from the input.
  low._('low');

  const ImageInputFidelity._(this._value);
  final String _value;

  /// Creates from JSON string.
  factory ImageInputFidelity.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => throw FormatException('Unknown input_fidelity: $json'),
  );

  /// Converts to JSON string.
  String toJson() => _value;
}
