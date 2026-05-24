part of 'response_formats.dart';

/// Aspect ratio for an image response.
enum InteractionImageResponseFormatAspectRatio {
  /// 1:1 aspect ratio.
  ratio1x1,

  /// 2:3 aspect ratio.
  ratio2x3,

  /// 3:2 aspect ratio.
  ratio3x2,

  /// 3:4 aspect ratio.
  ratio3x4,

  /// 4:3 aspect ratio.
  ratio4x3,

  /// 4:5 aspect ratio.
  ratio4x5,

  /// 5:4 aspect ratio.
  ratio5x4,

  /// 9:16 aspect ratio.
  ratio9x16,

  /// 16:9 aspect ratio.
  ratio16x9,

  /// 21:9 aspect ratio.
  ratio21x9,

  /// 1:8 aspect ratio.
  ratio1x8,

  /// 8:1 aspect ratio.
  ratio8x1,

  /// 1:4 aspect ratio.
  ratio1x4,

  /// 4:1 aspect ratio.
  ratio4x1,
}

/// Converts a JSON string to an [InteractionImageResponseFormatAspectRatio], or
/// `null` if unrecognized (forward-compatible).
InteractionImageResponseFormatAspectRatio?
interactionImageResponseFormatAspectRatioFromString(String? value) {
  return switch (value) {
    '1:1' => InteractionImageResponseFormatAspectRatio.ratio1x1,
    '2:3' => InteractionImageResponseFormatAspectRatio.ratio2x3,
    '3:2' => InteractionImageResponseFormatAspectRatio.ratio3x2,
    '3:4' => InteractionImageResponseFormatAspectRatio.ratio3x4,
    '4:3' => InteractionImageResponseFormatAspectRatio.ratio4x3,
    '4:5' => InteractionImageResponseFormatAspectRatio.ratio4x5,
    '5:4' => InteractionImageResponseFormatAspectRatio.ratio5x4,
    '9:16' => InteractionImageResponseFormatAspectRatio.ratio9x16,
    '16:9' => InteractionImageResponseFormatAspectRatio.ratio16x9,
    '21:9' => InteractionImageResponseFormatAspectRatio.ratio21x9,
    '1:8' => InteractionImageResponseFormatAspectRatio.ratio1x8,
    '8:1' => InteractionImageResponseFormatAspectRatio.ratio8x1,
    '1:4' => InteractionImageResponseFormatAspectRatio.ratio1x4,
    '4:1' => InteractionImageResponseFormatAspectRatio.ratio4x1,
    _ => null,
  };
}

/// Converts an [InteractionImageResponseFormatAspectRatio] to its JSON string.
String interactionImageResponseFormatAspectRatioToString(
  InteractionImageResponseFormatAspectRatio value,
) {
  return switch (value) {
    InteractionImageResponseFormatAspectRatio.ratio1x1 => '1:1',
    InteractionImageResponseFormatAspectRatio.ratio2x3 => '2:3',
    InteractionImageResponseFormatAspectRatio.ratio3x2 => '3:2',
    InteractionImageResponseFormatAspectRatio.ratio3x4 => '3:4',
    InteractionImageResponseFormatAspectRatio.ratio4x3 => '4:3',
    InteractionImageResponseFormatAspectRatio.ratio4x5 => '4:5',
    InteractionImageResponseFormatAspectRatio.ratio5x4 => '5:4',
    InteractionImageResponseFormatAspectRatio.ratio9x16 => '9:16',
    InteractionImageResponseFormatAspectRatio.ratio16x9 => '16:9',
    InteractionImageResponseFormatAspectRatio.ratio21x9 => '21:9',
    InteractionImageResponseFormatAspectRatio.ratio1x8 => '1:8',
    InteractionImageResponseFormatAspectRatio.ratio8x1 => '8:1',
    InteractionImageResponseFormatAspectRatio.ratio1x4 => '1:4',
    InteractionImageResponseFormatAspectRatio.ratio4x1 => '4:1',
  };
}

/// Image size for an image response.
enum InteractionImageResponseFormatSize {
  /// 512px image size.
  size512,

  /// 1K image size.
  size1k,

  /// 2K image size.
  size2k,

  /// 4K image size.
  size4k,
}

/// Converts a JSON string to an [InteractionImageResponseFormatSize], or `null`
/// if unrecognized (forward-compatible).
InteractionImageResponseFormatSize?
interactionImageResponseFormatSizeFromString(String? value) {
  return switch (value) {
    '512' => InteractionImageResponseFormatSize.size512,
    '1K' => InteractionImageResponseFormatSize.size1k,
    '2K' => InteractionImageResponseFormatSize.size2k,
    '4K' => InteractionImageResponseFormatSize.size4k,
    _ => null,
  };
}

/// Converts an [InteractionImageResponseFormatSize] to its JSON string.
String interactionImageResponseFormatSizeToString(
  InteractionImageResponseFormatSize value,
) {
  return switch (value) {
    InteractionImageResponseFormatSize.size512 => '512',
    InteractionImageResponseFormatSize.size1k => '1K',
    InteractionImageResponseFormatSize.size2k => '2K',
    InteractionImageResponseFormatSize.size4k => '4K',
  };
}

/// MIME type of the image output.
enum InteractionImageResponseFormatMimeType {
  /// JPEG image format (`image/jpeg`).
  imageJpeg,
}

/// Converts a JSON string to an [InteractionImageResponseFormatMimeType], or
/// `null` if unrecognized (forward-compatible).
InteractionImageResponseFormatMimeType?
interactionImageResponseFormatMimeTypeFromString(String? value) {
  return switch (value) {
    'image/jpeg' => InteractionImageResponseFormatMimeType.imageJpeg,
    _ => null,
  };
}

/// Converts an [InteractionImageResponseFormatMimeType] to its JSON string.
String interactionImageResponseFormatMimeTypeToString(
  InteractionImageResponseFormatMimeType value,
) {
  return switch (value) {
    InteractionImageResponseFormatMimeType.imageJpeg => 'image/jpeg',
  };
}

/// Delivery mode for an image response.
enum InteractionImageResponseFormatDelivery {
  /// Image data is returned inline in the response.
  inline,

  /// Image data is returned as a URI.
  uri,
}

/// Converts a JSON string to an [InteractionImageResponseFormatDelivery], or
/// `null` if unrecognized (forward-compatible).
InteractionImageResponseFormatDelivery?
interactionImageResponseFormatDeliveryFromString(String? value) {
  return switch (value) {
    'inline' => InteractionImageResponseFormatDelivery.inline,
    'uri' => InteractionImageResponseFormatDelivery.uri,
    _ => null,
  };
}

/// Converts an [InteractionImageResponseFormatDelivery] to its JSON string.
String interactionImageResponseFormatDeliveryToString(
  InteractionImageResponseFormatDelivery value,
) {
  return switch (value) {
    InteractionImageResponseFormatDelivery.inline => 'inline',
    InteractionImageResponseFormatDelivery.uri => 'uri',
  };
}

/// Configuration for image output format.
class InteractionImageResponseFormat extends InteractionResponseFormat {
  @override
  String get type => 'image';

  /// The aspect ratio of the image output.
  final InteractionImageResponseFormatAspectRatio? aspectRatio;

  /// The size of the image output.
  final InteractionImageResponseFormatSize? imageSize;

  /// The MIME type of the image output.
  final InteractionImageResponseFormatMimeType? mimeType;

  /// The delivery mode for the image output.
  final InteractionImageResponseFormatDelivery? delivery;

  /// Creates an [InteractionImageResponseFormat] instance.
  const InteractionImageResponseFormat({
    this.aspectRatio,
    this.imageSize,
    this.mimeType,
    this.delivery,
  });

  /// Creates an [InteractionImageResponseFormat] from JSON.
  factory InteractionImageResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image') {
      throw FormatException('Expected type "image" but got "${json['type']}"');
    }
    return InteractionImageResponseFormat(
      aspectRatio: interactionImageResponseFormatAspectRatioFromString(
        json['aspect_ratio'] as String?,
      ),
      imageSize: interactionImageResponseFormatSizeFromString(
        json['image_size'] as String?,
      ),
      mimeType: interactionImageResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      delivery: interactionImageResponseFormatDeliveryFromString(
        json['delivery'] as String?,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (aspectRatio != null)
      'aspect_ratio': interactionImageResponseFormatAspectRatioToString(
        aspectRatio!,
      ),
    if (imageSize != null)
      'image_size': interactionImageResponseFormatSizeToString(imageSize!),
    if (mimeType != null)
      'mime_type': interactionImageResponseFormatMimeTypeToString(mimeType!),
    if (delivery != null)
      'delivery': interactionImageResponseFormatDeliveryToString(delivery!),
  };

  /// Creates a copy with replaced values.
  InteractionImageResponseFormat copyWith({
    Object? aspectRatio = unsetCopyWithValue,
    Object? imageSize = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
  }) {
    return InteractionImageResponseFormat(
      aspectRatio: aspectRatio == unsetCopyWithValue
          ? this.aspectRatio
          : aspectRatio as InteractionImageResponseFormatAspectRatio?,
      imageSize: imageSize == unsetCopyWithValue
          ? this.imageSize
          : imageSize as InteractionImageResponseFormatSize?,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as InteractionImageResponseFormatMimeType?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as InteractionImageResponseFormatDelivery?,
    );
  }
}
