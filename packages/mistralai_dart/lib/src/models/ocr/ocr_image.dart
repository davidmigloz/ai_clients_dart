import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Represents an image extracted from a document page.
@immutable
class OcrImage {
  /// Unique identifier for the image.
  final String id;

  /// X coordinate of the top-left corner of the extracted image.
  final int? topLeftX;

  /// Y coordinate of the top-left corner of the extracted image.
  final int? topLeftY;

  /// X coordinate of the bottom-right corner of the extracted image.
  final int? bottomRightX;

  /// Y coordinate of the bottom-right corner of the extracted image.
  final int? bottomRightY;

  /// Base64 string of the extracted image (if requested).
  final String? imageBase64;

  /// Annotation of the extracted image as a JSON string.
  final String? imageAnnotation;

  /// Creates an [OcrImage].
  const OcrImage({
    required this.id,
    this.topLeftX,
    this.topLeftY,
    this.bottomRightX,
    this.bottomRightY,
    this.imageBase64,
    this.imageAnnotation,
  });

  /// Creates an [OcrImage] from JSON.
  factory OcrImage.fromJson(Map<String, dynamic> json) => OcrImage(
    id: json['id'] as String? ?? '',
    topLeftX: json['top_left_x'] as int?,
    topLeftY: json['top_left_y'] as int?,
    bottomRightX: json['bottom_right_x'] as int?,
    bottomRightY: json['bottom_right_y'] as int?,
    imageBase64: json['image_base64'] as String?,
    imageAnnotation: json['image_annotation'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (topLeftX != null) 'top_left_x': topLeftX,
    if (topLeftY != null) 'top_left_y': topLeftY,
    if (bottomRightX != null) 'bottom_right_x': bottomRightX,
    if (bottomRightY != null) 'bottom_right_y': bottomRightY,
    if (imageBase64 != null) 'image_base64': imageBase64,
    if (imageAnnotation != null) 'image_annotation': imageAnnotation,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  OcrImage copyWith({
    String? id,
    Object? topLeftX = unsetCopyWithValue,
    Object? topLeftY = unsetCopyWithValue,
    Object? bottomRightX = unsetCopyWithValue,
    Object? bottomRightY = unsetCopyWithValue,
    Object? imageBase64 = unsetCopyWithValue,
    Object? imageAnnotation = unsetCopyWithValue,
  }) => OcrImage(
    id: id ?? this.id,
    topLeftX: topLeftX == unsetCopyWithValue ? this.topLeftX : topLeftX as int?,
    topLeftY: topLeftY == unsetCopyWithValue ? this.topLeftY : topLeftY as int?,
    bottomRightX: bottomRightX == unsetCopyWithValue
        ? this.bottomRightX
        : bottomRightX as int?,
    bottomRightY: bottomRightY == unsetCopyWithValue
        ? this.bottomRightY
        : bottomRightY as int?,
    imageBase64: imageBase64 == unsetCopyWithValue
        ? this.imageBase64
        : imageBase64 as String?,
    imageAnnotation: imageAnnotation == unsetCopyWithValue
        ? this.imageAnnotation
        : imageAnnotation as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          topLeftX == other.topLeftX &&
          topLeftY == other.topLeftY &&
          bottomRightX == other.bottomRightX &&
          bottomRightY == other.bottomRightY &&
          imageBase64 == other.imageBase64 &&
          imageAnnotation == other.imageAnnotation;

  @override
  int get hashCode => Object.hash(
    id,
    topLeftX,
    topLeftY,
    bottomRightX,
    bottomRightY,
    imageBase64,
    imageAnnotation,
  );

  @override
  String toString() =>
      'OcrImage(id: $id, '
      'topLeft: ($topLeftX, $topLeftY), '
      'bottomRight: ($bottomRightX, $bottomRightY), '
      'imageBase64: ${imageBase64 != null ? "${imageBase64!.length} chars" : "null"}, '
      'imageAnnotation: $imageAnnotation)';
}
