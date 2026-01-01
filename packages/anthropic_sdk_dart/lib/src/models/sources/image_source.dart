import 'package:meta/meta.dart';

/// Supported image media types.
enum ImageMediaType {
  /// JPEG image.
  jpeg('image/jpeg'),

  /// PNG image.
  png('image/png'),

  /// GIF image.
  gif('image/gif'),

  /// WebP image.
  webp('image/webp');

  const ImageMediaType(this.value);

  /// MIME type value.
  final String value;

  /// Converts a string to [ImageMediaType].
  static ImageMediaType fromJson(String value) => switch (value) {
    'image/jpeg' => ImageMediaType.jpeg,
    'image/png' => ImageMediaType.png,
    'image/gif' => ImageMediaType.gif,
    'image/webp' => ImageMediaType.webp,
    _ => throw FormatException('Unknown ImageMediaType: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}

/// Source for image content.
///
/// Images can be provided as base64-encoded data or as URLs.
sealed class ImageSource {
  const ImageSource();

  /// Creates a base64-encoded image source.
  factory ImageSource.base64({
    required String data,
    required ImageMediaType mediaType,
  }) = Base64ImageSource;

  /// Creates a URL-based image source.
  factory ImageSource.url(String url) = UrlImageSource;

  /// Creates an [ImageSource] from JSON.
  factory ImageSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'base64' => Base64ImageSource.fromJson(json),
      'url' => UrlImageSource.fromJson(json),
      _ => throw FormatException('Unknown ImageSource type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Base64-encoded image source.
@immutable
class Base64ImageSource extends ImageSource {
  /// Base64-encoded image data.
  final String data;

  /// Media type of the image.
  final ImageMediaType mediaType;

  /// Creates a [Base64ImageSource].
  const Base64ImageSource({required this.data, required this.mediaType});

  /// Creates a [Base64ImageSource] from JSON.
  factory Base64ImageSource.fromJson(Map<String, dynamic> json) {
    return Base64ImageSource(
      data: json['data'] as String,
      mediaType: ImageMediaType.fromJson(json['media_type'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'base64',
    'data': data,
    'media_type': mediaType.toJson(),
  };

  /// Creates a copy with replaced values.
  Base64ImageSource copyWith({String? data, ImageMediaType? mediaType}) {
    return Base64ImageSource(
      data: data ?? this.data,
      mediaType: mediaType ?? this.mediaType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Base64ImageSource &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          mediaType == other.mediaType;

  @override
  int get hashCode => Object.hash(data, mediaType);

  @override
  String toString() =>
      'Base64ImageSource(data: [${data.length} chars], mediaType: $mediaType)';
}

/// URL-based image source.
@immutable
class UrlImageSource extends ImageSource {
  /// URL of the image.
  final String url;

  /// Creates a [UrlImageSource].
  const UrlImageSource(this.url);

  /// Creates a [UrlImageSource] from JSON.
  factory UrlImageSource.fromJson(Map<String, dynamic> json) {
    return UrlImageSource(json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'url', 'url': url};

  /// Creates a copy with replaced values.
  UrlImageSource copyWith({String? url}) {
    return UrlImageSource(url ?? this.url);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlImageSource &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'UrlImageSource(url: $url)';
}
