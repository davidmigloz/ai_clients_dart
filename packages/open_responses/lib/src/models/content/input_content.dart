import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/image_detail.dart';

/// Input content for messages.
sealed class InputContent {
  /// Creates an [InputContent].
  const InputContent();

  /// Creates a text input content.
  static InputContent text(String text) => InputTextContent(text: text);

  /// Creates an image input content from a URL.
  static InputContent imageUrl(String url, {ImageDetail? detail}) =>
      InputImageContent.url(url, detail: detail);

  /// Creates an image input content from a file ID.
  static InputContent imageFile(String fileId, {ImageDetail? detail}) =>
      InputImageContent.file(fileId, detail: detail);

  /// Creates a file input content from a URL.
  static InputContent fileUrl(String url, {String? filename}) =>
      InputFileContent.url(url, filename: filename);

  /// Creates a video input content from a URL.
  static InputContent videoUrl(String videoUrl) =>
      InputVideoContent(videoUrl: videoUrl);

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

  /// Creates a copy with replaced values.
  InputTextContent copyWith({String? text}) {
    return InputTextContent(text: text ?? this.text);
  }

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
  ///
  /// **Note:** This is an extension field not present in the official
  /// OpenResponses spec. It is included for compatibility with providers
  /// that support file uploads.
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

  /// Creates a copy with replaced values.
  InputImageContent copyWith({
    Object? imageUrl = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? detail = unsetCopyWithValue,
  }) {
    return InputImageContent(
      imageUrl: imageUrl == unsetCopyWithValue
          ? this.imageUrl
          : imageUrl as String?,
      fileId: fileId == unsetCopyWithValue ? this.fileId : fileId as String?,
      detail: detail == unsetCopyWithValue
          ? this.detail
          : detail as ImageDetail?,
    );
  }

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

/// File content via URL, file ID, or base64-encoded data.
@immutable
class InputFileContent extends InputContent {
  /// The file URL.
  final String? fileUrl;

  /// The file ID.
  ///
  /// **Note:** This is an extension field not present in the official
  /// OpenResponses spec. It is included for compatibility with providers
  /// that support file uploads.
  final String? fileId;

  /// Base64-encoded file content.
  ///
  /// Maximum length: 33554432 characters.
  final String? fileData;

  /// The filename.
  final String? filename;

  /// Creates an [InputFileContent].
  const InputFileContent({
    this.fileUrl,
    this.fileId,
    this.fileData,
    this.filename,
  });

  /// Creates an [InputFileContent] from a URL.
  const InputFileContent.url(String url, {this.filename})
    : fileUrl = url,
      fileId = null,
      fileData = null;

  /// Creates an [InputFileContent] from a file ID.
  const InputFileContent.file(String id, {this.filename})
    : fileUrl = null,
      fileId = id,
      fileData = null;

  /// Creates an [InputFileContent] from base64-encoded data.
  const InputFileContent.data(String data, {this.filename})
    : fileUrl = null,
      fileId = null,
      fileData = data;

  /// Creates an [InputFileContent] from JSON.
  factory InputFileContent.fromJson(Map<String, dynamic> json) {
    return InputFileContent(
      fileUrl: json['file_url'] as String?,
      fileId: json['file_id'] as String?,
      fileData: json['file_data'] as String?,
      filename: json['filename'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_file',
    if (fileUrl != null) 'file_url': fileUrl,
    if (fileId != null) 'file_id': fileId,
    if (fileData != null) 'file_data': fileData,
    if (filename != null) 'filename': filename,
  };

  /// Creates a copy with replaced values.
  InputFileContent copyWith({
    Object? fileUrl = unsetCopyWithValue,
    Object? fileId = unsetCopyWithValue,
    Object? fileData = unsetCopyWithValue,
    Object? filename = unsetCopyWithValue,
  }) {
    return InputFileContent(
      fileUrl: fileUrl == unsetCopyWithValue
          ? this.fileUrl
          : fileUrl as String?,
      fileId: fileId == unsetCopyWithValue ? this.fileId : fileId as String?,
      fileData: fileData == unsetCopyWithValue
          ? this.fileData
          : fileData as String?,
      filename: filename == unsetCopyWithValue
          ? this.filename
          : filename as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputFileContent &&
          runtimeType == other.runtimeType &&
          fileUrl == other.fileUrl &&
          fileId == other.fileId &&
          fileData == other.fileData &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(fileUrl, fileId, fileData, filename);

  @override
  String toString() =>
      'InputFileContent(fileUrl: $fileUrl, fileId: $fileId, fileData: $fileData, filename: $filename)';
}

/// Video content via URL.
@immutable
class InputVideoContent extends InputContent {
  /// The video URL.
  final String videoUrl;

  /// Creates an [InputVideoContent].
  const InputVideoContent({required this.videoUrl});

  /// Creates an [InputVideoContent] from JSON.
  factory InputVideoContent.fromJson(Map<String, dynamic> json) {
    return InputVideoContent(videoUrl: json['video_url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_video',
    'video_url': videoUrl,
  };

  /// Creates a copy with replaced values.
  InputVideoContent copyWith({String? videoUrl}) {
    return InputVideoContent(videoUrl: videoUrl ?? this.videoUrl);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputVideoContent &&
          runtimeType == other.runtimeType &&
          videoUrl == other.videoUrl;

  @override
  int get hashCode => videoUrl.hashCode;

  @override
  String toString() => 'InputVideoContent(videoUrl: $videoUrl)';
}
