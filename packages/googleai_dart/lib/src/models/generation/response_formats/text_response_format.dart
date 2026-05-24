import '../../copy_with_sentinel.dart';

/// MIME type of the text output.
enum TextResponseFormatMimeType {
  /// Default value. This value is unused.
  unspecified,

  /// JSON output format.
  applicationJson,

  /// Plain text output format.
  textPlain,
}

/// Converts a string to a [TextResponseFormatMimeType] enum value.
TextResponseFormatMimeType textResponseFormatMimeTypeFromString(String? value) {
  return switch (value) {
    'APPLICATION_JSON' => TextResponseFormatMimeType.applicationJson,
    'TEXT_PLAIN' => TextResponseFormatMimeType.textPlain,
    _ => TextResponseFormatMimeType.unspecified,
  };
}

/// Converts a [TextResponseFormatMimeType] enum value to a string.
String textResponseFormatMimeTypeToString(TextResponseFormatMimeType value) {
  return switch (value) {
    TextResponseFormatMimeType.applicationJson => 'APPLICATION_JSON',
    TextResponseFormatMimeType.textPlain => 'TEXT_PLAIN',
    TextResponseFormatMimeType.unspecified => 'MIME_TYPE_UNSPECIFIED',
  };
}

/// Configuration for text output format.
class TextResponseFormat {
  /// The MIME type of the text output.
  final TextResponseFormatMimeType? mimeType;

  /// The JSON schema that the output should conform to.
  ///
  /// Only applicable when [mimeType] is
  /// [TextResponseFormatMimeType.applicationJson].
  final Map<String, dynamic>? schema;

  /// Creates a [TextResponseFormat].
  const TextResponseFormat({this.mimeType, this.schema});

  /// Creates a [TextResponseFormat] from JSON.
  factory TextResponseFormat.fromJson(Map<String, dynamic> json) =>
      TextResponseFormat(
        mimeType: json['mimeType'] != null
            ? textResponseFormatMimeTypeFromString(json['mimeType'] as String)
            : null,
        schema: json['schema'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mimeType != null)
      'mimeType': textResponseFormatMimeTypeToString(mimeType!),
    if (schema != null) 'schema': schema,
  };

  /// Creates a copy with replaced values.
  TextResponseFormat copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? schema = unsetCopyWithValue,
  }) {
    return TextResponseFormat(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as TextResponseFormatMimeType?,
      schema: schema == unsetCopyWithValue
          ? this.schema
          : schema as Map<String, dynamic>?,
    );
  }
}
