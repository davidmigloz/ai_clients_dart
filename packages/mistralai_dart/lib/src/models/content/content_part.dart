import 'package:meta/meta.dart';

/// Sealed class for content parts in user messages.
///
/// Supports multimodal content including text and images.
sealed class ContentPart {
  const ContentPart();

  /// The type of this content part.
  String get type;

  /// Creates a [ContentPart] from JSON.
  factory ContentPart.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => TextContentPart.fromJson(json),
      'image_url' => ImageUrlContentPart.fromJson(json),
      _ => throw FormatException('Unknown content type: ${json['type']}'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  /// Creates a text content part.
  factory ContentPart.text(String text) => TextContentPart(text: text);

  /// Creates an image URL content part.
  factory ContentPart.imageUrl(String url) => ImageUrlContentPart(url: url);
}

/// Text content part.
@immutable
class TextContentPart extends ContentPart {
  @override
  String get type => 'text';

  /// The text content.
  final String text;

  /// Creates a [TextContentPart].
  const TextContentPart({required this.text});

  /// Creates a [TextContentPart] from JSON.
  factory TextContentPart.fromJson(Map<String, dynamic> json) =>
      TextContentPart(text: json['text'] as String? ?? '');

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentPart &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hash(type, text);

  @override
  String toString() => 'TextContentPart(text: $text)';
}

/// Image URL content part for vision models.
@immutable
class ImageUrlContentPart extends ContentPart {
  @override
  String get type => 'image_url';

  /// The URL of the image.
  ///
  /// Can be a web URL (https://) or a base64 data URL
  /// (data:image/jpeg;base64,...).
  final String url;

  /// Creates an [ImageUrlContentPart].
  const ImageUrlContentPart({required this.url});

  /// Creates an [ImageUrlContentPart] from JSON.
  factory ImageUrlContentPart.fromJson(Map<String, dynamic> json) {
    // Handle nested format: {"image_url": {"url": "..."}}
    final imageUrl = json['image_url'];
    if (imageUrl is Map<String, dynamic>) {
      return ImageUrlContentPart(url: imageUrl['url'] as String? ?? '');
    }
    // Handle flat format: {"image_url": "..."}
    return ImageUrlContentPart(url: imageUrl as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': {'url': url},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUrlContentPart &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => Object.hash(type, url);

  @override
  String toString() => 'ImageUrlContentPart(url: $url)';
}
