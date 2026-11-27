import 'package:meta/meta.dart';

/// Input audio encoding used by realtime transcription.
enum RealtimeAudioEncoding {
  /// Signed 16-bit little-endian PCM.
  pcmS16le('pcm_s16le'),

  /// Signed 32-bit little-endian PCM.
  pcmS32le('pcm_s32le'),

  /// 16-bit little-endian floating-point PCM.
  pcmF16le('pcm_f16le'),

  /// 32-bit little-endian floating-point PCM.
  pcmF32le('pcm_f32le'),

  /// PCM with μ-law companding.
  pcmMulaw('pcm_mulaw'),

  /// PCM with A-law companding.
  pcmAlaw('pcm_alaw'),

  /// An unrecognized encoding.
  unknown('unknown');

  const RealtimeAudioEncoding(this.value);

  /// The format name on the wire.
  final String value;

  /// Decodes a wire format.
  static RealtimeAudioEncoding fromJson(String value) => values.firstWhere(
    (encoding) => encoding.value == value,
    orElse: () => unknown,
  );
}

/// Describes the encoding and sample rate of incoming mono audio.
@immutable
final class RealtimeAudioFormat {
  /// Creates a format descriptor.
  const RealtimeAudioFormat({required this.encoding, required this.sampleRate});

  /// Format encoding.
  final RealtimeAudioEncoding encoding;

  /// Audio samples per second.
  final int sampleRate;

  /// Decodes the format from a session payload.
  factory RealtimeAudioFormat.fromJson(Map<String, dynamic> json) =>
      RealtimeAudioFormat(
        encoding: RealtimeAudioEncoding.fromJson(json['encoding'] as String),
        sampleRate: json['sample_rate'] as int,
      );

  /// Encodes the format for a session update.
  Map<String, dynamic> toJson() => {
    'encoding': encoding.value,
    'sample_rate': sampleRate,
  };
}

/// Semantic turn detection settings for Voxtral realtime transcription.
@immutable
final class RealtimeTurnDetection {
  /// Creates a turn detection configuration.
  const RealtimeTurnDetection({
    this.startThreshold,
    this.eagerEndThreshold,
    this.endThreshold,
    this.minSilenceMs,
    this.endTimeoutMs,
  });

  /// Probability threshold for starting a turn.
  final double? startThreshold;

  /// Probability threshold for a provisional end.
  final double? eagerEndThreshold;

  /// Probability threshold for a final end.
  final double? endThreshold;

  /// Minimum pause before signalling an end, in milliseconds.
  final int? minSilenceMs;

  /// Maximum pause before signalling an end, in milliseconds.
  final int? endTimeoutMs;

  /// Decodes session settings.
  factory RealtimeTurnDetection.fromJson(Map<String, dynamic> json) =>
      RealtimeTurnDetection(
        startThreshold: (json['start_threshold'] as num?)?.toDouble(),
        eagerEndThreshold: (json['eager_end_threshold'] as num?)?.toDouble(),
        endThreshold: (json['end_threshold'] as num?)?.toDouble(),
        minSilenceMs: json['min_silence_ms'] as int?,
        endTimeoutMs: json['end_timeout_ms'] as int?,
      );

  /// Encodes the settings for the server.
  Map<String, dynamic> toJson() => {
    'start_threshold': ?startThreshold,
    'eager_end_threshold': ?eagerEndThreshold,
    'end_threshold': ?endThreshold,
    'min_silence_ms': ?minSilenceMs,
    'end_timeout_ms': ?endTimeoutMs,
  };
}

/// Fields to set in a realtime transcription session.
///
/// Configure the session before sending audio. Speaker references require
/// diarization. Voxtral 3 can use either diarization or turn detection.
@immutable
final class RealtimeTranscriptionOptions {
  /// Creates a partial session update.
  const RealtimeTranscriptionOptions({
    this.audioFormat,
    this.targetStreamingDelayMs,
    this.diarize,
    this.contextBias,
    this.language,
    this.speakerReferences,
    this.turnDetection,
  });

  /// Encoding and sample rate of the audio that will be sent.
  final RealtimeAudioFormat? audioFormat;

  /// Target audio-to-transcript delay in milliseconds.
  final int? targetStreamingDelayMs;

  /// Whether to label speakers.
  final bool? diarize;

  /// Replacement list of names and terms to bias the transcription toward.
  ///
  /// On models that allow live context updates, changes apply after the next
  /// flush. Supply an empty list to clear the context.
  final List<String>? contextBias;

  /// ISO 639-1 language code for the input audio.
  final String? language;

  /// Speaker names mapped to their base64 reference clips.
  final Map<String, String>? speakerReferences;

  /// Configuration for turn boundary events.
  final RealtimeTurnDetection? turnDetection;

  /// Encodes the values to update. Omitted values keep their current settings.
  Map<String, dynamic> toJson() => {
    'audio_format': ?audioFormat?.toJson(),
    'target_streaming_delay_ms': ?targetStreamingDelayMs,
    'diarize': ?diarize,
    'context_bias': ?contextBias,
    'language': ?language,
    'speaker_references': ?speakerReferences,
    'turn_detection': ?turnDetection?.toJson(),
  };
}

/// The transcription session state returned by the server.
@immutable
final class RealtimeTranscriptionSession {
  /// Creates a session state object.
  const RealtimeTranscriptionSession({
    required this.model,
    required this.audioFormat,
    this.requestId,
    this.targetStreamingDelayMs,
    this.diarize,
    this.contextBias,
    this.language,
    this.speakerReferences,
    this.turnDetection,
  });

  /// Current model.
  final String model;

  /// Input audio format.
  final RealtimeAudioFormat audioFormat;

  /// Request identifier, if the server supplied one.
  final String? requestId;

  /// Current target delay in milliseconds.
  final int? targetStreamingDelayMs;

  /// Whether speaker labels are enabled.
  final bool? diarize;

  /// Current vocabulary hints.
  final List<String>? contextBias;

  /// Requested session language.
  final String? language;

  /// Named reference speakers. The server returns names without audio.
  final List<String>? speakerReferences;

  /// Current turn detection settings.
  final RealtimeTurnDetection? turnDetection;

  /// Decodes the session state.
  factory RealtimeTranscriptionSession.fromJson(Map<String, dynamic> json) =>
      RealtimeTranscriptionSession(
        model: json['model'] as String,
        audioFormat: RealtimeAudioFormat.fromJson(
          json['audio_format'] as Map<String, dynamic>,
        ),
        requestId: json['request_id'] as String?,
        targetStreamingDelayMs: json['target_streaming_delay_ms'] as int?,
        diarize: json['diarize'] as bool?,
        contextBias: (json['context_bias'] as List?)?.cast<String>(),
        language: json['language'] as String?,
        speakerReferences: (json['speaker_references'] as List?)
            ?.cast<String>(),
        turnDetection: switch (json['turn_detection']) {
          final Map<String, dynamic> settings => RealtimeTurnDetection.fromJson(
            settings,
          ),
          _ => null,
        },
      );

  /// Encodes the session state.
  Map<String, dynamic> toJson() => {
    'model': model,
    'audio_format': audioFormat.toJson(),
    'request_id': ?requestId,
    'target_streaming_delay_ms': ?targetStreamingDelayMs,
    'diarize': ?diarize,
    'context_bias': ?contextBias,
    'language': ?language,
    'speaker_references': ?speakerReferences,
    'turn_detection': ?turnDetection?.toJson(),
  };
}
