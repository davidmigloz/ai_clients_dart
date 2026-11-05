import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'speech_response_format.dart';

/// Text-to-speech request for `/v1/audio/speech` (Ollama 0.40.8+).
///
/// Ollama validates model capabilities, input length, voices, and options.
@immutable
class SpeechRequest {
  /// Speech model name, for example `phonon`.
  final String model;

  /// Text to speak, up to 4,096 Unicode characters.
  final String input;

  /// Model voice name. Omission selects the model's default voice.
  final String? voice;

  /// Audio format. Omission selects WAV on Ollama, rather than MP3.
  final SpeechResponseFormat? responseFormat;

  /// Playback speed. Ollama 0.40.14 accepts only `1`.
  final double? speed;

  /// Voice instructions. Ollama 0.40.14 rejects nonempty instructions.
  final String? instructions;

  /// Streaming representation. Ollama 0.40.14 accepts only `audio`.
  final String? streamFormat;

  /// Creates a [SpeechRequest].
  const SpeechRequest({
    required this.model,
    required this.input,
    this.voice,
    this.responseFormat,
    this.speed,
    this.instructions,
    this.streamFormat,
  });

  /// Creates a request from JSON.
  factory SpeechRequest.fromJson(Map<String, dynamic> json) => SpeechRequest(
    model: _requiredSpeechString(json['model'], 'model'),
    input: _requiredSpeechString(json['input'], 'input'),
    voice: json['voice'] as String?,
    responseFormat: json['response_format'] == null
        ? null
        : SpeechResponseFormat.fromJson(json['response_format'] as String),
    speed: (json['speed'] as num?)?.toDouble(),
    instructions: json['instructions'] as String?,
    streamFormat: json['stream_format'] as String?,
  );

  /// Converts to JSON, leaving unset server defaults omitted.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': input,
    if (voice != null) 'voice': voice,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (speed != null) 'speed': speed,
    if (instructions != null) 'instructions': instructions,
    if (streamFormat != null) 'stream_format': streamFormat,
  };

  /// Creates a copy, allowing nullable options to be cleared with `null`.
  SpeechRequest copyWith({
    String? model,
    String? input,
    Object? voice = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? streamFormat = unsetCopyWithValue,
  }) => SpeechRequest(
    model: model ?? this.model,
    input: input ?? this.input,
    voice: identical(voice, unsetCopyWithValue) ? this.voice : voice as String?,
    responseFormat: identical(responseFormat, unsetCopyWithValue)
        ? this.responseFormat
        : responseFormat as SpeechResponseFormat?,
    speed: identical(speed, unsetCopyWithValue)
        ? this.speed
        : (speed as num?)?.toDouble(),
    instructions: identical(instructions, unsetCopyWithValue)
        ? this.instructions
        : instructions as String?,
    streamFormat: identical(streamFormat, unsetCopyWithValue)
        ? this.streamFormat
        : streamFormat as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechRequest &&
          model == other.model &&
          input == other.input &&
          voice == other.voice &&
          responseFormat == other.responseFormat &&
          speed == other.speed &&
          instructions == other.instructions &&
          streamFormat == other.streamFormat;

  @override
  int get hashCode => Object.hash(
    model,
    input,
    voice,
    responseFormat,
    speed,
    instructions,
    streamFormat,
  );

  @override
  String toString() =>
      'SpeechRequest(model: $model, input: $input, '
      'voice: $voice, responseFormat: $responseFormat, speed: $speed, '
      'instructions: $instructions, streamFormat: $streamFormat)';
}

String _requiredSpeechString(Object? value, String field) {
  if (value is! String) {
    throw FormatException('SpeechRequest.$field must be a string');
  }
  return value;
}
