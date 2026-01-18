import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../items/item.dart';
import '../metadata/include.dart';
import '../metadata/service_tier.dart';
import '../metadata/truncation.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'reasoning_config.dart';
import 'stream_options.dart';
import 'text_config.dart';

/// Request to create a response.
@immutable
class CreateResponseRequest {
  /// The model to use for generation.
  final String model;

  /// The input for the response.
  ///
  /// Can be a `String` (for simple text) or `List<Item>` (for complex messages).
  final Object input;

  /// System-level instructions for the model.
  final String? instructions;

  /// Tools available to the model.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  final ToolChoice? toolChoice;

  /// ID of a previous response for multi-turn conversation.
  final String? previousResponseId;

  /// Maximum tokens to generate.
  final int? maxOutputTokens;

  /// Sampling temperature (0.0 - 2.0).
  final double? temperature;

  /// Top-p sampling parameter.
  final double? topP;

  /// Penalizes new tokens based on whether they appear in the text so far.
  final double? presencePenalty;

  /// Penalizes new tokens based on their frequency in the text so far.
  final double? frequencyPenalty;

  /// Whether to stream the response.
  final bool? stream;

  /// Options that control streamed response behavior.
  final StreamOptions? streamOptions;

  /// Configuration for reasoning models.
  final ReasoningConfig? reasoning;

  /// Configuration for text output.
  final TextConfig? text;

  /// Truncation strategy for long inputs.
  final Truncation? truncation;

  /// Whether the model may call multiple tools in parallel.
  final bool? parallelToolCalls;

  /// Service tier for request processing.
  final ServiceTier? serviceTier;

  /// User-defined metadata.
  final Map<String, String>? metadata;

  /// Additional data to include in response.
  final List<Include>? include;

  /// Whether to store the response for later retrieval.
  final bool? store;

  /// Whether to run the request in the background and return immediately.
  final bool? background;

  /// The maximum number of tool calls the model may make while generating.
  final int? maxToolCalls;

  /// A stable identifier used for safety monitoring and abuse detection.
  final String? safetyIdentifier;

  /// A key to use when reading from or writing to the prompt cache.
  final String? promptCacheKey;

  /// The number of most likely tokens to return at each position.
  final int? topLogprobs;

  /// Creates a [CreateResponseRequest].
  const CreateResponseRequest({
    required this.model,
    required this.input,
    this.instructions,
    this.tools,
    this.toolChoice,
    this.previousResponseId,
    this.maxOutputTokens,
    this.temperature,
    this.topP,
    this.presencePenalty,
    this.frequencyPenalty,
    this.stream,
    this.streamOptions,
    this.reasoning,
    this.text,
    this.truncation,
    this.parallelToolCalls,
    this.serviceTier,
    this.metadata,
    this.include,
    this.store,
    this.background,
    this.maxToolCalls,
    this.safetyIdentifier,
    this.promptCacheKey,
    this.topLogprobs,
  });

  /// Creates a simple text request.
  factory CreateResponseRequest.text({
    required String model,
    required String input,
    String? instructions,
    int? maxOutputTokens,
    double? temperature,
  }) {
    return CreateResponseRequest(
      model: model,
      input: input,
      instructions: instructions,
      maxOutputTokens: maxOutputTokens,
      temperature: temperature,
    );
  }

  /// Creates a [CreateResponseRequest] from JSON.
  factory CreateResponseRequest.fromJson(Map<String, dynamic> json) {
    return CreateResponseRequest(
      model: json['model'] as String,
      input: _parseInput(json['input']),
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      previousResponseId: json['previous_response_id'] as String?,
      maxOutputTokens: json['max_output_tokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      stream: json['stream'] as bool?,
      streamOptions: json['stream_options'] != null
          ? StreamOptions.fromJson(
              json['stream_options'] as Map<String, dynamic>,
            )
          : null,
      reasoning: json['reasoning'] != null
          ? ReasoningConfig.fromJson(json['reasoning'] as Map<String, dynamic>)
          : null,
      text: json['text'] != null
          ? TextConfig.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      truncation: json['truncation'] != null
          ? Truncation.fromJson(json['truncation'] as String)
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      serviceTier: json['service_tier'] != null
          ? ServiceTier.fromJson(json['service_tier'] as String)
          : null,
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
      include: (json['include'] as List?)
          ?.map((e) => Include.fromJson(e as String))
          .toList(),
      store: json['store'] as bool?,
      background: json['background'] as bool?,
      maxToolCalls: json['max_tool_calls'] as int?,
      safetyIdentifier: json['safety_identifier'] as String?,
      promptCacheKey: json['prompt_cache_key'] as String?,
      topLogprobs: json['top_logprobs'] as int?,
    );
  }

  static Object _parseInput(Object? input) {
    if (input is String) return input;
    if (input is List) {
      return input
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw FormatException('Invalid input format: $input');
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'input': _inputToJson(),
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (previousResponseId != null) 'previous_response_id': previousResponseId,
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (stream != null) 'stream': stream,
    if (streamOptions != null) 'stream_options': streamOptions!.toJson(),
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (text != null) 'text': text!.toJson(),
    if (truncation != null) 'truncation': truncation!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (include != null) 'include': include!.map((e) => e.toJson()).toList(),
    if (store != null) 'store': store,
    if (background != null) 'background': background,
    if (maxToolCalls != null) 'max_tool_calls': maxToolCalls,
    if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
    if (topLogprobs != null) 'top_logprobs': topLogprobs,
  };

  Object _inputToJson() {
    if (input is String) return input;
    if (input is List<Item>) {
      return (input as List<Item>).map((e) => e.toJson()).toList();
    }
    throw StateError('Invalid input type: ${input.runtimeType}');
  }

  /// Creates a copy with replaced values.
  CreateResponseRequest copyWith({
    String? model,
    Object? input,
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? previousResponseId = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? streamOptions = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
    Object? store = unsetCopyWithValue,
    Object? background = unsetCopyWithValue,
    Object? maxToolCalls = unsetCopyWithValue,
    Object? safetyIdentifier = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
  }) {
    return CreateResponseRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      previousResponseId: previousResponseId == unsetCopyWithValue
          ? this.previousResponseId
          : previousResponseId as String?,
      maxOutputTokens: maxOutputTokens == unsetCopyWithValue
          ? this.maxOutputTokens
          : maxOutputTokens as int?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      streamOptions: streamOptions == unsetCopyWithValue
          ? this.streamOptions
          : streamOptions as StreamOptions?,
      reasoning: reasoning == unsetCopyWithValue
          ? this.reasoning
          : reasoning as ReasoningConfig?,
      text: text == unsetCopyWithValue ? this.text : text as TextConfig?,
      truncation: truncation == unsetCopyWithValue
          ? this.truncation
          : truncation as Truncation?,
      parallelToolCalls: parallelToolCalls == unsetCopyWithValue
          ? this.parallelToolCalls
          : parallelToolCalls as bool?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      include: include == unsetCopyWithValue
          ? this.include
          : include as List<Include>?,
      store: store == unsetCopyWithValue ? this.store : store as bool?,
      background: background == unsetCopyWithValue
          ? this.background
          : background as bool?,
      maxToolCalls: maxToolCalls == unsetCopyWithValue
          ? this.maxToolCalls
          : maxToolCalls as int?,
      safetyIdentifier: safetyIdentifier == unsetCopyWithValue
          ? this.safetyIdentifier
          : safetyIdentifier as String?,
      promptCacheKey: promptCacheKey == unsetCopyWithValue
          ? this.promptCacheKey
          : promptCacheKey as String?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateResponseRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          input == other.input &&
          instructions == other.instructions &&
          toolChoice == other.toolChoice &&
          previousResponseId == other.previousResponseId &&
          maxOutputTokens == other.maxOutputTokens &&
          temperature == other.temperature &&
          topP == other.topP &&
          presencePenalty == other.presencePenalty &&
          frequencyPenalty == other.frequencyPenalty &&
          stream == other.stream &&
          streamOptions == other.streamOptions &&
          reasoning == other.reasoning &&
          text == other.text &&
          truncation == other.truncation &&
          parallelToolCalls == other.parallelToolCalls &&
          serviceTier == other.serviceTier &&
          store == other.store &&
          background == other.background &&
          maxToolCalls == other.maxToolCalls &&
          safetyIdentifier == other.safetyIdentifier &&
          promptCacheKey == other.promptCacheKey &&
          topLogprobs == other.topLogprobs;

  @override
  int get hashCode => Object.hashAll([
    model,
    input,
    instructions,
    toolChoice,
    previousResponseId,
    maxOutputTokens,
    temperature,
    topP,
    presencePenalty,
    frequencyPenalty,
    stream,
    streamOptions,
    reasoning,
    text,
    truncation,
    parallelToolCalls,
    serviceTier,
    store,
    background,
    maxToolCalls,
    safetyIdentifier,
    promptCacheKey,
    topLogprobs,
  ]);

  @override
  String toString() =>
      'CreateResponseRequest(model: $model, input: $input, ...)';
}
