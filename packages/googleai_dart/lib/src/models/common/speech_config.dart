import '../copy_with_sentinel.dart';
import 'voice_config.dart';

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

  /// Creates a [SpeechConfig].
  const SpeechConfig({
    this.voiceConfig,
    this.languageCode,
    this.multiSpeakerVoiceConfig,
  });

  /// Creates a configuration with a prebuilt voice.
  factory SpeechConfig.withVoice(String voiceName, {String? languageCode}) {
    return SpeechConfig(
      voiceConfig: VoiceConfig.prebuilt(voiceName),
      languageCode: languageCode,
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
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (voiceConfig != null) 'voiceConfig': voiceConfig!.toJson(),
    if (languageCode != null) 'languageCode': languageCode,
    if (multiSpeakerVoiceConfig != null)
      'multiSpeakerVoiceConfig': multiSpeakerVoiceConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  SpeechConfig copyWith({
    Object? voiceConfig = unsetCopyWithValue,
    Object? languageCode = unsetCopyWithValue,
    Object? multiSpeakerVoiceConfig = unsetCopyWithValue,
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
    );
  }

  @override
  String toString() =>
      'SpeechConfig(voiceConfig: $voiceConfig, languageCode: $languageCode, '
      'multiSpeakerVoiceConfig: $multiSpeakerVoiceConfig)';
}
