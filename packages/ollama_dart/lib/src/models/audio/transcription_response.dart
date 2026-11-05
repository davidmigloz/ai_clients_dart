import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// One transcribed clip in an Ollama verbose speech-to-text response.
///
/// These are clip-level boundaries, rather than word-level timestamps.
@immutable
class TranscriptionSegment {
  /// Zero-based clip index.
  final int id;

  /// Clip start in seconds.
  final double start;

  /// Clip end in seconds.
  final double end;

  /// Clip transcript.
  final String text;

  /// Creates a segment.
  const TranscriptionSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
  });

  /// Creates a segment from JSON.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) =>
      TranscriptionSegment(
        id: switch (json['id']) {
          final int value => value,
          _ => throw const FormatException(
            'TranscriptionSegment.id must be an integer',
          ),
        },
        start: _requiredAudioNumber(
          json['start'],
          'TranscriptionSegment.start',
        ),
        end: _requiredAudioNumber(json['end'], 'TranscriptionSegment.end'),
        text: _requiredAudioString(json['text'], 'TranscriptionSegment.text'),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start,
    'end': end,
    'text': text,
  };

  /// Creates a copy.
  TranscriptionSegment copyWith({
    int? id,
    double? start,
    double? end,
    String? text,
  }) => TranscriptionSegment(
    id: id ?? this.id,
    start: start ?? this.start,
    end: end ?? this.end,
    text: text ?? this.text,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegment &&
          id == other.id &&
          start == other.start &&
          end == other.end &&
          text == other.text;

  @override
  int get hashCode => Object.hash(id, start, end, text);

  @override
  String toString() =>
      'TranscriptionSegment(id: $id, start: $start, end: $end, text: $text)';
}

/// A transcription or translation, including optional verbose metadata.
///
/// Plain-text responses are exposed through [text]. JSON responses preserve
/// their clip metadata. For translations, [language] is the output language.
@immutable
class TranscriptionResponse {
  /// Complete recognized or translated text.
  final String text;

  /// `transcribe` or `translate`, supplied by verbose responses.
  final String? task;

  /// Lowercase English language name, when supplied by the server.
  final String? language;

  /// Audio duration in seconds, when supplied by a verbose response.
  final double? duration;

  /// Clip-level transcript segments, when supplied by a verbose response.
  final List<TranscriptionSegment>? segments;

  /// Creates an immutable response.
  TranscriptionResponse({
    required this.text,
    this.task,
    this.language,
    this.duration,
    List<TranscriptionSegment>? segments,
  }) : segments = segments == null ? null : List.unmodifiable(segments);

  /// Creates a response from JSON.
  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) =>
      TranscriptionResponse(
        text: _requiredAudioString(json['text'], 'TranscriptionResponse.text'),
        task: json['task'] as String?,
        language: json['language'] as String?,
        duration: (json['duration'] as num?)?.toDouble(),
        segments: (json['segments'] as List?)
            ?.map(
              (item) =>
                  TranscriptionSegment.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'text': text,
    if (task != null) 'task': task,
    if (language != null) 'language': language,
    if (duration != null) 'duration': duration,
    if (segments != null)
      'segments': segments!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy, allowing nullable metadata to be cleared with `null`.
  TranscriptionResponse copyWith({
    String? text,
    Object? task = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? duration = unsetCopyWithValue,
    Object? segments = unsetCopyWithValue,
  }) => TranscriptionResponse(
    text: text ?? this.text,
    task: identical(task, unsetCopyWithValue) ? this.task : task as String?,
    language: identical(language, unsetCopyWithValue)
        ? this.language
        : language as String?,
    duration: identical(duration, unsetCopyWithValue)
        ? this.duration
        : (duration as num?)?.toDouble(),
    segments: identical(segments, unsetCopyWithValue)
        ? this.segments
        : segments as List<TranscriptionSegment>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          text == other.text &&
          task == other.task &&
          language == other.language &&
          duration == other.duration &&
          listsEqual(segments, other.segments);

  @override
  int get hashCode =>
      Object.hash(text, task, language, duration, listHash(segments));

  @override
  String toString() =>
      'TranscriptionResponse(text: $text, task: $task, language: $language, '
      'duration: $duration, segments: ${segments == null ? null : '${segments!.length} items'})';
}

String _requiredAudioString(Object? value, String field) {
  if (value is! String) throw FormatException('$field must be a string');
  return value;
}

double _requiredAudioNumber(Object? value, String field) {
  if (value is! num) throw FormatException('$field must be a number');
  return value.toDouble();
}
