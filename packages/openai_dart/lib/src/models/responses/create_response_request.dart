import 'package:meta/meta.dart';

import '../chat/chat_completion_request.dart' show StreamOptions;
import 'common/equality_helpers.dart';
import 'config/config.dart';
import 'items/item.dart';
import 'tools/tools.dart';

/// Request to create a response.
///
/// The Responses API is OpenAI's next-generation interface that unifies
/// chat completions, reasoning, and tool use into a single API.
///
/// ## Example
///
/// ```dart
/// // Simple text request
/// final request = CreateResponseRequest(
///   model: 'gpt-4o',
///   input: 'Hello, how are you?',
/// );
///
/// // Multi-turn conversation with items
/// final request = CreateResponseRequest(
///   model: 'gpt-4o',
///   input: [
///     MessageItem.userText('What is 2+2?'),
///     MessageItem.assistantText('4'),
///     MessageItem.userText('What is 3+3?'),
///   ],
/// );
/// ```
@immutable
class CreateResponseRequest {
  /// The model to use for generating the response.
  final String model;

  /// The input to the model.
  ///
  /// Can be a simple string or a list of [Item] objects for multi-turn
  /// conversations.
  final Object input;

  /// System instructions for the model.
  ///
  /// This is equivalent to a system message at the start of the conversation.
  final String? instructions;

  /// The tools available to the model.
  final List<ResponseTool>? tools;

  /// How the model should select tools.
  final ResponseToolChoice? toolChoice;

  /// The ID of a previous response to continue from.
  ///
  /// Use this for multi-turn conversations where you want to continue
  /// from a previous response without re-sending the entire conversation
  /// history.
  final String? previousResponseId;

  /// Maximum number of output tokens.
  ///
  /// The value must be at least 16. Values below this minimum will result
  /// in a [BadRequestException].
  final int? maxOutputTokens;

  /// Sampling temperature (0-2).
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Presence penalty (-2 to 2).
  final double? presencePenalty;

  /// Frequency penalty (-2 to 2).
  final double? frequencyPenalty;

  /// Whether to stream the response.
  final bool? stream;

  /// Options for streaming responses.
  final StreamOptions? streamOptions;

  /// Configuration for reasoning models.
  final ReasoningConfig? reasoning;

  /// Configuration for text output.
  final TextConfig? text;

  /// Truncation strategy for long inputs.
  final Truncation? truncation;

  /// Whether to allow parallel tool calls.
  final bool? parallelToolCalls;

  /// The service tier for request processing.
  final ServiceTier? serviceTier;

  /// Custom metadata for the request.
  final Map<String, String>? metadata;

  /// Additional data to include in the response.
  final List<Include>? include;

  /// Whether to store the response for later retrieval.
  final bool? store;

  /// Whether to run the request in the background.
  ///
  /// Background requests return immediately with a response ID that can be
  /// used to poll for completion.
  final bool? background;

  /// Maximum number of tool calls to allow.
  final int? maxToolCalls;

  /// Safety identifier for content moderation.
  final String? safetyIdentifier;

  /// Prompt cache key for caching.
  final String? promptCacheKey;

  /// Number of top log probabilities to return.
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
    required String text,
    String? instructions,
  }) {
    return CreateResponseRequest(
      model: model,
      input: text,
      instructions: instructions,
    );
  }

  /// Creates a [CreateResponseRequest] from JSON.
  factory CreateResponseRequest.fromJson(Map<String, dynamic> json) {
    final inputJson = json['input'];
    final Object input;
    if (inputJson is String) {
      input = inputJson;
    } else if (inputJson is List) {
      input = inputJson
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw FormatException('Invalid input format: $inputJson');
    }

    return CreateResponseRequest(
      model: json['model'] as String,
      input: input,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List?)
          ?.map((e) => ResponseTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? ResponseToolChoice.fromJson(json['tool_choice'])
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

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    final Object inputJson;
    if (input is String) {
      inputJson = input;
    } else if (input is List<Item>) {
      inputJson = (input as List<Item>).map((e) => e.toJson()).toList();
    } else {
      throw ArgumentError('Invalid input type: ${input.runtimeType}');
    }

    return {
      'model': model,
      'input': inputJson,
      if (instructions != null) 'instructions': instructions,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
      if (previousResponseId != null)
        'previous_response_id': previousResponseId,
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
  }

  /// Creates a copy with replaced values.
  CreateResponseRequest copyWith({
    String? model,
    Object? input,
    String? instructions,
    List<ResponseTool>? tools,
    ResponseToolChoice? toolChoice,
    String? previousResponseId,
    int? maxOutputTokens,
    double? temperature,
    double? topP,
    double? presencePenalty,
    double? frequencyPenalty,
    bool? stream,
    StreamOptions? streamOptions,
    ReasoningConfig? reasoning,
    TextConfig? text,
    Truncation? truncation,
    bool? parallelToolCalls,
    ServiceTier? serviceTier,
    Map<String, String>? metadata,
    List<Include>? include,
    bool? store,
    bool? background,
    int? maxToolCalls,
    String? safetyIdentifier,
    String? promptCacheKey,
    int? topLogprobs,
  }) {
    return CreateResponseRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      instructions: instructions ?? this.instructions,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      previousResponseId: previousResponseId ?? this.previousResponseId,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      stream: stream ?? this.stream,
      streamOptions: streamOptions ?? this.streamOptions,
      reasoning: reasoning ?? this.reasoning,
      text: text ?? this.text,
      truncation: truncation ?? this.truncation,
      parallelToolCalls: parallelToolCalls ?? this.parallelToolCalls,
      serviceTier: serviceTier ?? this.serviceTier,
      metadata: metadata ?? this.metadata,
      include: include ?? this.include,
      store: store ?? this.store,
      background: background ?? this.background,
      maxToolCalls: maxToolCalls ?? this.maxToolCalls,
      safetyIdentifier: safetyIdentifier ?? this.safetyIdentifier,
      promptCacheKey: promptCacheKey ?? this.promptCacheKey,
      topLogprobs: topLogprobs ?? this.topLogprobs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateResponseRequest) return false;

    // Compare input
    bool inputEqual;
    if (input is String && other.input is String) {
      inputEqual = input == other.input;
    } else if (input is List<Item> && other.input is List<Item>) {
      inputEqual = listsEqual(input as List<Item>, other.input as List<Item>);
    } else {
      inputEqual = false;
    }

    return runtimeType == other.runtimeType &&
        model == other.model &&
        inputEqual &&
        instructions == other.instructions &&
        listsEqual(tools, other.tools) &&
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
        mapsEqual(metadata, other.metadata) &&
        listsEqual(include, other.include) &&
        store == other.store &&
        background == other.background &&
        maxToolCalls == other.maxToolCalls &&
        safetyIdentifier == other.safetyIdentifier &&
        promptCacheKey == other.promptCacheKey &&
        topLogprobs == other.topLogprobs;
  }

  @override
  int get hashCode => Object.hashAll([
    model,
    input,
    instructions,
    tools,
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
    metadata,
    include,
    store,
    background,
    maxToolCalls,
    safetyIdentifier,
    promptCacheKey,
    topLogprobs,
  ]);

  @override
  String toString() => 'CreateResponseRequest(model: $model, input: $input)';
}
