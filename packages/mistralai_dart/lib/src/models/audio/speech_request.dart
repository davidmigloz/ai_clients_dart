import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'speech_output_format.dart';

/// Request for speech synthesis (text-to-speech).
///
/// The [extra] field holds additional properties beyond the declared fields,
/// as the Mistral API spec allows `additionalProperties` on this type.
@immutable
class SpeechRequest {
  /// Text to generate speech from.
  final String input;

  /// The model to use for speech synthesis.
  final String? model;

  /// The preset or custom voice to use.
  final String? voiceId;

  /// Base64-encoded audio reference for zero-shot voice cloning.
  final String? refAudio;

  /// Output audio format. Defaults to mp3.
  final SpeechOutputFormat? responseFormat;

  /// Whether to stream the response.
  final bool? stream;

  /// Additional properties not covered by the named fields.
  final Map<String, dynamic>? extra;

  /// Creates a [SpeechRequest].
  const SpeechRequest({
    required this.input,
    this.model,
    this.voiceId,
    this.refAudio,
    this.responseFormat,
    this.stream,
    this.extra,
  });

  /// Creates a [SpeechRequest] from JSON.
  factory SpeechRequest.fromJson(Map<String, dynamic> json) {
    const knownKeys = {
      'input',
      'model',
      'voice_id',
      'ref_audio',
      'response_format',
      'stream',
    };
    final extraEntries = {
      for (final entry in json.entries)
        if (!knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return SpeechRequest(
      input: json['input'] as String? ?? '',
      model: json['model'] as String?,
      voiceId: json['voice_id'] as String?,
      refAudio: json['ref_audio'] as String?,
      responseFormat: SpeechOutputFormat.fromString(
        json['response_format'] as String?,
      ),
      stream: json['stream'] as bool?,
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  /// Converts to JSON.
  ///
  /// [extra] is spread first; non-null typed fields are written after, so they
  /// take precedence on key collision.
  Map<String, dynamic> toJson() => {
    if (extra != null) ...extra!,
    'input': input,
    if (model != null) 'model': model,
    if (voiceId != null) 'voice_id': voiceId,
    if (refAudio != null) 'ref_audio': refAudio,
    if (responseFormat != null) 'response_format': responseFormat!.value,
    if (stream != null) 'stream': stream,
  };

  /// Creates a copy with replaced values.
  SpeechRequest copyWith({
    String? input,
    Object? model = unsetCopyWithValue,
    Object? voiceId = unsetCopyWithValue,
    Object? refAudio = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) {
    return SpeechRequest(
      input: input ?? this.input,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      voiceId: voiceId == unsetCopyWithValue
          ? this.voiceId
          : voiceId as String?,
      refAudio: refAudio == unsetCopyWithValue
          ? this.refAudio
          : refAudio as String?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as SpeechOutputFormat?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      extra: extra == unsetCopyWithValue
          ? this.extra
          : extra as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechRequest &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          model == other.model &&
          voiceId == other.voiceId &&
          refAudio == other.refAudio &&
          responseFormat == other.responseFormat &&
          stream == other.stream &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    input,
    model,
    voiceId,
    refAudio,
    responseFormat,
    stream,
    mapDeepHashCode(extra),
  );

  @override
  String toString() =>
      'SpeechRequest(input: ${input.length > 50 ? '${input.substring(0, 50)}...' : input}, '
      'model: $model, '
      'voiceId: $voiceId, '
      'refAudio: ${refAudio != null ? '${refAudio!.length} chars' : null}, '
      'responseFormat: $responseFormat, '
      'stream: $stream, '
      'extra: ${extra != null ? '${extra!.length} entries' : null})';
}
