import '../common/copy_with_sentinel.dart';
import '../common/json_helpers.dart';
import 'image_common.dart';
import 'svg_options.dart';

/// Reads nullable planning effort on Images requests.
ImageComplexity? readImageComplexity(
  Map<String, dynamic> json,
  String context,
) {
  final value = optionalJsonString(json, 'complexity', context, nullable: true);
  return value == null ? null : ImageComplexity.fromJson(value);
}

/// Validates format-specific options without constraining model IDs.
void validateImageOutputSettings({
  required String? format,
  required int? frameCount,
  required int? frameDurationMs,
  required SvgOptions? svg,
  required int? compression,
  required int? partialImages,
  bool stream = false,
  bool hasMask = false,
  int? n,
  bool responsesTool = false,
  bool requireSvgModel = false,
}) {
  if (frameCount != null || frameDurationMs != null) {
    if (format != 'gif') {
      throw const FormatException('GIF frame settings require GIF output');
    }
    if (frameCount != null && (frameCount < 2 || frameCount > 16)) {
      throw const FormatException('GIF frameCount must be between 2 and 16');
    }
    if (frameDurationMs != null &&
        (frameDurationMs < 20 || (responsesTool && frameDurationMs > 2000))) {
      throw FormatException(
        responsesTool
            ? 'GIF frameDurationMs must be between 20 and 2000'
            : 'GIF frameDurationMs must be at least 20',
      );
    }
  }
  final hasCustomGifCompression =
      compression != null && !(responsesTool && compression == 100);
  if (format == 'gif' &&
      (stream ||
          (partialImages ?? 0) > 0 ||
          hasCustomGifCompression ||
          hasMask)) {
    throw const FormatException(
      'GIF output does not support Images streaming, partial images, '
      'custom output compression, or masks',
    );
  }
  if (svg != null) {
    if (format != 'svg') {
      throw const FormatException('SVG author settings require SVG output');
    }
    if (requireSvgModel && svg.model == null) {
      throw const FormatException(
        'SvgOptions.model is required for generation',
      );
    }
    svg.validate();
  }
  if (!responsesTool &&
      format == 'svg' &&
      (stream ||
          (partialImages ?? 0) > 0 ||
          compression != null ||
          (n ?? 1) != 1)) {
    throw const FormatException(
      'SVG output requires n=1 and does not support Images streaming, '
      'partial images, or output compression',
    );
  }
}

/// Reads the optional nullable image safety identifier without coercion.
String? readImageSafetyIdentifier(
  Map<String, dynamic> json,
  String context, {
  bool validateLength = false,
}) {
  final value = optionalJsonString(
    json,
    'safety_identifier',
    context,
    nullable: true,
  );
  if (validateLength) validateImageSafetyIdentifier(value);
  return value;
}

/// Applies the canonical Unicode code-point bound without exposing values.
void validateImageSafetyIdentifier(String? value) {
  if (value != null && value.runes.length > 128) {
    throw const FormatException(
      'Image safetyIdentifier: maximum 128 characters',
    );
  }
}

/// Copies a nullable field without disclosing invalid caller data.
T? copyImageValue<T>(Object? value, T? current, String context) {
  if (identical(value, unsetCopyWithValue)) return current;
  if (value == null) return null;
  if (value is! T) {
    throw FormatException('$context: expected the declared type');
  }
  return value as T;
}

/// Stable private diagnostic summary.
String imageIdentifierSummary(String? value) =>
    value == null ? 'null' : '[REDACTED]';
