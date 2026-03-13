import '../copy_with_sentinel.dart';

/// The configuration for image interaction.
class InteractionImageConfig {
  /// The aspect ratio of the generated image.
  final String? aspectRatio;

  /// The size of the generated image.
  final String? imageSize;

  /// Creates an [InteractionImageConfig] instance.
  const InteractionImageConfig({this.aspectRatio, this.imageSize});

  /// Creates an [InteractionImageConfig] from JSON.
  factory InteractionImageConfig.fromJson(Map<String, dynamic> json) =>
      InteractionImageConfig(
        aspectRatio: json['aspect_ratio'] as String?,
        imageSize: json['image_size'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (aspectRatio != null) 'aspect_ratio': aspectRatio,
    if (imageSize != null) 'image_size': imageSize,
  };

  /// Creates a copy with replaced values.
  InteractionImageConfig copyWith({
    Object? aspectRatio = unsetCopyWithValue,
    Object? imageSize = unsetCopyWithValue,
  }) {
    return InteractionImageConfig(
      aspectRatio: aspectRatio == unsetCopyWithValue
          ? this.aspectRatio
          : aspectRatio as String?,
      imageSize: imageSize == unsetCopyWithValue
          ? this.imageSize
          : imageSize as String?,
    );
  }
}
