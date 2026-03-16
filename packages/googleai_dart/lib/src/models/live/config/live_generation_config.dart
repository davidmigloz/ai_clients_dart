import '../../common/speech_config.dart';
import '../../copy_with_sentinel.dart';
import '../../generation/response_modality.dart';

/// Generation configuration for Live API sessions.
///
/// Controls response modalities, temperature, and other generation settings.
class LiveGenerationConfig {
  /// Response modalities.
  ///
  /// Specifies what types of content the model should generate.
  final List<ResponseModality>? responseModalities;

  /// Speech configuration for audio output.
  final SpeechConfig? speechConfig;

  /// Temperature for generation (0.0 to 2.0).
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  /// Maximum number of output tokens.
  final int? maxOutputTokens;

  /// Top-p sampling parameter (0.0 to 1.0).
  final double? topP;

  /// Top-k sampling parameter.
  final int? topK;

  /// Creates a [LiveGenerationConfig].
  const LiveGenerationConfig({
    this.responseModalities,
    this.speechConfig,
    this.temperature,
    this.maxOutputTokens,
    this.topP,
    this.topK,
  });

  /// Creates an audio-only configuration.
  factory LiveGenerationConfig.audioOnly({
    SpeechConfig? speechConfig,
    double? temperature,
    int? maxOutputTokens,
  }) {
    return LiveGenerationConfig(
      responseModalities: const [ResponseModality.audio],
      speechConfig: speechConfig,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
  }

  /// Creates a text-only configuration.
  factory LiveGenerationConfig.textOnly({
    double? temperature,
    int? maxOutputTokens,
  }) {
    return LiveGenerationConfig(
      responseModalities: const [ResponseModality.text],
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
  }

  /// Creates a configuration with both audio and text output.
  factory LiveGenerationConfig.textAndAudio({
    SpeechConfig? speechConfig,
    double? temperature,
    int? maxOutputTokens,
  }) {
    return LiveGenerationConfig(
      responseModalities: const [ResponseModality.audio, ResponseModality.text],
      speechConfig: speechConfig,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
  }

  /// Creates from JSON.
  factory LiveGenerationConfig.fromJson(Map<String, dynamic> json) {
    return LiveGenerationConfig(
      responseModalities: (json['responseModalities'] as List?)
          ?.map((e) => responseModalityFromString(e as String))
          .toList(),
      speechConfig: json['speechConfig'] != null
          ? SpeechConfig.fromJson(json['speechConfig'] as Map<String, dynamic>)
          : null,
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : null,
      maxOutputTokens: json['maxOutputTokens'] as int?,
      topP: json['topP'] != null ? (json['topP'] as num).toDouble() : null,
      topK: json['topK'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (responseModalities != null)
      'responseModalities': responseModalities!
          .map(responseModalityToString)
          .toList(),
    if (speechConfig != null) 'speechConfig': speechConfig!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (maxOutputTokens != null) 'maxOutputTokens': maxOutputTokens,
    if (topP != null) 'topP': topP,
    if (topK != null) 'topK': topK,
  };

  /// Creates a copy with the given fields replaced.
  LiveGenerationConfig copyWith({
    Object? responseModalities = unsetCopyWithValue,
    Object? speechConfig = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
  }) {
    return LiveGenerationConfig(
      responseModalities: responseModalities == unsetCopyWithValue
          ? this.responseModalities
          : responseModalities as List<ResponseModality>?,
      speechConfig: speechConfig == unsetCopyWithValue
          ? this.speechConfig
          : speechConfig as SpeechConfig?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      maxOutputTokens: maxOutputTokens == unsetCopyWithValue
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
    );
  }

  @override
  String toString() =>
      'LiveGenerationConfig(responseModalities: $responseModalities, '
      'temperature: $temperature)';
}
