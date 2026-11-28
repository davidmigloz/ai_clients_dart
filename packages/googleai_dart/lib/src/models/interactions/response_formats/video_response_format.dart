part of 'response_formats.dart';

/// Aspect ratio for a video response.
enum InteractionVideoResponseFormatAspectRatio {
  /// 16:9 aspect ratio.
  ratio16x9,

  /// 9:16 aspect ratio.
  ratio9x16,
}

/// Converts a JSON string to an [InteractionVideoResponseFormatAspectRatio],
/// or `null` if unrecognized (forward-compatible).
InteractionVideoResponseFormatAspectRatio?
interactionVideoResponseFormatAspectRatioFromString(String? value) {
  return switch (value) {
    '16:9' => InteractionVideoResponseFormatAspectRatio.ratio16x9,
    '9:16' => InteractionVideoResponseFormatAspectRatio.ratio9x16,
    _ => null,
  };
}

/// Converts an [InteractionVideoResponseFormatAspectRatio] to its JSON
/// string.
String interactionVideoResponseFormatAspectRatioToString(
  InteractionVideoResponseFormatAspectRatio value,
) {
  return switch (value) {
    InteractionVideoResponseFormatAspectRatio.ratio16x9 => '16:9',
    InteractionVideoResponseFormatAspectRatio.ratio9x16 => '9:16',
  };
}

/// Delivery mode for a video response.
enum InteractionVideoResponseFormatDelivery {
  /// Video data is returned inline in the response.
  inline,

  /// Video data is returned as a URI.
  uri,
}

/// Converts a JSON string to an [InteractionVideoResponseFormatDelivery], or
/// `null` if unrecognized (forward-compatible).
InteractionVideoResponseFormatDelivery?
interactionVideoResponseFormatDeliveryFromString(String? value) {
  return switch (value) {
    'inline' => InteractionVideoResponseFormatDelivery.inline,
    'uri' => InteractionVideoResponseFormatDelivery.uri,
    _ => null,
  };
}

/// Converts an [InteractionVideoResponseFormatDelivery] to its JSON string.
String interactionVideoResponseFormatDeliveryToString(
  InteractionVideoResponseFormatDelivery value,
) {
  return switch (value) {
    InteractionVideoResponseFormatDelivery.inline => 'inline',
    InteractionVideoResponseFormatDelivery.uri => 'uri',
  };
}

/// Resolution of generated video, preserving newer API values.
extension type const InteractionVideoResponseResolution(String value) {
  /// 360p video.
  static const p360 = InteractionVideoResponseResolution('360p');

  /// 720p video.
  static const p720 = InteractionVideoResponseResolution('720p');

  /// 1080p video.
  static const p1080 = InteractionVideoResponseResolution('1080p');

  /// 4K video.
  static const uhd4k = InteractionVideoResponseResolution('4k');
}

/// Configuration for video output format.
class InteractionVideoResponseFormat extends InteractionResponseFormat {
  @override
  String get type => 'video';

  /// The aspect ratio for the video output.
  final InteractionVideoResponseFormatAspectRatio? aspectRatio;

  /// The delivery mode for the video output.
  final InteractionVideoResponseFormatDelivery? delivery;

  /// The output resolution, where supported by the selected model.
  final InteractionVideoResponseResolution? resolution;

  /// The duration for the video output.
  final String? duration;

  /// The GCS URI to store the video output. Required for Vertex if delivery
  /// mode is URI.
  final String? gcsUri;

  /// Creates an [InteractionVideoResponseFormat] instance.
  const InteractionVideoResponseFormat({
    this.aspectRatio,
    this.resolution,
    this.delivery,
    this.duration,
    this.gcsUri,
  });

  /// Creates an [InteractionVideoResponseFormat] from JSON.
  factory InteractionVideoResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'video') {
      throw FormatException('Expected type "video" but got "${json['type']}"');
    }
    return InteractionVideoResponseFormat(
      aspectRatio: interactionVideoResponseFormatAspectRatioFromString(
        json['aspect_ratio'] as String?,
      ),
      delivery: interactionVideoResponseFormatDeliveryFromString(
        json['delivery'] as String?,
      ),
      duration: json['duration'] as String?,
      resolution: json['resolution'] == null
          ? null
          : InteractionVideoResponseResolution(json['resolution'] as String),
      gcsUri: json['gcs_uri'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (aspectRatio != null)
      'aspect_ratio': interactionVideoResponseFormatAspectRatioToString(
        aspectRatio!,
      ),
    if (delivery != null)
      'delivery': interactionVideoResponseFormatDeliveryToString(delivery!),
    if (duration != null) 'duration': duration,
    'resolution': ?resolution?.value,
    if (gcsUri != null) 'gcs_uri': gcsUri,
  };

  /// Creates a copy with replaced values.
  InteractionVideoResponseFormat copyWith({
    Object? aspectRatio = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
    Object? duration = unsetCopyWithValue,
    Object? resolution = unsetCopyWithValue,
    Object? gcsUri = unsetCopyWithValue,
  }) {
    return InteractionVideoResponseFormat(
      aspectRatio: aspectRatio == unsetCopyWithValue
          ? this.aspectRatio
          : aspectRatio as InteractionVideoResponseFormatAspectRatio?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as InteractionVideoResponseFormatDelivery?,
      resolution: resolution == unsetCopyWithValue
          ? this.resolution
          : resolution as InteractionVideoResponseResolution?,
      duration: duration == unsetCopyWithValue
          ? this.duration
          : duration as String?,
      gcsUri: gcsUri == unsetCopyWithValue ? this.gcsUri : gcsUri as String?,
    );
  }
}
