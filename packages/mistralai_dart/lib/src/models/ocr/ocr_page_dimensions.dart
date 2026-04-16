import 'package:meta/meta.dart';

/// Dimensions of a page image from OCR processing.
@immutable
class OcrPageDimensions {
  /// Width of the image in pixels.
  final int width;

  /// Height of the image in pixels.
  final int height;

  /// Dots per inch of the page image.
  final int dpi;

  /// Creates an [OcrPageDimensions].
  const OcrPageDimensions({
    required this.width,
    required this.height,
    required this.dpi,
  });

  /// Creates an [OcrPageDimensions] from JSON.
  factory OcrPageDimensions.fromJson(Map<String, dynamic> json) =>
      OcrPageDimensions(
        width: json['width'] as int,
        height: json['height'] as int,
        dpi: json['dpi'] as int,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'dpi': dpi,
  };

  /// Creates a copy with the specified fields replaced.
  OcrPageDimensions copyWith({int? width, int? height, int? dpi}) =>
      OcrPageDimensions(
        width: width ?? this.width,
        height: height ?? this.height,
        dpi: dpi ?? this.dpi,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPageDimensions &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          dpi == other.dpi;

  @override
  int get hashCode => Object.hash(width, height, dpi);

  @override
  String toString() =>
      'OcrPageDimensions(width: $width, height: $height, dpi: $dpi)';
}
