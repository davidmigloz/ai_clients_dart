import 'package:meta/meta.dart';

import '../chat/chat_completion_request.dart' show StreamOptions;
import '../common/copy_with_sentinel.dart';
import 'common/equality_helpers.dart';
import 'config/config.dart';
import 'items/item.dart';
import 'response_input.dart';
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
///   input: ResponseInput.text('Hello, how are you?'),
/// );
///
/// // Multi-turn conversation with items
/// final request = CreateResponseRequest(
///   model: 'gpt-4o',
///   input: ResponseInput.items([
///     MessageItem.userText('What is 2+2?'),
///     MessageItem.assistantText('4'),
///     MessageItem.userText('What is 3+3?'),
///   ]),
/// );
/// ```
@immutable
class CreateResponseRequest {
  /// The model to use for generating the response.
  final String model;

  /// The input to the model.
  ///
  /// Can be a [ResponseInputText] for simple text or [ResponseInputItems]
  /// for multi-turn conversations with [Item] objects.
  final ResponseInput input;

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
  ///
  /// Values can be of any type and will be automatically converted to strings
  /// when serialized to JSON, as the API requires string values. Null values
  /// are omitted. After a JSON round-trip (`toJson()` then `fromJson()`), all
  /// metadata values will be strings.
  final Map<String, dynamic>? metadata;

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
      input: ResponseInput.text(text),
      instructions: instructions,
    );
  }

  /// Creates a [CreateResponseRequest] from JSON.
  factory CreateResponseRequest.fromJson(Map<String, dynamic> json) {
    return CreateResponseRequest(
      model: json['model'] as String,
      input: ResponseInput.fromJson(json['input']),
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
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
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
    return {
      'model': model,
      'input': input.toJson(),
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
      if (metadata case final metadata?
          when metadata.values.any((v) => v != null))
        'metadata': {
          for (final MapEntry(:key, :value) in metadata.entries)
            if (value != null) key: value.toString(),
        },
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
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  /// Omitted fields retain their current values.
  CreateResponseRequest copyWith({
    String? model,
    ResponseInput? input,
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
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<ResponseTool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ResponseToolChoice?,
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
          : metadata as Map<String, dynamic>?,
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateResponseRequest) return false;

    return runtimeType == other.runtimeType &&
        model == other.model &&
        input == other.input &&
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
