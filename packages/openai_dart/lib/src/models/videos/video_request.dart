import 'package:meta/meta.dart';

import 'video.dart';

/// Request to create a new video generation job.
///
/// ## Example
///
/// ```dart
/// final video = await client.videos.create(
///   CreateVideoRequest(
///     prompt: 'A cat playing piano',
///     model: 'sora-2',
///     size: VideoSize.size1280x720,
///     seconds: VideoSeconds.s8,
///   ),
/// );
/// ```
@immutable
class CreateVideoRequest {
  /// Creates a [CreateVideoRequest].
  const CreateVideoRequest({
    required this.prompt,
    this.model,
    this.seconds,
    this.size,
    this.inputReference,
  });

  /// Text prompt that describes the video to generate.
  ///
  /// Maximum length is 32,000 characters.
  final String prompt;

  /// The video generation model to use.
  ///
  /// Allowed values: `sora-2`, `sora-2-pro`.
  /// Defaults to `sora-2`.
  final String? model;

  /// Clip duration in seconds.
  ///
  /// Allowed values: 4, 8, 12.
  /// Defaults to 4 seconds.
  final VideoSeconds? seconds;

  /// Output resolution.
  ///
  /// Defaults to 720x1280.
  final VideoSize? size;

  /// Optional reference image that guides generation.
  ///
  /// Provide a [VideoInputReference] with either an image URL or file ID.
  final VideoInputReference? inputReference;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    if (model != null) 'model': model,
    if (seconds != null) 'seconds': seconds!.toJson(),
    if (size != null) 'size': size!.toJson(),
    if (inputReference != null) 'input_reference': inputReference!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVideoRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          model == other.model &&
          seconds == other.seconds &&
          size == other.size &&
          inputReference == other.inputReference;

  @override
  int get hashCode => Object.hash(prompt, model, seconds, size, inputReference);

  @override
  String toString() =>
      'CreateVideoRequest(prompt: ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt})';
}

/// Request to create a video remix.
///
/// Remixes an existing generated video with a new prompt.
///
/// ## Example
///
/// ```dart
/// final remix = await client.videos.remix(
///   'video-abc123',
///   CreateVideoRemixRequest(
///     prompt: 'Same scene but at night with stars',
///   ),
/// );
/// ```
@immutable
class CreateVideoRemixRequest {
  /// Creates a [CreateVideoRemixRequest].
  const CreateVideoRemixRequest({required this.prompt});

  /// Updated text prompt that directs the remix generation.
  ///
  /// Maximum length is 32,000 characters.
  final String prompt;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'prompt': prompt};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVideoRemixRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt;

  @override
  int get hashCode => prompt.hashCode;

  @override
  String toString() =>
      'CreateVideoRemixRequest(prompt: ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt})';
}

/// Request to create a video edit.
///
/// Edits an existing completed video using a text prompt.
///
/// ## Example
///
/// ```dart
/// final edited = await client.videos.createEdit(
///   CreateVideoEditRequest(
///     prompt: 'Add a sunset in the background',
///     videoId: 'video-abc123',
///   ),
/// );
/// ```
@immutable
class CreateVideoEditRequest {
  /// Creates a [CreateVideoEditRequest].
  const CreateVideoEditRequest({required this.prompt, required this.videoId});

  /// Text prompt describing how to edit the video.
  final String prompt;

  /// The ID of the completed video to edit.
  final String videoId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'video': {'id': videoId},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVideoEditRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          videoId == other.videoId;

  @override
  int get hashCode => Object.hash(prompt, videoId);

  @override
  String toString() =>
      'CreateVideoEditRequest(prompt: ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt})';
}

/// Request to extend a completed video.
///
/// Creates an extension of an existing completed video.
///
/// ## Example
///
/// ```dart
/// final extended = await client.videos.createExtension(
///   CreateVideoExtendRequest(
///     prompt: 'Continue the scene with a slow zoom out',
///     videoId: 'video-abc123',
///     seconds: VideoSeconds.s8,
///   ),
/// );
/// ```
@immutable
class CreateVideoExtendRequest {
  /// Creates a [CreateVideoExtendRequest].
  const CreateVideoExtendRequest({
    required this.prompt,
    required this.videoId,
    required this.seconds,
  });

  /// Text prompt directing the extension generation.
  final String prompt;

  /// The ID of the completed video to extend.
  final String videoId;

  /// Length of the extension in seconds (allowed: 4, 8, 12, 16, 20).
  final VideoSeconds seconds;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'video': {'id': videoId},
    'seconds': seconds.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVideoExtendRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          videoId == other.videoId &&
          seconds == other.seconds;

  @override
  int get hashCode => Object.hash(prompt, videoId, seconds);

  @override
  String toString() =>
      'CreateVideoExtendRequest(prompt: ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt})';
}

/// Reference image that guides video generation.
///
/// Provide [imageUrl] or [fileId] to reference an image.
@immutable
class VideoInputReference {
  /// A fully qualified URL or base64-encoded data URL.
  final String? imageUrl;

  /// The ID of an uploaded file.
  final String? fileId;

  /// Creates a [VideoInputReference].
  const VideoInputReference({this.imageUrl, this.fileId});

  /// Creates a [VideoInputReference] from a URL.
  const VideoInputReference.url(String url) : imageUrl = url, fileId = null;

  /// Creates a [VideoInputReference] from a file ID.
  const VideoInputReference.file(String id) : imageUrl = null, fileId = id;

  /// Creates a [VideoInputReference] from JSON.
  factory VideoInputReference.fromJson(Map<String, dynamic> json) {
    return VideoInputReference(
      imageUrl: json['image_url'] as String?,
      fileId: json['file_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoInputReference &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId;

  @override
  int get hashCode => Object.hash(imageUrl, fileId);

  @override
  String toString() =>
      'VideoInputReference(imageUrl: $imageUrl, fileId: $fileId)';
}
