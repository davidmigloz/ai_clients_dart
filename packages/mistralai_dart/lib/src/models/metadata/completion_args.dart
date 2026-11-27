import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../tools/tool_choice.dart';
import 'prediction.dart';
import 'reasoning_effort.dart';
import 'response_format.dart';
import 'stop_sequence.dart';

/// Generation settings for the Agents and Conversations APIs.
@immutable
class CompletionArgs {
  /// Stop sequences for generated output.
  final StopSequence? stop;

  /// Penalty based on whether a token appeared.
  final double? presencePenalty;

  /// Penalty based on how often a token appeared.
  final double? frequencyPenalty;

  /// Sampling temperature.
  final double? temperature;

  /// Nucleus sampling probability.
  final double? topP;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Seed for reproducible sampling.
  final int? randomSeed;

  /// Legacy predicted output accepted by the API.
  final Prediction? prediction;

  /// Format to generate.
  final ResponseFormat? responseFormat;

  /// Tool choice mode: auto, none, any, or required.
  final ToolChoice? toolChoice;

  /// Reasoning effort on supported models.
  final ReasoningEffort? reasoningEffort;

  /// Creates generation settings.
  const CompletionArgs({
    this.stop,
    this.presencePenalty,
    this.frequencyPenalty,
    this.temperature,
    this.topP,
    this.maxTokens,
    this.randomSeed,
    this.prediction,
    this.responseFormat,
    this.toolChoice,
    this.reasoningEffort,
  });

  /// Reads generation settings from their wire representation.
  factory CompletionArgs.fromJson(Map<String, dynamic> json) => CompletionArgs(
    stop: json['stop'] == null
        ? null
        : StopSequence.fromJson(json['stop'] as Object),
    presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
    frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
    temperature: (json['temperature'] as num?)?.toDouble(),
    topP: (json['top_p'] as num?)?.toDouble(),
    maxTokens: json['max_tokens'] as int?,
    randomSeed: json['random_seed'] as int?,
    prediction: json['prediction'] == null
        ? null
        : Prediction.fromJson(json['prediction'] as Map<String, dynamic>),
    responseFormat: json['response_format'] == null
        ? null
        : ResponseFormat.fromJson(
            json['response_format'] as Map<String, dynamic>,
          ),
    toolChoice: json['tool_choice'] == null
        ? null
        : ToolChoice.fromJson(json['tool_choice'] as Object),
    reasoningEffort: ReasoningEffort.fromString(
      json['reasoning_effort'] as String?,
    ),
  );

  /// Converts to JSON. The API accepts only string tool choice modes here.
  Map<String, dynamic> toJson() {
    final choice = toolChoice?.toJson();
    if (choice != null && choice is! String) {
      throw ArgumentError.value(
        toolChoice,
        'toolChoice',
        'Expected a tool choice mode.',
      );
    }
    return {
      'stop': ?stop?.toJson(),
      'presence_penalty': ?presencePenalty,
      'frequency_penalty': ?frequencyPenalty,
      'temperature': ?temperature,
      'top_p': ?topP,
      'max_tokens': ?maxTokens,
      'random_seed': ?randomSeed,
      'prediction': ?prediction?.toJson(),
      'response_format': ?responseFormat?.toJson(),
      'tool_choice': ?choice,
      'reasoning_effort': ?reasoningEffort?.value,
    };
  }

  /// Creates a copy, with explicit null values clearing fields.
  CompletionArgs copyWith({
    Object? stop = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? randomSeed = unsetCopyWithValue,
    Object? prediction = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? reasoningEffort = unsetCopyWithValue,
  }) => CompletionArgs(
    stop: stop == unsetCopyWithValue ? this.stop : stop as StopSequence?,
    presencePenalty: presencePenalty == unsetCopyWithValue
        ? this.presencePenalty
        : (presencePenalty as num?)?.toDouble(),
    frequencyPenalty: frequencyPenalty == unsetCopyWithValue
        ? this.frequencyPenalty
        : (frequencyPenalty as num?)?.toDouble(),
    temperature: temperature == unsetCopyWithValue
        ? this.temperature
        : (temperature as num?)?.toDouble(),
    topP: topP == unsetCopyWithValue ? this.topP : (topP as num?)?.toDouble(),
    maxTokens: maxTokens == unsetCopyWithValue
        ? this.maxTokens
        : maxTokens as int?,
    randomSeed: randomSeed == unsetCopyWithValue
        ? this.randomSeed
        : randomSeed as int?,
    prediction: prediction == unsetCopyWithValue
        ? this.prediction
        : prediction as Prediction?,
    responseFormat: responseFormat == unsetCopyWithValue
        ? this.responseFormat
        : responseFormat as ResponseFormat?,
    toolChoice: toolChoice == unsetCopyWithValue
        ? this.toolChoice
        : toolChoice as ToolChoice?,
    reasoningEffort: reasoningEffort == unsetCopyWithValue
        ? this.reasoningEffort
        : reasoningEffort as ReasoningEffort?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionArgs &&
          stop == other.stop &&
          presencePenalty == other.presencePenalty &&
          frequencyPenalty == other.frequencyPenalty &&
          temperature == other.temperature &&
          topP == other.topP &&
          maxTokens == other.maxTokens &&
          randomSeed == other.randomSeed &&
          prediction == other.prediction &&
          responseFormat == other.responseFormat &&
          toolChoice == other.toolChoice &&
          reasoningEffort == other.reasoningEffort;

  @override
  int get hashCode => Object.hash(
    stop,
    presencePenalty,
    frequencyPenalty,
    temperature,
    topP,
    maxTokens,
    randomSeed,
    prediction,
    responseFormat,
    toolChoice,
    reasoningEffort,
  );

  @override
  String toString() =>
      'CompletionArgs(stop: $stop, presencePenalty: $presencePenalty, frequencyPenalty: $frequencyPenalty, temperature: $temperature, topP: $topP, maxTokens: $maxTokens, randomSeed: $randomSeed, prediction: $prediction, responseFormat: $responseFormat, toolChoice: $toolChoice, reasoningEffort: $reasoningEffort)';
}
