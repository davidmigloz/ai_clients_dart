/// Shared options for the images API (generate / edit / edit-json).
///
/// GPT image models (e.g. `gpt-image-2.5-sunburst`) accept more parameters
/// than the legacy DALL-E models. These enums cover the full spec surface;
/// individual parameter docs call out which values apply to which model.
///
/// Every enum includes an `unknown` variant for forward compatibility —
/// [fromJson] returns `unknown` rather than throwing when the server emits
/// a value outside the current spec. Note that this is lossy: round-tripping
/// an unknown value will serialize as `'unknown'`, and these enum types do
/// not preserve the original raw wire value.
library;

import 'package:meta/meta.dart';

/// Image quality options.
///
/// `standard` and `hd` apply to DALL-E 3. `low`, `medium`, `high`, and `auto`
/// apply to GPT image models. GPT Image 2.5 Sunburst and Flare also support
/// `xhigh` and `max`, including their dated snapshots.
enum ImageQuality {
  /// Unknown quality — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

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

  /// Extra high quality output for GPT Image 2.5 models.
  xhigh._('xhigh'),

  /// Maximum quality output for GPT Image 2.5 models.
  max._('max'),

  /// Let the server pick the quality (GPT image default).
  auto._('auto');

  const ImageQuality._(this._value);

  /// Creates from JSON string. Unknown values map to [ImageQuality.unknown].
  factory ImageQuality.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => ImageQuality.unknown,
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// An image size, including preset and custom resolutions.
///
/// DALL-E 2 supports `256x256`, `512x512`, `1024x1024`. DALL-E 3 supports
/// `1024x1024`, `1792x1024`, `1024x1792`. GPT image models support `auto`,
/// `1024x1024`, `1536x1024`, and `1024x1536`.
///
/// GPT Image 2 and 2.5 also accept custom `WIDTHxHEIGHT` strings, including
/// with dated model snapshots. For example, use `ImageSize.custom('1536x864')`.
/// Both dimensions must be divisible by 16, with an aspect ratio between 1:3
/// and 3:1. Resolutions above 2560x1440 are experimental; the maximum is
/// 3840x2160 (or its portrait equivalent). The API enforces model-specific
/// pixel and edge limits.
///
/// Unlike an enum, this type preserves every size returned by the API,
/// including transient streaming dimensions and future values.
@immutable
final class ImageSize {
  /// Creates a custom size. The value is sent verbatim to the API.
  const ImageSize.custom(String value) : _value = value;

  const ImageSize._(this._value);

  /// Legacy unknown sentinel. Unrecognized sizes now retain their raw value.
  static const unknown = ImageSize._('unknown');

  /// 256×256 (DALL-E 2 only).
  static const size256x256 = ImageSize._('256x256');

  /// 512×512 (DALL-E 2 only).
  static const size512x512 = ImageSize._('512x512');

  /// 1024×1024 square output.
  static const size1024x1024 = ImageSize._('1024x1024');

  /// 1792×1024 landscape (DALL-E 3, GPT Image 2 and 2.5).
  static const size1792x1024 = ImageSize._('1792x1024');

  /// 1024×1792 portrait (DALL-E 3, GPT Image 2 and 2.5).
  static const size1024x1792 = ImageSize._('1024x1792');

  /// 1536×1024 landscape (GPT image models).
  static const size1536x1024 = ImageSize._('1536x1024');

  /// 1024×1536 portrait (GPT image models).
  static const size1024x1536 = ImageSize._('1024x1536');

  /// Automatically choose the output size (GPT image models).
  static const auto = ImageSize._('auto');

  /// Known presets, retained for callers that list size options.
  ///
  /// This list is not exhaustive: [custom] can represent other sizes.
  static const List<ImageSize> values = [
    unknown,
    size256x256,
    size512x512,
    size1024x1024,
    size1792x1024,
    size1024x1792,
    size1536x1024,
    size1024x1536,
    auto,
  ];

  /// Creates from a JSON string without discarding custom or future sizes.
  factory ImageSize.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => ImageSize.custom(json),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ImageSize && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value;
}

/// Output format options for GPT image models.
enum ImageOutputFormat {
  /// Unknown format — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

  /// PNG lossless output.
  png._('png'),

  /// JPEG lossy output.
  jpeg._('jpeg'),

  /// WebP output.
  webp._('webp');

  const ImageOutputFormat._(this._value);
  final String _value;

  /// Creates from JSON string. Unknown values map to
  /// [ImageOutputFormat.unknown].
  factory ImageOutputFormat.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => ImageOutputFormat.unknown,
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Moderation level for GPT image models.
enum ImageModerationLevel {
  /// Unknown level — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

  /// Low moderation; fewer content restrictions applied.
  low._('low'),

  /// Let the server pick the moderation level (default).
  auto._('auto');

  const ImageModerationLevel._(this._value);
  final String _value;

  /// Creates from JSON string. Unknown values map to
  /// [ImageModerationLevel.unknown].
  factory ImageModerationLevel.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => ImageModerationLevel.unknown,
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Background handling for GPT image models.
///
/// GPT Image 2.5 supports transparent backgrounds. For GPT Image 2 this is
/// available in preview. Transparency requires PNG or WebP output.
enum ImageBackground {
  /// Unknown background — forward-compat fallback for unrecognized values.
  unknown._('unknown'),

  /// Transparent background.
  transparent._('transparent'),

  /// Opaque (solid) background.
  opaque._('opaque'),

  /// Let the server pick the background (default).
  auto._('auto');

  const ImageBackground._(this._value);
  final String _value;

  /// Creates from JSON string. Unknown values map to
  /// [ImageBackground.unknown].
  factory ImageBackground.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => ImageBackground.unknown,
  );

  /// Converts to JSON string.
  String toJson() => _value;
}

/// Input fidelity for GPT image edits.
///
/// Controls how closely the edit follows the input image.
enum ImageInputFidelity {
  /// Unknown fidelity — forward-compat fallback for unrecognized values.
  unknown._('unknown'),

  /// High fidelity; closely follows the input image.
  high._('high'),

  /// Low fidelity; allows more creative deviation from the input.
  low._('low');

  const ImageInputFidelity._(this._value);
  final String _value;

  /// Creates from JSON string. Unknown values map to
  /// [ImageInputFidelity.unknown].
  factory ImageInputFidelity.fromJson(String json) => values.firstWhere(
    (e) => e._value == json,
    orElse: () => ImageInputFidelity.unknown,
  );

  /// Converts to JSON string.
  String toJson() => _value;
}
