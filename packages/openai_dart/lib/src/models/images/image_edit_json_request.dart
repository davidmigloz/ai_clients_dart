import 'package:meta/meta.dart';

import 'image_common.dart';

/// Reference an input image by URL/data URL or uploaded file ID.
@immutable
class ImageReference {
  /// Fully qualified URL or data URL.
  final String? imageUrl;

  /// File API ID for an uploaded image.
  final String? fileId;

  /// Creates an [ImageReference].
  const ImageReference({this.imageUrl, this.fileId})
    : assert(
        (imageUrl == null) != (fileId == null),
        'Provide exactly one of imageUrl or fileId',
      );

  /// Creates a URL-based image reference.
  const ImageReference.url(String url) : this(imageUrl: url);

  /// Creates a file-ID image reference.
  const ImageReference.file(String id) : this(fileId: id);

  /// Creates an [ImageReference] from JSON.
  factory ImageReference.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['image_url'] as String?;
    final fileId = json['file_id'] as String?;
    if ((imageUrl == null) == (fileId == null)) {
      throw const FormatException(
        'ImageReference must have exactly one of imageUrl or fileId',
      );
    }
    return ImageReference(imageUrl: imageUrl, fileId: fileId);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageReference &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId;

  @override
  int get hashCode => Object.hash(imageUrl, fileId);

  @override
  String toString() => 'ImageReference(imageUrl: $imageUrl, fileId: $fileId)';
}

/// JSON request for image edits.
///
/// Uses references (`images`) instead of multipart file uploads.
@immutable
class ImageEditJsonRequest {
  /// Input image references.
  final List<ImageReference> images;

  /// The edit prompt.
  final String prompt;

  /// Optional mask reference.
  final ImageReference? mask;

  /// Optional model to use (e.g. `gpt-image-2`).
  final String? model;

  /// Number of images to generate.
  final int? n;

  /// Output quality.
  final ImageQuality? quality;

  /// Input fidelity.
  final ImageInputFidelity? inputFidelity;

  /// Requested output size.
  final ImageSize? size;

  /// End-user identifier.
  final String? user;

  /// Output format.
  final ImageOutputFormat? outputFormat;

  /// Compression level (0-100) for jpeg/webp.
  final int? outputCompression;

  /// Moderation level.
  final ImageModerationLevel? moderation;

  /// Background handling.
  final ImageBackground? background;

  /// Whether to stream partial image results.
  final bool? stream;

  /// Number of partial images to generate while streaming.
  final int? partialImages;

  /// Creates an [ImageEditJsonRequest].
  const ImageEditJsonRequest({
    required this.images,
    required this.prompt,
    this.mask,
    this.model,
    this.n,
    this.quality,
    this.inputFidelity,
    this.size,
    this.user,
    this.outputFormat,
    this.outputCompression,
    this.moderation,
    this.background,
    this.stream,
    this.partialImages,
  });

  /// Creates an [ImageEditJsonRequest] from JSON.
  factory ImageEditJsonRequest.fromJson(Map<String, dynamic> json) {
    return ImageEditJsonRequest(
      images: (json['images'] as List<dynamic>)
          .map((e) => ImageReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      prompt: json['prompt'] as String,
      mask: json['mask'] != null
          ? ImageReference.fromJson(json['mask'] as Map<String, dynamic>)
          : null,
      model: json['model'] as String?,
      n: json['n'] as int?,
      quality: json['quality'] != null
          ? ImageQuality.fromJson(json['quality'] as String)
          : null,
      inputFidelity: json['input_fidelity'] != null
          ? ImageInputFidelity.fromJson(json['input_fidelity'] as String)
          : null,
      size: json['size'] != null
          ? ImageSize.fromJson(json['size'] as String)
          : null,
      user: json['user'] as String?,
      outputFormat: json['output_format'] != null
          ? ImageOutputFormat.fromJson(json['output_format'] as String)
          : null,
      outputCompression: json['output_compression'] as int?,
      moderation: json['moderation'] != null
          ? ImageModerationLevel.fromJson(json['moderation'] as String)
          : null,
      background: json['background'] != null
          ? ImageBackground.fromJson(json['background'] as String)
          : null,
      stream: json['stream'] as bool?,
      partialImages: json['partial_images'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'images': images.map((e) => e.toJson()).toList(),
    'prompt': prompt,
    if (mask != null) 'mask': mask!.toJson(),
    if (model != null) 'model': model,
    if (n != null) 'n': n,
    if (quality != null) 'quality': quality!.toJson(),
    if (inputFidelity != null) 'input_fidelity': inputFidelity!.toJson(),
    if (size != null) 'size': size!.toJson(),
    if (user != null) 'user': user,
    if (outputFormat != null) 'output_format': outputFormat!.toJson(),
    if (outputCompression != null) 'output_compression': outputCompression,
    if (moderation != null) 'moderation': moderation!.toJson(),
    if (background != null) 'background': background!.toJson(),
    if (stream != null) 'stream': stream,
    if (partialImages != null) 'partial_images': partialImages,
  };
}

/// Backwards-compatible alias — quality values for JSON image edits now share
/// the unified [ImageQuality] enum.
@Deprecated('Use ImageQuality instead.')
typedef ImageEditJsonQuality = ImageQuality;

/// Backwards-compatible alias — size values for JSON image edits now share
/// the unified [ImageSize] enum.
@Deprecated('Use ImageSize instead.')
typedef ImageEditJsonSize = ImageSize;
