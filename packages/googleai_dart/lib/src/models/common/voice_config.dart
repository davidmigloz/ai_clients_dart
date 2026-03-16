import '../copy_with_sentinel.dart';

/// Configuration for voice selection.
///
/// Specifies which voice to use for audio output.
class VoiceConfig {
  /// Configuration for prebuilt voices.
  final PrebuiltVoiceConfig? prebuiltVoiceConfig;

  /// Creates a [VoiceConfig].
  const VoiceConfig({this.prebuiltVoiceConfig});

  /// Creates a configuration using a prebuilt voice.
  factory VoiceConfig.prebuilt(String voiceName) {
    return VoiceConfig(
      prebuiltVoiceConfig: PrebuiltVoiceConfig(voiceName: voiceName),
    );
  }

  /// Creates from JSON.
  factory VoiceConfig.fromJson(Map<String, dynamic> json) {
    return VoiceConfig(
      prebuiltVoiceConfig: json['prebuiltVoiceConfig'] != null
          ? PrebuiltVoiceConfig.fromJson(
              json['prebuiltVoiceConfig'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (prebuiltVoiceConfig != null)
      'prebuiltVoiceConfig': prebuiltVoiceConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceConfig copyWith({Object? prebuiltVoiceConfig = unsetCopyWithValue}) {
    return VoiceConfig(
      prebuiltVoiceConfig: prebuiltVoiceConfig == unsetCopyWithValue
          ? this.prebuiltVoiceConfig
          : prebuiltVoiceConfig as PrebuiltVoiceConfig?,
    );
  }

  @override
  String toString() => 'VoiceConfig(prebuiltVoiceConfig: $prebuiltVoiceConfig)';
}

/// Configuration for prebuilt voices.
class PrebuiltVoiceConfig {
  /// Name of the prebuilt voice.
  ///
  /// Available voices: Puck, Charon, Kore, Fenrir, Aoede, Leda, Orus, Zephyr.
  final String? voiceName;

  /// Creates a [PrebuiltVoiceConfig].
  const PrebuiltVoiceConfig({this.voiceName});

  /// Creates from JSON.
  factory PrebuiltVoiceConfig.fromJson(Map<String, dynamic> json) {
    return PrebuiltVoiceConfig(voiceName: json['voiceName'] as String?);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (voiceName != null) 'voiceName': voiceName,
  };

  /// Creates a copy with the given fields replaced.
  PrebuiltVoiceConfig copyWith({Object? voiceName = unsetCopyWithValue}) {
    return PrebuiltVoiceConfig(
      voiceName: voiceName == unsetCopyWithValue
          ? this.voiceName
          : voiceName as String?,
    );
  }

  @override
  String toString() => 'PrebuiltVoiceConfig(voiceName: $voiceName)';
}

/// Configuration for multi-speaker voice output.
///
/// Allows configuring different voices for different speakers.
class MultiSpeakerVoiceConfig {
  /// Voice configurations for each speaker.
  final List<SpeakerVoiceConfig> speakerVoiceConfigs;

  /// Creates a [MultiSpeakerVoiceConfig].
  const MultiSpeakerVoiceConfig({this.speakerVoiceConfigs = const []});

  /// Creates from JSON.
  factory MultiSpeakerVoiceConfig.fromJson(Map<String, dynamic> json) {
    return MultiSpeakerVoiceConfig(
      speakerVoiceConfigs: json['speakerVoiceConfigs'] != null
          ? (json['speakerVoiceConfigs'] as List)
                .map(
                  (e) => SpeakerVoiceConfig.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : const [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (speakerVoiceConfigs.isNotEmpty)
      'speakerVoiceConfigs': speakerVoiceConfigs
          .map((e) => e.toJson())
          .toList(),
  };

  /// Creates a copy with the given fields replaced.
  MultiSpeakerVoiceConfig copyWith({
    List<SpeakerVoiceConfig>? speakerVoiceConfigs,
  }) {
    return MultiSpeakerVoiceConfig(
      speakerVoiceConfigs: speakerVoiceConfigs ?? this.speakerVoiceConfigs,
    );
  }

  @override
  String toString() =>
      'MultiSpeakerVoiceConfig(speakerVoiceConfigs: $speakerVoiceConfigs)';
}

/// Configuration for a single speaker's voice.
class SpeakerVoiceConfig {
  /// The speaker identifier.
  final String? speaker;

  /// The voice configuration for this speaker.
  final VoiceConfig? voiceConfig;

  /// Creates a [SpeakerVoiceConfig].
  const SpeakerVoiceConfig({this.speaker, this.voiceConfig});

  /// Creates from JSON.
  factory SpeakerVoiceConfig.fromJson(Map<String, dynamic> json) {
    return SpeakerVoiceConfig(
      speaker: json['speaker'] as String?,
      voiceConfig: json['voiceConfig'] != null
          ? VoiceConfig.fromJson(json['voiceConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (speaker != null) 'speaker': speaker,
    if (voiceConfig != null) 'voiceConfig': voiceConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  SpeakerVoiceConfig copyWith({
    Object? speaker = unsetCopyWithValue,
    Object? voiceConfig = unsetCopyWithValue,
  }) {
    return SpeakerVoiceConfig(
      speaker: speaker == unsetCopyWithValue
          ? this.speaker
          : speaker as String?,
      voiceConfig: voiceConfig == unsetCopyWithValue
          ? this.voiceConfig
          : voiceConfig as VoiceConfig?,
    );
  }

  @override
  String toString() =>
      'SpeakerVoiceConfig(speaker: $speaker, voiceConfig: $voiceConfig)';
}

/// Available prebuilt voices for Live API.
abstract class LiveVoices {
  LiveVoices._();

  /// Puck - A distinctive voice.
  static const String puck = 'Puck';

  /// Charon - A distinctive voice.
  static const String charon = 'Charon';

  /// Kore - A distinctive voice.
  static const String kore = 'Kore';

  /// Fenrir - A distinctive voice.
  static const String fenrir = 'Fenrir';

  /// Aoede - A distinctive voice.
  static const String aoede = 'Aoede';

  /// Leda - A distinctive voice.
  static const String leda = 'Leda';

  /// Orus - A distinctive voice.
  static const String orus = 'Orus';

  /// Zephyr - A distinctive voice.
  static const String zephyr = 'Zephyr';
}
