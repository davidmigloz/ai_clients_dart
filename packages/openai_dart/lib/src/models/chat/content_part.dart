import 'package:meta/meta.dart';

/// A part of a multimodal message content.
///
/// Content parts allow user messages to contain multiple types of content,
/// including text, images, and audio.
///
/// ## Example
///
/// ```dart
/// final parts = [
///   ContentPart.text('What is in this image?'),
///   ContentPart.imageUrl(
///     url: 'https://example.com/image.jpg',
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
      _ => throw FormatException('Unknown content part type: $type'),
    };
  }

  /// Creates a text content part.
  static ContentPart text(String text) => TextContentPart(text: text);

  /// Creates an image URL content part.
  static ContentPart imageUrl({required String url, ImageDetail? detail}) =>
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
  /// - [ImageDetail.auto]: Let the model decide (default)
  final ImageDetail? detail;

  @override
  String get type => 'image_url';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'image_url': {'url': url, if (detail != null) 'detail': detail!.toJson()},
  };

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

/// Image detail level for vision models.
enum ImageDetail {
  /// Let the model automatically determine the detail level.
  auto('auto'),

  /// Low detail: faster processing, lower cost.
  low('low'),

  /// High detail: more thorough processing, higher cost.
  high('high');

  const ImageDetail(this.value);

  /// The JSON value for this detail level.
  final String value;

  /// Creates an [ImageDetail] from JSON.
  static ImageDetail fromJson(String value) => switch (value) {
    'auto' => ImageDetail.auto,
    'low' => ImageDetail.low,
    'high' => ImageDetail.high,
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
