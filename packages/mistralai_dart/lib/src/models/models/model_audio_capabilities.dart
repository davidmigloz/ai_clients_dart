import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Supported minimum and maximum streaming delay, in milliseconds.
@immutable
class StreamingDelayRange {
  /// Minimum streaming delay.
  final int min;

  /// Maximum streaming delay.
  final int max;

  /// Creates a [StreamingDelayRange].
  const StreamingDelayRange({required this.min, required this.max});

  /// Creates a [StreamingDelayRange] from JSON.
  factory StreamingDelayRange.fromJson(Map<String, dynamic> json) {
    final min = json['min'] as int?;
    final max = json['max'] as int?;
    if (min == null) {
      throw const FormatException(
        'StreamingDelayRange: missing required "min"',
      );
    }
    if (max == null) {
      throw const FormatException(
        'StreamingDelayRange: missing required "max"',
      );
    }
    return StreamingDelayRange(min: min, max: max);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'min': min, 'max': max};

  /// Creates a copy with replaced values.
  StreamingDelayRange copyWith({int? min, int? max}) =>
      StreamingDelayRange(min: min ?? this.min, max: max ?? this.max);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamingDelayRange && min == other.min && max == other.max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'StreamingDelayRange(min: $min, max: $max)';
}

/// Speech recognition features available on a model.
@immutable
class AudioTranscriptionCapabilities {
  /// Supported transcription modes.
  final List<String>? modes;

  /// Whether speaker diarization is supported.
  final bool? diarization;

  /// Whether the model supports context biasing.
  final bool? contextBias;

  /// Whether turn detection is available.
  final bool? turnDetection;

  /// Supported types of timestamps.
  final List<String>? timestampGranularities;

  /// Supported language identifiers.
  final List<String>? languages;

  /// Supported real-time delay ranges.
  final List<StreamingDelayRange>? streamingDelaysMs;

  /// Creates a [AudioTranscriptionCapabilities].
  const AudioTranscriptionCapabilities({
    this.modes,
    this.diarization,
    this.contextBias,
    this.turnDetection,
    this.timestampGranularities,
    this.languages,
    this.streamingDelaysMs,
  });

  /// Creates a [AudioTranscriptionCapabilities] from JSON.
  factory AudioTranscriptionCapabilities.fromJson(Map<String, dynamic> json) {
    return AudioTranscriptionCapabilities(
      modes: (json['modes'] as List<dynamic>?)?.cast<String>(),
      diarization: json['diarization'] as bool?,
      contextBias: json['context_bias'] as bool?,
      turnDetection: json['turn_detection'] as bool?,
      timestampGranularities:
          (json['timestamp_granularities'] as List<dynamic>?)?.cast<String>(),
      languages: (json['languages'] as List<dynamic>?)?.cast<String>(),
      streamingDelaysMs: (json['streaming_delays_ms'] as List<dynamic>?)
          ?.map((e) => StreamingDelayRange.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modes != null) 'modes': modes,
    if (diarization != null) 'diarization': diarization,
    if (contextBias != null) 'context_bias': contextBias,
    if (turnDetection != null) 'turn_detection': turnDetection,
    if (timestampGranularities != null)
      'timestamp_granularities': timestampGranularities,
    if (languages != null) 'languages': languages,
    if (streamingDelaysMs != null)
      'streaming_delays_ms': streamingDelaysMs!
          .map((element) => element.toJson())
          .toList(),
  };

  /// Creates a copy with replaced values.
  AudioTranscriptionCapabilities copyWith({
    Object? modes = unsetCopyWithValue,
    Object? diarization = unsetCopyWithValue,
    Object? contextBias = unsetCopyWithValue,
    Object? turnDetection = unsetCopyWithValue,
    Object? timestampGranularities = unsetCopyWithValue,
    Object? languages = unsetCopyWithValue,
    Object? streamingDelaysMs = unsetCopyWithValue,
  }) => AudioTranscriptionCapabilities(
    modes: modes == unsetCopyWithValue
        ? this.modes
        : modes == null
        ? null
        : List<String>.from(modes as Iterable<Object?>),
    diarization: diarization == unsetCopyWithValue
        ? this.diarization
        : diarization as bool?,
    contextBias: contextBias == unsetCopyWithValue
        ? this.contextBias
        : contextBias as bool?,
    turnDetection: turnDetection == unsetCopyWithValue
        ? this.turnDetection
        : turnDetection as bool?,
    timestampGranularities: timestampGranularities == unsetCopyWithValue
        ? this.timestampGranularities
        : timestampGranularities == null
        ? null
        : List<String>.from(timestampGranularities as Iterable<Object?>),
    languages: languages == unsetCopyWithValue
        ? this.languages
        : languages == null
        ? null
        : List<String>.from(languages as Iterable<Object?>),
    streamingDelaysMs: streamingDelaysMs == unsetCopyWithValue
        ? this.streamingDelaysMs
        : streamingDelaysMs == null
        ? null
        : List<StreamingDelayRange>.from(
            streamingDelaysMs as Iterable<Object?>,
          ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTranscriptionCapabilities &&
          listsEqual(modes, other.modes) &&
          diarization == other.diarization &&
          contextBias == other.contextBias &&
          turnDetection == other.turnDetection &&
          listsEqual(timestampGranularities, other.timestampGranularities) &&
          listsEqual(languages, other.languages) &&
          listsEqual(streamingDelaysMs, other.streamingDelaysMs);

  @override
  int get hashCode => Object.hash(
    listHash(modes),
    diarization,
    contextBias,
    turnDetection,
    listHash(timestampGranularities),
    listHash(languages),
    listHash(streamingDelaysMs),
  );

  @override
  String toString() =>
      'AudioTranscriptionCapabilities(modes: $modes, diarization: $diarization, contextBias: $contextBias, turnDetection: $turnDetection, timestampGranularities: $timestampGranularities, languages: $languages, streamingDelaysMs: $streamingDelaysMs)';
}

/// Speech synthesis features available on a model.
@immutable
class AudioSpeechCapabilities {
  /// Supported speech generation modes.
  final List<String>? modes;

  /// Whether the model accepts speech instructions.
  final bool? instruction;

  /// Supported output formats for synthesized audio.
  final List<String>? responseFormats;

  /// Creates a [AudioSpeechCapabilities].
  const AudioSpeechCapabilities({
    this.modes,
    this.instruction,
    this.responseFormats,
  });

  /// Creates a [AudioSpeechCapabilities] from JSON.
  factory AudioSpeechCapabilities.fromJson(Map<String, dynamic> json) {
    return AudioSpeechCapabilities(
      modes: (json['modes'] as List<dynamic>?)?.cast<String>(),
      instruction: json['instruction'] as bool?,
      responseFormats: (json['response_formats'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modes != null) 'modes': modes,
    if (instruction != null) 'instruction': instruction,
    if (responseFormats != null) 'response_formats': responseFormats,
  };

  /// Creates a copy with replaced values.
  AudioSpeechCapabilities copyWith({
    Object? modes = unsetCopyWithValue,
    Object? instruction = unsetCopyWithValue,
    Object? responseFormats = unsetCopyWithValue,
  }) => AudioSpeechCapabilities(
    modes: modes == unsetCopyWithValue
        ? this.modes
        : modes == null
        ? null
        : List<String>.from(modes as Iterable<Object?>),
    instruction: instruction == unsetCopyWithValue
        ? this.instruction
        : instruction as bool?,
    responseFormats: responseFormats == unsetCopyWithValue
        ? this.responseFormats
        : responseFormats == null
        ? null
        : List<String>.from(responseFormats as Iterable<Object?>),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSpeechCapabilities &&
          listsEqual(modes, other.modes) &&
          instruction == other.instruction &&
          listsEqual(responseFormats, other.responseFormats);

  @override
  int get hashCode =>
      Object.hash(listHash(modes), instruction, listHash(responseFormats));

  @override
  String toString() =>
      'AudioSpeechCapabilities(modes: $modes, instruction: $instruction, responseFormats: $responseFormats)';
}
