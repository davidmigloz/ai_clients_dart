import '../../copy_with_sentinel.dart';

part 'audio_response_format.dart';
part 'image_response_format.dart';
part 'response_format_config.dart';
part 'text_response_format.dart';
part 'unknown_response_format.dart';

/// A single response format for an interaction.
///
/// This is a sealed class with subtypes [InteractionAudioResponseFormat],
/// [InteractionTextResponseFormat], [InteractionImageResponseFormat], and
/// [UnknownInteractionResponseFormat] for the spec's open `{ "type": object }`
/// member.
///
/// To configure `response_format` on an interaction, wrap one or more of these
/// in an [InteractionResponseFormatConfig].
sealed class InteractionResponseFormat {
  /// The type discriminator for this response format.
  String get type;

  const InteractionResponseFormat();

  /// Creates an [InteractionResponseFormat] from JSON.
  ///
  /// Unrecognized `type` values are surfaced as
  /// [UnknownInteractionResponseFormat] (raw JSON preserved) to match the
  /// spec's open union member and stay forward-compatible.
  factory InteractionResponseFormat.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'audio' => InteractionAudioResponseFormat.fromJson(json),
      'text' => InteractionTextResponseFormat.fromJson(json),
      'image' => InteractionImageResponseFormat.fromJson(json),
      _ => UnknownInteractionResponseFormat.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
