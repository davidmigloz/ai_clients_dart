import '../../copy_with_sentinel.dart';
import '../../generation/audio_transcription_config.dart';
import '../../generation/audio_transcription_mode.dart';

export '../../generation/audio_transcription_mode.dart';

/// Configuration for audio transcription.
///
/// Enable transcription for input (user speech) or output (model speech).
class AudioTranscriptionConfig {
  /// Dart-side toggle for including this configuration in Live setup.
  ///
  /// A non-null configuration enables transcription unless this is false.
  /// Live setup identifies enabled transcription by the presence of the
  /// configuration object.
  final bool? enabled;

  /// BCP-47 language hints. Omit or pass an empty list for auto-detection.
  final List<String>? languageCodes;

  /// Recognition bias for terms such as names and acronyms.
  final List<String>? customVocabulary;

  /// Whether to request word-level timestamps on models that support them.
  ///
  /// Gemini Live Transcribe supports utterance-level timestamps.
  final bool? wordTimestamp;

  /// Whether to request speaker diarization on models that support it.
  ///
  /// Gemini Live Transcribe does not support speaker diarization.
  final bool? diarization;

  /// How to process the transcript. The API defaults to verbatim mode.
  final AudioTranscriptionConfigMode? mode;

  /// Initial text to edit by voice in smart input transcription mode.
  final String? sourceText;

  /// Legacy automatic language detection marker from the Google Gen AI SDKs.
  @Deprecated('Omit languageCodes to use automatic language detection.')
  final LanguageAuto? languageAuto;

  /// Legacy nested language hints from the Google Gen AI SDKs.
  @Deprecated('Use languageCodes instead.')
  final LanguageHints? languageHints;

  /// Legacy speech adaptation phrases from the Google Gen AI SDKs.
  @Deprecated('Use customVocabulary instead.')
  final List<String>? adaptationPhrases;

  /// Creates an [AudioTranscriptionConfig].
  const AudioTranscriptionConfig({
    this.enabled,
    this.languageCodes,
    this.customVocabulary,
    this.wordTimestamp,
    this.diarization,
    this.mode,
    this.sourceText,
    @Deprecated('Omit languageCodes to use automatic language detection.')
    this.languageAuto,
    @Deprecated('Use languageCodes instead.') this.languageHints,
    @Deprecated('Use customVocabulary instead.') this.adaptationPhrases,
  });

  /// Creates a configuration with transcription enabled.
  factory AudioTranscriptionConfig.enabled() =>
      const AudioTranscriptionConfig(enabled: true);

  /// Creates a configuration with transcription disabled.
  factory AudioTranscriptionConfig.disabled() =>
      const AudioTranscriptionConfig(enabled: false);

  /// Creates from JSON.
  factory AudioTranscriptionConfig.fromJson(Map<String, dynamic> json) {
    final languageAuto = json['languageAuto'] as Map<String, dynamic>?;
    final languageHints = json['languageHints'] as Map<String, dynamic>?;
    final mode = json['mode'] as String?;
    return AudioTranscriptionConfig(
      enabled: json['enabled'] as bool?,
      languageCodes: (json['languageCodes'] as List?)?.cast<String>(),
      customVocabulary: (json['customVocabulary'] as List?)?.cast<String>(),
      wordTimestamp: json['wordTimestamp'] as bool?,
      diarization: json['diarization'] as bool?,
      mode: mode == null ? null : AudioTranscriptionConfigMode.fromJson(mode),
      sourceText: json['sourceText'] as String?,
      languageAuto: languageAuto == null
          ? null
          : LanguageAuto.fromJson(languageAuto),
      languageHints: languageHints == null
          ? null
          : LanguageHints(
              languageCodes:
                  (languageHints['languageCodes'] as List?)?.cast<String>() ??
                  const [],
            ),
      adaptationPhrases: (json['adaptationPhrases'] as List?)?.cast<String>(),
    );
  }

  /// Converts to JSON for use by Dart callers and persisted configurations.
  ///
  /// When sending Live setup, the client omits the Dart-side [enabled] toggle.
  Map<String, dynamic> toJson() => {
    if (enabled != null) 'enabled': enabled,
    if (languageCodes != null) 'languageCodes': languageCodes,
    if (customVocabulary != null) 'customVocabulary': customVocabulary,
    if (wordTimestamp != null) 'wordTimestamp': wordTimestamp,
    if (diarization != null) 'diarization': diarization,
    if (mode != null) 'mode': mode!.toJson(),
    if (sourceText != null) 'sourceText': sourceText,
    if (languageAuto != null) 'languageAuto': languageAuto!.toJson(),
    if (languageHints != null) 'languageHints': languageHints!.toJson(),
    if (adaptationPhrases != null) 'adaptationPhrases': adaptationPhrases,
  };

  /// Creates a copy with the given fields replaced.
  AudioTranscriptionConfig copyWith({
    bool? enabled,
    Object? languageCodes = unsetCopyWithValue,
    Object? customVocabulary = unsetCopyWithValue,
    Object? wordTimestamp = unsetCopyWithValue,
    Object? diarization = unsetCopyWithValue,
    Object? mode = unsetCopyWithValue,
    Object? sourceText = unsetCopyWithValue,
    Object? languageAuto = unsetCopyWithValue,
    Object? languageHints = unsetCopyWithValue,
    Object? adaptationPhrases = unsetCopyWithValue,
  }) {
    return AudioTranscriptionConfig(
      enabled: enabled ?? this.enabled,
      languageCodes: languageCodes == unsetCopyWithValue
          ? this.languageCodes
          : languageCodes as List<String>?,
      customVocabulary: customVocabulary == unsetCopyWithValue
          ? this.customVocabulary
          : customVocabulary as List<String>?,
      wordTimestamp: wordTimestamp == unsetCopyWithValue
          ? this.wordTimestamp
          : wordTimestamp as bool?,
      diarization: diarization == unsetCopyWithValue
          ? this.diarization
          : diarization as bool?,
      mode: mode == unsetCopyWithValue
          ? this.mode
          : mode as AudioTranscriptionConfigMode?,
      sourceText: sourceText == unsetCopyWithValue
          ? this.sourceText
          : sourceText as String?,
      languageAuto: languageAuto == unsetCopyWithValue
          ? this.languageAuto
          : languageAuto as LanguageAuto?,
      languageHints: languageHints == unsetCopyWithValue
          ? this.languageHints
          : languageHints as LanguageHints?,
      adaptationPhrases: adaptationPhrases == unsetCopyWithValue
          ? this.adaptationPhrases
          : adaptationPhrases as List<String>?,
    );
  }

  @override
  String toString() =>
      'AudioTranscriptionConfig(enabled: $enabled, languageCodes: $languageCodes, '
      'customVocabulary: $customVocabulary, wordTimestamp: $wordTimestamp, '
      'diarization: $diarization, mode: $mode, sourceText: '
      '${sourceText == null ? null : '[${sourceText!.length} chars]'}, '
      'languageAuto: $languageAuto, languageHints: $languageHints, '
      'adaptationPhrases: $adaptationPhrases)';
}
