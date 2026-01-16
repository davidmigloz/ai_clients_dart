import 'package:meta/meta.dart';

import '../metadata/image_detail.dart';

/// Input content for messages.
sealed class InputContent {
  /// Creates an [InputContent].
  const InputContent();

  /// Creates an [InputContent] from JSON.
  factory InputContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'input_text' => InputTextContent.fromJson(json),
      'input_image' => InputImageContent.fromJson(json),
      'input_file' => InputFileContent.fromJson(json),
      'input_video' => InputVideoContent.fromJson(json),
      _ => throw FormatException('Unknown InputContent type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text content.
@immutable
class InputTextContent extends InputContent {
  /// The text content.
  final String text;

  /// Creates an [InputTextContent].
  const InputTextContent({required this.text});

  /// Creates an [InputTextContent] from JSON.
  factory InputTextContent.fromJson(Map<String, dynamic> json) {
    return InputTextContent(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'input_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'InputTextContent(text: $text)';
}

/// Image content via URL.
@immutable
class InputImageContent extends InputContent {
  /// The image URL.
  final String? imageUrl;

  /// The file ID (for uploaded files).
  final String? fileId;

  /// Optional detail level.
  final ImageDetail? detail;

  /// Creates an [InputImageContent] with URL.
  const InputImageContent({this.imageUrl, this.fileId, this.detail})
    : assert(
        imageUrl != null || fileId != null,
        'Either imageUrl or fileId must be provided',
      );

  /// Creates an [InputImageContent] from a URL.
  const InputImageContent.url(String url, {this.detail})
    : imageUrl = url,
      fileId = null;

  /// Creates an [InputImageContent] from a file ID.
  const InputImageContent.file(String id, {this.detail})
    : imageUrl = null,
      fileId = id;

  /// Creates an [InputImageContent] from JSON.
  factory InputImageContent.fromJson(Map<String, dynamic> json) {
    return InputImageContent(
      imageUrl: json['image_url'] as String?,
      fileId: json['file_id'] as String?,
      detail: json['detail'] != null
          ? ImageDetail.fromJson(json['detail'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_image',
    if (imageUrl != null) 'image_url': imageUrl,
    if (fileId != null) 'file_id': fileId,
    if (detail != null) 'detail': detail!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputImageContent &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl &&
          fileId == other.fileId &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(imageUrl, fileId, detail);

  @override
  String toString() =>
      'InputImageContent(imageUrl: $imageUrl, fileId: $fileId, detail: $detail)';
}

/// File content via URL or file ID.
@immutable
class InputFileContent extends InputContent {
  /// The file URL.
  final String? url;

  /// The file ID.
  final String? fileId;

  /// The filename.
  final String? filename;

  /// Creates an [InputFileContent].
  const InputFileContent({this.url, this.fileId, this.filename});

  /// Creates an [InputFileContent] from JSON.
  factory InputFileContent.fromJson(Map<String, dynamic> json) {
    return InputFileContent(
      url: json['url'] as String?,
      fileId: json['file_id'] as String?,
      filename: json['filename'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_file',
    if (url != null) 'url': url,
    if (fileId != null) 'file_id': fileId,
    if (filename != null) 'filename': filename,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputFileContent &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          fileId == other.fileId &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(url, fileId, filename);

  @override
  String toString() =>
      'InputFileContent(url: $url, fileId: $fileId, filename: $filename)';
}

/// Video content via URL.
@immutable
class InputVideoContent extends InputContent {
  /// The video URL.
  final String url;

  /// Creates an [InputVideoContent].
  const InputVideoContent({required this.url});

  /// Creates an [InputVideoContent] from JSON.
  factory InputVideoContent.fromJson(Map<String, dynamic> json) {
    return InputVideoContent(url: json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'input_video', 'url': url};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputVideoContent &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'InputVideoContent(url: $url)';
}
