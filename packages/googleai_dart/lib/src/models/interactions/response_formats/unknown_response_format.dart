part of 'response_formats.dart';

/// A [ResponseFormat] whose `type` is not one of the documented variants
/// (`audio`/`text`/`image`/`video`).
///
/// The spec's `ResponseFormat` union includes an open `{ "type": object }`
/// member for arbitrary objects (e.g. a bare JSON schema). Such values, and any
/// future variants, are surfaced here with their raw JSON preserved instead of
/// failing to parse.
class UnknownResponseFormat extends ResponseFormat {
  @override
  final String type;

  /// The raw JSON payload of the response format, preserved verbatim.
  final Map<String, dynamic> json;

  /// Creates an [UnknownResponseFormat] instance.
  const UnknownResponseFormat({required this.type, required this.json});

  /// Creates an [UnknownResponseFormat] from JSON.
  factory UnknownResponseFormat.fromJson(Map<String, dynamic> json) =>
      UnknownResponseFormat(type: json['type'] as String? ?? '', json: json);

  @override
  Map<String, dynamic> toJson() => json;
}
