import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'transcription_segment.dart';
import 'transcription_word.dart';

/// Response from audio transcription.
@immutable
class TranscriptionResponse {
  /// Unique identifier for the response.
  final String? id;

  final String? _object;

  /// Legacy object type. Defaults to `transcription` if omitted.
  String get object => _object ?? 'transcription';

  /// The model used for the transcription.
  ///
  /// May be absent in older API responses.
  final String? model;

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
    this._object = 'transcription',
    this.model,
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
        object: json['object'] as String?,
        model: json['model'] as String?,
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
    if (_object != null) 'object': _object,
    if (model != null) 'model': model,
    'text': text,
    if (language != null || model != null) 'language': language,
    if (duration != null) 'duration': duration,
    if (segments != null) 'segments': segments!.map((e) => e.toJson()).toList(),
    if (words != null) 'words': words!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with replacement fields. Pass null to clear a field.
  TranscriptionResponse copyWith({
    Object? id = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    String? text,
    Object? language = unsetCopyWithValue,
    Object? duration = unsetCopyWithValue,
    Object? segments = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
  }) => TranscriptionResponse(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    object: object == unsetCopyWithValue ? _object : object as String?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    text: text ?? this.text,
    language: language == unsetCopyWithValue
        ? this.language
        : language as String?,
    duration: duration == unsetCopyWithValue
        ? this.duration
        : (duration as num?)?.toDouble(),
    segments: segments == unsetCopyWithValue
        ? this.segments
        : (segments as List?)?.cast<TranscriptionSegment>(),
    words: words == unsetCopyWithValue
        ? this.words
        : (words as List?)?.cast<TranscriptionWord>(),
    usage: usage == unsetCopyWithValue ? this.usage : usage as UsageInfo?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          _object == other._object &&
          model == other.model &&
          text == other.text &&
          language == other.language &&
          duration == other.duration &&
          listsEqual(segments, other.segments) &&
          listsEqual(words, other.words) &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    id,
    _object,
    model,
    text,
    language,
    duration,
    listHash(segments),
    listHash(words),
    usage,
  );

  @override
  String toString() =>
      'TranscriptionResponse(text: ${text.length} chars, language: $language, '
      'model: $model, segments: ${segments?.length}, usage: $usage)';
}
