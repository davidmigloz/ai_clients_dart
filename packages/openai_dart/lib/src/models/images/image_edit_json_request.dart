import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'image_common.dart';
import 'image_json_helpers.dart';

/// An image URL, data URL or uploaded file ID. Exactly one must be selected.
@immutable
class ImageReference {
  /// Creates one image reference; serialization also enforces the constraint.
  const ImageReference({this.imageUrl, this.fileId})
    : assert(
        (imageUrl == null) != (fileId == null),
        'Provide exactly one image reference',
      );

  /// References a fully qualified URL or data URL.
  const ImageReference.url(String url) : this(imageUrl: url);

  /// References an uploaded file.
  const ImageReference.file(String id) : this(fileId: id);

  /// Fully qualified URL/data URL, mutually exclusive with fileId.
  final String? imageUrl;

  /// Uploaded file ID, mutually exclusive with imageUrl.
  final String? fileId;

  /// Parses the closed reference without silently dropping fields.
  factory ImageReference.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => key != 'image_url' && key != 'file_id')) {
      throw const FormatException('ImageReference: unexpected field');
    }
    final imageUrl = optionalJsonString(json, 'image_url', 'ImageReference');
    final fileId = optionalJsonString(json, 'file_id', 'ImageReference');
    if ((imageUrl == null) == (fileId == null)) {
      throw const FormatException(
        'ImageReference: provide exactly one image reference',
      );
    }
    final ref = ImageReference(imageUrl: imageUrl, fileId: fileId);
    return ref..validate();
  }

  /// Validates before authentication, also when assertions are disabled.
  void validate() {
    if ((imageUrl == null) == (fileId == null)) {
      throw const FormatException(
        'ImageReference: provide exactly one image reference',
      );
    }
    if (imageUrl != null && imageUrl!.runes.length > 20971520) {
      throw const FormatException(
        'ImageReference.imageUrl: exceeds maximum length',
      );
    }
  }

  /// Converts to canonical JSON.
  Map<String, dynamic> toJson() {
    validate();
    return {
      if (imageUrl != null) 'image_url': imageUrl,
      if (fileId != null) 'file_id': fileId,
    };
  }

  /// Copies a reference; clear the previous branch when changing representation.
  ImageReference copyWith({
    Object? imageUrl = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
  }) => ImageReference(
    imageUrl: copyImageValue<String>(
      imageUrl,
      this.imageUrl,
      'ImageReference.imageUrl',
    ),
    fileId: copyImageValue<String>(
      fileId,
      this.fileId,
      'ImageReference.fileId',
    ),
  )..validate();
  @override
  bool operator ==(Object other) =>
      other is ImageReference &&
      runtimeType == other.runtimeType &&
      imageUrl == other.imageUrl &&
      fileId == other.fileId;
  @override
  int get hashCode => Object.hash(imageUrl, fileId);
  @override
  String toString() =>
      'ImageReference(imageUrl: ${imageIdentifierSummary(imageUrl)}, fileId: ${imageIdentifierSummary(fileId)})';
}

/// Image edits using JSON image references instead of multipart binary uploads.
///
/// Owns its input list. A markup PNG must match the first image after orientation
/// and include transparent pixels; the service validates remote image contents.
@immutable
class ImageEditJsonRequest {
  /// Captures and validates a detached list of image references.
  ImageEditJsonRequest({
    required List<ImageReference> images,
    required this.prompt,
    this.mask,
    this.markup,
    this.model,
    this.n,
    this.quality,
    this.inputFidelity,
    this.size,
    @Deprecated('Use safetyIdentifier instead.') this.user,
    this.safetyIdentifier,
    this.outputFormat,
    this.outputCompression,
    this.moderation,
    this.background,
    this.stream,
    this.partialImages,
  }) : images = List<ImageReference>.unmodifiable(images) {
    validate();
  }

  /// Input image references (one through sixteen).
  final List<ImageReference> images;

  /// The edit prompt, one through 32,000 Unicode code points.
  final String prompt;

  /// Optional PNG mask reference; cannot be combined with markup.
  final ImageReference? mask;

  /// Transparent PNG overlay reference for the first input image. Dimensions must match after orientation; supports GPT Image 2.5/2.6.
  final ImageReference? markup;

  /// Explicit GPT image model. Omission leaves the service default unchanged.
  final String? model;

  /// Number of images to generate.
  final int? n;

  /// Output quality for the selected model.
  final ImageQuality? quality;

  /// Supported on gpt-image-1.5; gpt-image-1-mini supports low only. Omit for gpt-image-2.
  final ImageInputFidelity? inputFidelity;

  /// Output dimensions, including custom supported resolutions.
  final ImageSize? size;

  /// Legacy end-user identifier; a nonempty safetyIdentifier takes precedence.
  @Deprecated('Use safetyIdentifier instead.')
  final String? user;

  /// Stable privacy-preserving identifier, at most 128 Unicode code points. Null or empty permits the legacy user fallback.
  final String? safetyIdentifier;

  /// Output image format.
  final ImageOutputFormat? outputFormat;

  /// Compression level for JPEG/WebP output.
  final int? outputCompression;

  /// Moderation level for image generation.
  final ImageModerationLevel? moderation;

  /// Output background handling.
  final ImageBackground? background;

  /// Whether to request partial image events.
  final bool? stream;

  /// Number of partial image events requested.
  final int? partialImages;

  /// Parses known fields without coercion.
  factory ImageEditJsonRequest.fromJson(Map<String, dynamic> json) {
    final input = json['images'];
    if (input is! List) {
      throw const FormatException(
        'ImageEditJsonRequest.images: expected an array',
      );
    }
    return ImageEditJsonRequest(
      images: [
        for (final value in input)
          ImageReference.fromJson(
            requireJsonObject(value, 'ImageEditJsonRequest.images'),
          ),
      ],
      prompt: requireJsonString(json['prompt'], 'ImageEditJsonRequest.prompt'),
      mask: json.containsKey('mask')
          ? ImageReference.fromJson(
              requireJsonObject(json['mask'], 'ImageEditJsonRequest.mask'),
            )
          : null,
      markup: json.containsKey('markup')
          ? ImageReference.fromJson(
              requireJsonObject(json['markup'], 'ImageEditJsonRequest.markup'),
            )
          : null,
      model: optionalJsonString(
        json,
        'model',
        'ImageEditJsonRequest',
        nullable: true,
      ),
      n: json['n'] as int?,
      quality: json['quality'] == null
          ? null
          : ImageQuality.fromJson(
              requireJsonString(
                json['quality'],
                'ImageEditJsonRequest.quality',
              ),
            ),
      inputFidelity: json['input_fidelity'] == null
          ? null
          : ImageInputFidelity.fromJson(
              requireJsonString(
                json['input_fidelity'],
                'ImageEditJsonRequest.inputFidelity',
              ),
            ),
      size: json['size'] == null
          ? null
          : ImageSize.fromJson(
              requireJsonString(json['size'], 'ImageEditJsonRequest.size'),
            ),
      user: optionalJsonString(
        json,
        'user',
        'ImageEditJsonRequest',
        nullable: false,
      ),
      safetyIdentifier: readImageSafetyIdentifier(json, 'ImageEditJsonRequest'),
      outputFormat: json['output_format'] == null
          ? null
          : ImageOutputFormat.fromJson(
              requireJsonString(
                json['output_format'],
                'ImageEditJsonRequest.outputFormat',
              ),
            ),
      outputCompression: json['output_compression'] as int?,
      moderation: json['moderation'] == null
          ? null
          : ImageModerationLevel.fromJson(
              requireJsonString(
                json['moderation'],
                'ImageEditJsonRequest.moderation',
              ),
            ),
      background: json['background'] == null
          ? null
          : ImageBackground.fromJson(
              requireJsonString(
                json['background'],
                'ImageEditJsonRequest.background',
              ),
            ),
      stream: json['stream'] as bool?,
      partialImages: json['partial_images'] as int?,
    );
  }

  /// Validates the selected encoding before authentication or dispatch.
  void validate() {
    validateImageSafetyIdentifier(safetyIdentifier);
    if (mask != null && markup != null) {
      throw const FormatException(
        'ImageEditJsonRequest: mask and markup are mutually exclusive',
      );
    }
    if (images.isEmpty || images.length > 16) {
      throw const FormatException(
        'ImageEditJsonRequest.images: expected 1-16 images',
      );
    }
    if (prompt.isEmpty || prompt.runes.length > 32000) {
      throw const FormatException(
        'ImageEditJsonRequest.prompt: invalid length',
      );
    }
    if (inputFidelity == ImageInputFidelity.unknown) {
      throw const FormatException(
        'ImageEditJsonRequest.inputFidelity: unsupported request value',
      );
    }
    for (final image in images) {
      image.validate();
    }
    mask?.validate();
    markup?.validate();
  }

  /// Converts to JSON without inserting request defaults.
  Map<String, dynamic> toJson() {
    validate();
    return {
      'images': images.map((image) => image.toJson()).toList(),
      'prompt': prompt,
      if (mask != null) 'mask': mask!.toJson(),
      if (markup != null) 'markup': markup!.toJson(),
      if (model != null) 'model': model,
      if (n != null) 'n': n,
      if (quality != null) 'quality': quality!.toJson(),
      if (inputFidelity != null) 'input_fidelity': inputFidelity!.toJson(),
      if (size != null) 'size': size!.toJson(),
      if (user != null) 'user': user,
      if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
      if (outputFormat != null) 'output_format': outputFormat!.toJson(),
      if (outputCompression != null) 'output_compression': outputCompression,
      if (moderation != null) 'moderation': moderation!.toJson(),
      if (background != null) 'background': background!.toJson(),
      if (stream != null) 'stream': stream,
      if (partialImages != null) 'partial_images': partialImages,
    };
  }

  /// Copies all fields; null omits optional values locally.
  ImageEditJsonRequest copyWith({
    List<ImageReference>? images,
    String? prompt,
    Object? mask = unsetCopyWithValue,
    Object? markup = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? quality = unsetCopyWithValue,
    Object? inputFidelity = unsetCopyWithValue,
    Object? size = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
    Object? safetyIdentifier = unsetCopyWithValue,
    Object? outputFormat = unsetCopyWithValue,
    Object? outputCompression = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? background = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? partialImages = unsetCopyWithValue,
  }) => ImageEditJsonRequest(
    images: images ?? this.images,
    prompt: prompt ?? this.prompt,
    mask: copyImageValue<ImageReference>(
      mask,
      this.mask,
      'ImageEditJsonRequest.mask',
    ),
    markup: copyImageValue<ImageReference>(
      markup,
      this.markup,
      'ImageEditJsonRequest.markup',
    ),
    model: copyImageValue<String>(
      model,
      this.model,
      'ImageEditJsonRequest.model',
    ),
    n: copyImageValue<int>(n, this.n, 'ImageEditJsonRequest.n'),
    quality: copyImageValue<ImageQuality>(
      quality,
      this.quality,
      'ImageEditJsonRequest.quality',
    ),
    inputFidelity: copyImageValue<ImageInputFidelity>(
      inputFidelity,
      this.inputFidelity,
      'ImageEditJsonRequest.inputFidelity',
    ),
    size: copyImageValue<ImageSize>(
      size,
      this.size,
      'ImageEditJsonRequest.size',
    ),
    user: copyImageValue<String>(user, this.user, 'ImageEditJsonRequest.user'),
    safetyIdentifier: copyImageValue<String>(
      safetyIdentifier,
      this.safetyIdentifier,
      'ImageEditJsonRequest.safetyIdentifier',
    ),
    outputFormat: copyImageValue<ImageOutputFormat>(
      outputFormat,
      this.outputFormat,
      'ImageEditJsonRequest.outputFormat',
    ),
    outputCompression: copyImageValue<int>(
      outputCompression,
      this.outputCompression,
      'ImageEditJsonRequest.outputCompression',
    ),
    moderation: copyImageValue<ImageModerationLevel>(
      moderation,
      this.moderation,
      'ImageEditJsonRequest.moderation',
    ),
    background: copyImageValue<ImageBackground>(
      background,
      this.background,
      'ImageEditJsonRequest.background',
    ),
    stream: copyImageValue<bool>(
      stream,
      this.stream,
      'ImageEditJsonRequest.stream',
    ),
    partialImages: copyImageValue<int>(
      partialImages,
      this.partialImages,
      'ImageEditJsonRequest.partialImages',
    ),
  );
  @override
  bool operator ==(Object other) =>
      other is ImageEditJsonRequest &&
      runtimeType == other.runtimeType &&
      mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => mapDeepHashCode(toJson());
  @override
  String toString() =>
      'ImageEditJsonRequest(images: ${images.length}, prompt: ${prompt.length} chars, mask: $mask, markup: $markup, model: $model, n: $n, quality: $quality, inputFidelity: $inputFidelity, size: $size, user: ${imageIdentifierSummary(user)}, safetyIdentifier: ${imageIdentifierSummary(safetyIdentifier)}, outputFormat: $outputFormat, outputCompression: $outputCompression, moderation: $moderation, background: $background, stream: $stream, partialImages: $partialImages)';
}

/// Legacy quality alias; prefer the common image quality enum.
@Deprecated('Use ImageQuality instead.')
typedef ImageEditJsonQuality = ImageQuality;

/// Legacy size alias; prefer the common image size type.
@Deprecated('Use ImageSize instead.')
typedef ImageEditJsonSize = ImageSize;
