part of 'content.dart';

/// Speaker and synthesis style for an attributed text segment.
final class SpeechAnnotation extends Annotation {
  /// Inclusive start offset measured in bytes.
  final int? startIndex;

  /// Exclusive end offset measured in bytes.
  final int? endIndex;

  /// Speaker associated with the turn.
  final String? speaker;

  /// Synthesis style instruction for the turn.
  final String? style;

  /// Additional wire fields retained for forward compatibility.
  final Map<String, dynamic> additionalProperties;

  /// Creates a [SpeechAnnotation].
  const SpeechAnnotation({
    this.startIndex,
    this.endIndex,
    this.speaker,
    this.style,
    this.additionalProperties = const {},
  });

  /// Reads a speech annotation from the Interactions wire format.
  factory SpeechAnnotation.fromJson(Map<String, dynamic> json) =>
      SpeechAnnotation(
        startIndex: json['start_index'] as int?,
        endIndex: json['end_index'] as int?,
        speaker: json['speaker'] as String?,
        style: json['style'] as String?,
        additionalProperties: mediaExtensions(json, const {
          'type',
          'start_index',
          'end_index',
          'speaker',
          'style',
        }),
      );

  @override
  Map<String, dynamic> toJson() => {
    ...additionalProperties,
    'type': 'speech_metadata',
    'start_index': ?startIndex,
    'end_index': ?endIndex,
    'speaker': ?speaker,
    'style': ?style,
  };

  /// Creates a copy with updated fields.
  SpeechAnnotation copyWith({
    Object? startIndex = unsetCopyWithValue,
    Object? endIndex = unsetCopyWithValue,
    Object? speaker = unsetCopyWithValue,
    Object? style = unsetCopyWithValue,
    Map<String, dynamic>? additionalProperties,
  }) => SpeechAnnotation(
    startIndex: startIndex == unsetCopyWithValue
        ? this.startIndex
        : startIndex as int?,
    endIndex: endIndex == unsetCopyWithValue ? this.endIndex : endIndex as int?,
    speaker: speaker == unsetCopyWithValue ? this.speaker : speaker as String?,
    style: style == unsetCopyWithValue ? this.style : style as String?,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );
}
