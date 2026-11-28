import '../copy_with_sentinel.dart';
import 'voice_config.dart';

/// Text normalization before speech synthesis on supported v1beta models.
extension type const SpeechTextNormalization(String value) {
  /// Uses the service default.
  static const unspecified = SpeechTextNormalization(
    'TEXT_NORMALIZATION_UNSPECIFIED',
  );

  /// Lets the model decide whether to normalize the text.
  static const auto = SpeechTextNormalization('AUTO');

  /// Normalizes numbers, dates, currencies, and units.
  static const enabled = SpeechTextNormalization('ENABLED');

  /// Preserves pre-normalized text and phonetic spellings.
  static const disabled = SpeechTextNormalization('DISABLED');
}

/// Configuration for speech synthesis.
///
/// Controls voice selection and language for audio output.
class SpeechConfig {
  /// Voice configuration.
  final VoiceConfig? voiceConfig;

  /// Language code for speech synthesis (e.g., "en-US").
  final String? languageCode;

  /// Multi-speaker voice configuration.
  ///
  /// Allows configuring different voices for different speakers.
  final MultiSpeakerVoiceConfig? multiSpeakerVoiceConfig;

  /// Text normalization on supported Gemini Developer API v1beta TTS models.
  final SpeechTextNormalization? textNormalization;

  /// Creates a [SpeechConfig].
  const SpeechConfig({
    this.voiceConfig,
    this.languageCode,
    this.multiSpeakerVoiceConfig,
    this.textNormalization,
  });

  /// Creates a configuration with a prebuilt voice.
  factory SpeechConfig.withVoice(
    String voiceName, {
    String? languageCode,
    SpeechTextNormalization? textNormalization,
  }) {
    return SpeechConfig(
      voiceConfig: VoiceConfig.prebuilt(voiceName),
      languageCode: languageCode,
      textNormalization: textNormalization,
    );
  }

  /// Creates from JSON.
  factory SpeechConfig.fromJson(Map<String, dynamic> json) {
    return SpeechConfig(
      voiceConfig: json['voiceConfig'] != null
          ? VoiceConfig.fromJson(json['voiceConfig'] as Map<String, dynamic>)
          : null,
      languageCode: json['languageCode'] as String?,
      multiSpeakerVoiceConfig: json['multiSpeakerVoiceConfig'] != null
          ? MultiSpeakerVoiceConfig.fromJson(
              json['multiSpeakerVoiceConfig'] as Map<String, dynamic>,
            )
          : null,
      textNormalization: switch (json['textNormalization']) {
        final String value => SpeechTextNormalization(value),
        _ => null,
      },
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (voiceConfig != null) 'voiceConfig': voiceConfig!.toJson(),
    if (languageCode != null) 'languageCode': languageCode,
    if (multiSpeakerVoiceConfig != null)
      'multiSpeakerVoiceConfig': multiSpeakerVoiceConfig!.toJson(),
    'textNormalization': ?textNormalization?.value,
  };

  /// Creates a copy with the given fields replaced.
  SpeechConfig copyWith({
    Object? voiceConfig = unsetCopyWithValue,
    Object? languageCode = unsetCopyWithValue,
    Object? multiSpeakerVoiceConfig = unsetCopyWithValue,
    Object? textNormalization = unsetCopyWithValue,
  }) {
    return SpeechConfig(
      voiceConfig: voiceConfig == unsetCopyWithValue
          ? this.voiceConfig
          : voiceConfig as VoiceConfig?,
      languageCode: languageCode == unsetCopyWithValue
          ? this.languageCode
          : languageCode as String?,
      multiSpeakerVoiceConfig: multiSpeakerVoiceConfig == unsetCopyWithValue
          ? this.multiSpeakerVoiceConfig
          : multiSpeakerVoiceConfig as MultiSpeakerVoiceConfig?,
      textNormalization: textNormalization == unsetCopyWithValue
          ? this.textNormalization
          : textNormalization as SpeechTextNormalization?,
    );
  }

  @override
  String toString() =>
      'SpeechConfig(voiceConfig: $voiceConfig, languageCode: $languageCode, '
      'multiSpeakerVoiceConfig: $multiSpeakerVoiceConfig, '
      'textNormalization: $textNormalization)';
}
