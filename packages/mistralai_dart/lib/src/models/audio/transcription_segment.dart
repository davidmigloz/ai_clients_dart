import 'package:meta/meta.dart';

import 'transcription_word.dart';

/// A segment of transcribed audio.
@immutable
class TranscriptionSegment {
  /// Segment ID.
  final int id;

  /// Seek position in the audio.
  final int? seek;

  /// Start time in seconds.
  final double start;

  /// End time in seconds.
  final double end;

  /// The transcribed text.
  final String text;

  /// Token IDs for the segment.
  final List<int>? tokens;

  /// Temperature used for this segment.
  final double? temperature;

  /// Average log probability.
  final double? avgLogprob;

  /// Compression ratio.
  final double? compressionRatio;

  /// Probability of no speech.
  final double? noSpeechProb;

  /// Word-level timing information.
  final List<TranscriptionWord>? words;

  /// Creates a [TranscriptionSegment].
  const TranscriptionSegment({
    required this.id,
    this.seek,
    required this.start,
    required this.end,
    required this.text,
    this.tokens,
    this.temperature,
    this.avgLogprob,
    this.compressionRatio,
    this.noSpeechProb,
    this.words,
  });

  /// Creates a [TranscriptionSegment] from JSON.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) =>
      TranscriptionSegment(
        id: json['id'] as int? ?? 0,
        seek: json['seek'] as int?,
        start: (json['start'] as num?)?.toDouble() ?? 0.0,
        end: (json['end'] as num?)?.toDouble() ?? 0.0,
        text: json['text'] as String? ?? '',
        tokens: (json['tokens'] as List?)?.cast<int>(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        avgLogprob: (json['avg_logprob'] as num?)?.toDouble(),
        compressionRatio: (json['compression_ratio'] as num?)?.toDouble(),
        noSpeechProb: (json['no_speech_prob'] as num?)?.toDouble(),
        words: (json['words'] as List?)
            ?.map((e) => TranscriptionWord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (seek != null) 'seek': seek,
    'start': start,
    'end': end,
    'text': text,
    if (tokens != null) 'tokens': tokens,
    if (temperature != null) 'temperature': temperature,
    if (avgLogprob != null) 'avg_logprob': avgLogprob,
    if (compressionRatio != null) 'compression_ratio': compressionRatio,
    if (noSpeechProb != null) 'no_speech_prob': noSpeechProb,
    if (words != null) 'words': words!.map((e) => e.toJson()).toList(),
  };

  /// Duration of the segment in seconds.
  double get duration => end - start;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TranscriptionSegment(id: $id, text: ${text.length} chars)';
}
