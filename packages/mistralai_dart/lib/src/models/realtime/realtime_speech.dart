import 'package:meta/meta.dart';

import '../audio/ipa_phoneme.dart';
import '../audio/speech_output_format.dart';

/// How Voxtral realtime speech balances latency and prosody.
enum RealtimeSpeechMode {
  /// Start speaking quickly for interactive requests.
  responsive('responsive'),

  /// Buffer more text for longer, flowing speech.
  longForm('long_form'),

  /// An unrecognized mode.
  unknown('unknown');

  const RealtimeSpeechMode(this.value);

  /// The streaming mode on the wire.
  final String value;

  /// Decodes a streaming mode.
  static RealtimeSpeechMode? fromJson(String? value) => value == null
      ? null
      : values.firstWhere((mode) => mode.value == value, orElse: () => unknown);
}

Map<String, List<String>>? _encodeHints(Map<String, List<IpaPhoneme>>? hints) =>
    hints?.map(
      (term, values) =>
          MapEntry(term, values.map((value) => value.value).toList()),
    );

/// Fields that can be set in a realtime speech session.
@immutable
final class RealtimeSpeechOptions {
  /// Creates a partial session update.
  const RealtimeSpeechOptions({
    this.voiceId,
    this.refAudio,
    this.responseFormat,
    this.streamingMode,
    this.expressiveness,
    this.phonemeHints,
  });

  /// The voice ID to use. Mutually exclusive with [refAudio].
  final String? voiceId;

  /// Base64 reference audio, for a cloned voice.
  final String? refAudio;

  /// Output encoding. PCM means float32 little-endian mono.
  final SpeechOutputFormat? responseFormat;

  /// Whether to optimize for responsive or long-form speech.
  final RealtimeSpeechMode? streamingMode;

  /// Degree of expressiveness, with a minimum of 1.0.
  final double? expressiveness;

  /// Pronunciation overrides.
  final Map<String, List<IpaPhoneme>>? phonemeHints;

  /// Encodes the values to update. Omitted values keep their current settings.
  Map<String, dynamic> toJson() => {
    'voice': ?voiceId,
    'ref_audio': ?refAudio,
    'response_format': ?responseFormat?.value,
    'streaming_mode': ?streamingMode?.value,
    'expressiveness': ?expressiveness,
    'phoneme_hints': ?_encodeHints(phonemeHints),
  };
}

/// The speech session state returned by the server.
@immutable
final class RealtimeSpeechSession {
  /// Creates a speech session state.
  const RealtimeSpeechSession({
    required this.model,
    this.requestId,
    this.voiceId,
    this.isRefAudio,
    this.responseFormat,
    this.streamingMode,
    this.expressiveness,
    this.phonemeHints,
  });

  /// Current model.
  final String model;

  /// Request identifier, if the server supplied one.
  final String? requestId;

  /// Current voice ID.
  final String? voiceId;

  /// Whether reference audio supplies the voice.
  final bool? isRefAudio;

  /// Current output encoding.
  final SpeechOutputFormat? responseFormat;

  /// Current streaming mode.
  final RealtimeSpeechMode? streamingMode;

  /// Current expressiveness setting.
  final double? expressiveness;

  /// Current pronunciation overrides.
  final Map<String, List<IpaPhoneme>>? phonemeHints;

  /// Decodes the session state.
  factory RealtimeSpeechSession.fromJson(Map<String, dynamic> json) =>
      RealtimeSpeechSession(
        model: json['model'] as String,
        requestId: json['request_id'] as String?,
        voiceId: json['voice'] as String?,
        isRefAudio: json['is_ref_audio'] as bool?,
        responseFormat: SpeechOutputFormat.fromString(
          json['response_format'] as String?,
        ),
        streamingMode: RealtimeSpeechMode.fromJson(
          json['streaming_mode'] as String?,
        ),
        expressiveness: (json['expressiveness'] as num?)?.toDouble(),
        phonemeHints: (json['phoneme_hints'] as Map<String, dynamic>?)?.map(
          (term, values) => MapEntry(
            term,
            (values as List).cast<String>().map(IpaPhoneme.fromJson).toList(),
          ),
        ),
      );

  /// Encodes the session state.
  Map<String, dynamic> toJson() => {
    'model': model,
    'request_id': ?requestId,
    'voice': ?voiceId,
    'is_ref_audio': ?isRefAudio,
    'response_format': ?responseFormat?.value,
    'streaming_mode': ?streamingMode?.value,
    'expressiveness': ?expressiveness,
    'phoneme_hints': ?_encodeHints(phonemeHints),
  };
}
