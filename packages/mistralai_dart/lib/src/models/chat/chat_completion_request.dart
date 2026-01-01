import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../common/copy_with_sentinel.dart';
import '../metadata/prediction.dart';
import '../metadata/prompt_mode.dart';
import '../metadata/response_format.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'chat_message.dart';

/// Request for a chat completion.
@immutable
class ChatCompletionRequest {
  /// The model to use for completion.
  final String model;

  /// The messages to generate a completion for.
  final List<ChatMessage> messages;

  /// What sampling temperature to use (0.0-1.5).
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  /// Nucleus sampling probability (0.0-1.0).
  ///
  /// The model considers tokens with top_p probability mass.
  final double? topP;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Whether to stream the response.
  final bool? stream;

  /// Stop sequences to stop generation.
  ///
  /// Can be a single string or a list of strings.
  final Object? stop;

  /// Random seed for deterministic generation.
  final int? randomSeed;

  /// Response format specification.
  final ResponseFormat? responseFormat;

  /// Tools available to the model.
  final List<Tool>? tools;

  /// Controls how the model uses tools.
  final ToolChoice? toolChoice;

  /// Presence penalty (-2.0 to 2.0).
  ///
  /// Positive values penalize tokens based on whether they appear in the text.
  final double? presencePenalty;

  /// Frequency penalty (-2.0 to 2.0).
  ///
  /// Positive values penalize tokens based on their frequency in the text.
  final double? frequencyPenalty;

  /// Number of completions to generate.
  final int? n;

  /// Whether to allow parallel tool calls.
  final bool? parallelToolCalls;

  /// Whether to inject a safety prompt.
  ///
  /// When true, Mistral injects a system prompt about responsible AI usage.
  final bool? safePrompt;

  /// Custom request metadata.
  ///
  /// Allows attaching arbitrary key-value pairs to the request.
  final Map<String, dynamic>? metadata;

  /// Prediction configuration for speculative decoding.
  ///
  /// Enables users to define anticipated output content, optimizing response
  /// times by leveraging known or predictable content.
  ///
  /// Supported models: `mistral-large-2411`, `codestral-latest`
  ///
  /// Note: The `n` parameter is not supported when using predictions.
  final Prediction? prediction;

  /// Prompt mode for reasoning models.
  ///
  /// When set to [MistralPromptMode.reasoning], enables extended reasoning
  /// mode where the model engages in deeper reasoning before responding.
  final MistralPromptMode? promptMode;

  /// Creates a [ChatCompletionRequest].
  const ChatCompletionRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.topP,
    this.maxTokens,
    this.stream,
    this.stop,
    this.randomSeed,
    this.responseFormat,
    this.tools,
    this.toolChoice,
    this.presencePenalty,
    this.frequencyPenalty,
    this.n,
    this.parallelToolCalls,
    this.safePrompt,
    this.metadata,
    this.prediction,
    this.promptMode,
  });

  /// Creates a [ChatCompletionRequest] from JSON.
  factory ChatCompletionRequest.fromJson(Map<String, dynamic> json) =>
      ChatCompletionRequest(
        model: json['model'] as String? ?? '',
        messages:
            (json['messages'] as List?)
                ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        temperature: (json['temperature'] as num?)?.toDouble(),
        topP: (json['top_p'] as num?)?.toDouble(),
        maxTokens: json['max_tokens'] as int?,
        stream: json['stream'] as bool?,
        stop: json['stop'],
        randomSeed: json['random_seed'] as int?,
        responseFormat: json['response_format'] != null
            ? ResponseFormat.fromJson(
                json['response_format'] as Map<String, dynamic>,
              )
            : null,
        tools: (json['tools'] as List?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
        toolChoice: json['tool_choice'] != null
            ? ToolChoice.fromJson(json['tool_choice'] as Object)
            : null,
        presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
        frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
        n: json['n'] as int?,
        parallelToolCalls: json['parallel_tool_calls'] as bool?,
        safePrompt: json['safe_prompt'] as bool?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        prediction: json['prediction'] != null
            ? Prediction.fromJson(json['prediction'] as Map<String, dynamic>)
            : null,
        promptMode: MistralPromptMode.fromString(
          json['prompt_mode'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (stream != null) 'stream': stream,
    if (stop != null) 'stop': stop,
    if (randomSeed != null) 'random_seed': randomSeed,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (n != null) 'n': n,
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (safePrompt != null) 'safe_prompt': safePrompt,
    if (metadata != null) 'metadata': metadata,
    if (prediction != null) 'prediction': prediction!.toJson(),
    if (promptMode != null) 'prompt_mode': promptMode!.value,
  };

  /// Creates a copy with replaced values.
  ChatCompletionRequest copyWith({
    String? model,
    List<ChatMessage>? messages,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? maxTokens = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? randomSeed = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? safePrompt = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? prediction = unsetCopyWithValue,
    Object? promptMode = unsetCopyWithValue,
  }) {
    return ChatCompletionRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      stop: stop == unsetCopyWithValue ? this.stop : stop,
      randomSeed: randomSeed == unsetCopyWithValue
          ? this.randomSeed
          : randomSeed as int?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ResponseFormat?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      n: n == unsetCopyWithValue ? this.n : n as int?,
      parallelToolCalls: parallelToolCalls == unsetCopyWithValue
          ? this.parallelToolCalls
          : parallelToolCalls as bool?,
      safePrompt: safePrompt == unsetCopyWithValue
          ? this.safePrompt
          : safePrompt as bool?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      prediction: prediction == unsetCopyWithValue
          ? this.prediction
          : prediction as Prediction?,
      promptMode: promptMode == unsetCopyWithValue
          ? this.promptMode
          : promptMode as MistralPromptMode?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionRequest) return false;
    if (runtimeType != other.runtimeType) return false;

    // Compare lists with deep equality
    if (!listEquals(messages, other.messages)) return false;
    if (!listEquals(tools, other.tools)) return false;

    return model == other.model &&
        temperature == other.temperature &&
        topP == other.topP &&
        maxTokens == other.maxTokens &&
        stream == other.stream &&
        stop == other.stop &&
        randomSeed == other.randomSeed &&
        responseFormat == other.responseFormat &&
        toolChoice == other.toolChoice &&
        presencePenalty == other.presencePenalty &&
        frequencyPenalty == other.frequencyPenalty &&
        n == other.n &&
        parallelToolCalls == other.parallelToolCalls &&
        safePrompt == other.safePrompt &&
        mapEquals(metadata, other.metadata) &&
        prediction == other.prediction &&
        promptMode == other.promptMode;
  }

  @override
  int get hashCode => Object.hash(
    model,
    Object.hashAll(messages),
    temperature,
    topP,
    maxTokens,
    stream,
    stop,
    randomSeed,
    responseFormat,
    Object.hashAll(tools ?? []),
    toolChoice,
    presencePenalty,
    frequencyPenalty,
    n,
    parallelToolCalls,
    safePrompt,
    metadata,
    prediction,
    promptMode,
  );

  @override
  String toString() =>
      'ChatCompletionRequest(model: $model, messages: ${messages.length} msgs)';
}
