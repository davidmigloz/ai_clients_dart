import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../metadata/usage_info.dart';

/// A streaming event from the speech synthesis API.
///
/// Subtypes:
/// - [SpeechStreamAudioDelta] — contains a chunk of audio data
/// - [SpeechStreamDone] — signals completion with usage information
/// - [UnknownSpeechStreamEvent] — fallback for unrecognized event types
sealed class SpeechStreamEvent {
  const SpeechStreamEvent();

  /// Creates a [SpeechStreamEvent] from JSON.
  ///
  /// Dispatches to the appropriate subtype based on the `type` field.
  factory SpeechStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'speech.audio.delta' => SpeechStreamAudioDelta.fromJson(json),
      'speech.audio.done' => SpeechStreamDone.fromJson(json),
      _ => UnknownSpeechStreamEvent.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A chunk of audio data from the speech stream.
@immutable
class SpeechStreamAudioDelta extends SpeechStreamEvent {
  /// The event type.
  final String type;

  /// Base64-encoded audio data chunk.
  final String audioData;

  /// Creates a [SpeechStreamAudioDelta].
  const SpeechStreamAudioDelta({
    this.type = 'speech.audio.delta',
    required this.audioData,
  });

  /// Creates a [SpeechStreamAudioDelta] from JSON.
  factory SpeechStreamAudioDelta.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'speech.audio.delta') {
      throw FormatException('Expected type "speech.audio.delta", got "$type"');
    }
    return SpeechStreamAudioDelta(
      type: type!,
      audioData: json['audio_data'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'audio_data': audioData};

  /// Creates a copy with replaced values.
  SpeechStreamAudioDelta copyWith({String? type, String? audioData}) =>
      SpeechStreamAudioDelta(
        type: type ?? this.type,
        audioData: audioData ?? this.audioData,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechStreamAudioDelta &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          audioData == other.audioData;

  @override
  int get hashCode => Object.hash(type, audioData);

  @override
  String toString() =>
      'SpeechStreamAudioDelta(type: $type, '
      'audioData: ${audioData.length} chars)';
}

/// Signals that the speech stream is complete.
@immutable
class SpeechStreamDone extends SpeechStreamEvent {
  /// The event type.
  final String type;

  /// Token usage information.
  final UsageInfo usage;

  /// Creates a [SpeechStreamDone].
  const SpeechStreamDone({
    this.type = 'speech.audio.done',
    required this.usage,
  });

  /// Creates a [SpeechStreamDone] from JSON.
  factory SpeechStreamDone.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'speech.audio.done') {
      throw FormatException('Expected type "speech.audio.done", got "$type"');
    }
    return SpeechStreamDone(
      type: type!,
      usage: UsageInfo.fromJson(
        json['usage'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'usage': usage.toJson()};

  /// Creates a copy with replaced values.
  SpeechStreamDone copyWith({String? type, UsageInfo? usage}) =>
      SpeechStreamDone(type: type ?? this.type, usage: usage ?? this.usage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechStreamDone &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(type, usage);

  @override
  String toString() => 'SpeechStreamDone(type: $type, usage: $usage)';
}

/// Fallback for unrecognized speech stream event types.
///
/// Wraps the raw JSON map when the event type is not recognized.
@immutable
class UnknownSpeechStreamEvent extends SpeechStreamEvent {
  final Map<String, dynamic> _raw;

  /// Creates an [UnknownSpeechStreamEvent].
  UnknownSpeechStreamEvent(Map<String, dynamic> raw)
    : _raw = Map<String, dynamic>.unmodifiable(raw);

  /// The raw JSON data.
  Map<String, dynamic> get raw => _raw;

  /// Creates an [UnknownSpeechStreamEvent] from JSON.
  factory UnknownSpeechStreamEvent.fromJson(Map<String, dynamic> json) =>
      UnknownSpeechStreamEvent(json);

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSpeechStreamEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() => 'UnknownSpeechStreamEvent(raw: $_raw)';
}
