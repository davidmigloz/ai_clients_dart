part of 'response_formats.dart';

/// An [InteractionResponseFormat] whose `type` is not one of the documented
/// variants (`audio`/`text`/`image`).
///
/// The spec's `ResponseFormat` union includes an open `{ "type": object }`
/// member for arbitrary objects (e.g. a bare JSON schema). Such values, and any
/// future variants, are surfaced here with their raw JSON preserved instead of
/// failing to parse.
class UnknownInteractionResponseFormat extends InteractionResponseFormat {
  @override
  final String type;

  /// The raw JSON payload of the response format, preserved verbatim.
  final Map<String, dynamic> json;

  /// Creates an [UnknownInteractionResponseFormat] instance.
  const UnknownInteractionResponseFormat({
    required this.type,
    required this.json,
  });

  /// Creates an [UnknownInteractionResponseFormat] from JSON.
  factory UnknownInteractionResponseFormat.fromJson(
    Map<String, dynamic> json,
  ) => UnknownInteractionResponseFormat(
    type: json['type'] as String? ?? '',
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => json;
}
