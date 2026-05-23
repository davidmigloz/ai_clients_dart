part of 'response_formats.dart';

/// Aspect ratio for an image response.
enum ImageResponseFormatAspectRatio {
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

/// Converts a JSON string to an [ImageResponseFormatAspectRatio], or `null`
/// if unrecognized (forward-compatible).
ImageResponseFormatAspectRatio? imageResponseFormatAspectRatioFromString(
  String? value,
) {
  return switch (value) {
    '1:1' => ImageResponseFormatAspectRatio.ratio1x1,
    '2:3' => ImageResponseFormatAspectRatio.ratio2x3,
    '3:2' => ImageResponseFormatAspectRatio.ratio3x2,
    '3:4' => ImageResponseFormatAspectRatio.ratio3x4,
    '4:3' => ImageResponseFormatAspectRatio.ratio4x3,
    '4:5' => ImageResponseFormatAspectRatio.ratio4x5,
    '5:4' => ImageResponseFormatAspectRatio.ratio5x4,
    '9:16' => ImageResponseFormatAspectRatio.ratio9x16,
    '16:9' => ImageResponseFormatAspectRatio.ratio16x9,
    '21:9' => ImageResponseFormatAspectRatio.ratio21x9,
    '1:8' => ImageResponseFormatAspectRatio.ratio1x8,
    '8:1' => ImageResponseFormatAspectRatio.ratio8x1,
    '1:4' => ImageResponseFormatAspectRatio.ratio1x4,
    '4:1' => ImageResponseFormatAspectRatio.ratio4x1,
    _ => null,
  };
}

/// Converts an [ImageResponseFormatAspectRatio] to its JSON string.
String imageResponseFormatAspectRatioToString(
  ImageResponseFormatAspectRatio value,
) {
  return switch (value) {
    ImageResponseFormatAspectRatio.ratio1x1 => '1:1',
    ImageResponseFormatAspectRatio.ratio2x3 => '2:3',
    ImageResponseFormatAspectRatio.ratio3x2 => '3:2',
    ImageResponseFormatAspectRatio.ratio3x4 => '3:4',
    ImageResponseFormatAspectRatio.ratio4x3 => '4:3',
    ImageResponseFormatAspectRatio.ratio4x5 => '4:5',
    ImageResponseFormatAspectRatio.ratio5x4 => '5:4',
    ImageResponseFormatAspectRatio.ratio9x16 => '9:16',
    ImageResponseFormatAspectRatio.ratio16x9 => '16:9',
    ImageResponseFormatAspectRatio.ratio21x9 => '21:9',
    ImageResponseFormatAspectRatio.ratio1x8 => '1:8',
    ImageResponseFormatAspectRatio.ratio8x1 => '8:1',
    ImageResponseFormatAspectRatio.ratio1x4 => '1:4',
    ImageResponseFormatAspectRatio.ratio4x1 => '4:1',
  };
}

/// Image size for an image response.
enum ImageResponseFormatSize {
  /// 512px image size.
  size512,

  /// 1K image size.
  size1k,

  /// 2K image size.
  size2k,

  /// 4K image size.
  size4k,
}

/// Converts a JSON string to an [ImageResponseFormatSize], or `null` if
/// unrecognized (forward-compatible).
ImageResponseFormatSize? imageResponseFormatSizeFromString(String? value) {
  return switch (value) {
    '512' => ImageResponseFormatSize.size512,
    '1K' => ImageResponseFormatSize.size1k,
    '2K' => ImageResponseFormatSize.size2k,
    '4K' => ImageResponseFormatSize.size4k,
    _ => null,
  };
}

/// Converts an [ImageResponseFormatSize] to its JSON string.
String imageResponseFormatSizeToString(ImageResponseFormatSize value) {
  return switch (value) {
    ImageResponseFormatSize.size512 => '512',
    ImageResponseFormatSize.size1k => '1K',
    ImageResponseFormatSize.size2k => '2K',
    ImageResponseFormatSize.size4k => '4K',
  };
}

/// MIME type of the image output.
enum ImageResponseFormatMimeType {
  /// JPEG image format (`image/jpeg`).
  imageJpeg,
}

/// Converts a JSON string to an [ImageResponseFormatMimeType], or `null` if
/// unrecognized (forward-compatible).
ImageResponseFormatMimeType? imageResponseFormatMimeTypeFromString(
  String? value,
) {
  return switch (value) {
    'image/jpeg' => ImageResponseFormatMimeType.imageJpeg,
    _ => null,
  };
}

/// Converts an [ImageResponseFormatMimeType] to its JSON string.
String imageResponseFormatMimeTypeToString(ImageResponseFormatMimeType value) {
  return switch (value) {
    ImageResponseFormatMimeType.imageJpeg => 'image/jpeg',
  };
}

/// Delivery mode for an image response.
enum ImageResponseFormatDelivery {
  /// Image data is returned inline in the response.
  inline,

  /// Image data is returned as a URL.
  url,
}

/// Converts a JSON string to an [ImageResponseFormatDelivery], or `null` if
/// unrecognized (forward-compatible).
ImageResponseFormatDelivery? imageResponseFormatDeliveryFromString(
  String? value,
) {
  return switch (value) {
    'inline' => ImageResponseFormatDelivery.inline,
    'url' => ImageResponseFormatDelivery.url,
    _ => null,
  };
}

/// Converts an [ImageResponseFormatDelivery] to its JSON string.
String imageResponseFormatDeliveryToString(ImageResponseFormatDelivery value) {
  return switch (value) {
    ImageResponseFormatDelivery.inline => 'inline',
    ImageResponseFormatDelivery.url => 'url',
  };
}

/// Configuration for image output format.
class ImageResponseFormat extends ResponseFormat {
  @override
  String get type => 'image';

  /// The aspect ratio of the image output.
  final ImageResponseFormatAspectRatio? aspectRatio;

  /// The size of the image output.
  final ImageResponseFormatSize? imageSize;

  /// The MIME type of the image output.
  final ImageResponseFormatMimeType? mimeType;

  /// The delivery mode for the image output.
  final ImageResponseFormatDelivery? delivery;

  /// Creates an [ImageResponseFormat] instance.
  const ImageResponseFormat({
    this.aspectRatio,
    this.imageSize,
    this.mimeType,
    this.delivery,
  });

  /// Creates an [ImageResponseFormat] from JSON.
  factory ImageResponseFormat.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image') {
      throw FormatException('Expected type "image" but got "${json['type']}"');
    }
    return ImageResponseFormat(
      aspectRatio: imageResponseFormatAspectRatioFromString(
        json['aspect_ratio'] as String?,
      ),
      imageSize: imageResponseFormatSizeFromString(
        json['image_size'] as String?,
      ),
      mimeType: imageResponseFormatMimeTypeFromString(
        json['mime_type'] as String?,
      ),
      delivery: imageResponseFormatDeliveryFromString(
        json['delivery'] as String?,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (aspectRatio != null)
      'aspect_ratio': imageResponseFormatAspectRatioToString(aspectRatio!),
    if (imageSize != null)
      'image_size': imageResponseFormatSizeToString(imageSize!),
    if (mimeType != null)
      'mime_type': imageResponseFormatMimeTypeToString(mimeType!),
    if (delivery != null)
      'delivery': imageResponseFormatDeliveryToString(delivery!),
  };

  /// Creates a copy with replaced values.
  ImageResponseFormat copyWith({
    Object? aspectRatio = unsetCopyWithValue,
    Object? imageSize = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
  }) {
    return ImageResponseFormat(
      aspectRatio: aspectRatio == unsetCopyWithValue
          ? this.aspectRatio
          : aspectRatio as ImageResponseFormatAspectRatio?,
      imageSize: imageSize == unsetCopyWithValue
          ? this.imageSize
          : imageSize as ImageResponseFormatSize?,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as ImageResponseFormatMimeType?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as ImageResponseFormatDelivery?,
    );
  }
}
