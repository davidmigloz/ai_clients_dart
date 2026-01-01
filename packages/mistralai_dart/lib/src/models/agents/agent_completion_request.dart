import 'package:meta/meta.dart';

import '../chat/chat_message.dart';
import '../metadata/response_format.dart';
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

  /// Stop sequences.
  final List<String>? stop;

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
        stop: (json['stop'] as List?)?.cast<String>(),
        temperature: (json['temperature'] as num?)?.toDouble(),
        topP: (json['top_p'] as num?)?.toDouble(),
        tools: (json['tools'] as List?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
        toolChoice: json['tool_choice'] != null
            ? ToolChoice.fromJson(json['tool_choice'])
            : null,
        responseFormat: json['response_format'] != null
            ? ResponseFormat.fromJson(
                json['response_format'] as Map<String, dynamic>,
              )
            : null,
        randomSeed: json['random_seed'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (maxTokens != null) 'max_tokens': maxTokens,
    if (stream != null) 'stream': stream,
    if (stop != null) 'stop': stop,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (randomSeed != null) 'random_seed': randomSeed,
  };

  /// Creates a copy with the specified fields replaced.
  AgentCompletionRequest copyWith({
    String? agentId,
    List<ChatMessage>? messages,
    int? maxTokens,
    bool? stream,
    List<String>? stop,
    double? temperature,
    double? topP,
    List<Tool>? tools,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    int? randomSeed,
  }) => AgentCompletionRequest(
    agentId: agentId ?? this.agentId,
    messages: messages ?? this.messages,
    maxTokens: maxTokens ?? this.maxTokens,
    stream: stream ?? this.stream,
    stop: stop ?? this.stop,
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    tools: tools ?? this.tools,
    toolChoice: toolChoice ?? this.toolChoice,
    responseFormat: responseFormat ?? this.responseFormat,
    randomSeed: randomSeed ?? this.randomSeed,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentCompletionRequest &&
          runtimeType == other.runtimeType &&
          agentId == other.agentId;

  @override
  int get hashCode => agentId.hashCode;

  @override
  String toString() =>
      'AgentCompletionRequest(agentId: $agentId, messages: ${messages.length})';
}
