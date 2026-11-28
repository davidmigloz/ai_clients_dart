import '../../common/speech_config.dart';
import '../../content/media_resolution.dart';
import '../../copy_with_sentinel.dart';
import '../../generation/response_modality.dart';
import '../../generation/thinking_config.dart';
import '../../generation/translation_config.dart';

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

  /// Default resolution for media input on supported models.
  final MediaResolutionLevel? mediaResolution;

  /// Seed used by models that support seeded generation.
  final int? seed;

  /// Reasoning settings for a model that supports thinking.
  final ThinkingConfig? thinkingConfig;

  /// Whether a supported model adapts its responses to the user's tone.
  ///
  /// Use with supported Gemini 2.5 Flash Live models. Omit for Vertex AI
  /// Gemini 3.8 Live, which enables affective dialogue by default.
  final bool? enableAffectiveDialog;

  /// Target language and echo settings on Live Translate models.
  final TranslationConfig? translationConfig;

  /// Creates a [LiveGenerationConfig].
  const LiveGenerationConfig({
    this.responseModalities,
    this.speechConfig,
    this.temperature,
    this.maxOutputTokens,
    this.topP,
    this.topK,
    this.mediaResolution,
    this.seed,
    this.thinkingConfig,
    this.enableAffectiveDialog,
    this.translationConfig,
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
    final mediaResolution = json['mediaResolution'] as String?;
    final thinking = json['thinkingConfig'] as Map<String, dynamic>?;
    final translation = json['translationConfig'] as Map<String, dynamic>?;
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
      topK: switch (json['topK']) {
        null => null,
        final int value => value,
        final num value when value.isFinite && value == value.toInt() =>
          value.toInt(),
        _ => throw const FormatException('Expected an integer for Live topK.'),
      },
      mediaResolution: mediaResolution == null
          ? null
          : mediaResolutionLevelFromString(mediaResolution),
      seed: json['seed'] as int?,
      thinkingConfig: thinking == null
          ? null
          : ThinkingConfig.fromJson(thinking),
      enableAffectiveDialog: json['enableAffectiveDialog'] as bool?,
      translationConfig: translation == null
          ? null
          : TranslationConfig.fromJson({
              ...translation,
              'targetLanguageCode': translation['targetLanguageCode'] ?? 'en',
            }),
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
    if (mediaResolution != null)
      'mediaResolution': mediaResolutionLevelToString(mediaResolution!),
    if (seed != null) 'seed': seed,
    if (thinkingConfig != null) 'thinkingConfig': thinkingConfig!.toJson(),
    if (enableAffectiveDialog != null)
      'enableAffectiveDialog': enableAffectiveDialog,
    if (translationConfig != null)
      'translationConfig': translationConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  LiveGenerationConfig copyWith({
    Object? responseModalities = unsetCopyWithValue,
    Object? speechConfig = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
    Object? mediaResolution = unsetCopyWithValue,
    Object? seed = unsetCopyWithValue,
    Object? thinkingConfig = unsetCopyWithValue,
    Object? enableAffectiveDialog = unsetCopyWithValue,
    Object? translationConfig = unsetCopyWithValue,
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
      mediaResolution: mediaResolution == unsetCopyWithValue
          ? this.mediaResolution
          : mediaResolution as MediaResolutionLevel?,
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
      thinkingConfig: thinkingConfig == unsetCopyWithValue
          ? this.thinkingConfig
          : thinkingConfig as ThinkingConfig?,
      enableAffectiveDialog: enableAffectiveDialog == unsetCopyWithValue
          ? this.enableAffectiveDialog
          : enableAffectiveDialog as bool?,
      translationConfig: translationConfig == unsetCopyWithValue
          ? this.translationConfig
          : translationConfig as TranslationConfig?,
    );
  }

  @override
  String toString() =>
      'LiveGenerationConfig(responseModalities: $responseModalities, '
      'temperature: $temperature, mediaResolution: $mediaResolution, '
      'seed: $seed, thinkingConfig: $thinkingConfig, '
      'enableAffectiveDialog: $enableAffectiveDialog, '
      'translationConfig: $translationConfig)';
}
