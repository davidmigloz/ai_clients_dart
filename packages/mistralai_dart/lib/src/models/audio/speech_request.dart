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

  /// Custom request metadata.
  final Map<String, dynamic>? metadata;

  /// Cache key for reusing prompt processing across requests.
  final String? promptCacheKey;

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
    this.metadata,
    this.promptCacheKey,
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
      'metadata',
      'prompt_cache_key',
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
      metadata: json['metadata'] as Map<String, dynamic>?,
      promptCacheKey: json['prompt_cache_key'] as String?,
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  /// Converts to JSON.
  ///
  /// [extra] is spread first; non-null typed fields are written after, so they
  /// take precedence on key collision.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'input': input,
    if (model != null) 'model': model,
    if (voiceId != null) 'voice_id': voiceId,
    if (refAudio != null) 'ref_audio': refAudio,
    if (responseFormat != null) 'response_format': responseFormat!.value,
    if (stream != null) 'stream': stream,
    if (metadata != null) 'metadata': metadata,
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
  };

  /// Creates a copy with replaced values.
  SpeechRequest copyWith({
    String? input,
    Object? model = unsetCopyWithValue,
    Object? voiceId = unsetCopyWithValue,
    Object? refAudio = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
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
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      promptCacheKey: promptCacheKey == unsetCopyWithValue
          ? this.promptCacheKey
          : promptCacheKey as String?,
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
          mapsDeepEqual(metadata, other.metadata) &&
          promptCacheKey == other.promptCacheKey &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    input,
    model,
    voiceId,
    refAudio,
    responseFormat,
    stream,
    mapDeepHashCode(metadata),
    promptCacheKey,
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
      'metadata: $metadata, '
      'promptCacheKey: $promptCacheKey, '
      'extra: ${extra != null ? '${extra!.length} entries' : null})';
}
