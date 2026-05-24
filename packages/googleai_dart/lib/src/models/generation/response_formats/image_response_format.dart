import '../../copy_with_sentinel.dart';

/// MIME type of the image output.
enum ImageResponseFormatMimeType {
  /// Default value. This value is unused.
  unspecified,

  /// JPEG image format.
  imageJpeg,
}

/// Converts a string to an [ImageResponseFormatMimeType] enum value.
ImageResponseFormatMimeType imageResponseFormatMimeTypeFromString(
  String? value,
) {
  return switch (value) {
    'IMAGE_JPEG' => ImageResponseFormatMimeType.imageJpeg,
    _ => ImageResponseFormatMimeType.unspecified,
  };
}

/// Converts an [ImageResponseFormatMimeType] enum value to a string.
String imageResponseFormatMimeTypeToString(ImageResponseFormatMimeType value) {
  return switch (value) {
    ImageResponseFormatMimeType.imageJpeg => 'IMAGE_JPEG',
    ImageResponseFormatMimeType.unspecified => 'MIME_TYPE_UNSPECIFIED',
  };
}

/// The aspect ratio for the image output.
enum ImageResponseFormatAspectRatio {
  /// Default value. This value is unused.
  unspecified,

  /// 1:1 aspect ratio.
  oneByOne,

  /// 2:3 aspect ratio.
  twoByThree,

  /// 3:2 aspect ratio.
  threeByTwo,

  /// 3:4 aspect ratio.
  threeByFour,

  /// 4:3 aspect ratio.
  fourByThree,

  /// 4:5 aspect ratio.
  fourByFive,

  /// 5:4 aspect ratio.
  fiveByFour,

  /// 9:16 aspect ratio.
  nineBySixteen,

  /// 16:9 aspect ratio.
  sixteenByNine,

  /// 21:9 aspect ratio.
  twentyOneByNine,

  /// 1:8 aspect ratio.
  oneByEight,

  /// 8:1 aspect ratio.
  eightByOne,

  /// 1:4 aspect ratio.
  oneByFour,

  /// 4:1 aspect ratio.
  fourByOne,
}

/// Converts a string to an [ImageResponseFormatAspectRatio] enum value.
ImageResponseFormatAspectRatio imageResponseFormatAspectRatioFromString(
  String? value,
) {
  return switch (value) {
    'ASPECT_RATIO_ONE_BY_ONE' => ImageResponseFormatAspectRatio.oneByOne,
    'ASPECT_RATIO_TWO_BY_THREE' => ImageResponseFormatAspectRatio.twoByThree,
    'ASPECT_RATIO_THREE_BY_TWO' => ImageResponseFormatAspectRatio.threeByTwo,
    'ASPECT_RATIO_THREE_BY_FOUR' => ImageResponseFormatAspectRatio.threeByFour,
    'ASPECT_RATIO_FOUR_BY_THREE' => ImageResponseFormatAspectRatio.fourByThree,
    'ASPECT_RATIO_FOUR_BY_FIVE' => ImageResponseFormatAspectRatio.fourByFive,
    'ASPECT_RATIO_FIVE_BY_FOUR' => ImageResponseFormatAspectRatio.fiveByFour,
    'ASPECT_RATIO_NINE_BY_SIXTEEN' =>
      ImageResponseFormatAspectRatio.nineBySixteen,
    'ASPECT_RATIO_SIXTEEN_BY_NINE' =>
      ImageResponseFormatAspectRatio.sixteenByNine,
    'ASPECT_RATIO_TWENTY_ONE_BY_NINE' =>
      ImageResponseFormatAspectRatio.twentyOneByNine,
    'ASPECT_RATIO_ONE_BY_EIGHT' => ImageResponseFormatAspectRatio.oneByEight,
    'ASPECT_RATIO_EIGHT_BY_ONE' => ImageResponseFormatAspectRatio.eightByOne,
    'ASPECT_RATIO_ONE_BY_FOUR' => ImageResponseFormatAspectRatio.oneByFour,
    'ASPECT_RATIO_FOUR_BY_ONE' => ImageResponseFormatAspectRatio.fourByOne,
    _ => ImageResponseFormatAspectRatio.unspecified,
  };
}

/// Converts an [ImageResponseFormatAspectRatio] enum value to a string.
String imageResponseFormatAspectRatioToString(
  ImageResponseFormatAspectRatio value,
) {
  return switch (value) {
    ImageResponseFormatAspectRatio.oneByOne => 'ASPECT_RATIO_ONE_BY_ONE',
    ImageResponseFormatAspectRatio.twoByThree => 'ASPECT_RATIO_TWO_BY_THREE',
    ImageResponseFormatAspectRatio.threeByTwo => 'ASPECT_RATIO_THREE_BY_TWO',
    ImageResponseFormatAspectRatio.threeByFour => 'ASPECT_RATIO_THREE_BY_FOUR',
    ImageResponseFormatAspectRatio.fourByThree => 'ASPECT_RATIO_FOUR_BY_THREE',
    ImageResponseFormatAspectRatio.fourByFive => 'ASPECT_RATIO_FOUR_BY_FIVE',
    ImageResponseFormatAspectRatio.fiveByFour => 'ASPECT_RATIO_FIVE_BY_FOUR',
    ImageResponseFormatAspectRatio.nineBySixteen =>
      'ASPECT_RATIO_NINE_BY_SIXTEEN',
    ImageResponseFormatAspectRatio.sixteenByNine =>
      'ASPECT_RATIO_SIXTEEN_BY_NINE',
    ImageResponseFormatAspectRatio.twentyOneByNine =>
      'ASPECT_RATIO_TWENTY_ONE_BY_NINE',
    ImageResponseFormatAspectRatio.oneByEight => 'ASPECT_RATIO_ONE_BY_EIGHT',
    ImageResponseFormatAspectRatio.eightByOne => 'ASPECT_RATIO_EIGHT_BY_ONE',
    ImageResponseFormatAspectRatio.oneByFour => 'ASPECT_RATIO_ONE_BY_FOUR',
    ImageResponseFormatAspectRatio.fourByOne => 'ASPECT_RATIO_FOUR_BY_ONE',
    ImageResponseFormatAspectRatio.unspecified => 'ASPECT_RATIO_UNSPECIFIED',
  };
}

/// The size of the image output.
enum ImageResponseFormatImageSize {
  /// Default value. This value is unused.
  unspecified,

  /// 512px image size.
  fiveTwelve,

  /// 1K image size.
  oneK,

  /// 2K image size.
  twoK,

  /// 4K image size.
  fourK,
}

/// Converts a string to an [ImageResponseFormatImageSize] enum value.
ImageResponseFormatImageSize imageResponseFormatImageSizeFromString(
  String? value,
) {
  return switch (value) {
    'IMAGE_SIZE_FIVE_TWELVE' => ImageResponseFormatImageSize.fiveTwelve,
    'IMAGE_SIZE_ONE_K' => ImageResponseFormatImageSize.oneK,
    'IMAGE_SIZE_TWO_K' => ImageResponseFormatImageSize.twoK,
    'IMAGE_SIZE_FOUR_K' => ImageResponseFormatImageSize.fourK,
    _ => ImageResponseFormatImageSize.unspecified,
  };
}

/// Converts an [ImageResponseFormatImageSize] enum value to a string.
String imageResponseFormatImageSizeToString(
  ImageResponseFormatImageSize value,
) {
  return switch (value) {
    ImageResponseFormatImageSize.fiveTwelve => 'IMAGE_SIZE_FIVE_TWELVE',
    ImageResponseFormatImageSize.oneK => 'IMAGE_SIZE_ONE_K',
    ImageResponseFormatImageSize.twoK => 'IMAGE_SIZE_TWO_K',
    ImageResponseFormatImageSize.fourK => 'IMAGE_SIZE_FOUR_K',
    ImageResponseFormatImageSize.unspecified => 'IMAGE_SIZE_UNSPECIFIED',
  };
}

/// Delivery mode for an image response.
enum ImageResponseFormatDelivery {
  /// Default value. This value is unused.
  unspecified,

  /// Image data is returned inline in the response.
  inline,

  /// Image data is returned as a URI.
  uri,
}

/// Converts a string to an [ImageResponseFormatDelivery] enum value.
ImageResponseFormatDelivery imageResponseFormatDeliveryFromString(
  String? value,
) {
  return switch (value) {
    'INLINE' => ImageResponseFormatDelivery.inline,
    'URI' => ImageResponseFormatDelivery.uri,
    _ => ImageResponseFormatDelivery.unspecified,
  };
}

/// Converts an [ImageResponseFormatDelivery] enum value to a string.
String imageResponseFormatDeliveryToString(ImageResponseFormatDelivery value) {
  return switch (value) {
    ImageResponseFormatDelivery.inline => 'INLINE',
    ImageResponseFormatDelivery.uri => 'URI',
    ImageResponseFormatDelivery.unspecified => 'DELIVERY_UNSPECIFIED',
  };
}

/// Configuration for image output format.
class ImageResponseFormat {
  /// The MIME type of the image output.
  final ImageResponseFormatMimeType? mimeType;

  /// The aspect ratio for the image output.
  final ImageResponseFormatAspectRatio? aspectRatio;

  /// The size of the image output.
  final ImageResponseFormatImageSize? imageSize;

  /// The delivery mode for the image output.
  final ImageResponseFormatDelivery? delivery;

  /// Creates an [ImageResponseFormat].
  const ImageResponseFormat({
    this.mimeType,
    this.aspectRatio,
    this.imageSize,
    this.delivery,
  });

  /// Creates an [ImageResponseFormat] from JSON.
  factory ImageResponseFormat.fromJson(Map<String, dynamic> json) =>
      ImageResponseFormat(
        mimeType: json['mimeType'] != null
            ? imageResponseFormatMimeTypeFromString(json['mimeType'] as String)
            : null,
        aspectRatio: json['aspectRatio'] != null
            ? imageResponseFormatAspectRatioFromString(
                json['aspectRatio'] as String,
              )
            : null,
        imageSize: json['imageSize'] != null
            ? imageResponseFormatImageSizeFromString(
                json['imageSize'] as String,
              )
            : null,
        delivery: json['delivery'] != null
            ? imageResponseFormatDeliveryFromString(json['delivery'] as String)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mimeType != null)
      'mimeType': imageResponseFormatMimeTypeToString(mimeType!),
    if (aspectRatio != null)
      'aspectRatio': imageResponseFormatAspectRatioToString(aspectRatio!),
    if (imageSize != null)
      'imageSize': imageResponseFormatImageSizeToString(imageSize!),
    if (delivery != null)
      'delivery': imageResponseFormatDeliveryToString(delivery!),
  };

  /// Creates a copy with replaced values.
  ImageResponseFormat copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? aspectRatio = unsetCopyWithValue,
    Object? imageSize = unsetCopyWithValue,
    Object? delivery = unsetCopyWithValue,
  }) {
    return ImageResponseFormat(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as ImageResponseFormatMimeType?,
      aspectRatio: aspectRatio == unsetCopyWithValue
          ? this.aspectRatio
          : aspectRatio as ImageResponseFormatAspectRatio?,
      imageSize: imageSize == unsetCopyWithValue
          ? this.imageSize
          : imageSize as ImageResponseFormatImageSize?,
      delivery: delivery == unsetCopyWithValue
          ? this.delivery
          : delivery as ImageResponseFormatDelivery?,
    );
  }
}
