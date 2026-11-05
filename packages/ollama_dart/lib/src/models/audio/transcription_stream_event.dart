import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Server-sent transcript events shared by transcriptions and translations.
@immutable
sealed class TranscriptionStreamEvent {
  /// Creates a transcript event.
  const TranscriptionStreamEvent();

  /// API event type.
  String get type;

  /// Parses an event, preserving unknown future event types.
  factory TranscriptionStreamEvent.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'transcript.text.delta' => TranscriptTextDelta.fromJson(json),
        'transcript.text.done' => TranscriptTextDone.fromJson(json),
        _ => UnknownTranscriptionEvent(json: json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Transcript for a completed audio clip, including any joining space.
final class TranscriptTextDelta extends TranscriptionStreamEvent {
  /// The newly transcribed text.
  final String delta;

  /// Creates a delta event.
  const TranscriptTextDelta({required this.delta});

  @override
  String get type => 'transcript.text.delta';

  /// Parses a delta event.
  factory TranscriptTextDelta.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.delta') {
      throw const FormatException('Expected transcript.text.delta');
    }
    final delta = json['delta'];
    if (delta is! String) {
      throw const FormatException('TranscriptTextDelta.delta must be a string');
    }
    return TranscriptTextDelta(delta: delta);
  }

  /// Creates a copy.
  TranscriptTextDelta copyWith({String? delta}) =>
      TranscriptTextDelta(delta: delta ?? this.delta);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'delta': delta};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDelta && delta == other.delta;

  @override
  int get hashCode => Object.hash(type, delta);

  @override
  String toString() => 'TranscriptTextDelta(type: $type, delta: $delta)';
}

/// Complete transcript, emitted after all audio clips have finished.
final class TranscriptTextDone extends TranscriptionStreamEvent {
  /// Complete transcript.
  final String text;

  /// Creates a done event.
  const TranscriptTextDone({required this.text});

  @override
  String get type => 'transcript.text.done';

  /// Parses a done event.
  factory TranscriptTextDone.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.done') {
      throw const FormatException('Expected transcript.text.done');
    }
    final text = json['text'];
    if (text is! String) {
      throw const FormatException('TranscriptTextDone.text must be a string');
    }
    return TranscriptTextDone(text: text);
  }

  /// Creates a copy.
  TranscriptTextDone copyWith({String? text}) =>
      TranscriptTextDone(text: text ?? this.text);

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDone && text == other.text;

  @override
  int get hashCode => Object.hash(type, text);

  @override
  String toString() => 'TranscriptTextDone(type: $type, text: $text)';
}

/// An unrecognized transcript event, preserved for forward compatibility.
final class UnknownTranscriptionEvent extends TranscriptionStreamEvent {
  /// Original JSON. Nested JSON values must not be mutated.
  final Map<String, dynamic> json;

  /// Creates an unknown event.
  UnknownTranscriptionEvent({required Map<String, dynamic> json})
    : json = Map.unmodifiable(json);

  @override
  String get type => json['type'] as String? ?? '';

  /// Creates a copy.
  UnknownTranscriptionEvent copyWith({Map<String, dynamic>? json}) =>
      UnknownTranscriptionEvent(json: json ?? this.json);

  @override
  Map<String, dynamic> toJson() => {...json};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownTranscriptionEvent && mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() =>
      'UnknownTranscriptionEvent(type: $type, json: ${json.length} entries)';
}
