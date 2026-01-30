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

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    if (model != null) 'model': model,
    if (seconds != null) 'seconds': seconds!.toJson(),
    if (size != null) 'size': size!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVideoRequest &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          model == other.model &&
          seconds == other.seconds &&
          size == other.size;

  @override
  int get hashCode => Object.hash(prompt, model, seconds, size);

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
