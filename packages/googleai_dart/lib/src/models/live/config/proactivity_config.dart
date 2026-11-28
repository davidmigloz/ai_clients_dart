import '../../copy_with_sentinel.dart';

/// Configuration for proactive Live responses.
///
/// Allows a supported model to generate audio without explicit prompts.
/// Omit this configuration for Vertex AI Gemini 3.8 Live, which enables
/// proactive audio by default.
class ProactivityConfig {
  /// Whether proactive audio is enabled.
  ///
  /// When enabled, the model may generate audio responses proactively.
  final bool? proactiveAudio;

  /// Whether images can trigger responses on a model that supports it.
  ///
  /// Requires [proactiveAudio] to be enabled.
  final bool? proactiveVideo;

  /// Creates a [ProactivityConfig].
  const ProactivityConfig({this.proactiveAudio, this.proactiveVideo});

  /// Creates a configuration with proactive audio enabled.
  factory ProactivityConfig.enabled() =>
      const ProactivityConfig(proactiveAudio: true);

  /// Creates a configuration with proactive audio disabled.
  factory ProactivityConfig.disabled() =>
      const ProactivityConfig(proactiveAudio: false);

  /// Creates from JSON.
  factory ProactivityConfig.fromJson(Map<String, dynamic> json) {
    return ProactivityConfig(
      proactiveAudio: json['proactiveAudio'] as bool?,
      proactiveVideo: json['proactiveVideo'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (proactiveAudio != null) 'proactiveAudio': proactiveAudio,
    if (proactiveVideo != null) 'proactiveVideo': proactiveVideo,
  };

  /// Creates a copy with the given fields replaced.
  ProactivityConfig copyWith({
    bool? proactiveAudio,
    Object? proactiveVideo = unsetCopyWithValue,
  }) {
    return ProactivityConfig(
      proactiveAudio: proactiveAudio ?? this.proactiveAudio,
      proactiveVideo: proactiveVideo == unsetCopyWithValue
          ? this.proactiveVideo
          : proactiveVideo as bool?,
    );
  }

  @override
  String toString() =>
      'ProactivityConfig(proactiveAudio: $proactiveAudio, '
      'proactiveVideo: $proactiveVideo)';
}
