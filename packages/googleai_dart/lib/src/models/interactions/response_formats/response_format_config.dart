part of 'response_formats.dart';

/// The `response_format` configuration for an interaction.
///
/// Per the spec, `response_format` is either a single [ResponseFormat]
/// ([SingleResponseFormat]) or a list of them ([ResponseFormatList]).
sealed class ResponseFormatConfig {
  const ResponseFormatConfig();

  /// Wraps a single [ResponseFormat].
  const factory ResponseFormatConfig.single(ResponseFormat format) =
      SingleResponseFormat;

  /// Wraps a list of [ResponseFormat]s.
  const factory ResponseFormatConfig.list(List<ResponseFormat> formats) =
      ResponseFormatList;

  /// Creates a [ResponseFormatConfig] from a JSON value.
  ///
  /// Accepts either a single response-format object ([SingleResponseFormat]) or
  /// a list of them ([ResponseFormatList]).
  factory ResponseFormatConfig.fromJson(Object json) {
    if (json is List) {
      return ResponseFormatList(
        json
            .map((e) => ResponseFormat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      return SingleResponseFormat(ResponseFormat.fromJson(json));
    }
    throw ArgumentError(
      'Unknown response format: expected an object or a list, got '
      '${json.runtimeType}',
    );
  }

  /// Converts to its JSON representation (an object or a list of objects).
  Object toJson();
}

/// A single [ResponseFormat] response-format configuration.
class SingleResponseFormat extends ResponseFormatConfig {
  /// The response format.
  final ResponseFormat format;

  /// Creates a [SingleResponseFormat].
  const SingleResponseFormat(this.format);

  @override
  Object toJson() => format.toJson();
}

/// A list of [ResponseFormat]s as the response-format configuration.
class ResponseFormatList extends ResponseFormatConfig {
  /// The response formats.
  final List<ResponseFormat> formats;

  /// Creates a [ResponseFormatList].
  const ResponseFormatList(this.formats);

  @override
  Object toJson() => formats.map((f) => f.toJson()).toList();
}
