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

  /// Creates an [ImageMediaType] from a MIME type string.
  ///
  /// Supported values: `'image/jpeg'`, `'image/png'`, `'image/gif'`,
  /// `'image/webp'`.
  ///
  /// Throws [FormatException] if the value is not recognized.
  static ImageMediaType fromMimeType(String mimeType) => fromJson(mimeType);

  /// Converts to JSON string.
  String toJson() => value;
}

/// Source for image content.
///
/// Images can be provided as base64-encoded data, URLs, or uploaded files.
sealed class ImageSource {
  const ImageSource();

  /// Creates a base64-encoded image source.
  factory ImageSource.base64({
    required String data,
    required ImageMediaType mediaType,
  }) = Base64ImageSource;

  /// Creates a URL-based image source.
  factory ImageSource.url(String url) = UrlImageSource;

  /// Creates a source referencing an image uploaded through the Files API.
  factory ImageSource.file(String fileId) = FileImageSource;

  /// Creates an [ImageSource] from JSON.
  factory ImageSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'base64' => Base64ImageSource.fromJson(json),
      'url' => UrlImageSource.fromJson(json),
      'file' => FileImageSource.fromJson(json),
      _ => throw FormatException('Unknown ImageSource type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Base64-encoded image source.
@immutable
class Base64ImageSource extends ImageSource {
  /// The source type, always 'base64'.
  String get type => 'base64';

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
    'type': type,
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
  /// The source type, always 'url'.
  String get type => 'url';

  /// URL of the image.
  final String url;

  /// Creates a [UrlImageSource].
  const UrlImageSource(this.url);

  /// Creates a [UrlImageSource] from JSON.
  factory UrlImageSource.fromJson(Map<String, dynamic> json) {
    return UrlImageSource(json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'url': url};

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

/// Image source that references a file uploaded through the Files API.
@immutable
final class FileImageSource extends ImageSource {
  /// Creates a source for the uploaded file.
  const FileImageSource(this.fileId);

  /// Parses an uploaded file reference.
  factory FileImageSource.fromJson(Map<String, dynamic> json) {
    if (json case {'type': 'file', 'file_id': final String fileId}) {
      return FileImageSource(fileId);
    }
    throw const FormatException('Expected an uploaded image file reference');
  }

  /// The source discriminator.
  String get type => 'file';

  /// The uploaded image file's ID.
  final String fileId;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'file_id': fileId};

  /// Copies this source with an optional replacement file ID.
  FileImageSource copyWith({String? fileId}) =>
      FileImageSource(fileId ?? this.fileId);

  @override
  bool operator ==(Object other) =>
      other is FileImageSource && fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileImageSource(fileId: $fileId)';
}
