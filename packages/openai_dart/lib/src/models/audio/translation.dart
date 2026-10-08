import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_json_helpers.dart';
import 'file_audio_json_helpers.dart';
import 'transcription.dart' show TranscriptionSegment;

/// A request to translate audio into English text.
///
/// Converts audio in various languages to English text.
///
/// ## Example
///
/// ```dart
/// final request = TranslationRequest(
///   file: audioBytes,
///   filename: 'german_audio.mp3',
///   model: 'whisper-1',
/// );
/// ```
@immutable
class TranslationRequest {
  /// Creates a [TranslationRequest].
  TranslationRequest({
    required Uint8List file,
    required this.filename,
    required this.model,
    this.fileContentType,
    this.prompt,
    this.responseFormat,
    this.temperature,
  }) : file = Uint8List.fromList(file).asUnmodifiableView();

  /// The audio file to translate.
  ///
  /// Supported formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.
  final Uint8List file;

  /// The filename of the audio file.
  ///
  /// Provide enough format metadata for identification. An extension-bearing
  /// filename and an appropriate [fileContentType] are recommended.
  final String filename;

  /// Optional MIME metadata for the file part, separate from API form fields.
  final String? fileContentType;

  /// The model to use for translation.
  ///
  /// Currently only `whisper-1` is available.
  final String model;

  /// Optional text to guide the model's style.
  ///
  /// Should be in English and can include example phrases to improve accuracy.
  final String? prompt;

  /// The format of the translation output.
  ///
  /// Defaults to `json`.
  final TranslationResponseFormat? responseFormat;

  /// The sampling temperature, between 0 and 1.
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  /// Validates writable admission before authentication or multipart dispatch.
  void validate() {
    if (responseFormat == TranslationResponseFormat.unknown) {
      throw const FormatException(
        'TranslationRequest.responseFormat: unsupported writable value',
      );
    }
    validateFileAudioTemperature(temperature, 'TranslationRequest.temperature');
  }

  /// Copies every field, with explicit null clearing optional values.
  TranslationRequest copyWith({
    Uint8List? file,
    String? filename,
    String? model,
    Object? fileContentType = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
  }) => TranslationRequest(
    file: file ?? this.file,
    filename: filename ?? this.filename,
    model: model ?? this.model,
    fileContentType: fileContentType == unsetCopyWithValue
        ? this.fileContentType
        : fileContentType as String?,
    prompt: prompt == unsetCopyWithValue ? this.prompt : prompt as String?,
    responseFormat: responseFormat == unsetCopyWithValue
        ? this.responseFormat
        : responseFormat as TranslationResponseFormat?,
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : copyFileAudioNumber(temperature, 'TranslationRequest.temperature'),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(file, other.file) &&
          filename == other.filename &&
          model == other.model &&
          fileContentType == other.fileContentType &&
          prompt == other.prompt &&
          responseFormat == other.responseFormat &&
          temperature == other.temperature;

  @override
  int get hashCode => Object.hash(
    listHash(file),
    filename,
    model,
    fileContentType,
    prompt,
    responseFormat,
    temperature,
  );

  @override
  String toString() =>
      'TranslationRequest(file: ${file.length} bytes, filename: [REDACTED], model: [REDACTED], fileContentType: ${fileAudioPresence(fileContentType)}, prompt: ${fileAudioPresence(prompt)}, responseFormat: $responseFormat, temperature: $temperature)';
}

/// The format of the translation output.
///
/// `CreateTranslationRequest.response_format` is its own inline enum in the
/// spec — it does not include `diarized_json` and does not reference the
/// shared `AudioResponseFormat` component used by transcriptions, so it is
/// modeled as a separate type here rather than being widened to
/// [AudioResponseFormat].
enum TranslationResponseFormat {
  /// Unknown format — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

  /// JSON format with just the text.
  json._('json'),

  /// Plain text format.
  text._('text'),

  /// SubRip subtitle format.
  srt._('srt'),

  /// Verbose JSON with timestamps and metadata.
  verboseJson._('verbose_json'),

  /// WebVTT subtitle format.
  vtt._('vtt');

  const TranslationResponseFormat._(this._value);

  /// Creates from JSON string. Unknown values map to
  /// [TranslationResponseFormat.unknown].
  factory TranslationResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => TranslationResponseFormat.unknown,
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Typed TranslationResponse fields and immutable received future metadata.
@immutable
class TranslationResponse {
  /// Creates a [TranslationResponse]; scalar const construction remains available.
  const TranslationResponse({required this.text}) : rawJson = const {};

  TranslationResponse._({
    required this.text,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranslationResponse',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'text'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranslationResponse',
      knownKeys: _fields,
    );
    return TranslationResponse._(
      text: requireFileAudioString(raw['text'], 'TranslationResponse.text'),
      rawJson: raw,
    );
  }

  /// The text field.
  final String text;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'text': text,
    }, 'TranslationResponse');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranslationResponse copyWith({String? text, Map<String, dynamic>? rawJson}) {
    return TranslationResponse._(
      text: text ?? this.text,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranslationResponse(text: ${fileAudioPresence(text)}, rawJson: [REDACTED])';
}

/// English translation with duration and optional segment timestamps.
///
/// Canonical responses require language, duration and text; [task] is retained
/// only as optional legacy metadata. Parsed and constructed collections own
/// immutable snapshots, including received future members.
@immutable
class TranslationVerboseResponse {
  /// Creates a [TranslationVerboseResponse] with owned snapshots.
  TranslationVerboseResponse({
    this.task,
    required this.language,
    required this.duration,
    required this.text,
    List<TranscriptionSegment>? segments,
    Map<String, dynamic> rawJson = const {},
  }) : segments = immutableFileAudioList(segments),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranslationVerboseResponse',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'language',
    'duration',
    'text',
    'segments',
    'task',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranslationVerboseResponse.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranslationVerboseResponse',
      knownKeys: _fields,
    );
    return TranslationVerboseResponse(
      task: optionalFileAudio(
        raw,
        'task',
        'TranslationVerboseResponse',
        requireFileAudioString,
      ),
      language: requireFileAudioString(
        raw['language'],
        'TranslationVerboseResponse.language',
      ),
      duration: requireAudioNumber(
        raw['duration'],
        'TranslationVerboseResponse.duration',
      ),
      text: requireFileAudioString(
        raw['text'],
        'TranslationVerboseResponse.text',
      ),
      segments: optionalFileAudio(
        raw,
        'segments',
        'TranslationVerboseResponse',
        (value, context) => requireFileAudioList<TranscriptionSegment>(
          value,
          context,
          (value, context) => TranscriptionSegment.fromJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      rawJson: raw,
    );
  }

  /// Optional legacy task metadata; absent in the canonical response.
  final String? task;

  /// Output language (English), not detected source language.
  final String language;

  /// The duration field.
  final double duration;

  /// The text field.
  final String text;

  /// The segments field when present.
  final List<TranscriptionSegment>? segments;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      if (task != null) 'task': task,
      'language': language,
      'duration': duration,
      'text': text,
      if (segments != null)
        'segments': mergeFileAudioChildren(
          rawJson['segments'],
          segments!.map((value) => value.toJson()).toList(),
          const {
            'id',
            'seek',
            'start',
            'end',
            'text',
            'tokens',
            'temperature',
            'avg_logprob',
            'compression_ratio',
            'no_speech_prob',
          },
        ),
    }, 'TranslationVerboseResponse');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranslationVerboseResponse copyWith({
    Object? task = unsetCopyWithValue,
    String? language,
    double? duration,
    String? text,
    Object? segments = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranslationVerboseResponse(
      task: task == unsetCopyWithValue ? this.task : task as String?,
      language: language ?? this.language,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      segments: segments == unsetCopyWithValue
          ? this.segments
          : segments as List<TranscriptionSegment>?,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (segments != unsetCopyWithValue) 'segments',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationVerboseResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranslationVerboseResponse(task: ${fileAudioPresence(task)}, language: ${fileAudioPresence(language)}, duration: $duration, text: ${fileAudioPresence(text)}, segments: ${fileAudioListSummary(segments)}, rawJson: [REDACTED])';
}
