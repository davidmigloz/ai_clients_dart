import '../copy_with_sentinel.dart';

/// The task mode for video generation.
enum InteractionVideoConfigTask {
  /// Generates video solely from a text prompt.
  textToVideo,

  /// Generates video from one or two source images. The first image defines
  /// the starting frame, and the optional second image defines the ending
  /// frame.
  imageToVideo,

  /// Generates video using reference media (such as images, audio, or video).
  referenceToVideo,

  /// Modifies an existing input video.
  edit,
}

/// Converts a string to an [InteractionVideoConfigTask], or `null` if
/// unrecognized (forward-compatible).
InteractionVideoConfigTask? interactionVideoConfigTaskFromString(
  String? value,
) {
  return switch (value) {
    'text_to_video' => InteractionVideoConfigTask.textToVideo,
    'image_to_video' => InteractionVideoConfigTask.imageToVideo,
    'reference_to_video' => InteractionVideoConfigTask.referenceToVideo,
    'edit' => InteractionVideoConfigTask.edit,
    _ => null,
  };
}

/// Converts an [InteractionVideoConfigTask] to its JSON string.
String interactionVideoConfigTaskToString(InteractionVideoConfigTask task) {
  return switch (task) {
    InteractionVideoConfigTask.textToVideo => 'text_to_video',
    InteractionVideoConfigTask.imageToVideo => 'image_to_video',
    InteractionVideoConfigTask.referenceToVideo => 'reference_to_video',
    InteractionVideoConfigTask.edit => 'edit',
  };
}

/// Configuration options for video generation.
class InteractionVideoConfig {
  /// Optional task mode for video generation. If not specified, the model
  /// automatically determines the appropriate mode based on the provided text
  /// prompt and input media.
  final InteractionVideoConfigTask? task;

  /// Creates an [InteractionVideoConfig] instance.
  const InteractionVideoConfig({this.task});

  /// Creates an [InteractionVideoConfig] from JSON.
  factory InteractionVideoConfig.fromJson(Map<String, dynamic> json) =>
      InteractionVideoConfig(
        task: interactionVideoConfigTaskFromString(json['task'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (task != null) 'task': interactionVideoConfigTaskToString(task!),
  };

  /// Creates a copy with replaced values.
  InteractionVideoConfig copyWith({Object? task = unsetCopyWithValue}) {
    return InteractionVideoConfig(
      task: task == unsetCopyWithValue
          ? this.task
          : task as InteractionVideoConfigTask?,
    );
  }
}
