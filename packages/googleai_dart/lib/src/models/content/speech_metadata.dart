import '../../utils/media_wire_options.dart';
import '../copy_with_sentinel.dart';

/// Controls how a text part is synthesized as speech.
class SpeechMetadata {
  /// Speaker name for multi-speaker synthesis.
  final String? speaker;

  /// A speaking style instruction.
  final String? style;

  /// Creates a [SpeechMetadata].
  const SpeechMetadata({this.speaker, this.style}) : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const SpeechMetadata._({
    this.speaker,
    this.style,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory SpeechMetadata.fromJson(Map<String, dynamic> json) =>
      SpeechMetadata._(
        speaker: json['speaker'] as String?,
        style: json['style'] as String?,
        wireExtensions: mediaExtensions(json, const {'speaker', 'style'}),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    'speaker': ?speaker,
    'style': ?style,
  };

  /// Creates a copy with replaced values.
  SpeechMetadata copyWith({
    Object? speaker = unsetCopyWithValue,
    Object? style = unsetCopyWithValue,
  }) => SpeechMetadata._(
    speaker: speaker == unsetCopyWithValue ? this.speaker : speaker as String?,
    style: style == unsetCopyWithValue ? this.style : style as String?,
    wireExtensions: _wireExtensions,
  );
}

/// A recognized word in a GenerateContent audio part.
class AudioTranscriptionWord {
  /// The recognized word.
  final String word;

  /// Start offset from the audio start as a protobuf duration.
  final String? startOffset;

  /// End offset from the audio start as a protobuf duration.
  final String? endOffset;

  /// Creates a [AudioTranscriptionWord].
  const AudioTranscriptionWord({
    required this.word,
    this.startOffset,
    this.endOffset,
  }) : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const AudioTranscriptionWord._({
    required this.word,
    this.startOffset,
    this.endOffset,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory AudioTranscriptionWord.fromJson(Map<String, dynamic> json) =>
      AudioTranscriptionWord._(
        word: json['word'] as String,
        startOffset: json['startOffset'] as String?,
        endOffset: json['endOffset'] as String?,
        wireExtensions: mediaExtensions(json, const {
          'word',
          'startOffset',
          'endOffset',
        }),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    'word': word,
    'startOffset': ?startOffset,
    'endOffset': ?endOffset,
  };

  /// Creates a copy with replaced values.
  AudioTranscriptionWord copyWith({
    Object? word = unsetCopyWithValue,
    Object? startOffset = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
  }) => AudioTranscriptionWord._(
    word: word == unsetCopyWithValue ? this.word : word! as String,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as String?,
    wireExtensions: _wireExtensions,
  );
}

/// Transcript returned for a GenerateContent audio part.
class AudioTranscription {
  /// Full transcript when the model includes it alongside timed words.
  final String? text;

  /// Speaker label when diarization is available.
  final String? speakerLabel;

  /// Word-level transcription and timing when requested.
  final List<AudioTranscriptionWord>? words;

  /// Creates a [AudioTranscription].
  const AudioTranscription({this.text, this.speakerLabel, this.words})
    : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const AudioTranscription._({
    required this.text,
    this.speakerLabel,
    this.words,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory AudioTranscription.fromJson(Map<String, dynamic> json) =>
      AudioTranscription._(
        text: json['text'] as String?,
        speakerLabel: json['speakerLabel'] as String?,
        words: (json['words'] as List?)
            ?.map(
              (word) =>
                  AudioTranscriptionWord.fromJson(word as Map<String, dynamic>),
            )
            .toList(),
        wireExtensions: mediaExtensions(json, const {
          'text',
          'speakerLabel',
          'words',
        }),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    'text': ?text,
    'speakerLabel': ?speakerLabel,
    'words': ?words?.map((word) => word.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  AudioTranscription copyWith({
    Object? text = unsetCopyWithValue,
    Object? speakerLabel = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
  }) => AudioTranscription._(
    text: text == unsetCopyWithValue ? this.text : text as String?,
    speakerLabel: speakerLabel == unsetCopyWithValue
        ? this.speakerLabel
        : speakerLabel as String?,
    words: words == unsetCopyWithValue
        ? this.words
        : words as List<AudioTranscriptionWord>?,
    wireExtensions: _wireExtensions,
  );
}
