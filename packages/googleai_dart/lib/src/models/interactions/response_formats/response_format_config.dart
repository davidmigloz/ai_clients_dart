part of 'response_formats.dart';

/// The `response_format` configuration for an interaction.
///
/// Per the spec, `response_format` is either a single
/// [InteractionResponseFormat] ([InteractionSingleResponseFormat]) or a list of
/// them ([InteractionResponseFormatList]).
sealed class InteractionResponseFormatConfig {
  const InteractionResponseFormatConfig();

  /// Wraps a single [InteractionResponseFormat].
  const factory InteractionResponseFormatConfig.single(
    InteractionResponseFormat format,
  ) = InteractionSingleResponseFormat;

  /// Wraps a list of [InteractionResponseFormat]s.
  const factory InteractionResponseFormatConfig.list(
    List<InteractionResponseFormat> formats,
  ) = InteractionResponseFormatList;

  /// Creates an [InteractionResponseFormatConfig] from a JSON value.
  ///
  /// Accepts either a single response-format object
  /// ([InteractionSingleResponseFormat]) or a list of them
  /// ([InteractionResponseFormatList]).
  factory InteractionResponseFormatConfig.fromJson(Object json) {
    if (json is List) {
      return InteractionResponseFormatList(
        json
            .map(
              (e) =>
                  InteractionResponseFormat.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      return InteractionSingleResponseFormat(
        InteractionResponseFormat.fromJson(json),
      );
    }
    throw ArgumentError(
      'Unknown response format: expected an object or a list, got '
      '${json.runtimeType}',
    );
  }

  /// Converts to its JSON representation (an object or a list of objects).
  Object toJson();
}

/// A single [InteractionResponseFormat] response-format configuration.
class InteractionSingleResponseFormat extends InteractionResponseFormatConfig {
  /// The response format.
  final InteractionResponseFormat format;

  /// Creates an [InteractionSingleResponseFormat].
  const InteractionSingleResponseFormat(this.format);

  @override
  Object toJson() => format.toJson();
}

/// A list of [InteractionResponseFormat]s as the response-format configuration.
class InteractionResponseFormatList extends InteractionResponseFormatConfig {
  /// The response formats.
  final List<InteractionResponseFormat> formats;

  /// Creates an [InteractionResponseFormatList].
  const InteractionResponseFormatList(this.formats);

  @override
  Object toJson() => formats.map((f) => f.toJson()).toList();
}
