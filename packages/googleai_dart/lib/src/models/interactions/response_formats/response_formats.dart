import '../../copy_with_sentinel.dart';

part 'audio_response_format.dart';
part 'image_response_format.dart';
part 'response_format_config.dart';
part 'text_response_format.dart';
part 'unknown_response_format.dart';
part 'video_response_format.dart';

/// A single response format for an interaction.
///
/// This is a sealed class with subtypes [AudioResponseFormat],
/// [TextResponseFormat], [ImageResponseFormat], [VideoResponseFormat], and
/// [UnknownResponseFormat] for the spec's open `{ "type": object }` member.
///
/// To configure `response_format` on an interaction, wrap one or more of these
/// in a [ResponseFormatConfig].
sealed class ResponseFormat {
  /// The type discriminator for this response format.
  String get type;

  const ResponseFormat();

  /// Creates a [ResponseFormat] from JSON.
  ///
  /// Unrecognized `type` values are surfaced as [UnknownResponseFormat] (raw
  /// JSON preserved) to match the spec's open union member and stay
  /// forward-compatible.
  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'audio' => AudioResponseFormat.fromJson(json),
      'text' => TextResponseFormat.fromJson(json),
      'image' => ImageResponseFormat.fromJson(json),
      'video' => VideoResponseFormat.fromJson(json),
      _ => UnknownResponseFormat.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
