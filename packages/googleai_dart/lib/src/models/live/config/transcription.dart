import '../../copy_with_sentinel.dart';

/// Transcription of audio content.
///
/// Used for both input (user speech) and output (model speech) transcription.
class Transcription {
  /// The transcribed text.
  final String? text;

  /// Whether the API marked this transcription finished.
  final bool? finished;

  /// BCP-47 language code, when reported by the model.
  final String? languageCode;

  /// Speaker label, when reported by the model.
  final String? speakerLabel;

  /// Individual words and their offsets, when reported by the model.
  final List<LiveTranscriptionWord>? words;

  /// Start offset relative to the audio start as a protobuf duration string.
  final String? startOffset;

  /// End offset relative to the audio start as a protobuf duration string.
  final String? endOffset;

  /// Creates a [Transcription].
  const Transcription({
    this.text,
    this.finished,
    this.languageCode,
    this.speakerLabel,
    this.words,
    this.startOffset,
    this.endOffset,
  });

  /// Creates from JSON.
  factory Transcription.fromJson(Map<String, dynamic> json) {
    return Transcription(
      text: json['text'] as String?,
      finished: json['finished'] as bool?,
      languageCode: json['languageCode'] as String?,
      speakerLabel: json['speakerLabel'] as String?,
      words: (json['words'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map(LiveTranscriptionWord.fromJson)
          .toList(),
      startOffset: json['startOffset'] as String?,
      endOffset: json['endOffset'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (text != null) 'text': text,
    if (finished != null) 'finished': finished,
    if (languageCode != null) 'languageCode': languageCode,
    if (speakerLabel != null) 'speakerLabel': speakerLabel,
    if (words != null) 'words': words!.map((word) => word.toJson()).toList(),
    if (startOffset != null) 'startOffset': startOffset,
    if (endOffset != null) 'endOffset': endOffset,
  };

  /// Creates a copy with the given fields replaced.
  Transcription copyWith({
    Object? text = unsetCopyWithValue,
    Object? finished = unsetCopyWithValue,
    Object? languageCode = unsetCopyWithValue,
    Object? speakerLabel = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
    Object? startOffset = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
  }) => Transcription(
    text: text == unsetCopyWithValue ? this.text : text as String?,
    finished: finished == unsetCopyWithValue
        ? this.finished
        : finished as bool?,
    languageCode: languageCode == unsetCopyWithValue
        ? this.languageCode
        : languageCode as String?,
    speakerLabel: speakerLabel == unsetCopyWithValue
        ? this.speakerLabel
        : speakerLabel as String?,
    words: words == unsetCopyWithValue
        ? this.words
        : words as List<LiveTranscriptionWord>?,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as String?,
  );

  @override
  String toString() =>
      'Transcription(text: $text, finished: $finished, '
      'languageCode: $languageCode, speakerLabel: $speakerLabel, '
      'words: ${words?.length}, startOffset: $startOffset, endOffset: $endOffset)';
}

/// One word in a Live transcription.
class LiveTranscriptionWord {
  /// The recognized word, when present.
  final String? word;

  /// Start offset relative to the audio start as a protobuf duration string.
  final String? startOffset;

  /// End offset relative to the audio start as a protobuf duration string.
  final String? endOffset;

  /// Creates a [LiveTranscriptionWord].
  const LiveTranscriptionWord({this.word, this.startOffset, this.endOffset});

  /// Creates from JSON.
  factory LiveTranscriptionWord.fromJson(Map<String, dynamic> json) {
    return LiveTranscriptionWord(
      word: json['word'] as String?,
      startOffset: json['startOffset'] as String?,
      endOffset: json['endOffset'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (word != null) 'word': word,
    if (startOffset != null) 'startOffset': startOffset,
    if (endOffset != null) 'endOffset': endOffset,
  };

  /// Copies this word. Pass `null` to clear a field.
  LiveTranscriptionWord copyWith({
    Object? word = unsetCopyWithValue,
    Object? startOffset = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
  }) => LiveTranscriptionWord(
    word: word == unsetCopyWithValue ? this.word : word as String?,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as String?,
  );

  @override
  String toString() =>
      'LiveTranscriptionWord(word: $word, startOffset: $startOffset, '
      'endOffset: $endOffset)';
}
