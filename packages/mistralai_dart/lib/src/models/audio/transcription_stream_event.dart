import 'package:meta/meta.dart';

import 'transcription_segment.dart';
import 'transcription_word.dart';

/// A streaming event during audio transcription.
@immutable
class TranscriptionStreamEvent {
  /// Event type.
  final String type;

  /// Unique identifier for the transcription.
  final String? id;

  /// The transcribed text delta.
  final String? text;

  /// Segment information for this event.
  final TranscriptionSegment? segment;

  /// Word information for this event.
  final TranscriptionWord? word;

  /// Whether this is the final event.
  final bool? isFinal;

  /// Creates a [TranscriptionStreamEvent].
  const TranscriptionStreamEvent({
    required this.type,
    this.id,
    this.text,
    this.segment,
    this.word,
    this.isFinal,
  });

  /// Creates a [TranscriptionStreamEvent] from JSON.
  factory TranscriptionStreamEvent.fromJson(Map<String, dynamic> json) =>
      TranscriptionStreamEvent(
        type: json['type'] as String? ?? 'text',
        id: json['id'] as String?,
        text: json['text'] as String?,
        segment: json['segment'] != null
            ? TranscriptionSegment.fromJson(
                json['segment'] as Map<String, dynamic>,
              )
            : null,
        word: json['word'] != null
            ? TranscriptionWord.fromJson(json['word'] as Map<String, dynamic>)
            : null,
        isFinal: json['is_final'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (text != null) 'text': text,
    if (segment != null) 'segment': segment!.toJson(),
    if (word != null) 'word': word!.toJson(),
    if (isFinal != null) 'is_final': isFinal,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionStreamEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          text == other.text;

  @override
  int get hashCode => Object.hash(type, text);

  @override
  String toString() => 'TranscriptionStreamEvent(type: $type, text: $text)';
}
