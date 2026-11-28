import '../copy_with_sentinel.dart';
import 'audio_transcription_mode.dart';

/// Configuration for main-spec speech transcription (ASR) output.
///
/// Maps to the API schema `AudioTranscriptionConfig` and is referenced by
/// [GenerationConfig.audioTranscriptionConfig]. This is distinct from the
/// Live API's `AudioTranscriptionConfig`, which configures streaming audio.
class GenerationAudioTranscriptionConfig {
  /// The list of phrases to bias the transcription towards.
  @Deprecated('Use customVocabulary instead.')
  final List<String>? adaptationPhrases;

  /// The list of custom vocabulary terms to bias the transcription towards.
  final List<String>? customVocabulary;

  /// Whether to enable speaker diarization.
  final bool? diarization;

  /// Marker indicating automatic language detection.
  @Deprecated(
    'Automatic language detection is the default when languageCodes is '
    'omitted.',
  )
  final LanguageAuto? languageAuto;

  /// The list of BCP-47 language codes the transcription may contain.
  final List<String>? languageCodes;

  /// Hints to help the model select the transcription language.
  @Deprecated('Use languageCodes instead.')
  final LanguageHints? languageHints;

  /// Whether to include word-level timestamps in the transcription.
  final bool? wordTimestamp;

  /// How to process the transcript. Verbatim is the server default.
  final AudioTranscriptionConfigMode? mode;

  /// Text to edit by voice with a SMART-capable transcription model.
  final String? sourceText;

  /// Creates a [GenerationAudioTranscriptionConfig].
  const GenerationAudioTranscriptionConfig({
    @Deprecated('Use customVocabulary instead.') this.adaptationPhrases,
    this.customVocabulary,
    this.diarization,
    @Deprecated(
      'Automatic language detection is the default when languageCodes is '
      'omitted.',
    )
    this.languageAuto,
    this.languageCodes,
    @Deprecated('Use languageCodes instead.') this.languageHints,
    this.wordTimestamp,
    this.mode,
    this.sourceText,
  });

  /// Creates a [GenerationAudioTranscriptionConfig] from JSON.
  factory GenerationAudioTranscriptionConfig.fromJson(
    Map<String, dynamic> json,
  ) => GenerationAudioTranscriptionConfig(
    adaptationPhrases: (json['adaptationPhrases'] as List?)?.cast<String>(),
    customVocabulary: (json['customVocabulary'] as List?)?.cast<String>(),
    diarization: json['diarization'] as bool?,
    languageAuto: json['languageAuto'] != null
        ? LanguageAuto.fromJson(json['languageAuto'] as Map<String, dynamic>)
        : null,
    languageCodes: (json['languageCodes'] as List?)?.cast<String>(),
    languageHints: json['languageHints'] != null
        ? LanguageHints.fromJson(json['languageHints'] as Map<String, dynamic>)
        : null,
    wordTimestamp: json['wordTimestamp'] as bool?,
    mode: json['mode'] == null
        ? null
        : AudioTranscriptionConfigMode.fromJson(json['mode'] as String),
    sourceText: json['sourceText'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (adaptationPhrases != null) 'adaptationPhrases': adaptationPhrases,
    if (customVocabulary != null) 'customVocabulary': customVocabulary,
    if (diarization != null) 'diarization': diarization,
    if (languageAuto != null) 'languageAuto': languageAuto!.toJson(),
    if (languageCodes != null) 'languageCodes': languageCodes,
    if (languageHints != null) 'languageHints': languageHints!.toJson(),
    if (wordTimestamp != null) 'wordTimestamp': wordTimestamp,
    if (mode != null) 'mode': mode!.toJson(),
    if (sourceText != null) 'sourceText': sourceText,
  };

  /// Creates a copy with replaced values.
  GenerationAudioTranscriptionConfig copyWith({
    Object? adaptationPhrases = unsetCopyWithValue,
    Object? customVocabulary = unsetCopyWithValue,
    Object? diarization = unsetCopyWithValue,
    Object? languageAuto = unsetCopyWithValue,
    Object? languageCodes = unsetCopyWithValue,
    Object? languageHints = unsetCopyWithValue,
    Object? wordTimestamp = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? sourceText = unsetCopyWithValue,
  }) {
    return GenerationAudioTranscriptionConfig(
      adaptationPhrases: adaptationPhrases == unsetCopyWithValue
          ? this.adaptationPhrases
          : adaptationPhrases as List<String>?,
      customVocabulary: customVocabulary == unsetCopyWithValue
          ? this.customVocabulary
          : customVocabulary as List<String>?,
      diarization: diarization == unsetCopyWithValue
          ? this.diarization
          : diarization as bool?,
      languageAuto: languageAuto == unsetCopyWithValue
          ? this.languageAuto
          : languageAuto as LanguageAuto?,
      languageCodes: languageCodes == unsetCopyWithValue
          ? this.languageCodes
          : languageCodes as List<String>?,
      languageHints: languageHints == unsetCopyWithValue
          ? this.languageHints
          : languageHints as LanguageHints?,
      wordTimestamp: wordTimestamp == unsetCopyWithValue
          ? this.wordTimestamp
          : wordTimestamp as bool?,
      mode: mode == unsetCopyWithValue
          ? this.mode
          : mode as AudioTranscriptionConfigMode?,
      sourceText: sourceText == unsetCopyWithValue
          ? this.sourceText
          : sourceText as String?,
    );
  }

  @override
  String toString() =>
      'GenerationAudioTranscriptionConfig('
      'adaptationPhrases: $adaptationPhrases, '
      'customVocabulary: $customVocabulary, '
      'diarization: $diarization, '
      'languageAuto: $languageAuto, '
      'languageCodes: $languageCodes, '
      'languageHints: $languageHints, '
      'wordTimestamp: $wordTimestamp, mode: $mode, '
      'hasSourceText: ${sourceText != null})';
}

/// Hints to help the model select the transcription language.
///
/// Deprecated by the API in favor of
/// [GenerationAudioTranscriptionConfig.languageCodes]; kept for wire
/// compatibility.
class LanguageHints {
  /// The list of BCP-47 language codes to hint the transcription towards.
  final List<String> languageCodes;

  /// Creates a [LanguageHints].
  const LanguageHints({required this.languageCodes});

  /// Creates a [LanguageHints] from JSON.
  factory LanguageHints.fromJson(Map<String, dynamic> json) => LanguageHints(
    languageCodes: (json['languageCodes'] as List).cast<String>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'languageCodes': languageCodes};

  /// Creates a copy with replaced values.
  LanguageHints copyWith({List<String>? languageCodes}) {
    return LanguageHints(languageCodes: languageCodes ?? this.languageCodes);
  }

  @override
  String toString() => 'LanguageHints(languageCodes: $languageCodes)';
}

/// Deprecated marker schema: the model detects language automatically.
class LanguageAuto {
  /// Creates a [LanguageAuto].
  const LanguageAuto();

  /// Creates a [LanguageAuto] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory LanguageAuto.fromJson(Map<String, dynamic> json) =>
      const LanguageAuto();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => const {};

  @override
  String toString() => 'LanguageAuto()';
}
