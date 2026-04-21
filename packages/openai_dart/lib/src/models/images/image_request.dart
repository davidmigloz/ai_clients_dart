import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'image_common.dart';

/// A request to generate images from a text prompt.
///
/// Supports DALL-E and GPT image models (including `gpt-image-2`).
///
/// ## Example
///
/// ```dart
/// final request = ImageGenerationRequest(
///   prompt: 'A white cat wearing a top hat',
///   model: 'gpt-image-2',
///   size: ImageSize.size1024x1024,
///   quality: ImageQuality.high,
///   background: ImageBackground.transparent,
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
    this.background,
    this.moderation,
    this.outputFormat,
    this.outputCompression,
    this.stream,
    this.partialImages,
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
      background: json['background'] != null
          ? ImageBackground.fromJson(json['background'] as String)
          : null,
      moderation: json['moderation'] != null
          ? ImageModerationLevel.fromJson(json['moderation'] as String)
          : null,
      outputFormat: json['output_format'] != null
          ? ImageOutputFormat.fromJson(json['output_format'] as String)
          : null,
      outputCompression: json['output_compression'] as int?,
      stream: json['stream'] as bool?,
      partialImages: json['partial_images'] as int?,
    );
  }

  /// The text description of the desired image(s).
  ///
  /// Maximum length:
  /// - DALL-E 2: 1000 characters
  /// - DALL-E 3: 4000 characters
  /// - GPT image models: 32000 characters
  final String prompt;

  /// The model to use for generation.
  ///
  /// Examples:
  /// - `gpt-image-2` — flagship GPT image model (token-based pricing,
  ///   flexible sizes, high-fidelity inputs, Batch API support)
  /// - `gpt-image-1.5`, `gpt-image-1`, `gpt-image-1-mini`
  /// - `dall-e-3`, `dall-e-2`
  final String? model;

  /// The number of images to generate.
  ///
  /// For DALL-E 3, only 1 is supported. For DALL-E 2 and GPT image models,
  /// 1-10 images.
  final int? n;

  /// The quality of the generated images.
  ///
  /// `standard`/`hd` apply to DALL-E 3. `low`/`medium`/`high`/`auto` apply to
  /// GPT image models.
  final ImageQuality? quality;

  /// The format for the generated images.
  ///
  /// Only supported for DALL-E 2 and DALL-E 3. GPT image models always
  /// return base64-encoded data.
  final ImageResponseFormat? responseFormat;

  /// The size of the generated images.
  ///
  /// Supported sizes vary by model — see [ImageSize].
  final ImageSize? size;

  /// The style of the generated images.
  ///
  /// Only supported for DALL-E 3.
  final ImageStyle? style;

  /// A unique identifier representing your end-user.
  final String? user;

  /// Transparency of the background.
  ///
  /// Only supported for GPT image models.
  final ImageBackground? background;

  /// Content-moderation level.
  ///
  /// Only supported for GPT image models.
  final ImageModerationLevel? moderation;

  /// The format in which generated images are returned.
  ///
  /// Only supported for GPT image models.
  final ImageOutputFormat? outputFormat;

  /// Compression level (0-100) for `jpeg`/`webp` outputs.
  ///
  /// Only supported for GPT image models.
  final int? outputCompression;

  /// Whether to stream partial images via SSE.
  ///
  /// Only supported for GPT image models.
  final bool? stream;

  /// Number of partial images to emit while streaming.
  ///
  /// Only supported for GPT image models.
  final int? partialImages;

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
    if (background != null) 'background': background!.toJson(),
    if (moderation != null) 'moderation': moderation!.toJson(),
    if (outputFormat != null) 'output_format': outputFormat!.toJson(),
    if (outputCompression != null) 'output_compression': outputCompression,
    if (stream != null) 'stream': stream,
    if (partialImages != null) 'partial_images': partialImages,
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
    Object? background = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? outputFormat = unsetCopyWithValue,
    Object? outputCompression = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? partialImages = unsetCopyWithValue,
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
      background: background == unsetCopyWithValue
          ? this.background
          : background as ImageBackground?,
      moderation: moderation == unsetCopyWithValue
          ? this.moderation
          : moderation as ImageModerationLevel?,
      outputFormat: outputFormat == unsetCopyWithValue
          ? this.outputFormat
          : outputFormat as ImageOutputFormat?,
      outputCompression: outputCompression == unsetCopyWithValue
          ? this.outputCompression
          : outputCompression as int?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      partialImages: partialImages == unsetCopyWithValue
          ? this.partialImages
          : partialImages as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          model == other.model &&
          n == other.n &&
          quality == other.quality &&
          responseFormat == other.responseFormat &&
          size == other.size &&
          style == other.style &&
          user == other.user &&
          background == other.background &&
          moderation == other.moderation &&
          outputFormat == other.outputFormat &&
          outputCompression == other.outputCompression &&
          stream == other.stream &&
          partialImages == other.partialImages;

  @override
  int get hashCode => Object.hash(
    prompt,
    model,
    n,
    quality,
    responseFormat,
    size,
    style,
    user,
    background,
    moderation,
    outputFormat,
    outputCompression,
    stream,
    partialImages,
  );

  @override
  String toString() =>
      'ImageGenerationRequest(prompt: ${prompt.length} chars, model: $model, '
      'size: $size, quality: $quality, background: $background, '
      'outputFormat: $outputFormat)';
}

/// A request to edit an existing image via multipart upload.
///
/// Creates edits or extensions of an existing image using a prompt. For
/// GPT image models (e.g. `gpt-image-2`), supports high-fidelity inputs,
/// custom backgrounds, output format, and token-based pricing.
///
/// ## Example
///
/// ```dart
/// final request = ImageEditRequest(
///   image: originalImageBytes,
///   imageFilename: 'original.png',
///   prompt: 'Add a rainbow in the sky',
///   model: 'gpt-image-2',
///   inputFidelity: ImageInputFidelity.high,
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
    this.background,
    this.inputFidelity,
    this.quality,
    this.outputFormat,
    this.outputCompression,
    this.moderation,
    this.stream,
    this.partialImages,
  });

  /// The image to edit.
  ///
  /// For DALL-E 2: PNG, square, ≤4MB. For GPT image models: PNG/JPEG/WebP,
  /// any supported size.
  final Uint8List image;

  /// The filename of the image.
  final String imageFilename;

  /// The text description of the desired edit.
  ///
  /// Maximum length: 1000 characters (DALL-E 2) or 32000 (GPT image models).
  final String prompt;

  /// An optional mask image for inpainting.
  ///
  /// Transparent areas indicate where edits should be made.
  final Uint8List? mask;

  /// The filename of the mask image.
  final String? maskFilename;

  /// The model to use.
  ///
  /// Examples: `gpt-image-2`, `gpt-image-1.5`, `gpt-image-1-mini`,
  /// `chatgpt-image-latest`, `dall-e-2`.
  final String? model;

  /// The number of images to generate.
  final int? n;

  /// The size of the generated images.
  final ImageSize? size;

  /// The format for the generated images.
  ///
  /// Only supported for DALL-E 2.
  final ImageResponseFormat? responseFormat;

  /// A unique identifier representing your end-user.
  final String? user;

  /// Transparency of the background. GPT image models only.
  final ImageBackground? background;

  /// How closely the edit follows the input image. GPT image models only.
  final ImageInputFidelity? inputFidelity;

  /// Output quality. GPT image models only.
  final ImageQuality? quality;

  /// Output format. GPT image models only.
  final ImageOutputFormat? outputFormat;

  /// Compression level (0-100) for `jpeg`/`webp`. GPT image models only.
  final int? outputCompression;

  /// Content-moderation level. GPT image models only.
  final ImageModerationLevel? moderation;

  /// Whether to stream partial edits via SSE. GPT image models only.
  final bool? stream;

  /// Number of partial images to emit while streaming. GPT image models only.
  final int? partialImages;

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them. The
  /// required `image`, `imageFilename`, and `prompt` are passed through
  /// unchanged unless explicitly overridden.
  ImageEditRequest copyWith({
    Uint8List? image,
    String? imageFilename,
    String? prompt,
    Object? mask = unsetCopyWithValue,
    Object? maskFilename = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
    Object? background = unsetCopyWithValue,
    Object? inputFidelity = unsetCopyWithValue,
    Object? quality = unsetCopyWithValue,
    Object? outputFormat = unsetCopyWithValue,
    Object? outputCompression = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? partialImages = unsetCopyWithValue,
  }) {
    return ImageEditRequest(
      image: image ?? this.image,
      imageFilename: imageFilename ?? this.imageFilename,
      prompt: prompt ?? this.prompt,
      mask: mask == unsetCopyWithValue ? this.mask : mask as Uint8List?,
      maskFilename: maskFilename == unsetCopyWithValue
          ? this.maskFilename
          : maskFilename as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      n: n == unsetCopyWithValue ? this.n : n as int?,
      size: size == unsetCopyWithValue ? this.size : size as ImageSize?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ImageResponseFormat?,
      user: user == unsetCopyWithValue ? this.user : user as String?,
      background: background == unsetCopyWithValue
          ? this.background
          : background as ImageBackground?,
      inputFidelity: inputFidelity == unsetCopyWithValue
          ? this.inputFidelity
          : inputFidelity as ImageInputFidelity?,
      quality: quality == unsetCopyWithValue
          ? this.quality
          : quality as ImageQuality?,
      outputFormat: outputFormat == unsetCopyWithValue
          ? this.outputFormat
          : outputFormat as ImageOutputFormat?,
      outputCompression: outputCompression == unsetCopyWithValue
          ? this.outputCompression
          : outputCompression as int?,
      moderation: moderation == unsetCopyWithValue
          ? this.moderation
          : moderation as ImageModerationLevel?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      partialImages: partialImages == unsetCopyWithValue
          ? this.partialImages
          : partialImages as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageEditRequest &&
          runtimeType == other.runtimeType &&
          imageFilename == other.imageFilename &&
          maskFilename == other.maskFilename &&
          prompt == other.prompt &&
          model == other.model &&
          n == other.n &&
          size == other.size &&
          responseFormat == other.responseFormat &&
          user == other.user &&
          background == other.background &&
          inputFidelity == other.inputFidelity &&
          quality == other.quality &&
          outputFormat == other.outputFormat &&
          outputCompression == other.outputCompression &&
          moderation == other.moderation &&
          stream == other.stream &&
          partialImages == other.partialImages;

  @override
  int get hashCode => Object.hash(
    imageFilename,
    maskFilename,
    prompt,
    model,
    n,
    size,
    responseFormat,
    user,
    background,
    inputFidelity,
    quality,
    outputFormat,
    outputCompression,
    moderation,
    stream,
    partialImages,
  );

  @override
  String toString() =>
      'ImageEditRequest(image: $imageFilename, prompt: ${prompt.length} chars, '
      'model: $model, inputFidelity: $inputFidelity, quality: $quality)';
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

/// Image response format options.
enum ImageResponseFormat {
  /// Unknown format — forward-compat fallback for unrecognized values.
  unknown._('unknown'),

  /// Return a URL to the generated image.
  url._('url'),

  /// Return the image as base64-encoded JSON.
  b64Json._('b64_json');

  const ImageResponseFormat._(this._value);

  /// Creates from JSON string. Unknown values map to
  /// [ImageResponseFormat.unknown].
  factory ImageResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => ImageResponseFormat.unknown,
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
  /// Unknown style — forward-compat fallback for unrecognized values.
  unknown._('unknown'),

  /// Vivid style (more hyper-real and dramatic).
  vivid._('vivid'),

  /// Natural style (more realistic, less hyper-real).
  natural._('natural');

  const ImageStyle._(this._value);

  /// Creates from JSON string. Unknown values map to [ImageStyle.unknown].
  factory ImageStyle.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => ImageStyle.unknown,
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
