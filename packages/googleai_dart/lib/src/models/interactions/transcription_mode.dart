/// Selects how an Interactions transcription model processes speech.
sealed class InteractionTranscriptionMode {
  const InteractionTranscriptionMode();

  /// Requests formatted transcription or voice-driven editing.
  const factory InteractionTranscriptionMode.smart({String? sourceText}) =
      InteractionSmartTranscriptionMode;

  /// Requests literal transcription with optional diarization and timestamps.
  const factory InteractionTranscriptionMode.verbatim({
    String? diarizationMode,
    List<String>? timestampGranularities,
  }) = InteractionVerbatimTranscriptionMode;

  /// The shorthand wire value for SMART mode.
  static const smartPreset = InteractionTranscriptionPreset('smart');

  /// The shorthand wire value for verbatim mode.
  static const verbatimPreset = InteractionTranscriptionPreset('verbatim');

  /// Parses shorthand, options, and future wire representations.
  factory InteractionTranscriptionMode.fromJson(Object json) => switch (json) {
    final String mode => InteractionTranscriptionPreset(mode),
    final Map<String, dynamic> mode when mode['type'] == 'smart' =>
      InteractionSmartTranscriptionMode(
        sourceText: mode['source_text'] as String?,
      ),
    final Map<String, dynamic> mode when mode['type'] == 'verbatim' =>
      InteractionVerbatimTranscriptionMode(
        diarizationMode: mode['diarization_mode'] as String?,
        timestampGranularities: (mode['timestamp_granularities'] as List?)
            ?.cast<String>(),
      ),
    final Map<String, dynamic> mode => UnknownInteractionTranscriptionMode(
      mode,
    ),
    _ => throw const FormatException(
      'Invalid Interactions transcription mode.',
    ),
  };

  /// Encodes the shorthand or options representation.
  Object toJson();
}

/// Mode for formatting or voice-editing transcript text.
final class InteractionSmartTranscriptionMode
    extends InteractionTranscriptionMode {
  /// The text to rewrite when the audio contains editing instructions.
  final String? sourceText;

  /// Creates SMART transcription options.
  const InteractionSmartTranscriptionMode({this.sourceText});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'smart',
    'source_text': ?sourceText,
  };
}

/// Mode for literal transcription with optional timing or speaker information.
final class InteractionVerbatimTranscriptionMode
    extends InteractionTranscriptionMode {
  /// The speaker grouping mode, such as `speaker`.
  final String? diarizationMode;

  /// Requested timestamp levels, such as `word`.
  final List<String>? timestampGranularities;

  /// Creates verbatim transcription options.
  const InteractionVerbatimTranscriptionMode({
    this.diarizationMode,
    this.timestampGranularities,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'verbatim',
    'diarization_mode': ?diarizationMode,
    'timestamp_granularities': ?timestampGranularities,
  };
}

/// A shorthand transcription mode.
final class InteractionTranscriptionPreset
    extends InteractionTranscriptionMode {
  /// The wire value, retained when newer modes are returned.
  final String value;

  /// Creates a shorthand mode.
  const InteractionTranscriptionPreset(this.value);

  @override
  String toJson() => value;
}

/// An object-form transcription mode added by the API.
final class UnknownInteractionTranscriptionMode
    extends InteractionTranscriptionMode {
  /// Original mode fields for replay.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown mode without discarding fields.
  UnknownInteractionTranscriptionMode(Map<String, dynamic> json)
    : rawJson = Map.unmodifiable(json);

  @override
  Map<String, dynamic> toJson() => rawJson;
}
