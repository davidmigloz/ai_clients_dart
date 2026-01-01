import 'package:meta/meta.dart';

import '../metadata/usage_info.dart';
import 'transcription_segment.dart';
import 'transcription_word.dart';

/// Response from audio transcription.
@immutable
class TranscriptionResponse {
  /// Unique identifier for the response.
  final String? id;

  /// Object type.
  final String object;

  /// The transcribed text.
  final String text;

  /// The language of the audio.
  final String? language;

  /// Total duration of the audio in seconds.
  final double? duration;

  /// Segments of the transcription.
  final List<TranscriptionSegment>? segments;

  /// Word-level timing information.
  final List<TranscriptionWord>? words;

  /// Usage statistics.
  final UsageInfo? usage;

  /// Creates a [TranscriptionResponse].
  const TranscriptionResponse({
    this.id,
    this.object = 'transcription',
    required this.text,
    this.language,
    this.duration,
    this.segments,
    this.words,
    this.usage,
  });

  /// Creates a [TranscriptionResponse] from JSON.
  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) =>
      TranscriptionResponse(
        id: json['id'] as String?,
        object: json['object'] as String? ?? 'transcription',
        text: json['text'] as String? ?? '',
        language: json['language'] as String?,
        duration: (json['duration'] as num?)?.toDouble(),
        segments: (json['segments'] as List?)
            ?.map(
              (e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        words: (json['words'] as List?)
            ?.map((e) => TranscriptionWord.fromJson(e as Map<String, dynamic>))
            .toList(),
        usage: json['usage'] != null
            ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'object': object,
    'text': text,
    if (language != null) 'language': language,
    if (duration != null) 'duration': duration,
    if (segments != null) 'segments': segments!.map((e) => e.toJson()).toList(),
    if (words != null) 'words': words!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() =>
      'TranscriptionResponse(text: ${text.length} chars, language: $language)';
}
