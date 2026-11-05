import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_file.dart';
import 'audio_text_response_format.dart';

/// Common options for multipart speech-to-text requests.
@immutable
sealed class AudioTextRequest {
  /// Model accepting audio input.
  final String model;

  /// Audio to transcribe or translate.
  final AudioFile file;

  /// Spoken language, as an ISO code, BCP 47 tag, or English language name.
  /// Omit this to let the model detect the language.
  final String? language;

  /// Context for models without speech-specific instructions.
  final String? prompt;

  /// Response representation. Omission selects JSON.
  final AudioTextResponseFormat? responseFormat;

  /// Sampling temperature. Omission selects zero on Ollama.
  final double? temperature;

  /// Whether the server emits transcript SSE events.
  /// Resource methods set this to match buffered or streaming consumption.
  final bool? stream;

  /// Creates shared request options.
  const AudioTextRequest({
    required this.model,
    required this.file,
    this.language,
    this.prompt,
    this.responseFormat,
    this.temperature,
    this.stream,
  });

  /// Converts to JSON for storage; HTTP requests use multipart form data.
  Map<String, dynamic> toJson() => {
    'model': model,
    'file': file.toJson(),
    if (language != null) 'language': language,
    if (prompt != null) 'prompt': prompt,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (stream != null) 'stream': stream,
  };

  /// Multipart scalar fields, excluding the uploaded file.
  Map<String, String> toFields({bool? streamOverride}) => {
    'model': model,
    'language': ?language,
    'prompt': ?prompt,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (temperature != null) 'temperature': temperature.toString(),
    if (streamOverride ?? stream case final value?) 'stream': value.toString(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTextRequest &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      '${this is TranscriptionRequest ? 'TranscriptionRequest' : 'TranslationRequest'}(model: $model, file: $file, '
      'language: $language, prompt: $prompt, responseFormat: $responseFormat, '
      'temperature: $temperature, stream: $stream)';
}

/// Request for `/v1/audio/transcriptions`.
final class TranscriptionRequest extends AudioTextRequest {
  /// Creates a transcription request.
  const TranscriptionRequest({
    required super.model,
    required super.file,
    super.language,
    super.prompt,
    super.responseFormat,
    super.temperature,
    super.stream,
  });

  /// Creates a request from JSON.
  factory TranscriptionRequest.fromJson(Map<String, dynamic> json) =>
      TranscriptionRequest(
        model: _audioTextModel(json['model']),
        file: _audioTextFile(json['file']),
        language: json['language'] as String?,
        prompt: json['prompt'] as String?,
        responseFormat: json['response_format'] == null
            ? null
            : AudioTextResponseFormat.fromJson(
                json['response_format'] as String,
              ),
        temperature: (json['temperature'] as num?)?.toDouble(),
        stream: json['stream'] as bool?,
      );

  /// Creates a copy, allowing nullable options to be cleared with `null`.
  TranscriptionRequest copyWith({
    String? model,
    AudioFile? file,
    Object? language = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
  }) => TranscriptionRequest(
    model: model ?? this.model,
    file: file ?? this.file,
    language: identical(language, unsetCopyWithValue)
        ? this.language
        : language as String?,
    prompt: identical(prompt, unsetCopyWithValue)
        ? this.prompt
        : prompt as String?,
    responseFormat: identical(responseFormat, unsetCopyWithValue)
        ? this.responseFormat
        : responseFormat as AudioTextResponseFormat?,
    temperature: identical(temperature, unsetCopyWithValue)
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    stream: identical(stream, unsetCopyWithValue)
        ? this.stream
        : stream as bool?,
  );
}

/// Request for `/v1/audio/translations` (Ollama 0.40.12+).
final class TranslationRequest extends AudioTextRequest {
  /// Output language, as an ISO code, BCP 47 tag, or English name.
  /// Omission selects English on Ollama.
  final String? toLanguage;

  /// Creates a translation request.
  const TranslationRequest({
    required super.model,
    required super.file,
    super.language,
    super.prompt,
    super.responseFormat,
    super.temperature,
    super.stream,
    this.toLanguage,
  });

  /// Creates a request from JSON.
  factory TranslationRequest.fromJson(Map<String, dynamic> json) =>
      TranslationRequest(
        model: _audioTextModel(json['model']),
        file: _audioTextFile(json['file']),
        language: json['language'] as String?,
        prompt: json['prompt'] as String?,
        responseFormat: json['response_format'] == null
            ? null
            : AudioTextResponseFormat.fromJson(
                json['response_format'] as String,
              ),
        temperature: (json['temperature'] as num?)?.toDouble(),
        stream: json['stream'] as bool?,
        toLanguage: json['to_language'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    if (toLanguage != null) 'to_language': toLanguage,
  };

  @override
  Map<String, String> toFields({bool? streamOverride}) => {
    ...super.toFields(streamOverride: streamOverride),
    'to_language': ?toLanguage,
  };

  /// Creates a copy, allowing nullable options to be cleared with `null`.
  TranslationRequest copyWith({
    String? model,
    AudioFile? file,
    Object? language = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? toLanguage = unsetCopyWithValue,
  }) => TranslationRequest(
    model: model ?? this.model,
    file: file ?? this.file,
    language: identical(language, unsetCopyWithValue)
        ? this.language
        : language as String?,
    prompt: identical(prompt, unsetCopyWithValue)
        ? this.prompt
        : prompt as String?,
    responseFormat: identical(responseFormat, unsetCopyWithValue)
        ? this.responseFormat
        : responseFormat as AudioTextResponseFormat?,
    temperature: identical(temperature, unsetCopyWithValue)
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    stream: identical(stream, unsetCopyWithValue)
        ? this.stream
        : stream as bool?,
    toLanguage: identical(toLanguage, unsetCopyWithValue)
        ? this.toLanguage
        : toLanguage as String?,
  );

  @override
  String toString() => '${super.toString()}, toLanguage: $toLanguage';
}

String _audioTextModel(Object? value) {
  if (value is! String) {
    throw const FormatException('AudioTextRequest.model must be a string');
  }
  return value;
}

AudioFile _audioTextFile(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('AudioTextRequest.file must be an object');
  }
  return AudioFile.fromJson(value);
}
