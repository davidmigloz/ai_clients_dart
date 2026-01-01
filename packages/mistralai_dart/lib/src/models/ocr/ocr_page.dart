import 'package:meta/meta.dart';

import 'ocr_image.dart';

/// Represents a processed page from OCR.
@immutable
class OcrPage {
  /// The page index (0-based).
  final int index;

  /// The extracted markdown text from the page.
  final String markdown;

  /// Images extracted from the page.
  final List<OcrImage> images;

  /// Dimensions of the page [width, height].
  final List<double>? dimensions;

  /// Creates an [OcrPage].
  const OcrPage({
    required this.index,
    required this.markdown,
    this.images = const [],
    this.dimensions,
  });

  /// Creates an [OcrPage] from JSON.
  factory OcrPage.fromJson(Map<String, dynamic> json) => OcrPage(
    index: json['index'] as int? ?? 0,
    markdown: json['markdown'] as String? ?? '',
    images:
        (json['images'] as List?)
            ?.map((e) => OcrImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    dimensions: (json['dimensions'] as List?)?.cast<double>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    'markdown': markdown,
    if (images.isNotEmpty) 'images': images.map((e) => e.toJson()).toList(),
    if (dimensions != null) 'dimensions': dimensions,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPage &&
          runtimeType == other.runtimeType &&
          index == other.index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() =>
      'OcrPage(index: $index, markdown: ${markdown.length} chars)';
}
