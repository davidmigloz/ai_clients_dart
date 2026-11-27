import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/usage_info.dart';
import 'transcription_segment.dart';
import 'transcription_word.dart';

/// A streaming event during audio transcription.
///
/// Inspect [type] for `transcription.language`,
/// `transcription.text.delta`, `transcription.segment`, or
/// `transcription.done`. Realtime turn detection also emits `turn.start`,
/// `turn.eager_end`, `turn.resume` and `turn.end`.
@immutable
class TranscriptionStreamEvent {
  /// Wire event type.
  final String type;

  /// Legacy transcription ID, when present.
  final String? id;

  /// Transcribed text. A done event can repeat the full transcript.
  final String? text;

  /// The segment for a `transcription.segment` event.
  final TranscriptionSegment? segment;

  /// Legacy word information, when present.
  final TranscriptionWord? word;

  /// Legacy flag for a final event. Use [isDone] for both formats.
  final bool? isFinal;

  /// Detected language for a `transcription.language` event.
  final String? audioLanguage;

  /// Transcription model returned by a `transcription.done` event.
  final String? model;

  /// Final audio language, if available on a `transcription.done` event.
  final String? language;

  /// Completed segments, if available on a `transcription.done` event.
  final List<TranscriptionSegment>? segments;

  /// Usage returned by a `transcription.done` event.
  final UsageInfo? usage;

  /// Turn detection timestamp in seconds, when present.
  final double? timeSeconds;

  /// Reason for a `turn.end` event, such as `threshold` or `timeout`.
  final String? endReason;

  /// Additional fields received from an unrecognized future event.
  final Map<String, dynamic>? extra;

  /// Creates a [TranscriptionStreamEvent].
  const TranscriptionStreamEvent({
    required this.type,
    this.id,
    this.text,
    this.segment,
    this.word,
    this.isFinal,
    this.audioLanguage,
    this.model,
    this.language,
    this.segments,
    this.usage,
    this.timeSeconds,
    this.endReason,
    this.extra,
  });

  /// Whether the transcription is complete.
  bool get isDone => type == 'transcription.done' || isFinal == true;

  /// Creates a [TranscriptionStreamEvent] from JSON.
  factory TranscriptionStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['_event']) as String? ?? 'text';
    final TranscriptionSegment? segment;
    if (type == 'transcription.segment') {
      segment = TranscriptionSegment(
        text: json['text'] as String? ?? '',
        start: (json['start'] as num?)?.toDouble(),
        end: (json['end'] as num?)?.toDouble(),
        speakerId: json['speaker_id'] as String?,
      );
    } else {
      final nested = json['segment'] as Map<String, dynamic>?;
      segment = nested == null ? null : TranscriptionSegment.fromJson(nested);
    }
    final extra = <String, dynamic>{
      for (final entry in json.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    };

    return TranscriptionStreamEvent(
      type: type,
      id: json['id'] as String?,
      text: json['text'] as String?,
      segment: segment,
      word: json['word'] == null
          ? null
          : TranscriptionWord.fromJson(json['word'] as Map<String, dynamic>),
      isFinal: json['is_final'] as bool?,
      audioLanguage: json['audio_language'] as String?,
      model: json['model'] as String?,
      language: json['language'] as String?,
      segments: (json['segments'] as List?)
          ?.map(
            (item) =>
                TranscriptionSegment.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      usage: json['usage'] == null
          ? null
          : UsageInfo.fromJson(json['usage'] as Map<String, dynamic>),
      timeSeconds: (json['time_s'] as num?)?.toDouble(),
      endReason: json['end_reason'] as String?,
      extra: extra.isEmpty ? null : extra,
    );
  }

  static const _knownKeys = {
    'type',
    '_event',
    'id',
    'text',
    'segment',
    'word',
    'is_final',
    'audio_language',
    'model',
    'language',
    'segments',
    'usage',
    'time_s',
    'end_reason',
    'start',
    'end',
    'speaker_id',
  };

  /// Converts to JSON, using the flat wire shape for segment delta events.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    if (id != null) 'id': id,
    if (text != null) 'text': text,
    if (segment case final value?)
      if (type == 'transcription.segment') ...{
        'text': text ?? value.text,
        'start': value.start,
        'end': value.end,
        if (value.speakerId != null) 'speaker_id': value.speakerId,
      } else
        'segment': value.toJson(),
    if (word != null) 'word': word!.toJson(),
    if (isFinal != null) 'is_final': isFinal,
    if (audioLanguage != null) 'audio_language': audioLanguage,
    if (model != null) 'model': model,
    if (language != null || type == 'transcription.done') 'language': language,
    if (segments != null)
      'segments': segments!.map((item) => item.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (timeSeconds != null) 'time_s': timeSeconds,
    if (endReason != null) 'end_reason': endReason,
  };

  /// Creates a copy with replacement fields. Pass null to clear a field.
  TranscriptionStreamEvent copyWith({
    String? type,
    Object? id = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? segment = unsetCopyWithValue,
    Object? word = unsetCopyWithValue,
    Object? isFinal = unsetCopyWithValue,
    Object? audioLanguage = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? segments = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? timeSeconds = unsetCopyWithValue,
    Object? endReason = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) {
    final eventType = type ?? this.type;
    final updatedSegment = segment == unsetCopyWithValue
        ? this.segment
        : segment as TranscriptionSegment?;
    final updatedText = switch (text) {
      unsetCopyWithValue
          when segment != unsetCopyWithValue &&
              eventType == 'transcription.segment' =>
        updatedSegment?.text,
      unsetCopyWithValue => this.text,
      _ => text as String?,
    };
    return TranscriptionStreamEvent(
      type: eventType,
      id: id == unsetCopyWithValue ? this.id : id as String?,
      text: updatedText,
      segment: updatedSegment,
      word: word == unsetCopyWithValue ? this.word : word as TranscriptionWord?,
      isFinal: isFinal == unsetCopyWithValue ? this.isFinal : isFinal as bool?,
      audioLanguage: audioLanguage == unsetCopyWithValue
          ? this.audioLanguage
          : audioLanguage as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      language: language == unsetCopyWithValue
          ? this.language
          : language as String?,
      segments: segments == unsetCopyWithValue
          ? this.segments
          : (segments as List?)?.cast<TranscriptionSegment>(),
      usage: usage == unsetCopyWithValue ? this.usage : usage as UsageInfo?,
      timeSeconds: timeSeconds == unsetCopyWithValue
          ? this.timeSeconds
          : (timeSeconds as num?)?.toDouble(),
      endReason: endReason == unsetCopyWithValue
          ? this.endReason
          : endReason as String?,
      extra: extra == unsetCopyWithValue
          ? this.extra
          : extra as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionStreamEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          text == other.text &&
          segment == other.segment &&
          word == other.word &&
          isFinal == other.isFinal &&
          audioLanguage == other.audioLanguage &&
          model == other.model &&
          language == other.language &&
          listsEqual(segments, other.segments) &&
          usage == other.usage &&
          timeSeconds == other.timeSeconds &&
          endReason == other.endReason &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    type,
    id,
    text,
    segment,
    word,
    isFinal,
    audioLanguage,
    model,
    language,
    listHash(segments),
    usage,
    timeSeconds,
    endReason,
    mapDeepHashCode(extra),
  );

  @override
  String toString() =>
      'TranscriptionStreamEvent(type: $type, text: $text, '
      'audioLanguage: $audioLanguage, model: $model, language: $language, '
      'segments: ${segments?.length}, usage: $usage, timeSeconds: $timeSeconds, '
      'endReason: $endReason, extra: ${extra?.length})';
}
