import 'package:meta/meta.dart';

/// Request for audio transcription.
@immutable
class TranscriptionRequest {
  /// The audio file to transcribe.
  ///
  /// This should be the file ID of an uploaded audio file,
  /// or base64-encoded audio data.
  final String file;

  /// The model to use for transcription.
  ///
  /// Use 'mistral-audio-latest' for the best results.
  final String model;

  /// The language of the audio in ISO-639-1 format.
  ///
  /// If not specified, the language is auto-detected.
  final String? language;

  /// The format of the output.
  ///
  /// Options: 'json', 'text', 'srt', 'vtt', 'verbose_json'
  final String? responseFormat;

  /// A prompt to guide the transcription.
  ///
  /// This can help with proper nouns, technical terms, etc.
  final String? prompt;

  /// Temperature for sampling.
  ///
  /// Higher values make output more random, lower values more deterministic.
  /// Range: 0.0 to 1.0
  final double? temperature;

  /// Whether to include word-level timestamps.
  final bool? timestampGranularities;

  /// Creates a [TranscriptionRequest].
  const TranscriptionRequest({
    required this.file,
    this.model = 'mistral-audio-latest',
    this.language,
    this.responseFormat,
    this.prompt,
    this.temperature,
    this.timestampGranularities,
  });

  /// Creates a [TranscriptionRequest] from JSON.
  factory TranscriptionRequest.fromJson(Map<String, dynamic> json) =>
      TranscriptionRequest(
        file: json['file'] as String? ?? '',
        model: json['model'] as String? ?? 'mistral-audio-latest',
        language: json['language'] as String?,
        responseFormat: json['response_format'] as String?,
        prompt: json['prompt'] as String?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        timestampGranularities: json['timestamp_granularities'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file': file,
    'model': model,
    if (language != null) 'language': language,
    if (responseFormat != null) 'response_format': responseFormat,
    if (prompt != null) 'prompt': prompt,
    if (temperature != null) 'temperature': temperature,
    if (timestampGranularities != null)
      'timestamp_granularities': timestampGranularities,
  };

  /// Creates a copy with the specified fields replaced.
  TranscriptionRequest copyWith({
    String? file,
    String? model,
    String? language,
    String? responseFormat,
    String? prompt,
    double? temperature,
    bool? timestampGranularities,
  }) => TranscriptionRequest(
    file: file ?? this.file,
    model: model ?? this.model,
    language: language ?? this.language,
    responseFormat: responseFormat ?? this.responseFormat,
    prompt: prompt ?? this.prompt,
    temperature: temperature ?? this.temperature,
    timestampGranularities:
        timestampGranularities ?? this.timestampGranularities,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionRequest &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          model == other.model;

  @override
  int get hashCode => Object.hash(file, model);

  @override
  String toString() => 'TranscriptionRequest(file: $file, model: $model)';
}
