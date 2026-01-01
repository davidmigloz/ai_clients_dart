import 'package:meta/meta.dart';

/// A word in the transcription with timing information.
@immutable
class TranscriptionWord {
  /// The word text.
  final String word;

  /// Start time in seconds.
  final double start;

  /// End time in seconds.
  final double end;

  /// Creates a [TranscriptionWord].
  const TranscriptionWord({
    required this.word,
    required this.start,
    required this.end,
  });

  /// Creates a [TranscriptionWord] from JSON.
  factory TranscriptionWord.fromJson(Map<String, dynamic> json) =>
      TranscriptionWord(
        word: json['word'] as String? ?? '',
        start: (json['start'] as num?)?.toDouble() ?? 0.0,
        end: (json['end'] as num?)?.toDouble() ?? 0.0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'word': word, 'start': start, 'end': end};

  /// Duration of the word in seconds.
  double get duration => end - start;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionWord &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(word, start, end);

  @override
  String toString() =>
      'TranscriptionWord(word: $word, start: $start, end: $end)';
}
