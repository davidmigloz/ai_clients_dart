import '../copy_with_sentinel.dart';

/// Configuration for speech recognition (transcription).
class TranscriptionConfig {
  /// A list of phrases to bias the ASR model towards.
  @Deprecated('Use customVocabulary instead.')
  final List<String>? adaptationPhrases;

  /// A list of custom vocabulary phrases to bias the speech recognition
  /// model toward recognizing specific terms.
  final List<String>? customVocabulary;

  /// Configures speaker diarization. Supported value: `"speaker"`.
  final String? diarizationMode;

  /// BCP-47 language codes providing hints about the languages present in
  /// the audio.
  ///
  /// If omitted or empty, defaults to automatic language detection.
  final List<String>? languageCodes;

  /// The granularity of timestamps to include in the transcription output.
  ///
  /// Supported value: `"word"`. If empty, no timestamps are generated.
  final List<String>? timestampGranularities;

  /// Creates a [TranscriptionConfig] instance.
  const TranscriptionConfig({
    @Deprecated('Use customVocabulary instead.') this.adaptationPhrases,
    this.customVocabulary,
    this.diarizationMode,
    this.languageCodes,
    this.timestampGranularities,
  });

  /// Creates a [TranscriptionConfig] from JSON.
  factory TranscriptionConfig.fromJson(Map<String, dynamic> json) =>
      TranscriptionConfig(
        adaptationPhrases: (json['adaptation_phrases'] as List?)
            ?.cast<String>(),
        customVocabulary: (json['custom_vocabulary'] as List?)?.cast<String>(),
        diarizationMode: json['diarization_mode'] as String?,
        languageCodes: (json['language_codes'] as List?)?.cast<String>(),
        timestampGranularities: (json['timestamp_granularities'] as List?)
            ?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    // ignore: deprecated_member_use_from_same_package
    if (adaptationPhrases != null) 'adaptation_phrases': adaptationPhrases,
    if (customVocabulary != null) 'custom_vocabulary': customVocabulary,
    if (diarizationMode != null) 'diarization_mode': diarizationMode,
    if (languageCodes != null) 'language_codes': languageCodes,
    if (timestampGranularities != null)
      'timestamp_granularities': timestampGranularities,
  };

  /// Creates a copy with replaced values.
  TranscriptionConfig copyWith({
    Object? adaptationPhrases = unsetCopyWithValue,
    Object? customVocabulary = unsetCopyWithValue,
    Object? diarizationMode = unsetCopyWithValue,
    Object? languageCodes = unsetCopyWithValue,
    Object? timestampGranularities = unsetCopyWithValue,
  }) {
    return TranscriptionConfig(
      // ignore: deprecated_member_use_from_same_package
      adaptationPhrases: adaptationPhrases == unsetCopyWithValue
          // ignore: deprecated_member_use_from_same_package
          ? this.adaptationPhrases
          : adaptationPhrases as List<String>?,
      customVocabulary: customVocabulary == unsetCopyWithValue
          ? this.customVocabulary
          : customVocabulary as List<String>?,
      diarizationMode: diarizationMode == unsetCopyWithValue
          ? this.diarizationMode
          : diarizationMode as String?,
      languageCodes: languageCodes == unsetCopyWithValue
          ? this.languageCodes
          : languageCodes as List<String>?,
      timestampGranularities: timestampGranularities == unsetCopyWithValue
          ? this.timestampGranularities
          : timestampGranularities as List<String>?,
    );
  }
}
