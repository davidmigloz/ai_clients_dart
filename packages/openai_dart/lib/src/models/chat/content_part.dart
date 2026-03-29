import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A part of a multimodal message content.
///
/// Content parts allow messages to contain multiple types of content.
/// User messages support text, images, audio, and files.
/// Assistant messages support text and refusal.
///
/// ## Example
///
/// ```dart
/// final parts = [
///   ContentPart.text('What is in this image?'),
///   ContentPart.imageUrl(
///     'https://example.com/image.jpg',
///     detail: ImageDetail.high,
///   ),
/// ];
///
/// final message = ChatMessage.user(parts);
/// ```
@immutable
sealed class ContentPart {
  const ContentPart();

  /// Creates a [ContentPart] from JSON.
  factory ContentPart.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextContentPart.fromJson(json),
      'image_url' => ImageContentPart.fromJson(json),
      'input_audio' => AudioContentPart.fromJson(json),
      'file' => FileContentPart.fromJson(json),
      'refusal' => RefusalContentPart.fromJson(json),
      _ => throw FormatException('Unknown content part type: $type'),
    };
  }

  /// Creates a text content part.
  static ContentPart text(String text) => TextContentPart(text: text);

  /// Creates an image URL content part.
  static ContentPart imageUrl(String url, {ImageDetail? detail}) =>
      ImageContentPart(url: url, detail: detail);

  /// Creates an image content part from base64-encoded data.
  static ContentPart imageBase64({
    required String data,
    required String mediaType,
    ImageDetail? detail,
  }) => ImageContentPart(url: 'data:$mediaType;base64,$data', detail: detail);

  /// Creates an audio content part.
  static ContentPart inputAudio({
    required String data,
    required AudioFormat format,
  }) => AudioContentPart(data: data, format: format);

  /// Creates a file content part from an uploaded file ID.
  static ContentPart file({required String fileId, String? filename}) =>
      FileContentPart(fileId: fileId, filename: filename);

  /// Creates a file content part from base64-encoded file data.
  ///
  /// The [data] should be a base64-encoded string representing the file bytes.
  /// The [mediaType] specifies the MIME type (e.g., `'application/pdf'`).
  /// These are combined into a data URL (`data:<mediaType>;base64,<data>`) as
  /// required by the API.
  static ContentPart fileData({
    required String data,
    required String mediaType,
    String? filename,
  }) => FileContentPart(
    fileData: 'data:$mediaType;base64,$data',
    filename: filename,
  );

  /// Creates a refusal content part.
  static ContentPart refusal(String refusal) =>
      RefusalContentPart(refusal: refusal);

  /// The type of this content part.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A text content part.
@immutable
class TextContentPart extends ContentPart {
  /// Creates a [TextContentPart].
  const TextContentPart({required this.text});

  /// Creates a [TextContentPart] from JSON.
  factory TextContentPart.fromJson(Map<String, dynamic> json) {
    return TextContentPart(text: json['text'] as String);
  }

  /// The text content.
  final String text;

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Creates a copy with the given fields replaced.
  TextContentPart copyWith({String? text}) {
    return TextContentPart(text: text ?? this.text);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentPart &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ContentPart.text($text)';
}

/// An image URL content part.
@immutable
class ImageContentPart extends ContentPart {
  /// Creates an [ImageContentPart].
  const ImageContentPart({required this.url, this.detail});

  /// Creates an [ImageContentPart] from JSON.
  factory ImageContentPart.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['image_url'] as Map<String, dynamic>;
    return ImageContentPart(
      url: imageUrl['url'] as String,
      detail: imageUrl['detail'] != null
          ? ImageDetail.fromJson(imageUrl['detail'] as String)
          : null,
    );
  }

  /// The URL of the image.
  ///
  /// Can be either:
  /// - An HTTP(S) URL: `https://example.com/image.jpg`
  /// - A base64 data URL: `data:image/jpeg;base64,{base64_data}`
  final String url;

  /// The detail level for image processing.
  ///
  /// Controls how the model processes the image:
  /// - [ImageDetail.low]: Faster, lower cost, less detail
  /// - [ImageDetail.high]: Slower, higher cost, more detail
  /// - [ImageDetail.original]: Use the original image without modification
  /// - [ImageDetail.auto]: Let the model decide (default)
  final ImageDetail? detail;

  @override
  String get type => 'image_url';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': {'url': url, if (detail != null) 'detail': detail!.toJson()},
  };

  /// Creates a copy with the given fields replaced.
  ImageContentPart copyWith({
    String? url,
    Object? detail = unsetCopyWithValue,
  }) {
    return ImageContentPart(
      url: url ?? this.url,
      detail: detail == unsetCopyWithValue
          ? this.detail
          : detail as ImageDetail?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageContentPart &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(url, detail);

  @override
  String toString() => 'ContentPart.imageUrl($url)';
}

/// An audio content part for audio input.
@immutable
class AudioContentPart extends ContentPart {
  /// Creates an [AudioContentPart].
  const AudioContentPart({required this.data, required this.format});

  /// Creates an [AudioContentPart] from JSON.
  factory AudioContentPart.fromJson(Map<String, dynamic> json) {
    final inputAudio = json['input_audio'] as Map<String, dynamic>;
    return AudioContentPart(
      data: inputAudio['data'] as String,
      format: AudioFormat.fromJson(inputAudio['format'] as String),
    );
  }

  /// Base64-encoded audio data.
  final String data;

  /// The format of the audio data.
  final AudioFormat format;

  @override
  String get type => 'input_audio';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'input_audio': {'data': data, 'format': format.toJson()},
  };

  /// Creates a copy with the given fields replaced.
  AudioContentPart copyWith({String? data, AudioFormat? format}) {
    return AudioContentPart(
      data: data ?? this.data,
      format: format ?? this.format,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioContentPart &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          format == other.format;

  @override
  int get hashCode => Object.hash(data, format);

  @override
  String toString() => 'ContentPart.inputAudio(${format.name})';
}

/// A file content part for document/file inputs.
///
/// Allows sending files (such as PDFs) as part of user messages.
/// Files can be referenced by an uploaded file ID or provided as
/// base64-encoded data.
///
/// Learn about [file inputs](https://platform.openai.com/docs/guides/text)
/// for text generation.
@immutable
class FileContentPart extends ContentPart {
  /// Creates a [FileContentPart].
  const FileContentPart({this.fileId, this.fileData, this.filename});

  /// Creates a [FileContentPart] from JSON.
  factory FileContentPart.fromJson(Map<String, dynamic> json) {
    final file = json['file'] as Map<String, dynamic>;
    return FileContentPart(
      fileId: file['file_id'] as String?,
      fileData: file['file_data'] as String?,
      filename: file['filename'] as String?,
    );
  }

  /// The ID of an uploaded file to use as input.
  final String? fileId;

  /// The file data as a data URL (e.g., `data:application/pdf;base64,<data>`).
  ///
  /// Use [ContentPart.fileData] to construct this from a base64-encoded string.
  final String? fileData;

  /// The name of the file.
  final String? filename;

  @override
  String get type => 'file';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'file': {
      if (fileId != null) 'file_id': fileId,
      if (fileData != null) 'file_data': fileData,
      if (filename != null) 'filename': filename,
    },
  };

  /// Creates a copy with the given fields replaced.
  FileContentPart copyWith({
    Object? fileId = unsetCopyWithValue,
    Object? fileData = unsetCopyWithValue,
    Object? filename = unsetCopyWithValue,
  }) {
    return FileContentPart(
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
      other is FileContentPart &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          fileData == other.fileData &&
          filename == other.filename;

  @override
  int get hashCode => Object.hash(fileId, fileData, filename);

  @override
  String toString() =>
      'ContentPart.file(fileId: $fileId, hasFileData: ${fileData != null}, filename: $filename)';
}

/// A refusal content part indicating the model declined to respond.
@immutable
class RefusalContentPart extends ContentPart {
  /// Creates a [RefusalContentPart].
  const RefusalContentPart({required this.refusal});

  /// Creates a [RefusalContentPart] from JSON.
  factory RefusalContentPart.fromJson(Map<String, dynamic> json) {
    return RefusalContentPart(refusal: json['refusal'] as String);
  }

  /// The refusal message generated by the model.
  final String refusal;

  @override
  String get type => 'refusal';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'refusal': refusal};

  /// Creates a copy with the given fields replaced.
  RefusalContentPart copyWith({String? refusal}) {
    return RefusalContentPart(refusal: refusal ?? this.refusal);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalContentPart &&
          runtimeType == other.runtimeType &&
          refusal == other.refusal;

  @override
  int get hashCode => refusal.hashCode;

  @override
  String toString() => 'ContentPart.refusal($refusal)';
}

/// Image detail level for vision models.
enum ImageDetail {
  /// Let the model automatically determine the detail level.
  auto('auto'),

  /// Low detail: faster processing, lower cost.
  low('low'),

  /// High detail: more thorough processing, higher cost.
  high('high'),

  /// Original detail: use the original image without modification.
  original('original');

  const ImageDetail(this.value);

  /// The JSON value for this detail level.
  final String value;

  /// Creates an [ImageDetail] from JSON.
  static ImageDetail fromJson(String value) => switch (value) {
    'auto' => ImageDetail.auto,
    'low' => ImageDetail.low,
    'high' => ImageDetail.high,
    'original' => ImageDetail.original,
    _ => throw FormatException('Unknown ImageDetail: $value'),
  };

  /// Converts to JSON.
  String toJson() => value;
}

/// Audio format for audio input/output.
enum AudioFormat {
  /// WAV format.
  wav('wav'),

  /// MP3 format.
  mp3('mp3'),

  /// FLAC format.
  flac('flac'),

  /// Opus format.
  opus('opus'),

  /// PCM 16-bit format.
  pcm16('pcm16');

  const AudioFormat(this.value);

  /// The JSON value for this format.
  final String value;

  /// Creates an [AudioFormat] from JSON.
  static AudioFormat fromJson(String value) => switch (value) {
    'wav' => AudioFormat.wav,
    'mp3' => AudioFormat.mp3,
    'flac' => AudioFormat.flac,
    'opus' => AudioFormat.opus,
    'pcm16' => AudioFormat.pcm16,
    _ => throw FormatException('Unknown AudioFormat: $value'),
  };

  /// Converts to JSON.
  String toJson() => value;
}
