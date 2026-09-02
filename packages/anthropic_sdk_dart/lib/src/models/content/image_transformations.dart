import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// What the server does when an image exceeds the model's maximum image
/// size.
enum OversizedImageBehavior {
  /// The default. Scales the image down to fit, which changes the
  /// dimensions the model observes without telling you.
  downsize('downsize'),

  /// Rejects the request with a 400 error naming the image's dimensions and
  /// the largest dimensions that fit, so you can scale the image
  /// deliberately. The image is never silently scaled down.
  error('error');

  /// The wire value for this behavior.
  final String value;

  const OversizedImageBehavior(this.value);

  /// Creates an [OversizedImageBehavior] from its wire value.
  ///
  /// Throws [FormatException] for an unrecognized value — this is a
  /// request-side enum with no server-driven forward-compatibility need.
  factory OversizedImageBehavior.fromJson(String value) {
    return switch (value) {
      'downsize' => OversizedImageBehavior.downsize,
      'error' => OversizedImageBehavior.error,
      _ => throw FormatException('Unknown OversizedImageBehavior: $value'),
    };
  }

  /// Converts to its wire value.
  String toJson() => value;
}

/// Configures the transformations the server applies to an image before the
/// model observes it.
///
/// Each key names a condition the server transforms images for; its value
/// selects the transformation applied. Omitted keys keep their default
/// behavior, and an empty [ImageTransformations] is equivalent to omitting
/// the field entirely.
@immutable
class ImageTransformations {
  /// What the server does when this image exceeds the model's maximum image
  /// size.
  ///
  /// `downsize` (the default) scales the image down to fit, which changes the
  /// dimensions the model observes without telling you. `error` instead
  /// rejects the request with a 400 error naming the image's dimensions and
  /// the largest dimensions that fit, so you can scale the image
  /// deliberately — your image is never silently scaled down.
  final OversizedImageBehavior? oversizedImage;

  /// Creates [ImageTransformations].
  const ImageTransformations({this.oversizedImage});

  /// Creates [ImageTransformations] from JSON.
  factory ImageTransformations.fromJson(Map<String, dynamic> json) {
    return ImageTransformations(
      oversizedImage: json['oversized_image'] != null
          ? OversizedImageBehavior.fromJson(json['oversized_image'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (oversizedImage != null) 'oversized_image': oversizedImage!.toJson(),
  };

  /// Creates a copy with replaced values.
  ImageTransformations copyWith({Object? oversizedImage = unsetCopyWithValue}) {
    return ImageTransformations(
      oversizedImage: oversizedImage == unsetCopyWithValue
          ? this.oversizedImage
          : oversizedImage as OversizedImageBehavior?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageTransformations &&
          runtimeType == other.runtimeType &&
          oversizedImage == other.oversizedImage;

  @override
  int get hashCode => oversizedImage.hashCode;

  @override
  String toString() => 'ImageTransformations(oversizedImage: $oversizedImage)';
}
