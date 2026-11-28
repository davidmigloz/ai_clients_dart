import 'speech_config.dart';

/// Text normalization before speech synthesis.
extension type const InteractionTextNormalization(String value) {
  /// Let the model choose how to normalize the text.
  static const auto = InteractionTextNormalization('auto');

  /// Normalize numbers, dates, currencies, and units.
  static const enabled = InteractionTextNormalization('enabled');

  /// Preserve pre-normalized and phonetic text.
  static const disabled = InteractionTextNormalization('disabled');
}

/// Speaker settings accepted by the Interactions generation configuration.
sealed class InteractionStructuredSpeechConfig {
  const InteractionStructuredSpeechConfig();

  /// Creates speaker settings with an optional text-normalization mode.
  const factory InteractionStructuredSpeechConfig.speakers({
    List<InteractionSpeechConfig>? speakers,
    InteractionTextNormalization? textNormalization,
  }) = InteractionSpeakerConfig;

  /// Creates speaker settings in the compact array form.
  const factory InteractionStructuredSpeechConfig.list(
    List<InteractionSpeechConfig> speakers,
  ) = InteractionSpeechConfigList;

  /// Parses the object or array wire format.
  factory InteractionStructuredSpeechConfig.fromJson(Object json) =>
      switch (json) {
        final Map<String, dynamic> value => InteractionSpeakerConfig.fromJson(
          value,
        ),
        final List<dynamic> value => InteractionSpeechConfigList(
          _decodeSpeakers(value),
        ),
        _ => throw const FormatException(
          'Invalid structured speech configuration.',
        ),
      };

  /// Encodes the object or array wire format.
  Object toJson();
}

/// Object-form speech configuration for a single or multi-speaker model.
final class InteractionSpeakerConfig extends InteractionStructuredSpeechConfig {
  /// Per-speaker configuration.
  final List<InteractionSpeechConfig>? speakers;

  /// How to normalize the input text before synthesis.
  final InteractionTextNormalization? textNormalization;

  /// Creates object-form speech settings.
  const InteractionSpeakerConfig({this.speakers, this.textNormalization});

  /// Creates object-form speech settings from JSON.
  factory InteractionSpeakerConfig.fromJson(Map<String, dynamic> json) =>
      InteractionSpeakerConfig(
        speakers: json['speakers'] == null
            ? null
            : _decodeSpeakers(json['speakers'] as List),
        textNormalization: json['text_normalization'] == null
            ? null
            : InteractionTextNormalization(
                json['text_normalization'] as String,
              ),
      );

  @override
  Map<String, dynamic> toJson() => {
    if (speakers != null)
      'speakers': [for (final speaker in speakers!) speaker.toJson()],
    'text_normalization': ?textNormalization?.value,
  };
}

/// Array-form speech settings for a list of speakers.
final class InteractionSpeechConfigList
    extends InteractionStructuredSpeechConfig {
  /// Per-speaker configuration.
  final List<InteractionSpeechConfig> speakers;

  /// Creates array-form speech settings.
  const InteractionSpeechConfigList(this.speakers);

  @override
  List<Map<String, dynamic>> toJson() => [
    for (final speaker in speakers) speaker.toJson(),
  ];
}

List<InteractionSpeechConfig> _decodeSpeakers(List<dynamic> json) => [
  for (final speaker in json)
    InteractionSpeechConfig.fromJson(speaker as Map<String, dynamic>),
];
