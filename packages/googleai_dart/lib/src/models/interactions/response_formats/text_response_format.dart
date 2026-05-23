part of 'response_formats.dart';

/// MIME type of the text output.
enum TextResponseFormatMimeType {
  /// JSON output format (`application/json`).
  applicationJson,

  /// Plain text output format (`text/plain`).
  textPlain,
}

/// Converts a JSON string to a [TextResponseFormatMimeType], or `null` if
/// unrecognized (forward-compatible).
TextResponseFormatMimeType? textResponseFormatMimeTypeFromString(
  String? value,
) {
  return switch (value) {
    'application/json' => TextResponseFormatMimeType.applicationJson,
    'text/plain' => TextResponseFormatMimeType.textPlain,
    _ => null,
  };
}

/// Converts a [TextResponseFormatMimeType] to its JSON string.
String textResponseFormatMimeTypeToString(TextResponseFormatMimeType value) {
  return switch (value) {
    TextResponseFormatMimeType.applicationJson => 'application/json',
    TextResponseFormatMimeType.textPlain => 'text/plain',
  };
}

/// Configuration for text output format.
class TextResponseFormat extends ResponseFormat {
  @override
  String get type => 'text';

  /// The MIME type of the text output.
  final TextResponseFormatMimeType? mimeType;

  /// JSON schema that the output should conform to. Only applicable when
  /// [mimeType] is [TextResponseFormatMimeType.applicationJson].
  final Map<String, dynamic>? schema;

  /// Creates a [TextResponseFormat] instance.
  const TextResponseFormat({this.mimeType, this.schema});

  /// Creates a [TextResponseFormat] from JSON.
  factory TextResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'text') {
      throw FormatException('Expected type "text" but got "${json['type']}"');
    }
    return TextResponseFormat(
      mimeType: textResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      schema: json['schema'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mimeType != null)
      'mime_type': textResponseFormatMimeTypeToString(mimeType!),
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
