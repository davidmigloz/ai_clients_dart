import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request for audio transcription.
///
/// The audio source must be provided in exactly one of three ways, matching
/// the `multipart/form-data` fields of `POST /v1/audio/transcriptions`:
///
/// - [fileBytes] together with [fileName]: the raw audio, sent inline as the
///   `file` part, without creating an entry in the Files store.
/// - [fileUrl]: a URL the API downloads the audio from (`file_url`).
/// - [file]: the ID of a file previously uploaded to `/v1/files` (`file_id`).
@immutable
class TranscriptionRequest {
  /// ID of a file previously uploaded to `/v1/files`, sent as the `file_id`
  /// form field.
  ///
  /// Prefer [fileBytes] when the audio is already in memory: it avoids the
  /// upload round-trip and leaves nothing in the Files store.
  final String? file;

  /// URL of the audio to transcribe, sent as the `file_url` form field.
  final String? fileUrl;

  /// Raw audio bytes, sent inline as the `file` multipart part.
  ///
  /// Requires [fileName]; its extension lets the server detect the format.
  final List<int>? fileBytes;

  /// File name attached to [fileBytes] (e.g. `recording.wav`).
  final String? fileName;

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
  ///
  /// When `true`, both `segment` and `word` granularities are requested.
  final bool? timestampGranularities;

  /// Bias towards specific words or phrases during transcription.
  ///
  /// A list of words or phrases to bias towards during transcription.
  final List<String>? contextBias;

  /// Whether to enable speaker diarization.
  final bool? diarize;

  /// Creates a [TranscriptionRequest].
  const TranscriptionRequest({
    this.file,
    this.fileUrl,
    this.fileBytes,
    this.fileName,
    this.model = 'mistral-audio-latest',
    this.language,
    this.responseFormat,
    this.prompt,
    this.temperature,
    this.timestampGranularities,
    this.contextBias,
    this.diarize,
  });

  /// Creates a [TranscriptionRequest] from JSON.
  ///
  /// Only the reference-based sources ([file], [fileUrl]) round-trip through
  /// JSON; [fileBytes] is a transport-level payload and is never serialized.
  factory TranscriptionRequest.fromJson(Map<String, dynamic> json) =>
      TranscriptionRequest(
        file: json['file'] as String?,
        fileUrl: json['file_url'] as String?,
        model: json['model'] as String? ?? 'mistral-audio-latest',
        language: json['language'] as String?,
        responseFormat: json['response_format'] as String?,
        prompt: json['prompt'] as String?,
        temperature: (json['temperature'] as num?)?.toDouble(),
        timestampGranularities: json['timestamp_granularities'] as bool?,
        contextBias: (json['context_bias'] as List?)?.cast<String>(),
        diarize: json['diarize'] as bool?,
      );

  /// Whether exactly one audio source ([file], [fileUrl] or [fileBytes]) is
  /// set, as required by the API.
  bool get hasSingleAudioSource =>
      [file, fileUrl, fileBytes].where((source) => source != null).length == 1;

  /// Converts to JSON.
  ///
  /// [fileBytes] and [fileName] are omitted: the binary source only exists in
  /// the multipart request body.
  Map<String, dynamic> toJson() => {
    if (file != null) 'file': file,
    if (fileUrl != null) 'file_url': fileUrl,
    'model': model,
    if (language != null) 'language': language,
    if (responseFormat != null) 'response_format': responseFormat,
    if (prompt != null) 'prompt': prompt,
    if (temperature != null) 'temperature': temperature,
    if (timestampGranularities != null)
      'timestamp_granularities': timestampGranularities,
    if (contextBias != null) 'context_bias': contextBias,
    if (diarize != null) 'diarize': diarize,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` to clear a nullable field. When changing audio sources,
  /// explicitly clear the previous source so exactly one remains set.
  TranscriptionRequest copyWith({
    Object? file = unsetCopyWithValue,
    Object? fileUrl = unsetCopyWithValue,
    Object? fileBytes = unsetCopyWithValue,
    Object? fileName = unsetCopyWithValue,
    String? model,
    Object? language = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? timestampGranularities = unsetCopyWithValue,
    Object? contextBias = unsetCopyWithValue,
    Object? diarize = unsetCopyWithValue,
  }) => TranscriptionRequest(
    file: file == unsetCopyWithValue ? this.file : file as String?,
    fileUrl: fileUrl == unsetCopyWithValue ? this.fileUrl : fileUrl as String?,
    fileBytes: fileBytes == unsetCopyWithValue
        ? this.fileBytes
        : (fileBytes as List?)?.cast<int>(),
    fileName: fileName == unsetCopyWithValue
        ? this.fileName
        : fileName as String?,
    model: model ?? this.model,
    language: language == unsetCopyWithValue
        ? this.language
        : language as String?,
    responseFormat: responseFormat == unsetCopyWithValue
        ? this.responseFormat
        : responseFormat as String?,
    prompt: prompt == unsetCopyWithValue ? this.prompt : prompt as String?,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    timestampGranularities: timestampGranularities == unsetCopyWithValue
        ? this.timestampGranularities
        : timestampGranularities as bool?,
    contextBias: contextBias == unsetCopyWithValue
        ? this.contextBias
        : (contextBias as List?)?.cast<String>(),
    diarize: diarize == unsetCopyWithValue ? this.diarize : diarize as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionRequest &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          fileUrl == other.fileUrl &&
          listsEqual(fileBytes, other.fileBytes) &&
          fileName == other.fileName &&
          model == other.model &&
          language == other.language &&
          responseFormat == other.responseFormat &&
          prompt == other.prompt &&
          temperature == other.temperature &&
          timestampGranularities == other.timestampGranularities &&
          listsEqual(contextBias, other.contextBias) &&
          diarize == other.diarize;

  @override
  int get hashCode => Object.hash(
    file,
    fileUrl,
    listHash(fileBytes),
    fileName,
    model,
    language,
    responseFormat,
    prompt,
    temperature,
    timestampGranularities,
    listHash(contextBias),
    diarize,
  );

  @override
  String toString() =>
      'TranscriptionRequest('
      'file: $file, '
      'fileUrl: $fileUrl, '
      'fileBytes: ${fileBytes == null ? 'null' : '${fileBytes!.length} bytes'}, '
      'fileName: $fileName, '
      'model: $model, '
      'language: $language, '
      'responseFormat: $responseFormat, '
      'prompt: $prompt, '
      'temperature: $temperature, '
      'timestampGranularities: $timestampGranularities, '
      'contextBias: ${contextBias == null ? 'null' : '${contextBias!.length} items'}, '
      'diarize: $diarize)';
}
