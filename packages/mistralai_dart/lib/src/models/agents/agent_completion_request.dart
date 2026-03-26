import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/prediction.dart';
import '../metadata/prompt_mode.dart';
import '../metadata/reasoning_effort.dart';
import '../metadata/response_format.dart';
import '../metadata/stop_sequence.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';

/// Request for agent completion.
@immutable
class AgentCompletionRequest {
  /// The agent ID to use for completion.
  final String agentId;

  /// The conversation messages.
  final List<ChatMessage> messages;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Whether to stream the response.
  final bool? stream;

  /// Stop sequences to stop generation.
  ///
  /// Use [StopSequence.single] for a single stop string or
  /// [StopSequence.multiple] for multiple stop strings.
  final StopSequence? stop;

  /// Sampling temperature (0.0-1.0).
  final double? temperature;

  /// Top-p sampling.
  final double? topP;

  /// Additional tools to use for this request.
  final List<Tool>? tools;

  /// Tool choice configuration.
  final ToolChoice? toolChoice;

  /// Response format configuration.
  final ResponseFormat? responseFormat;

  /// Random seed for reproducibility.
  final int? randomSeed;

  /// Frequency penalty (-2.0 to 2.0).
  ///
  /// Positive values penalize tokens based on their frequency in the text.
  final double? frequencyPenalty;

  /// Presence penalty (-2.0 to 2.0).
  ///
  /// Positive values penalize tokens based on whether they appear in the text.
  final double? presencePenalty;

  /// Number of completions to generate.
  final int? n;

  /// Whether to allow parallel tool calls.
  final bool? parallelToolCalls;

  /// Custom request metadata.
  final Map<String, dynamic>? metadata;

  /// Prediction configuration for speculative decoding.
  final Prediction? prediction;

  /// Prompt mode for reasoning models.
  ///
  /// **Deprecated** — use [reasoningEffort] instead.
  final MistralPromptMode? promptMode;

  /// Controls the reasoning effort level for reasoning models.
  final ReasoningEffort? reasoningEffort;

  /// Creates an [AgentCompletionRequest].
  const AgentCompletionRequest({
    required this.agentId,
    required this.messages,
    this.maxTokens,
    this.stream,
    this.stop,
    this.temperature,
    this.topP,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.randomSeed,
    this.frequencyPenalty,
    this.presencePenalty,
    this.n,
    this.parallelToolCalls,
    this.metadata,
    this.prediction,
    this.promptMode,
    this.reasoningEffort,
  });

  /// Creates an [AgentCompletionRequest] from JSON.
  factory AgentCompletionRequest.fromJson(Map<String, dynamic> json) =>
      AgentCompletionRequest(
        agentId: json['agent_id'] as String? ?? '',
        messages:
            (json['messages'] as List?)
                ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        maxTokens: json['max_tokens'] as int?,
        stream: json['stream'] as bool?,
        stop: json['stop'] != null
            ? StopSequence.fromJson(json['stop'] as Object)
            : null,
        temperature: (json['temperature'] as num?)?.toDouble(),
        topP: (json['top_p'] as num?)?.toDouble(),
        tools: (json['tools'] as List?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
        toolChoice: json['tool_choice'] != null
            ? ToolChoice.fromJson(json['tool_choice'] as Object)
            : null,
        responseFormat: json['response_format'] != null
            ? ResponseFormat.fromJson(
                json['response_format'] as Map<String, dynamic>,
              )
            : null,
        randomSeed: json['random_seed'] as int?,
        frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
        presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
        n: json['n'] as int?,
        parallelToolCalls: json['parallel_tool_calls'] as bool?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        prediction: json['prediction'] != null
            ? Prediction.fromJson(json['prediction'] as Map<String, dynamic>)
            : null,
        promptMode: MistralPromptMode.fromString(
          json['prompt_mode'] as String?,
        ),
        reasoningEffort: ReasoningEffort.fromString(
          json['reasoning_effort'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (stream != null) 'stream': stream,
    if (stop != null) 'stop': stop!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (randomSeed != null) 'random_seed': randomSeed,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (n != null) 'n': n,
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (metadata != null) 'metadata': metadata,
    if (prediction != null) 'prediction': prediction!.toJson(),
    if (promptMode != null) 'prompt_mode': promptMode!.value,
    if (reasoningEffort != null) 'reasoning_effort': reasoningEffort!.value,
  };

  /// Creates a copy with replaced values.
  AgentCompletionRequest copyWith({
    String? agentId,
    List<ChatMessage>? messages,
    Object? maxTokens = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? randomSeed = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? n = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? prediction = unsetCopyWithValue,
    Object? promptMode = unsetCopyWithValue,
    Object? reasoningEffort = unsetCopyWithValue,
  }) {
    return AgentCompletionRequest(
      agentId: agentId ?? this.agentId,
      messages: messages ?? this.messages,
      maxTokens: maxTokens == unsetCopyWithValue
          ? this.maxTokens
          : maxTokens as int?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      stop: stop == unsetCopyWithValue ? this.stop : stop as StopSequence?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      tools: tools == unsetCopyWithValue ? this.tools : tools as List<Tool>?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ResponseFormat?,
      randomSeed: randomSeed == unsetCopyWithValue
          ? this.randomSeed
          : randomSeed as int?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      n: n == unsetCopyWithValue ? this.n : n as int?,
      parallelToolCalls: parallelToolCalls == unsetCopyWithValue
          ? this.parallelToolCalls
          : parallelToolCalls as bool?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      prediction: prediction == unsetCopyWithValue
          ? this.prediction
          : prediction as Prediction?,
      promptMode: promptMode == unsetCopyWithValue
          ? this.promptMode
          : promptMode as MistralPromptMode?,
      reasoningEffort: reasoningEffort == unsetCopyWithValue
          ? this.reasoningEffort
          : reasoningEffort as ReasoningEffort?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AgentCompletionRequest) return false;
    if (runtimeType != other.runtimeType) return false;

    // Compare lists with deep equality
    if (!listsEqual(messages, other.messages)) return false;
    if (!listsEqual(tools, other.tools)) return false;

    return agentId == other.agentId &&
        maxTokens == other.maxTokens &&
        stream == other.stream &&
        stop == other.stop &&
        temperature == other.temperature &&
        topP == other.topP &&
        toolChoice == other.toolChoice &&
        responseFormat == other.responseFormat &&
        randomSeed == other.randomSeed &&
        frequencyPenalty == other.frequencyPenalty &&
        presencePenalty == other.presencePenalty &&
        n == other.n &&
        parallelToolCalls == other.parallelToolCalls &&
        mapsEqual(metadata, other.metadata) &&
        prediction == other.prediction &&
        promptMode == other.promptMode &&
        reasoningEffort == other.reasoningEffort;
    // messages and tools compared above via listsEqual
  }

  @override
  int get hashCode => Object.hash(
    agentId,
    Object.hashAll(messages),
    maxTokens,
    stream,
    stop,
    temperature,
    topP,
    listHash(tools),
    toolChoice,
    responseFormat,
    randomSeed,
    frequencyPenalty,
    presencePenalty,
    n,
    parallelToolCalls,
    mapHash(metadata),
    Object.hash(prediction, promptMode, reasoningEffort),
  );

  @override
  String toString() =>
      'AgentCompletionRequest(agentId: $agentId, '
      'messages: ${messages.length}, '
      'maxTokens: $maxTokens, '
      'stream: $stream, '
      'stop: $stop, '
      'temperature: $temperature, '
      'topP: $topP, '
      'tools: $tools, '
      'toolChoice: $toolChoice, '
      'responseFormat: $responseFormat, '
      'randomSeed: $randomSeed, '
      'frequencyPenalty: $frequencyPenalty, '
      'presencePenalty: $presencePenalty, '
      'n: $n, '
      'parallelToolCalls: $parallelToolCalls, '
      'metadata: $metadata, '
      'prediction: $prediction, '
      'promptMode: $promptMode, '
      'reasoningEffort: $reasoningEffort)';
}
