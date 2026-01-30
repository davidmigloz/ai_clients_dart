import 'package:meta/meta.dart';

// =============================================================================
// RealtimeVoice
// =============================================================================

/// Voice options for realtime audio output.
///
/// These are the available voices for generating audio responses
/// in realtime sessions.
enum RealtimeVoice {
  /// Alloy voice.
  alloy._('alloy'),

  /// Ash voice.
  ash._('ash'),

  /// Ballad voice.
  ballad._('ballad'),

  /// Coral voice.
  coral._('coral'),

  /// Echo voice.
  echo._('echo'),

  /// Sage voice.
  sage._('sage'),

  /// Shimmer voice.
  shimmer._('shimmer'),

  /// Verse voice.
  verse._('verse');

  const RealtimeVoice._(this._value);

  /// Creates from JSON string.
  factory RealtimeVoice.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown RealtimeVoice: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// RealtimeAudioFormat
// =============================================================================

/// Audio format for realtime sessions.
///
/// Specifies the encoding format for audio input and output.
enum RealtimeAudioFormat {
  /// 16-bit PCM audio.
  pcm16._('pcm16'),

  /// G.711 μ-law audio.
  g711Ulaw._('g711_ulaw'),

  /// G.711 A-law audio.
  g711Alaw._('g711_alaw');

  const RealtimeAudioFormat._(this._value);

  /// Creates from JSON string.
  factory RealtimeAudioFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown RealtimeAudioFormat: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// TurnDetectionType
// =============================================================================

/// Turn detection type for realtime sessions.
///
/// Determines how the server detects when the user has finished speaking.
enum TurnDetectionType {
  /// Server-side voice activity detection.
  serverVad._('server_vad'),

  /// No automatic turn detection.
  none._('none');

  const TurnDetectionType._(this._value);

  /// Creates from JSON string.
  factory TurnDetectionType.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown TurnDetectionType: $json'),
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
