part of 'response_formats.dart';

/// Configuration for video output format.
///
/// Discriminator-only — the spec defines no additional fields.
class VideoResponseFormat extends ResponseFormat {
  @override
  String get type => 'video';

  /// Creates a [VideoResponseFormat] instance.
  const VideoResponseFormat();

  /// Creates a [VideoResponseFormat] from JSON.
  factory VideoResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'video') {
      throw FormatException('Expected type "video" but got "${json['type']}"');
    }
    return const VideoResponseFormat();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};
}
