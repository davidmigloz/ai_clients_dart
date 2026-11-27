import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'transcription_word.dart';

/// A segment of transcribed audio.
@immutable
class TranscriptionSegment {
  /// Legacy segment ID, if the server returned one.
  final int? id;

  /// Completed-segment discriminator, when present.
  final String? type;

  /// Label of the detected speaker, when diarization is enabled.
  final String? speakerId;

  /// Segment score, if supplied by the model.
  final double? score;

  /// Seek position in the audio.
  final int? seek;

  /// Start time in seconds, or null if unavailable.
  final double? start;

  /// End time in seconds, or null if unavailable.
  final double? end;

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
    this.id,
    this.type,
    this.speakerId,
    this.score,
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
        id: json['id'] as int?,
        type: json['type'] as String?,
        speakerId: json['speaker_id'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        seek: json['seek'] as int?,
        start: (json['start'] as num?)?.toDouble(),
        end: (json['end'] as num?)?.toDouble(),
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
    if (id != null) 'id': id,
    if (type != null) 'type': type,
    if (speakerId != null) 'speaker_id': speakerId,
    if (score != null) 'score': score,
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

  /// Duration in seconds, or null if either timestamp is unavailable.
  double? get duration {
    final startTime = start;
    final endTime = end;
    return startTime == null || endTime == null ? null : endTime - startTime;
  }

  /// Creates a copy with replacement fields. Pass null to clear a field.
  TranscriptionSegment copyWith({
    Object? id = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    Object? speakerId = unsetCopyWithValue,
    Object? score = unsetCopyWithValue,
    Object? seek = unsetCopyWithValue,
    Object? start = unsetCopyWithValue,
    Object? end = unsetCopyWithValue,
    String? text,
    Object? tokens = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? avgLogprob = unsetCopyWithValue,
    Object? compressionRatio = unsetCopyWithValue,
    Object? noSpeechProb = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
  }) => TranscriptionSegment(
    id: id == unsetCopyWithValue ? this.id : id as int?,
    type: type == unsetCopyWithValue ? this.type : type as String?,
    speakerId: speakerId == unsetCopyWithValue
        ? this.speakerId
        : speakerId as String?,
    score: score == unsetCopyWithValue
        ? this.score
        : (score as num?)?.toDouble(),
    seek: seek == unsetCopyWithValue ? this.seek : seek as int?,
    start: start == unsetCopyWithValue
        ? this.start
        : (start as num?)?.toDouble(),
    end: end == unsetCopyWithValue ? this.end : (end as num?)?.toDouble(),
    text: text ?? this.text,
    tokens: tokens == unsetCopyWithValue
        ? this.tokens
        : (tokens as List?)?.cast<int>(),
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    avgLogprob: avgLogprob == unsetCopyWithValue
        ? this.avgLogprob
        : (avgLogprob as num?)?.toDouble(),
    compressionRatio: compressionRatio == unsetCopyWithValue
        ? this.compressionRatio
        : (compressionRatio as num?)?.toDouble(),
    noSpeechProb: noSpeechProb == unsetCopyWithValue
        ? this.noSpeechProb
        : (noSpeechProb as num?)?.toDouble(),
    words: words == unsetCopyWithValue
        ? this.words
        : (words as List?)?.cast<TranscriptionWord>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          speakerId == other.speakerId &&
          score == other.score &&
          seek == other.seek &&
          start == other.start &&
          end == other.end &&
          text == other.text &&
          listsEqual(tokens, other.tokens) &&
          temperature == other.temperature &&
          avgLogprob == other.avgLogprob &&
          compressionRatio == other.compressionRatio &&
          noSpeechProb == other.noSpeechProb &&
          listsEqual(words, other.words);

  @override
  int get hashCode => Object.hash(
    id,
    type,
    speakerId,
    score,
    seek,
    start,
    end,
    text,
    listHash(tokens),
    temperature,
    avgLogprob,
    compressionRatio,
    noSpeechProb,
    listHash(words),
  );

  @override
  String toString() =>
      'TranscriptionSegment(id: $id, text: ${text.length} chars, '
      'type: $type, speakerId: $speakerId, score: $score, '
      'start: $start, end: $end)';
}
