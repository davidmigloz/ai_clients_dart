import 'package:meta/meta.dart';

// =============================================================================
// NoiseReductionType
// =============================================================================

/// Noise reduction profile for the input audio buffer.
///
/// `near_field` is for close-talking microphones such as headphones;
/// `far_field` is for far-field microphones such as conference-room mics or
/// laptops.
///
/// Unknown values from `fromJson` throw `FormatException`, matching the
/// existing convention used by other realtime enums.
enum NoiseReductionType {
  /// Close-talking microphone profile.
  nearField._('near_field'),

  /// Far-field microphone profile.
  farField._('far_field');

  const NoiseReductionType._(this._value);

  /// Creates from JSON string. Throws `FormatException` for unknown values.
  factory NoiseReductionType.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown NoiseReductionType: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// AudioTranscriptionDelay
// =============================================================================

/// Transcription latency-vs-accuracy delay knob.
///
/// Higher values trade latency for accuracy. Only supported with
/// `gpt-realtime-whisper` in Realtime sessions.
///
/// Unknown values from `fromJson` throw `FormatException`, matching the
/// existing convention used by other realtime enums.
enum AudioTranscriptionDelay {
  /// Lowest latency, lowest accuracy.
  minimal._('minimal'),

  /// Low transcription delay.
  low._('low'),

  /// Medium transcription delay.
  medium._('medium'),

  /// High transcription delay.
  high._('high'),

  /// Highest latency, highest accuracy.
  xhigh._('xhigh');

  const AudioTranscriptionDelay._(this._value);

  /// Creates from JSON string. Throws `FormatException` for unknown values.
  factory AudioTranscriptionDelay.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () =>
          throw FormatException('Unknown AudioTranscriptionDelay: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// RealtimeToolChoice
// =============================================================================

/// Tool choice for realtime sessions.
///
/// Determines how the model selects which tool (if any) to use.
///
/// ## Example
///
/// ```dart
/// // Let the model decide
/// final choice = RealtimeToolChoice.auto();
///
/// // Disable tool use
/// final choice = RealtimeToolChoice.none();
///
/// // Require a specific function
/// final choice = RealtimeToolChoice.function('get_weather');
/// ```
sealed class RealtimeToolChoice {
  const RealtimeToolChoice();

  /// Auto - let the model decide.
  const factory RealtimeToolChoice.auto() = RealtimeToolChoiceAuto;

  /// None - disable tool use.
  const factory RealtimeToolChoice.none() = RealtimeToolChoiceNone;

  /// Required - force tool use.
  const factory RealtimeToolChoice.required() = RealtimeToolChoiceRequired;

  /// Function - require a specific function.
  const factory RealtimeToolChoice.function(String name) =
      RealtimeToolChoiceFunction;

  /// Creates from JSON.
  factory RealtimeToolChoice.fromJson(Object json) {
    if (json == 'auto') return const RealtimeToolChoiceAuto();
    if (json == 'none') return const RealtimeToolChoiceNone();
    if (json == 'required') return const RealtimeToolChoiceRequired();
    if (json is Map<String, dynamic>) {
      final type = json['type'] as String?;
      if (type == 'function') {
        final function = json['function'] as Map<String, dynamic>;
        return RealtimeToolChoiceFunction(function['name'] as String);
      }
    }
    throw FormatException('Invalid RealtimeToolChoice: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// Auto tool choice - let the model decide.
@immutable
class RealtimeToolChoiceAuto extends RealtimeToolChoice {
  /// Creates a [RealtimeToolChoiceAuto].
  const RealtimeToolChoiceAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeToolChoiceAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'RealtimeToolChoice.auto()';
}

/// None tool choice - disable tool use.
@immutable
class RealtimeToolChoiceNone extends RealtimeToolChoice {
  /// Creates a [RealtimeToolChoiceNone].
  const RealtimeToolChoiceNone();

  @override
  Object toJson() => 'none';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeToolChoiceNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'none'.hashCode;

  @override
  String toString() => 'RealtimeToolChoice.none()';
}

/// Required tool choice - force tool use.
@immutable
class RealtimeToolChoiceRequired extends RealtimeToolChoice {
  /// Creates a [RealtimeToolChoiceRequired].
  const RealtimeToolChoiceRequired();

  @override
  Object toJson() => 'required';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeToolChoiceRequired && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'required'.hashCode;

  @override
  String toString() => 'RealtimeToolChoice.required()';
}

/// Function tool choice - require a specific function.
@immutable
class RealtimeToolChoiceFunction extends RealtimeToolChoice {
  /// Creates a [RealtimeToolChoiceFunction].
  const RealtimeToolChoiceFunction(this.name);

  /// The function name to require.
  final String name;

  @override
  Object toJson() => {
    'type': 'function',
    'function': {'name': name},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeToolChoiceFunction &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RealtimeToolChoice.function($name)';
}
