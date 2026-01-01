import 'package:meta/meta.dart';

/// Represents an image extracted from a document page.
@immutable
class OcrImage {
  /// Unique identifier for the image.
  final String id;

  /// The bounding box of the image [x, y, width, height].
  final List<double>? boundingBox;

  /// Base64-encoded image data (if requested).
  final String? imageBase64;

  /// The format of the image (e.g., 'png', 'jpeg').
  final String? format;

  /// Creates an [OcrImage].
  const OcrImage({
    required this.id,
    this.boundingBox,
    this.imageBase64,
    this.format,
  });

  /// Creates an [OcrImage] from JSON.
  factory OcrImage.fromJson(Map<String, dynamic> json) => OcrImage(
    id: json['id'] as String? ?? '',
    boundingBox: (json['bounding_box'] as List?)?.cast<double>(),
    imageBase64: json['image_base64'] as String?,
    format: json['format'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (boundingBox != null) 'bounding_box': boundingBox,
    if (imageBase64 != null) 'image_base64': imageBase64,
    if (format != null) 'format': format,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrImage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OcrImage(id: $id)';
}
