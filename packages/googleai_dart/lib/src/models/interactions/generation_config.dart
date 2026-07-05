import '../copy_with_sentinel.dart';
import 'image_config.dart';
import 'speech_config.dart';
import 'thinking_level.dart';
import 'thinking_summaries.dart';
import 'tool_choice.dart';

/// Configuration parameters for model interactions.
class InteractionGenerationConfig {
  /// Controls the randomness of the output.
  final double? temperature;

  /// The maximum cumulative probability of tokens to consider when sampling.
  final double? topP;

  /// Penalizes tokens based on their frequency in the generated text.
  ///
  /// A positive value helps to reduce the repetition of words and phrases.
  /// Valid values range from [-2.0, 2.0].
  final double? frequencyPenalty;

  /// Penalizes tokens that have already appeared in the generated text.
  ///
  /// A positive value encourages the model to generate more diverse and less
  /// repetitive text. Valid values range from [-2.0, 2.0].
  final double? presencePenalty;

  /// Seed used in decoding for reproducibility.
  final int? seed;

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

  /// Configuration for speech interaction.
  final List<InteractionSpeechConfig>? speechConfig;

  /// Configuration for image interaction.
  final InteractionImageConfig? imageConfig;

  /// Creates an [InteractionGenerationConfig] instance.
  const InteractionGenerationConfig({
    this.temperature,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.seed,
    this.stopSequences,
    this.toolChoice,
    this.thinkingLevel,
    this.thinkingSummaries,
    this.maxOutputTokens,
    this.speechConfig,
    this.imageConfig,
  });

  /// Creates an [InteractionGenerationConfig] from JSON.
  factory InteractionGenerationConfig.fromJson(
    Map<String, dynamic> json,
  ) => InteractionGenerationConfig(
    temperature: (json['temperature'] as num?)?.toDouble(),
    topP: (json['top_p'] as num?)?.toDouble(),
    frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
    presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
    seed: json['seed'] as int?,
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
    speechConfig: (json['speech_config'] as List<dynamic>?)
        ?.map(
          (e) => InteractionSpeechConfig.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
    imageConfig: json['image_config'] != null
        ? InteractionImageConfig.fromJson(
            json['image_config'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (seed != null) 'seed': seed,
    if (stopSequences != null) 'stop_sequences': stopSequences,
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (thinkingLevel != null)
      'thinking_level': interactionThinkingLevelToString(thinkingLevel!),
    if (thinkingSummaries != null)
      'thinking_summaries': interactionThinkingSummariesToString(
        thinkingSummaries!,
      ),
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
    if (speechConfig != null)
      'speech_config': speechConfig!.map((e) => e.toJson()).toList(),
    if (imageConfig != null) 'image_config': imageConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  InteractionGenerationConfig copyWith({
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? seed = unsetCopyWithValue,
    Object? stopSequences = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? thinkingLevel = unsetCopyWithValue,
    Object? thinkingSummaries = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? speechConfig = unsetCopyWithValue,
    Object? imageConfig = unsetCopyWithValue,
  }) {
    return InteractionGenerationConfig(
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
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
      imageConfig: imageConfig == unsetCopyWithValue
          ? this.imageConfig
          : imageConfig as InteractionImageConfig?,
    );
  }
}
