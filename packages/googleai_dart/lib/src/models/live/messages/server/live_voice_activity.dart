import '../../../copy_with_sentinel.dart';

/// The kind of audio activity detected by the Live API.
extension type const LiveVoiceActivityType(String value) {
  /// The server did not specify an activity type.
  static const unspecified = LiveVoiceActivityType('TYPE_UNSPECIFIED');

  /// The server detected the start of speech.
  static const activityStart = LiveVoiceActivityType('ACTIVITY_START');

  /// The server detected the end of speech.
  static const activityEnd = LiveVoiceActivityType('ACTIVITY_END');
}

/// Server-detected voice activity associated with a Live frame.
class LiveVoiceActivity {
  /// The detected activity, when reported.
  final LiveVoiceActivityType? type;

  /// Protobuf duration from the start of the audio stream, such as `1.250s`.
  final String? audioOffset;

  /// Creates a voice activity signal.
  const LiveVoiceActivity({this.type, this.audioOffset});

  /// Parses a voice activity signal, retaining future type values.
  factory LiveVoiceActivity.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return LiveVoiceActivity(
      type: type == null ? null : LiveVoiceActivityType(type),
      audioOffset: json['audioOffset'] as String?,
    );
  }

  /// Converts to the Live wire shape.
  Map<String, dynamic> toJson() => {
    'type': ?type?.value,
    'audioOffset': ?audioOffset,
  };

  /// Copies this signal. Pass `null` to clear a field.
  LiveVoiceActivity copyWith({
    Object? type = unsetCopyWithValue,
    Object? audioOffset = unsetCopyWithValue,
  }) => LiveVoiceActivity(
    type: type == unsetCopyWithValue
        ? this.type
        : type as LiveVoiceActivityType?,
    audioOffset: audioOffset == unsetCopyWithValue
        ? this.audioOffset
        : audioOffset as String?,
  );

  @override
  String toString() =>
      'LiveVoiceActivity(type: $type, audioOffset: $audioOffset)';
}
