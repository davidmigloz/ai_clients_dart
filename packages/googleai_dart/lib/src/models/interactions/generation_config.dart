import '../copy_with_sentinel.dart';
import 'image_config.dart';
import 'speech_config.dart';
import 'structured_speech_config.dart';
import 'thinking_level.dart';
import 'thinking_summaries.dart';
import 'tool_choice.dart';
import 'transcription_config.dart';
import 'video_config.dart';

/// Configuration parameters for model interactions.
class InteractionGenerationConfig {
  /// Seed used in decoding for reproducibility.
  final int? seed;

  /// Randomness of generation on supported models.
  ///
  /// The upstream schema marks this option deprecated.
  final double? temperature;

  /// Nucleus sampling threshold on supported models.
  ///
  /// The upstream schema marks this option deprecated.
  final double? topP;

  /// A list of character sequences that will stop output interaction.
  final List<String>? stopSequences;

  /// The tool choice for the interaction.
  final InteractionToolChoice? toolChoice;

  /// The level of thought tokens that the model should generate.
  final InteractionThinkingLevel? thinkingLevel;

  /// Whether to include thought summaries in the response.
  final InteractionThinkingSummaries? thinkingSummaries;

  /// The maximum number of tokens to include in the response.
  final int? maxOutputTokens;

  /// Array-form speech settings under the existing beta wire field.
  final List<InteractionSpeechConfig>? speechConfig;

  /// Object-form settings under the existing beta `speech_config` field.
  ///
  /// When supplied, this replaces the array form [speechConfig] in JSON.
  final InteractionSpeakerConfig? speechConfigObject;

  /// Speaker configuration and text normalization for speech generation.
  final InteractionStructuredSpeechConfig? structuredSpeechConfig;

  /// Configuration for image interaction.
  final InteractionImageConfig? imageConfig;

  /// Configuration for video generation.
  final InteractionVideoConfig? videoConfig;

  /// Configuration for speech recognition (transcription).
  final TranscriptionConfig? transcriptionConfig;

  /// Creates an [InteractionGenerationConfig] instance.
  const InteractionGenerationConfig({
    this.seed,
    this.temperature,
    this.topP,
    this.structuredSpeechConfig,
    this.stopSequences,
    this.toolChoice,
    this.thinkingLevel,
    this.thinkingSummaries,
    this.maxOutputTokens,
    this.speechConfig,
    this.speechConfigObject,
    this.imageConfig,
    this.videoConfig,
    this.transcriptionConfig,
  });

  /// Creates an [InteractionGenerationConfig] from JSON.
  factory InteractionGenerationConfig.fromJson(
    Map<String, dynamic> json,
  ) => InteractionGenerationConfig(
    seed: json['seed'] as int?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    topP: (json['top_p'] as num?)?.toDouble(),
    structuredSpeechConfig: json['structured_speech_config'] == null
        ? null
        : InteractionStructuredSpeechConfig.fromJson(
            json['structured_speech_config'] as Object,
          ),
    stopSequences: (json['stop_sequences'] as List<dynamic>?)?.cast<String>(),
    toolChoice: json['tool_choice'] != null
        ? InteractionToolChoice.fromJson(json['tool_choice'])
        : null,
    thinkingLevel: json['thinking_level'] != null
        ? interactionThinkingLevelFromString(json['thinking_level'] as String?)
        : null,
    thinkingSummaries: json['thinking_summaries'] != null
        ? interactionThinkingSummariesFromString(
            json['thinking_summaries'] as String?,
          )
        : null,
    maxOutputTokens: json['max_output_tokens'] as int?,
    speechConfig: switch (json['speech_config']) {
      final List<dynamic> entries => [
        for (final entry in entries)
          InteractionSpeechConfig.fromJson(entry as Map<String, dynamic>),
      ],
      _ => null,
    },
    speechConfigObject: switch (json['speech_config']) {
      final Map<String, dynamic> object => InteractionSpeakerConfig.fromJson(
        object,
      ),
      _ => null,
    },
    imageConfig: json['image_config'] != null
        ? InteractionImageConfig.fromJson(
            json['image_config'] as Map<String, dynamic>,
          )
        : null,
    videoConfig: json['video_config'] != null
        ? InteractionVideoConfig.fromJson(
            json['video_config'] as Map<String, dynamic>,
          )
        : null,
    transcriptionConfig: json['transcription_config'] != null
        ? TranscriptionConfig.fromJson(
            json['transcription_config'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (seed != null) 'seed': seed,
    'temperature': ?temperature,
    'top_p': ?topP,
    'structured_speech_config': ?structuredSpeechConfig?.toJson(),
    if (stopSequences != null) 'stop_sequences': stopSequences,
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (thinkingLevel != null)
      'thinking_level': interactionThinkingLevelToString(thinkingLevel!),
    if (thinkingSummaries != null)
      'thinking_summaries': interactionThinkingSummariesToString(
        thinkingSummaries!,
      ),
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
    if (speechConfigObject != null)
      'speech_config': speechConfigObject!.toJson()
    else if (speechConfig != null)
      'speech_config': speechConfig!.map((e) => e.toJson()).toList(),
    if (imageConfig != null) 'image_config': imageConfig!.toJson(),
    if (videoConfig != null) 'video_config': videoConfig!.toJson(),
    if (transcriptionConfig != null)
      'transcription_config': transcriptionConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  InteractionGenerationConfig copyWith({
    Object? seed = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? structuredSpeechConfig = unsetCopyWithValue,
    Object? stopSequences = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? thinkingLevel = unsetCopyWithValue,
    Object? thinkingSummaries = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? speechConfig = unsetCopyWithValue,
    Object? speechConfigObject = unsetCopyWithValue,
    Object? imageConfig = unsetCopyWithValue,
    Object? videoConfig = unsetCopyWithValue,
    Object? transcriptionConfig = unsetCopyWithValue,
  }) {
    return InteractionGenerationConfig(
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : (temperature as num?)?.toDouble(),
      topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
      structuredSpeechConfig: structuredSpeechConfig == unsetCopyWithValue
          ? this.structuredSpeechConfig
          : structuredSpeechConfig as InteractionStructuredSpeechConfig?,
      stopSequences: stopSequences == unsetCopyWithValue
          ? this.stopSequences
          : stopSequences as List<String>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as InteractionToolChoice?,
      thinkingLevel: thinkingLevel == unsetCopyWithValue
          ? this.thinkingLevel
          : thinkingLevel as InteractionThinkingLevel?,
      thinkingSummaries: thinkingSummaries == unsetCopyWithValue
          ? this.thinkingSummaries
          : thinkingSummaries as InteractionThinkingSummaries?,
      maxOutputTokens: maxOutputTokens == unsetCopyWithValue
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      speechConfig: speechConfig == unsetCopyWithValue
          ? this.speechConfig
          : speechConfig as List<InteractionSpeechConfig>?,
      speechConfigObject: speechConfigObject == unsetCopyWithValue
          ? this.speechConfigObject
          : speechConfigObject as InteractionSpeakerConfig?,
      imageConfig: imageConfig == unsetCopyWithValue
          ? this.imageConfig
          : imageConfig as InteractionImageConfig?,
      videoConfig: videoConfig == unsetCopyWithValue
          ? this.videoConfig
          : videoConfig as InteractionVideoConfig?,
      transcriptionConfig: transcriptionConfig == unsetCopyWithValue
          ? this.transcriptionConfig
          : transcriptionConfig as TranscriptionConfig?,
    );
  }
}
