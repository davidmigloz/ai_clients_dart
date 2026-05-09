import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'realtime_audio_formats.dart';
import 'realtime_audio_input_turn_detection.dart';
import 'realtime_enums.dart';

// =============================================================================
// AudioInputNoiseReduction
// =============================================================================

/// Noise reduction configuration for the input audio buffer.
///
/// `null` (the field omitted) disables noise reduction.
@immutable
class AudioInputNoiseReduction {
  /// Creates an [AudioInputNoiseReduction].
  const AudioInputNoiseReduction({this.type});

  /// Creates from JSON.
  factory AudioInputNoiseReduction.fromJson(Map<String, dynamic> json) {
    return AudioInputNoiseReduction(
      type: json['type'] != null
          ? NoiseReductionType.fromJson(json['type'] as String)
          : null,
    );
  }

  /// The noise-reduction profile.
  final NoiseReductionType? type;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (type != null) 'type': type!.toJson()};

  /// Returns a copy of this [AudioInputNoiseReduction] with the given fields
  /// replaced. Pass `null` for [type] to clear the existing value.
  AudioInputNoiseReduction copyWith({Object? type = unsetCopyWithValue}) =>
      AudioInputNoiseReduction(
        type: identical(type, unsetCopyWithValue)
            ? this.type
            : type as NoiseReductionType?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioInputNoiseReduction &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'AudioInputNoiseReduction(type: $type)';
}

// =============================================================================
// InputAudioTranscription
// =============================================================================

/// Configuration for input audio transcription.
///
/// Transcription runs asynchronously through the Whisper or GPT-realtime
/// transcription pipeline and is treated as guidance about the input audio
/// content rather than precisely what the model heard.
@immutable
class InputAudioTranscription {
  /// Creates an [InputAudioTranscription].
  const InputAudioTranscription({
    this.delay,
    this.language,
    this.model,
    this.prompt,
  });

  /// Creates from JSON.
  factory InputAudioTranscription.fromJson(Map<String, dynamic> json) {
    return InputAudioTranscription(
      delay: json['delay'] != null
          ? AudioTranscriptionDelay.fromJson(json['delay'] as String)
          : null,
      language: json['language'] as String?,
      model: json['model'] as String?,
      prompt: json['prompt'] as String?,
    );
  }

  /// Optional delay knob.
  ///
  /// Higher values trade latency for accuracy. Only supported with
  /// `gpt-realtime-whisper` in Realtime sessions.
  final AudioTranscriptionDelay? delay;

  /// ISO-639-1 language hint, e.g. `'en'`.
  final String? language;

  /// Transcription model identifier (e.g. `'whisper-1'`,
  /// `'gpt-realtime-whisper'`).
  final String? model;

  /// Optional free-text prompt to guide the transcription.
  ///
  /// Not supported with `gpt-realtime-whisper`.
  final String? prompt;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (delay != null) 'delay': delay!.toJson(),
    if (language != null) 'language': language,
    if (model != null) 'model': model,
    if (prompt != null) 'prompt': prompt,
  };

  /// Returns a copy of this [InputAudioTranscription] with the given fields
  /// replaced. Pass `null` for any field to clear the existing value.
  InputAudioTranscription copyWith({
    Object? delay = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
  }) => InputAudioTranscription(
    delay: identical(delay, unsetCopyWithValue)
        ? this.delay
        : delay as AudioTranscriptionDelay?,
    language: identical(language, unsetCopyWithValue)
        ? this.language
        : language as String?,
    model: identical(model, unsetCopyWithValue) ? this.model : model as String?,
    prompt: identical(prompt, unsetCopyWithValue)
        ? this.prompt
        : prompt as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscription &&
          runtimeType == other.runtimeType &&
          delay == other.delay &&
          language == other.language &&
          model == other.model &&
          prompt == other.prompt;

  @override
  int get hashCode => Object.hash(delay, language, model, prompt);

  @override
  String toString() =>
      'InputAudioTranscription(delay: $delay, language: $language, '
      'model: $model, prompt: $prompt)';
}

// =============================================================================
// RealtimeAudioConfigInput
// =============================================================================

/// Input audio configuration for a Realtime session.
///
/// **Tri-state serialization for `noise_reduction`, `transcription`,
/// `turn_detection`** — these fields have three distinct meanings on
/// `session.update`:
///
/// - **Field omitted from the request** → server keeps the current value
///   (don't change). This is the default when the typed field is `null`.
/// - **Field present with value** → server sets/replaces the configuration.
/// - **Field present with explicit JSON `null`** → server *disables* the
///   feature (clears any prior configuration).
///
/// To send the third form (explicit JSON null), pass the matching
/// `clearNoiseReduction` / `clearTranscription` / `clearTurnDetection`
/// flag as `true`. The flags are ignored when the corresponding typed
/// field is also non-null (the value wins). Roundtrip preserves the
/// distinction: a wire payload with `"noise_reduction": null` parses
/// back as `clearNoiseReduction: true`.
@immutable
class RealtimeAudioConfigInput {
  /// Creates a [RealtimeAudioConfigInput].
  const RealtimeAudioConfigInput({
    this.format,
    this.noiseReduction,
    this.transcription,
    this.turnDetection,
    this.clearNoiseReduction = false,
    this.clearTranscription = false,
    this.clearTurnDetection = false,
  });

  /// Creates from JSON.
  factory RealtimeAudioConfigInput.fromJson(Map<String, dynamic> json) {
    return RealtimeAudioConfigInput(
      format: json['format'] != null
          ? RealtimeAudioFormats.fromJson(
              json['format'] as Map<String, dynamic>,
            )
          : null,
      noiseReduction: json['noise_reduction'] != null
          ? AudioInputNoiseReduction.fromJson(
              json['noise_reduction'] as Map<String, dynamic>,
            )
          : null,
      transcription: json['transcription'] != null
          ? InputAudioTranscription.fromJson(
              json['transcription'] as Map<String, dynamic>,
            )
          : null,
      turnDetection: json['turn_detection'] != null
          ? RealtimeAudioInputTurnDetection.fromJson(
              json['turn_detection'] as Map<String, dynamic>,
            )
          : null,
      clearNoiseReduction:
          json.containsKey('noise_reduction') &&
          json['noise_reduction'] == null,
      clearTranscription:
          json.containsKey('transcription') && json['transcription'] == null,
      clearTurnDetection:
          json.containsKey('turn_detection') && json['turn_detection'] == null,
    );
  }

  /// Input audio format.
  final RealtimeAudioFormats? format;

  /// Noise-reduction configuration.
  final AudioInputNoiseReduction? noiseReduction;

  /// Transcription configuration.
  final InputAudioTranscription? transcription;

  /// Turn-detection configuration.
  final RealtimeAudioInputTurnDetection? turnDetection;

  /// When `true`, emit `"noise_reduction": null` on the wire to ask the
  /// server to disable noise reduction (only relevant on
  /// `session.update`). Has no effect when [noiseReduction] is non-null.
  final bool clearNoiseReduction;

  /// When `true`, emit `"transcription": null` on the wire to ask the
  /// server to disable transcription. Has no effect when [transcription]
  /// is non-null.
  final bool clearTranscription;

  /// When `true`, emit `"turn_detection": null` on the wire to ask the
  /// server to disable turn detection. Has no effect when
  /// [turnDetection] is non-null.
  final bool clearTurnDetection;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (format != null) 'format': format!.toJson(),
    if (noiseReduction != null)
      'noise_reduction': noiseReduction!.toJson()
    else if (clearNoiseReduction)
      'noise_reduction': null,
    if (transcription != null)
      'transcription': transcription!.toJson()
    else if (clearTranscription)
      'transcription': null,
    if (turnDetection != null)
      'turn_detection': turnDetection!.toJson()
    else if (clearTurnDetection)
      'turn_detection': null,
  };

  /// Returns a copy of this [RealtimeAudioConfigInput] with the given fields
  /// replaced. Pass `null` for any nullable field to clear the in-memory
  /// value (use the `clear*` flags to send explicit JSON null over the
  /// wire).
  RealtimeAudioConfigInput copyWith({
    Object? format = unsetCopyWithValue,
    Object? noiseReduction = unsetCopyWithValue,
    Object? transcription = unsetCopyWithValue,
    Object? turnDetection = unsetCopyWithValue,
    bool? clearNoiseReduction,
    bool? clearTranscription,
    bool? clearTurnDetection,
  }) => RealtimeAudioConfigInput(
    format: identical(format, unsetCopyWithValue)
        ? this.format
        : format as RealtimeAudioFormats?,
    noiseReduction: identical(noiseReduction, unsetCopyWithValue)
        ? this.noiseReduction
        : noiseReduction as AudioInputNoiseReduction?,
    transcription: identical(transcription, unsetCopyWithValue)
        ? this.transcription
        : transcription as InputAudioTranscription?,
    turnDetection: identical(turnDetection, unsetCopyWithValue)
        ? this.turnDetection
        : turnDetection as RealtimeAudioInputTurnDetection?,
    clearNoiseReduction: clearNoiseReduction ?? this.clearNoiseReduction,
    clearTranscription: clearTranscription ?? this.clearTranscription,
    clearTurnDetection: clearTurnDetection ?? this.clearTurnDetection,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeAudioConfigInput &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          noiseReduction == other.noiseReduction &&
          transcription == other.transcription &&
          turnDetection == other.turnDetection &&
          clearNoiseReduction == other.clearNoiseReduction &&
          clearTranscription == other.clearTranscription &&
          clearTurnDetection == other.clearTurnDetection;

  @override
  int get hashCode => Object.hash(
    format,
    noiseReduction,
    transcription,
    turnDetection,
    clearNoiseReduction,
    clearTranscription,
    clearTurnDetection,
  );

  @override
  String toString() =>
      'RealtimeAudioConfigInput(format: $format, noiseReduction: $noiseReduction, '
      'transcription: $transcription, turnDetection: $turnDetection, '
      'clearNoiseReduction: $clearNoiseReduction, '
      'clearTranscription: $clearTranscription, '
      'clearTurnDetection: $clearTurnDetection)';
}

// =============================================================================
// RealtimeAudioConfigOutput
// =============================================================================

/// Output audio configuration for a Realtime session.
@immutable
class RealtimeAudioConfigOutput {
  /// Creates a [RealtimeAudioConfigOutput].
  const RealtimeAudioConfigOutput({this.format, this.voice, this.speed});

  /// Creates from JSON.
  factory RealtimeAudioConfigOutput.fromJson(Map<String, dynamic> json) {
    return RealtimeAudioConfigOutput(
      format: json['format'] != null
          ? RealtimeAudioFormats.fromJson(
              json['format'] as Map<String, dynamic>,
            )
          : null,
      voice: json['voice'] as String?,
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  /// Output audio format.
  final RealtimeAudioFormats? format;

  /// Voice identifier or custom voice name (e.g. `'alloy'`, `'cedar'`).
  ///
  /// Modeled as an open `String` to match the spec's `VoiceIdsOrCustomVoice`
  /// union (built-in voices + custom strings).
  final String? voice;

  /// Speech speed multiplier (0.25–1.5; default `1.0`).
  final double? speed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (format != null) 'format': format!.toJson(),
    if (voice != null) 'voice': voice,
    if (speed != null) 'speed': speed,
  };

  /// Returns a copy of this [RealtimeAudioConfigOutput] with the given fields
  /// replaced. Pass `null` for any field to clear the existing value.
  RealtimeAudioConfigOutput copyWith({
    Object? format = unsetCopyWithValue,
    Object? voice = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
  }) => RealtimeAudioConfigOutput(
    format: identical(format, unsetCopyWithValue)
        ? this.format
        : format as RealtimeAudioFormats?,
    voice: identical(voice, unsetCopyWithValue) ? this.voice : voice as String?,
    speed: identical(speed, unsetCopyWithValue) ? this.speed : speed as double?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeAudioConfigOutput &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          voice == other.voice &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(format, voice, speed);

  @override
  String toString() =>
      'RealtimeAudioConfigOutput(format: $format, voice: $voice, speed: $speed)';
}

// =============================================================================
// RealtimeAudioConfig
// =============================================================================

/// Audio configuration for a Realtime session.
///
/// Groups input audio settings (`format`, `transcription`, `turn_detection`,
/// `noise_reduction`) and output audio settings (`format`, `voice`, `speed`)
/// under a single nested object on the session payload.
@immutable
class RealtimeAudioConfig {
  /// Creates a [RealtimeAudioConfig].
  const RealtimeAudioConfig({this.input, this.output});

  /// Creates from JSON.
  factory RealtimeAudioConfig.fromJson(Map<String, dynamic> json) {
    return RealtimeAudioConfig(
      input: json['input'] != null
          ? RealtimeAudioConfigInput.fromJson(
              json['input'] as Map<String, dynamic>,
            )
          : null,
      output: json['output'] != null
          ? RealtimeAudioConfigOutput.fromJson(
              json['output'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Input audio configuration.
  final RealtimeAudioConfigInput? input;

  /// Output audio configuration.
  final RealtimeAudioConfigOutput? output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input!.toJson(),
    if (output != null) 'output': output!.toJson(),
  };

  /// Returns a copy of this [RealtimeAudioConfig] with the given fields
  /// replaced. Pass `null` for any field to clear the existing value.
  RealtimeAudioConfig copyWith({
    Object? input = unsetCopyWithValue,
    Object? output = unsetCopyWithValue,
  }) => RealtimeAudioConfig(
    input: identical(input, unsetCopyWithValue)
        ? this.input
        : input as RealtimeAudioConfigInput?,
    output: identical(output, unsetCopyWithValue)
        ? this.output
        : output as RealtimeAudioConfigOutput?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeAudioConfig &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output;

  @override
  int get hashCode => Object.hash(input, output);

  @override
  String toString() => 'RealtimeAudioConfig(input: $input, output: $output)';
}
