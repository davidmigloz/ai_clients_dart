import 'package:meta/meta.dart';

/// A request to generate speech from text.
///
/// Uses the text-to-speech API to convert text into spoken audio.
///
/// ## Example
///
/// ```dart
/// final request = SpeechRequest(
///   model: 'tts-1',
///   input: 'Hello, world!',
///   voice: SpeechVoice.alloy,
/// );
/// ```
@immutable
class SpeechRequest {
  /// Creates a [SpeechRequest].
  const SpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
    this.responseFormat,
    this.speed,
  });

  /// Creates a [SpeechRequest] from JSON.
  factory SpeechRequest.fromJson(Map<String, dynamic> json) {
    return SpeechRequest(
      model: json['model'] as String,
      input: json['input'] as String,
      voice: SpeechVoice.fromJson(json['voice'] as String),
      responseFormat: json['response_format'] != null
          ? SpeechResponseFormat.fromJson(json['response_format'] as String)
          : null,
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  /// The TTS model to use.
  ///
  /// Available models:
  /// - `tts-1` - Standard quality, lower latency
  /// - `tts-1-hd` - Higher quality audio
  final String model;

  /// The text to generate audio for.
  ///
  /// Maximum length is 4096 characters.
  final String input;

  /// The voice to use for speech generation.
  final SpeechVoice voice;

  /// The audio format for the output.
  ///
  /// Defaults to `mp3`.
  final SpeechResponseFormat? responseFormat;

  /// The speed of the generated audio.
  ///
  /// Range: 0.25 to 4.0. Default is 1.0.
  final double? speed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input,
    'voice': voice.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (speed != null) 'speed': speed,
  };

  /// Creates a copy with the given fields replaced.
  SpeechRequest copyWith({
    String? model,
    String? input,
    SpeechVoice? voice,
    SpeechResponseFormat? responseFormat,
    double? speed,
  }) {
    return SpeechRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      voice: voice ?? this.voice,
      responseFormat: responseFormat ?? this.responseFormat,
      speed: speed ?? this.speed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          voice == other.voice &&
          responseFormat == other.responseFormat &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(model, input, voice, responseFormat, speed);

  @override
  String toString() =>
      'SpeechRequest(model: $model, voice: $voice, ${input.length} chars)';
}

/// Available voices for text-to-speech.
enum SpeechVoice {
  /// Alloy voice.
  alloy._('alloy'),

  /// Echo voice.
  echo._('echo'),

  /// Fable voice.
  fable._('fable'),

  /// Onyx voice.
  onyx._('onyx'),

  /// Nova voice.
  nova._('nova'),

  /// Shimmer voice.
  shimmer._('shimmer');

  const SpeechVoice._(this._value);

  /// Creates from JSON string.
  factory SpeechVoice.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown voice: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Audio output formats for speech generation.
enum SpeechResponseFormat {
  /// MP3 format (default).
  mp3._('mp3'),

  /// Opus format.
  opus._('opus'),

  /// AAC format.
  aac._('aac'),

  /// FLAC format.
  flac._('flac'),

  /// WAV format.
  wav._('wav'),

  /// PCM format.
  pcm._('pcm');

  const SpeechResponseFormat._(this._value);

  /// Creates from JSON string.
  factory SpeechResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown audio format: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}
