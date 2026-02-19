import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A request to generate images from a text prompt.
///
/// Uses DALL-E models to create images from textual descriptions.
///
/// ## Example
///
/// ```dart
/// final request = ImageGenerationRequest(
///   prompt: 'A white cat wearing a top hat',
///   model: 'dall-e-3',
///   size: ImageSize.size1024x1024,
/// );
/// ```
@immutable
class ImageGenerationRequest {
  /// Creates an [ImageGenerationRequest].
  const ImageGenerationRequest({
    required this.prompt,
    this.model,
    this.n,
    this.quality,
    this.responseFormat,
    this.size,
    this.style,
    this.user,
  });

  /// Creates an [ImageGenerationRequest] from JSON.
  factory ImageGenerationRequest.fromJson(Map<String, dynamic> json) {
    return ImageGenerationRequest(
      prompt: json['prompt'] as String,
      model: json['model'] as String?,
      n: json['n'] as int?,
      quality: json['quality'] != null
          ? ImageQuality.fromJson(json['quality'] as String)
          : null,
      responseFormat: json['response_format'] != null
          ? ImageResponseFormat.fromJson(json['response_format'] as String)
          : null,
      size: json['size'] != null
          ? ImageSize.fromJson(json['size'] as String)
          : null,
      style: json['style'] != null
          ? ImageStyle.fromJson(json['style'] as String)
          : null,
      user: json['user'] as String?,
    );
  }

  /// The text description of the desired image(s).
  ///
  /// Maximum length:
  /// - DALL-E 2: 1000 characters
  /// - DALL-E 3: 4000 characters
  final String prompt;

  /// The model to use for generation.
  ///
  /// Available models:
  /// - `dall-e-3` - Higher quality, more expensive
  /// - `dall-e-2` - Faster, more affordable
  final String? model;

  /// The number of images to generate.
  ///
  /// For DALL-E 3, only 1 is supported. For DALL-E 2, 1-10 images.
  final int? n;

  /// The quality of the generated images.
  ///
  /// Only supported for DALL-E 3.
  final ImageQuality? quality;

  /// The format for the generated images.
  ///
  /// Defaults to `url`.
  final ImageResponseFormat? responseFormat;

  /// The size of the generated images.
  ///
  /// Supported sizes vary by model.
  final ImageSize? size;

  /// The style of the generated images.
  ///
  /// Only supported for DALL-E 3.
  final ImageStyle? style;

  /// A unique identifier representing your end-user.
  final String? user;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    if (model != null) 'model': model,
    if (n != null) 'n': n,
    if (quality != null) 'quality': quality!.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (size != null) 'size': size!.toJson(),
    if (style != null) 'style': style!.toJson(),
    if (user != null) 'user': user,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  ImageGenerationRequest copyWith({
    String? prompt,
    Object? model = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? quality = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? style = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
  }) {
    return ImageGenerationRequest(
      prompt: prompt ?? this.prompt,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      n: n == unsetCopyWithValue ? this.n : n as int?,
      quality: quality == unsetCopyWithValue
          ? this.quality
          : quality as ImageQuality?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ImageResponseFormat?,
      size: size == unsetCopyWithValue ? this.size : size as ImageSize?,
      style: style == unsetCopyWithValue ? this.style : style as ImageStyle?,
      user: user == unsetCopyWithValue ? this.user : user as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          model == other.model;

  @override
  int get hashCode => Object.hash(prompt, model);

  @override
  String toString() =>
      'ImageGenerationRequest(prompt: ${prompt.length} chars, model: $model)';
}

/// A request to edit an existing image.
///
/// Creates edits or extensions of an existing image using a prompt.
///
/// ## Example
///
/// ```dart
/// final request = ImageEditRequest(
///   image: originalImageBytes,
///   imageFilename: 'original.png',
///   prompt: 'Add a rainbow in the sky',
/// );
/// ```
@immutable
class ImageEditRequest {
  /// Creates an [ImageEditRequest].
  const ImageEditRequest({
    required this.image,
    required this.imageFilename,
    required this.prompt,
    this.mask,
    this.maskFilename,
    this.model,
    this.n,
    this.size,
    this.responseFormat,
    this.user,
  });

  /// The image to edit.
  ///
  /// Must be a valid PNG file, less than 4MB, and square.
  final Uint8List image;

  /// The filename of the image.
  final String imageFilename;

  /// The text description of the desired edit.
  ///
  /// Maximum length: 1000 characters.
  final String prompt;

  /// An optional mask image for inpainting.
  ///
  /// Must be a valid PNG file, less than 4MB, same dimensions as the image,
  /// with transparent areas indicating where edits should be made.
  final Uint8List? mask;

  /// The filename of the mask image.
  final String? maskFilename;

  /// The model to use.
  ///
  /// Only `dall-e-2` is supported.
  final String? model;

  /// The number of images to generate.
  final int? n;

  /// The size of the generated images.
  final ImageSize? size;

  /// The format for the generated images.
  final ImageResponseFormat? responseFormat;

  /// A unique identifier representing your end-user.
  final String? user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditRequest &&
          runtimeType == other.runtimeType &&
          imageFilename == other.imageFilename &&
          prompt == other.prompt;

  @override
  int get hashCode => Object.hash(imageFilename, prompt);

  @override
  String toString() =>
      'ImageEditRequest(image: $imageFilename, prompt: ${prompt.length} chars)';
}

/// A request to create variations of an image.
///
/// Creates variations of an existing image.
///
/// ## Example
///
/// ```dart
/// final request = ImageVariationRequest(
///   image: originalImageBytes,
///   imageFilename: 'original.png',
///   n: 3,
/// );
/// ```
@immutable
class ImageVariationRequest {
  /// Creates an [ImageVariationRequest].
  const ImageVariationRequest({
    required this.image,
    required this.imageFilename,
    this.model,
    this.n,
    this.responseFormat,
    this.size,
    this.user,
  });

  /// The image to use as the basis for variations.
  ///
  /// Must be a valid PNG file, less than 4MB, and square.
  final Uint8List image;

  /// The filename of the image.
  final String imageFilename;

  /// The model to use.
  ///
  /// Only `dall-e-2` is supported.
  final String? model;

  /// The number of images to generate.
  final int? n;

  /// The format for the generated images.
  final ImageResponseFormat? responseFormat;

  /// The size of the generated images.
  final ImageSize? size;

  /// A unique identifier representing your end-user.
  final String? user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageVariationRequest &&
          runtimeType == other.runtimeType &&
          imageFilename == other.imageFilename;

  @override
  int get hashCode => imageFilename.hashCode;

  @override
  String toString() => 'ImageVariationRequest(image: $imageFilename)';
}

/// Image quality options.
enum ImageQuality {
  /// Standard quality.
  standard._('standard'),

  /// HD quality (higher detail).
  hd._('hd');

  const ImageQuality._(this._value);

  /// Creates from JSON string.
  factory ImageQuality.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown quality: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Image response format options.
enum ImageResponseFormat {
  /// Return a URL to the generated image.
  url._('url'),

  /// Return the image as base64-encoded JSON.
  b64Json._('b64_json');

  const ImageResponseFormat._(this._value);

  /// Creates from JSON string.
  factory ImageResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown format: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Image size options.
enum ImageSize {
  /// 256x256 pixels.
  size256x256._('256x256'),

  /// 512x512 pixels.
  size512x512._('512x512'),

  /// 1024x1024 pixels.
  size1024x1024._('1024x1024'),

  /// 1792x1024 pixels (DALL-E 3 only).
  size1792x1024._('1792x1024'),

  /// 1024x1792 pixels (DALL-E 3 only).
  size1024x1792._('1024x1792');

  const ImageSize._(this._value);

  /// Creates from JSON string.
  factory ImageSize.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown size: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Image style options.
enum ImageStyle {
  /// Vivid style (more hyper-real and dramatic).
  vivid._('vivid'),

  /// Natural style (more realistic, less hyper-real).
  natural._('natural');

  const ImageStyle._(this._value);

  /// Creates from JSON string.
  factory ImageStyle.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown style: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
