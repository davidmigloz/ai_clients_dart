import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'speech_output_format.dart';

/// Request for speech synthesis (text-to-speech).
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

  /// Creates a [SpeechRequest].
  const SpeechRequest({
    required this.input,
    this.model,
    this.voiceId,
    this.refAudio,
    this.responseFormat,
    this.stream,
  });

  /// Creates a [SpeechRequest] from JSON.
  factory SpeechRequest.fromJson(Map<String, dynamic> json) => SpeechRequest(
    input: json['input'] as String? ?? '',
    model: json['model'] as String?,
    voiceId: json['voice_id'] as String?,
    refAudio: json['ref_audio'] as String?,
    responseFormat: SpeechOutputFormat.fromString(
      json['response_format'] as String?,
    ),
    stream: json['stream'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
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
          stream == other.stream;

  @override
  int get hashCode =>
      Object.hash(input, model, voiceId, refAudio, responseFormat, stream);

  @override
  String toString() =>
      'SpeechRequest(input: ${input.length > 50 ? '${input.substring(0, 50)}...' : input}, '
      'model: $model, '
      'voiceId: $voiceId, '
      'refAudio: ${refAudio != null ? '${refAudio!.length} chars' : null}, '
      'responseFormat: $responseFormat, '
      'stream: $stream)';
}
