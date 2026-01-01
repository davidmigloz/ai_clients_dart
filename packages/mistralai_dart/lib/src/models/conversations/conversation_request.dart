import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import '../metadata/response_format.dart';
import '../tools/tool.dart';
import '../tools/tool_choice.dart';
import 'conversation_entry.dart';

/// Request to start a new conversation.
@immutable
class StartConversationRequest {
  /// The model to use for the conversation.
  /// Either [model] or [agentId] must be provided.
  final String? model;

  /// The ID of the agent to use for the conversation.
  /// Either [model] or [agentId] must be provided.
  final String? agentId;

  /// The initial inputs to start the conversation.
  /// Can be a single string (user message) or a list of entries.
  final List<ConversationEntry> inputs;

  /// Whether to store the conversation on Mistral's servers.
  final bool? store;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Stop sequences for generation.
  final List<String>? stop;

  /// Sampling temperature (0.0 to 1.0).
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Tools available for the conversation.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  final ToolChoice? toolChoice;

  /// The format of the response.
  final ResponseFormat? responseFormat;

  /// Random seed for reproducibility.
  final int? randomSeed;

  /// Optional metadata for the conversation.
  final Map<String, dynamic>? metadata;

  /// Creates a [StartConversationRequest].
  const StartConversationRequest({
    this.model,
    this.agentId,
    required this.inputs,
    this.store,
    this.maxTokens,
    this.stop,
    this.temperature,
    this.topP,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.randomSeed,
    this.metadata,
  });

  /// Creates a request with a simple user message.
  factory StartConversationRequest.withMessage({
    String? model,
    String? agentId,
    required String message,
    bool? store,
    int? maxTokens,
    double? temperature,
    List<Tool>? tools,
  }) {
    return StartConversationRequest(
      model: model,
      agentId: agentId,
      inputs: [MessageInputEntry(content: message)],
      store: store,
      maxTokens: maxTokens,
      temperature: temperature,
      tools: tools,
    );
  }

  /// Creates a [StartConversationRequest] from JSON.
  factory StartConversationRequest.fromJson(Map<String, dynamic> json) {
    return StartConversationRequest(
      model: json['model'] as String?,
      agentId: json['agent_id'] as String?,
      inputs:
          (json['inputs'] as List<dynamic>?)
              ?.map(
                (e) => ConversationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: (json['stop'] as List<dynamic>?)?.cast<String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
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
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (model != null) 'model': model,
      if (agentId != null) 'agent_id': agentId,
      'inputs': inputs.map((e) => e.toJson()).toList(),
      if (store != null) 'store': store,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (stop != null) 'stop': stop,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
      if (responseFormat != null) 'response_format': responseFormat!.toJson(),
      if (randomSeed != null) 'random_seed': randomSeed,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a copy with the given fields replaced.
  StartConversationRequest copyWith({
    String? model,
    String? agentId,
    List<ConversationEntry>? inputs,
    bool? store,
    int? maxTokens,
    List<String>? stop,
    double? temperature,
    double? topP,
    List<Tool>? tools,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    int? randomSeed,
    Map<String, dynamic>? metadata,
  }) {
    return StartConversationRequest(
      model: model ?? this.model,
      agentId: agentId ?? this.agentId,
      inputs: inputs ?? this.inputs,
      store: store ?? this.store,
      maxTokens: maxTokens ?? this.maxTokens,
      stop: stop ?? this.stop,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      responseFormat: responseFormat ?? this.responseFormat,
      randomSeed: randomSeed ?? this.randomSeed,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartConversationRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          agentId == other.agentId;

  @override
  int get hashCode => Object.hash(model, agentId);

  @override
  String toString() =>
      'StartConversationRequest(model: $model, agentId: $agentId, inputs: ${inputs.length})';
}

/// Request to append entries to an existing conversation.
@immutable
class AppendConversationRequest {
  /// The inputs to append to the conversation.
  final List<ConversationEntry> inputs;

  /// Whether to store the results on Mistral's servers.
  final bool? store;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Stop sequences for generation.
  final List<String>? stop;

  /// Sampling temperature (0.0 to 1.0).
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Tools available for the conversation.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  final ToolChoice? toolChoice;

  /// The format of the response.
  final ResponseFormat? responseFormat;

  /// Random seed for reproducibility.
  final int? randomSeed;

  /// Creates an [AppendConversationRequest].
  const AppendConversationRequest({
    required this.inputs,
    this.store,
    this.maxTokens,
    this.stop,
    this.temperature,
    this.topP,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.randomSeed,
  });

  /// Creates a request with a simple user message.
  factory AppendConversationRequest.withMessage({
    required String message,
    bool? store,
    int? maxTokens,
    double? temperature,
  }) {
    return AppendConversationRequest(
      inputs: [MessageInputEntry(content: message)],
      store: store,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  /// Creates an [AppendConversationRequest] from JSON.
  factory AppendConversationRequest.fromJson(Map<String, dynamic> json) {
    return AppendConversationRequest(
      inputs:
          (json['inputs'] as List<dynamic>?)
              ?.map(
                (e) => ConversationEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: (json['stop'] as List<dynamic>?)?.cast<String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
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
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {
      'inputs': inputs.map((e) => e.toJson()).toList(),
      if (store != null) 'store': store,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (stop != null) 'stop': stop,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
      if (responseFormat != null) 'response_format': responseFormat!.toJson(),
      if (randomSeed != null) 'random_seed': randomSeed,
    };
  }

  /// Creates a copy with the given fields replaced.
  AppendConversationRequest copyWith({
    List<ConversationEntry>? inputs,
    bool? store,
    int? maxTokens,
    List<String>? stop,
    double? temperature,
    double? topP,
    List<Tool>? tools,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    int? randomSeed,
  }) {
    return AppendConversationRequest(
      inputs: inputs ?? this.inputs,
      store: store ?? this.store,
      maxTokens: maxTokens ?? this.maxTokens,
      stop: stop ?? this.stop,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      responseFormat: responseFormat ?? this.responseFormat,
      randomSeed: randomSeed ?? this.randomSeed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppendConversationRequest &&
          runtimeType == other.runtimeType &&
          listEquals(inputs, other.inputs) &&
          store == other.store &&
          maxTokens == other.maxTokens &&
          listEquals(stop, other.stop) &&
          temperature == other.temperature &&
          topP == other.topP &&
          listEquals(tools, other.tools) &&
          toolChoice == other.toolChoice &&
          responseFormat == other.responseFormat &&
          randomSeed == other.randomSeed;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(inputs),
    store,
    maxTokens,
    Object.hashAll(stop ?? []),
    temperature,
    topP,
    Object.hashAll(tools ?? []),
    toolChoice,
    responseFormat,
    randomSeed,
  );

  @override
  String toString() => 'AppendConversationRequest(inputs: ${inputs.length})';
}

/// Request to restart a conversation from a specific entry.
@immutable
class RestartConversationRequest {
  /// The ID of the entry to restart from.
  final String entryId;

  /// Whether to store the results on Mistral's servers.
  final bool? store;

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Stop sequences for generation.
  final List<String>? stop;

  /// Sampling temperature (0.0 to 1.0).
  final double? temperature;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Tools available for the conversation.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  final ToolChoice? toolChoice;

  /// The format of the response.
  final ResponseFormat? responseFormat;

  /// Random seed for reproducibility.
  final int? randomSeed;

  /// Creates a [RestartConversationRequest].
  const RestartConversationRequest({
    required this.entryId,
    this.store,
    this.maxTokens,
    this.stop,
    this.temperature,
    this.topP,
    this.tools,
    this.toolChoice,
    this.responseFormat,
    this.randomSeed,
  });

  /// Creates a [RestartConversationRequest] from JSON.
  factory RestartConversationRequest.fromJson(Map<String, dynamic> json) {
    return RestartConversationRequest(
      entryId: json['entry_id'] as String? ?? '',
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: (json['stop'] as List<dynamic>?)?.cast<String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
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
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      if (store != null) 'store': store,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (stop != null) 'stop': stop,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
      if (responseFormat != null) 'response_format': responseFormat!.toJson(),
      if (randomSeed != null) 'random_seed': randomSeed,
    };
  }

  /// Creates a copy with the given fields replaced.
  RestartConversationRequest copyWith({
    String? entryId,
    bool? store,
    int? maxTokens,
    List<String>? stop,
    double? temperature,
    double? topP,
    List<Tool>? tools,
    ToolChoice? toolChoice,
    ResponseFormat? responseFormat,
    int? randomSeed,
  }) {
    return RestartConversationRequest(
      entryId: entryId ?? this.entryId,
      store: store ?? this.store,
      maxTokens: maxTokens ?? this.maxTokens,
      stop: stop ?? this.stop,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? this.toolChoice,
      responseFormat: responseFormat ?? this.responseFormat,
      randomSeed: randomSeed ?? this.randomSeed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestartConversationRequest &&
          runtimeType == other.runtimeType &&
          entryId == other.entryId;

  @override
  int get hashCode => entryId.hashCode;

  @override
  String toString() => 'RestartConversationRequest(entryId: $entryId)';
}
