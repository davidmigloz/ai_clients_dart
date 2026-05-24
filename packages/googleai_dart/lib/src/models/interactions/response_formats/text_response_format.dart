part of 'response_formats.dart';

/// MIME type of the text output.
enum InteractionTextResponseFormatMimeType {
  /// JSON output format (`application/json`).
  applicationJson,

  /// Plain text output format (`text/plain`).
  textPlain,
}

/// Converts a JSON string to an [InteractionTextResponseFormatMimeType], or
/// `null` if unrecognized (forward-compatible).
InteractionTextResponseFormatMimeType?
interactionTextResponseFormatMimeTypeFromString(String? value) {
  return switch (value) {
    'application/json' => InteractionTextResponseFormatMimeType.applicationJson,
    'text/plain' => InteractionTextResponseFormatMimeType.textPlain,
    _ => null,
  };
}

/// Converts an [InteractionTextResponseFormatMimeType] to its JSON string.
String interactionTextResponseFormatMimeTypeToString(
  InteractionTextResponseFormatMimeType value,
) {
  return switch (value) {
    InteractionTextResponseFormatMimeType.applicationJson => 'application/json',
    InteractionTextResponseFormatMimeType.textPlain => 'text/plain',
  };
}

/// Configuration for text output format.
class InteractionTextResponseFormat extends InteractionResponseFormat {
  @override
  String get type => 'text';

  /// The MIME type of the text output.
  final InteractionTextResponseFormatMimeType? mimeType;

  /// JSON schema that the output should conform to. Only applicable when
  /// [mimeType] is [InteractionTextResponseFormatMimeType.applicationJson].
  final Map<String, dynamic>? schema;

  /// Creates an [InteractionTextResponseFormat] instance.
  const InteractionTextResponseFormat({this.mimeType, this.schema});

  /// Creates an [InteractionTextResponseFormat] from JSON.
  factory InteractionTextResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'text') {
      throw FormatException('Expected type "text" but got "${json['type']}"');
    }
    return InteractionTextResponseFormat(
      mimeType: interactionTextResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      schema: json['schema'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mimeType != null)
      'mime_type': interactionTextResponseFormatMimeTypeToString(mimeType!),
    if (schema != null) 'schema': schema,
  };

  /// Creates a copy with replaced values.
  InteractionTextResponseFormat copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? schema = unsetCopyWithValue,
  }) {
    return InteractionTextResponseFormat(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as InteractionTextResponseFormatMimeType?,
      schema: schema == unsetCopyWithValue
          ? this.schema
          : schema as Map<String, dynamic>?,
    );
  }
}
