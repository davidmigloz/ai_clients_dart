import 'package:meta/meta.dart';

import '../../chat/content_part.dart' show ImageDetail;

/// Input content for messages.
///
/// This is a sealed class hierarchy for different input content types.
///
/// ## User/System/Developer Messages
///
/// Use [InputContent.text], [InputContent.imageUrl], [InputContent.imageFile],
/// [InputContent.fileUrl], [InputContent.fileId], [InputContent.fileData], or
/// [InputContent.video] for user, system, and developer messages.
///
/// ## Assistant Messages
///
/// Use [InputContent.assistantText] for assistant message content, as the API
/// expects `output_text` type for assistant messages rather than `input_text`.
sealed class InputContent {
  /// Creates an [InputContent].
  const InputContent();

  /// Creates an [InputTextContent] with the given [text].
  const factory InputContent.text(String text) = InputTextContent;

  /// Creates an [AssistantTextContent] with the given [text].
  const factory InputContent.assistantText(String text) = AssistantTextContent;

  /// Creates an [InputVideoContent] with the given [videoUrl].
  const factory InputContent.video(String videoUrl) = InputVideoContent;

  /// Creates an [InputImageContent] from a URL.
  const factory InputContent.imageUrl(String url, {ImageDetail? detail}) =
      InputImageContent.url;

  /// Creates an [InputImageContent] from a file ID.
  const factory InputContent.imageFile(String id, {ImageDetail? detail}) =
      InputImageContent.file;

  /// Creates an [InputFileContent] from a URL.
  const factory InputContent.fileUrl(String url, {String? filename}) =
      InputFileContent.url;

  /// Creates an [InputFileContent] from a file ID.
  const factory InputContent.fileId(String id, {String? filename}) =
      InputFileContent.file;

  /// Creates an [InputFileContent] from base64-encoded data.
  ///
  /// The [data] should be a base64-encoded string representing the file bytes.
  /// The [mediaType] specifies the MIME type (e.g., `'application/pdf'`).
  /// These are combined into a data URL (`data:<mediaType>;base64,<data>`) as
  /// required by the API.
  const factory InputContent.fileData(
    String data, {
    required String mediaType,
    String? filename,
  }) = InputFileContent.data;

  /// Creates an [InputContent] from JSON.
  factory InputContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'input_text' => InputTextContent.fromJson(json),
      'output_text' => AssistantTextContent.fromJson(json),
      'input_image' => InputImageContent.fromJson(json),
      'input_file' => InputFileContent.fromJson(json),
      'input_video' => InputVideoContent.fromJson(json),
      _ => throw FormatException('Unknown InputContent type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text content for user, system, and developer messages.
///
/// Serializes with `type: 'input_text'`. For assistant messages, use
/// [AssistantTextContent] instead.
@immutable
class InputTextContent extends InputContent {
  /// The text content.
  final String text;

  /// Creates an [InputTextContent].
  const InputTextContent(this.text);

  /// Creates an [InputTextContent] from JSON.
  factory InputTextContent.fromJson(Map<String, dynamic> json) {
    return InputTextContent(json['text'] as String);
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

/// Text content for assistant messages.
///
/// Serializes with `type: 'output_text'`, which is required when providing
/// assistant messages as input for multi-turn conversations.
///
/// The API requires assistant message content to use `output_text` type
/// rather than `input_text`.
@immutable
class AssistantTextContent extends InputContent {
  /// The text content.
  final String text;

  /// Creates an [AssistantTextContent].
  const AssistantTextContent(this.text);

  /// Creates an [AssistantTextContent] from JSON.
  factory AssistantTextContent.fromJson(Map<String, dynamic> json) {
    return AssistantTextContent(json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'output_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantTextContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'AssistantTextContent(text: $text)';
}

/// Image content via URL or file ID.
@immutable
class InputImageContent extends InputContent {
  /// The image URL.
  final String? imageUrl;

  /// The file ID (for uploaded files).
  final String? fileId;

  /// Optional detail level.
  final ImageDetail? detail;

  /// Creates an [InputImageContent] with URL or file ID.
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

/// File content via URL, file ID, or base64-encoded data.
@immutable
class InputFileContent extends InputContent {
  /// The file URL.
  final String? fileUrl;

  /// The file ID.
  final String? fileId;

  /// The file data as a data URL (e.g., `data:application/pdf;base64,<data>`).
  ///
  /// Use [InputContent.fileData] or [InputFileContent.data] to construct this
  /// from a base64-encoded string.
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
  ///
  /// The [data] should be a base64-encoded string representing the file bytes.
  /// The [mediaType] specifies the MIME type (e.g., `'application/pdf'`).
  /// These are combined into a data URL (`data:<mediaType>;base64,<data>`) as
  /// required by the API.
  const InputFileContent.data(
    String data, {
    required String mediaType,
    this.filename,
  }) : fileUrl = null,
       fileId = null,
       fileData = 'data:$mediaType;base64,$data';

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
  const InputVideoContent(this.videoUrl);

  /// Creates an [InputVideoContent] from JSON.
  factory InputVideoContent.fromJson(Map<String, dynamic> json) {
    return InputVideoContent(json['video_url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'input_video',
    'video_url': videoUrl,
  };

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
