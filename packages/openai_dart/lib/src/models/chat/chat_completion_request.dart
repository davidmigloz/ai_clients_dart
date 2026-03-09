import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/response_format.dart';
import '../responses/config/prompt_cache_retention.dart';
import '../responses/config/reasoning_effort.dart';
import '../responses/config/verbosity.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'chat_audio_config.dart';
import 'chat_message.dart';
import 'openrouter_config.dart';
import 'prediction.dart';
import 'web_search_options.dart';

/// Request for creating a chat completion.
///
/// This is the primary request model for the chat completions API.
/// It contains all the parameters needed to generate a response.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o',
///   messages: [
///     ChatMessage.system('You are a helpful assistant.'),
///     ChatMessage.user('Hello!'),
///   ],
///   temperature: 0.7,
///   maxTokens: 1000,
/// );
///
/// final response = await client.chat.completions.create(request);
/// ```
@immutable
class ChatCompletionCreateRequest {
  /// Creates a [ChatCompletionCreateRequest].
  const ChatCompletionCreateRequest({
    required this.model,
    required this.messages,
    this.frequencyPenalty,
    this.logitBias,
    this.logprobs,
    this.topLogprobs,
    this.maxTokens,
    this.maxCompletionTokens,
    this.n,
    this.presencePenalty,
    this.responseFormat,
    this.seed,
    this.serviceTier,
    this.stop,
    this.temperature,
    this.topP,
    this.tools,
    this.toolChoice,
    this.parallelToolCalls,
    this.user,
    this.metadata,
    this.store,
    this.streamOptions,
    this.reasoningEffort,
    this.verbosity,
    this.prediction,
    this.modalities,
    this.audio,
    this.webSearchOptions,
    this.promptCacheKey,
    this.promptCacheRetention,
    this.safetyIdentifier,
    // OpenRouter-specific parameters
    this.topK,
    this.minP,
    this.topA,
    this.repetitionPenalty,
    this.openRouterProvider,
    this.models,
    this.route,
    this.transforms,
    this.openRouterUsage,
    this.openRouterReasoning,
  });

  /// Creates a [ChatCompletionCreateRequest] from JSON.
  factory ChatCompletionCreateRequest.fromJson(Map<String, dynamic> json) {
    return ChatCompletionCreateRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      logitBias: (json['logit_bias'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      logprobs: json['logprobs'] as bool?,
      topLogprobs: json['top_logprobs'] as int?,
      maxTokens: json['max_tokens'] as int?,
      maxCompletionTokens: json['max_completion_tokens'] as int?,
      n: json['n'] as int?,
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      responseFormat: json['response_format'] != null
          ? ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            )
          : null,
      seed: json['seed'] as int?,
      serviceTier: json['service_tier'] as String?,
      stop: _parseStop(json['stop']),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      user: json['user'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      store: json['store'] as bool?,
      streamOptions: json['stream_options'] != null
          ? StreamOptions.fromJson(
              json['stream_options'] as Map<String, dynamic>,
            )
          : null,
      reasoningEffort: json['reasoning_effort'] != null
          ? ReasoningEffort.fromJson(json['reasoning_effort'] as String)
          : null,
      verbosity: json['verbosity'] != null
          ? Verbosity.fromJson(json['verbosity'] as String)
          : null,
      prediction: json['prediction'] != null
          ? Prediction.fromJson(json['prediction'] as Map<String, dynamic>)
          : null,
      modalities: (json['modalities'] as List<dynamic>?)
          ?.map((e) => ChatModality.fromJson(e as String))
          .toList(),
      audio: json['audio'] != null
          ? ChatAudioConfig.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
      webSearchOptions: json['web_search_options'] != null
          ? WebSearchOptions.fromJson(
              json['web_search_options'] as Map<String, dynamic>,
            )
          : null,
      promptCacheKey: json['prompt_cache_key'] as String?,
      promptCacheRetention: json['prompt_cache_retention'] != null
          ? PromptCacheRetention.fromJson(
              json['prompt_cache_retention'] as String,
            )
          : null,
      safetyIdentifier: json['safety_identifier'] as String?,
      // OpenRouter-specific parameters
      topK: json['top_k'] as int?,
      minP: (json['min_p'] as num?)?.toDouble(),
      topA: (json['top_a'] as num?)?.toDouble(),
      repetitionPenalty: (json['repetition_penalty'] as num?)?.toDouble(),
      openRouterProvider: json['provider'] != null
          ? OpenRouterProviderPreferences.fromJson(
              json['provider'] as Map<String, dynamic>,
            )
          : null,
      models: (json['models'] as List<dynamic>?)?.cast<String>(),
      route: json['route'] as String?,
      transforms: (json['transforms'] as List<dynamic>?)?.cast<String>(),
      openRouterUsage: json['usage'] != null && json['usage'] is Map
          ? OpenRouterUsageConfig.fromJson(
              json['usage'] as Map<String, dynamic>,
            )
          : null,
      openRouterReasoning: json['reasoning'] != null
          ? OpenRouterReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The model to use for completion.
  ///
  /// Examples: `gpt-4o`, `gpt-4o-mini`, `gpt-4-turbo`, `o1-preview`
  final String model;

  /// The messages to generate a completion for.
  final List<ChatMessage> messages;

  /// Penalty for repeating tokens based on frequency.
  ///
  /// Number between -2.0 and 2.0. Positive values penalize tokens based on
  /// their existing frequency in the text, decreasing the likelihood of
  /// repeating the same line verbatim.
  final double? frequencyPenalty;

  /// Modify the likelihood of specified tokens appearing.
  ///
  /// Maps token IDs to bias values from -100 to 100.
  /// Values between -1 and 1 should decrease or increase likelihood of selection.
  /// Values like -100 or 100 result in a ban or exclusive selection.
  final Map<String, int>? logitBias;

  /// Whether to return log probabilities of output tokens.
  final bool? logprobs;

  /// Number of most likely tokens to return at each position (0-20).
  ///
  /// Only valid when [logprobs] is true.
  final int? topLogprobs;

  /// Maximum number of tokens to generate.
  ///
  /// Deprecated: Use [maxCompletionTokens] for newer models.
  final int? maxTokens;

  /// Maximum number of tokens to generate (for o1 and newer models).
  final int? maxCompletionTokens;

  /// Number of completions to generate.
  ///
  /// Defaults to 1. Note: generating multiple completions consumes your token
  /// quota proportionally.
  final int? n;

  /// Penalty for new tokens based on presence in text so far.
  ///
  /// Number between -2.0 and 2.0. Positive values penalize new tokens based on
  /// whether they appear in the text so far, increasing the model's likelihood
  /// to talk about new topics.
  final double? presencePenalty;

  /// The format of the response.
  ///
  /// Use [ResponseFormat.jsonObject] or [ResponseFormat.jsonSchema] for
  /// structured outputs.
  final ResponseFormat? responseFormat;

  /// Random seed for deterministic sampling.
  ///
  /// Using the same seed with the same parameters should return
  /// similar (though not identical) results.
  final int? seed;

  /// The service tier to use.
  ///
  /// Can be `auto` or `default`. If not specified, defaults to `auto`.
  final String? serviceTier;

  /// Stop sequences to end generation.
  ///
  /// Up to 4 sequences where the API will stop generating.
  final List<String>? stop;

  /// Sampling temperature between 0 and 2.
  ///
  /// Higher values make output more random, lower values more deterministic.
  /// Generally, use either this or [topP], not both.
  final double? temperature;

  /// Nucleus sampling parameter.
  ///
  /// Only sample from tokens with cumulative probability >= topP.
  /// Generally, use either this or [temperature], not both.
  final double? topP;

  /// The tools available for the model to call.
  final List<Tool>? tools;

  /// Controls which tool is called.
  ///
  /// Can be:
  /// - `auto`: Let the model decide
  /// - `none`: Don't call any tools
  /// - `required`: Must call a tool
  /// - Specific tool: Force a specific tool
  final ToolChoice? toolChoice;

  /// Whether to enable parallel function calling.
  ///
  /// Defaults to true. Set to false to force sequential tool calls.
  final bool? parallelToolCalls;

  /// A unique identifier for the end-user.
  ///
  /// Can help OpenAI monitor and detect abuse.
  final String? user;

  /// Custom metadata to attach to the request.
  ///
  /// Values can be of any type and will be automatically converted to strings
  /// when serialized to JSON, as the API requires string values. Null values
  /// are omitted. After a JSON round-trip (`toJson()` then `fromJson()`), all
  /// metadata values will be strings.
  final Map<String, dynamic>? metadata;

  /// Whether to store this completion for model improvements.
  final bool? store;

  /// Options for streaming responses.
  final StreamOptions? streamOptions;

  /// Controls reasoning effort for reasoning models (o1, o3, o4-mini).
  ///
  /// Higher effort levels may produce better results for complex problems
  /// but take longer to process.
  final ReasoningEffort? reasoningEffort;

  /// Controls the verbosity of the model's response.
  ///
  /// Lower values will result in more concise responses, while higher values
  /// will result in more verbose responses.
  final Verbosity? verbosity;

  /// Predicted output for faster responses.
  ///
  /// When you have high confidence in a significant portion of the response,
  /// providing a prediction can reduce latency by letting the model focus
  /// on differences. Works best with gpt-4o and gpt-4.1 models.
  final Prediction? prediction;

  /// Output modalities to request.
  ///
  /// Use `[ChatModality.text, ChatModality.audio]` to request both text
  /// and audio output from audio-capable models like `gpt-audio-1.5`.
  final List<ChatModality>? modalities;

  /// Audio output configuration.
  ///
  /// Required when [modalities] includes [ChatModality.audio].
  /// Configures the voice and format for audio responses.
  final ChatAudioConfig? audio;

  /// Web search options for including web results in the response.
  ///
  /// Learn more about the
  /// [web search tool](https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat).
  final WebSearchOptions? webSearchOptions;

  /// Prompt cache key for optimizing cache hit rates.
  ///
  /// Used by OpenAI to cache responses for similar requests.
  /// Replaces the [user] field for caching purposes.
  final String? promptCacheKey;

  /// The retention policy for the prompt cache.
  ///
  /// Set to [PromptCacheRetention.h24] to enable extended prompt caching,
  /// which keeps cached prefixes active for up to 24 hours.
  final PromptCacheRetention? promptCacheRetention;

  /// A stable identifier for detecting usage policy violations.
  ///
  /// Should uniquely identify each user (max 64 characters).
  /// We recommend hashing the username or email address.
  final String? safetyIdentifier;

  // ---------------------------------------------------------------------------
  // OpenRouter-specific parameters
  // ---------------------------------------------------------------------------

  /// **OpenRouter only.** Sample from the top K most likely tokens.
  ///
  /// Not part of the official OpenAI API.
  final int? topK;

  /// **OpenRouter only.** Minimum probability threshold for token sampling.
  ///
  /// Not part of the official OpenAI API. Tokens with probability below this
  /// threshold are filtered out before sampling.
  final double? minP;

  /// **OpenRouter only.** Dynamic top-p filter.
  ///
  /// Not part of the official OpenAI API. Similar to top-p but dynamically
  /// adjusts based on token probabilities.
  final double? topA;

  /// **OpenRouter only.** Penalty for repetition.
  ///
  /// Not part of the official OpenAI API. Value of 1.0 means no penalty,
  /// values up to 2.0 increase the penalty for repeating tokens.
  final double? repetitionPenalty;

  /// **OpenRouter only.** Provider routing preferences.
  ///
  /// Not part of the official OpenAI API. Controls which providers are used
  /// and how requests are routed.
  final OpenRouterProviderPreferences? openRouterProvider;

  /// **OpenRouter only.** Fallback model list.
  ///
  /// Not part of the official OpenAI API. If the primary model is unavailable,
  /// OpenRouter will try these models in order.
  final List<String>? models;

  /// **OpenRouter only.** Routing strategy.
  ///
  /// Not part of the official OpenAI API. Currently only `"fallback"` is
  /// supported, which enables the fallback model list.
  final String? route;

  /// **OpenRouter only.** Prompt transforms to apply.
  ///
  /// Not part of the official OpenAI API. Example: `["middle-out"]` to
  /// compress long prompts.
  final List<String>? transforms;

  /// **OpenRouter only.** Usage configuration.
  ///
  /// Not part of the official OpenAI API. Controls whether detailed token
  /// usage information is included in responses.
  ///
  /// Named `openRouterUsage` to avoid conflict with response `usage` field.
  final OpenRouterUsageConfig? openRouterUsage;

  /// **OpenRouter only.** Reasoning configuration.
  ///
  /// Not part of the official OpenAI API. Controls reasoning behavior for
  /// models that support it (e.g., DeepSeek R1).
  ///
  /// Named `openRouterReasoning` to avoid conflict with [reasoningEffort].
  final OpenRouterReasoning? openRouterReasoning;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((m) => m.toJson()).toList(),
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (logitBias != null) 'logit_bias': logitBias,
    if (logprobs != null) 'logprobs': logprobs,
    if (topLogprobs != null) 'top_logprobs': topLogprobs,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (maxCompletionTokens != null)
      'max_completion_tokens': maxCompletionTokens,
    if (n != null) 'n': n,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (seed != null) 'seed': seed,
    if (serviceTier != null) 'service_tier': serviceTier,
    if (stop != null) 'stop': stop,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (user != null) 'user': user,
    if (metadata case final metadata?
        when metadata.values.any((v) => v != null))
      'metadata': {
        for (final MapEntry(:key, :value) in metadata.entries)
          if (value != null) key: value.toString(),
      },
    if (store != null) 'store': store,
    if (streamOptions != null) 'stream_options': streamOptions!.toJson(),
    if (reasoningEffort != null) 'reasoning_effort': reasoningEffort!.toJson(),
    if (verbosity != null) 'verbosity': verbosity!.toJson(),
    if (prediction != null) 'prediction': prediction!.toJson(),
    if (modalities != null)
      'modalities': modalities!.map((m) => m.toJson()).toList(),
    if (audio != null) 'audio': audio!.toJson(),
    if (webSearchOptions != null)
      'web_search_options': webSearchOptions!.toJson(),
    if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
    if (promptCacheRetention != null)
      'prompt_cache_retention': promptCacheRetention!.toJson(),
    if (safetyIdentifier != null) 'safety_identifier': safetyIdentifier,
    // OpenRouter-specific parameters
    if (topK != null) 'top_k': topK,
    if (minP != null) 'min_p': minP,
    if (topA != null) 'top_a': topA,
    if (repetitionPenalty != null) 'repetition_penalty': repetitionPenalty,
    if (openRouterProvider != null) 'provider': openRouterProvider!.toJson(),
    if (models != null) 'models': models,
    if (route != null) 'route': route,
    if (transforms != null) 'transforms': transforms,
    if (openRouterUsage != null) 'usage': openRouterUsage!.toJson(),
    if (openRouterReasoning != null) 'reasoning': openRouterReasoning!.toJson(),
  };

  /// Creates a copy with replaced values.
  ChatCompletionCreateRequest copyWith({
    String? model,
    List<ChatMessage>? messages,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? logitBias = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? maxCompletionTokens = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? seed = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? store = unsetCopyWithValue,
    Object? streamOptions = unsetCopyWithValue,
    Object? reasoningEffort = unsetCopyWithValue,
    Object? verbosity = unsetCopyWithValue,
    Object? prediction = unsetCopyWithValue,
    Object? modalities = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? webSearchOptions = unsetCopyWithValue,
    Object? promptCacheKey = unsetCopyWithValue,
    Object? promptCacheRetention = unsetCopyWithValue,
    Object? safetyIdentifier = unsetCopyWithValue,
    // OpenRouter-specific parameters
    Object? topK = unsetCopyWithValue,
    Object? minP = unsetCopyWithValue,
    Object? topA = unsetCopyWithValue,
    Object? repetitionPenalty = unsetCopyWithValue,
    Object? openRouterProvider = unsetCopyWithValue,
    Object? models = unsetCopyWithValue,
    Object? route = unsetCopyWithValue,
    Object? transforms = unsetCopyWithValue,
    Object? openRouterUsage = unsetCopyWithValue,
    Object? openRouterReasoning = unsetCopyWithValue,
  }) {
    return ChatCompletionCreateRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      logitBias: logitBias == unsetCopyWithValue
          ? this.logitBias
          : logitBias as Map<String, int>?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as bool?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as int?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      maxCompletionTokens: maxCompletionTokens == unsetCopyWithValue
          ? this.maxCompletionTokens
          : maxCompletionTokens as int?,
      n: n == unsetCopyWithValue ? this.n : n as int?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ResponseFormat?,
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as String?,
      stop: stop == unsetCopyWithValue ? this.stop : stop as List<String>?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      parallelToolCalls: parallelToolCalls == unsetCopyWithValue
          ? this.parallelToolCalls
          : parallelToolCalls as bool?,
      user: user == unsetCopyWithValue ? this.user : user as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      store: store == unsetCopyWithValue ? this.store : store as bool?,
      streamOptions: streamOptions == unsetCopyWithValue
          ? this.streamOptions
          : streamOptions as StreamOptions?,
      reasoningEffort: reasoningEffort == unsetCopyWithValue
          ? this.reasoningEffort
          : reasoningEffort as ReasoningEffort?,
      verbosity: verbosity == unsetCopyWithValue
          ? this.verbosity
          : verbosity as Verbosity?,
      prediction: prediction == unsetCopyWithValue
          ? this.prediction
          : prediction as Prediction?,
      modalities: modalities == unsetCopyWithValue
          ? this.modalities
          : modalities as List<ChatModality>?,
      audio: audio == unsetCopyWithValue
          ? this.audio
          : audio as ChatAudioConfig?,
      webSearchOptions: webSearchOptions == unsetCopyWithValue
          ? this.webSearchOptions
          : webSearchOptions as WebSearchOptions?,
      promptCacheKey: promptCacheKey == unsetCopyWithValue
          ? this.promptCacheKey
          : promptCacheKey as String?,
      promptCacheRetention: promptCacheRetention == unsetCopyWithValue
          ? this.promptCacheRetention
          : promptCacheRetention as PromptCacheRetention?,
      safetyIdentifier: safetyIdentifier == unsetCopyWithValue
          ? this.safetyIdentifier
          : safetyIdentifier as String?,
      // OpenRouter-specific parameters
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
      minP: minP == unsetCopyWithValue ? this.minP : minP as double?,
      topA: topA == unsetCopyWithValue ? this.topA : topA as double?,
      repetitionPenalty: repetitionPenalty == unsetCopyWithValue
          ? this.repetitionPenalty
          : repetitionPenalty as double?,
      openRouterProvider: openRouterProvider == unsetCopyWithValue
          ? this.openRouterProvider
          : openRouterProvider as OpenRouterProviderPreferences?,
      models: models == unsetCopyWithValue
          ? this.models
          : models as List<String>?,
      route: route == unsetCopyWithValue ? this.route : route as String?,
      transforms: transforms == unsetCopyWithValue
          ? this.transforms
          : transforms as List<String>?,
      openRouterUsage: openRouterUsage == unsetCopyWithValue
          ? this.openRouterUsage
          : openRouterUsage as OpenRouterUsageConfig?,
      openRouterReasoning: openRouterReasoning == unsetCopyWithValue
          ? this.openRouterReasoning
          : openRouterReasoning as OpenRouterReasoning?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletionCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          _listEquals(messages, other.messages);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(model, Object.hashAll(messages));

  @override
  String toString() =>
      'ChatCompletionCreateRequest(model: $model, messages: ${messages.length})';
}

/// Options for streaming responses.
@immutable
class StreamOptions {
  /// Creates [StreamOptions].
  const StreamOptions({this.includeUsage});

  /// Creates [StreamOptions] from JSON.
  factory StreamOptions.fromJson(Map<String, dynamic> json) {
    return StreamOptions(includeUsage: json['include_usage'] as bool?);
  }

  /// Whether to include usage statistics in the stream.
  ///
  /// If true, the final chunk will include usage information.
  final bool? includeUsage;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (includeUsage != null) 'include_usage': includeUsage,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamOptions &&
          runtimeType == other.runtimeType &&
          includeUsage == other.includeUsage;

  @override
  int get hashCode => includeUsage.hashCode;

  @override
  String toString() => 'StreamOptions(includeUsage: $includeUsage)';
}

List<String>? _parseStop(Object? stop) {
  if (stop == null) return null;
  if (stop is String) return [stop];
  if (stop is List) return stop.cast<String>();
  return null;
}
