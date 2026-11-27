import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/completion_args.dart';
import '../metadata/response_format.dart';
import '../metadata/stop_sequence.dart';
import '../moderations/guardrail_config.dart';
import '../tools/tool.dart';
import '../tools/tool_call_confirmation.dart';
import '../tools/tool_choice.dart';
import 'conversation_entry.dart';

/// Starts a conversation.
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
  int? get maxTokens => completionArgs?.maxTokens ?? _maxTokens;
  final int? _maxTokens;

  /// Stop sequences for generation.
  List<String>? get stop => _stopAsList(completionArgs?.stop) ?? _stop;
  final List<String>? _stop;

  /// Sampling temperature (0.0 to 1.0).
  double? get temperature => completionArgs?.temperature ?? _temperature;
  final double? _temperature;

  /// Nucleus sampling parameter.
  double? get topP => completionArgs?.topP ?? _topP;
  final double? _topP;

  /// Tools available for the conversation.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  ToolChoice? get toolChoice => completionArgs?.toolChoice ?? _toolChoice;
  final ToolChoice? _toolChoice;

  /// The format of the response.
  ResponseFormat? get responseFormat =>
      completionArgs?.responseFormat ?? _responseFormat;
  final ResponseFormat? _responseFormat;

  /// Random seed for reproducibility.
  int? get randomSeed => completionArgs?.randomSeed ?? _randomSeed;
  final int? _randomSeed;

  /// Optional metadata for the conversation.
  final Map<String, dynamic>? metadata;

  /// Guardrail configurations for content moderation.
  final List<GuardrailConfig>? guardrails;

  /// Generation settings sent under `completion_args`.
  /// Individually supplied settings provide defaults for fields omitted here.
  final CompletionArgs? completionArgs;

  /// A plain string to send as the input instead of entries.
  final String? inputText;

  /// Whether handoffs run on the server or client.
  final String? handoffExecution;

  /// An agent version number or alias.
  final Object? agentVersion;

  /// A display name for the conversation.
  final String? name;

  /// What this conversation is about.
  final String? description;

  /// System instructions for model conversations.
  final String? instructions;

  /// Creates a [StartConversationRequest].
  const StartConversationRequest({
    this.model,
    this.agentId,
    this.inputs = const [],
    this.store,
    this._maxTokens,
    this._stop,
    this._temperature,
    this._topP,
    this.tools,
    this._toolChoice,
    this._responseFormat,
    this._randomSeed,
    this.metadata,
    this.guardrails,
    this.completionArgs,
    this.inputText,
    this.handoffExecution,
    this.agentVersion,
    this.name,
    this.description,
    this.instructions,
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
    final args = json['completion_args'] == null
        ? null
        : CompletionArgs.fromJson(
            json['completion_args'] as Map<String, dynamic>,
          );
    final rawInput = json['inputs'];
    return StartConversationRequest(
      model: json['model'] as String?,
      agentId: json['agent_id'] as String?,
      inputs: _decodeEntries(rawInput) ?? const [],
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: _decodeStop(json['stop']),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] == null
          ? null
          : ToolChoice.fromJson(json['tool_choice'] as Object),
      responseFormat: json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            ),
      randomSeed: json['random_seed'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      guardrails: (json['guardrails'] as List?)
          ?.map((e) => GuardrailConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionArgs: args,
      inputText: rawInput is String ? rawInput : null,
      handoffExecution: json['handoff_execution'] as String?,
      agentVersion: json['agent_version'] as Object?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    final args = _completionWithFallbacks(
      completionArgs,
      maxTokens: maxTokens,
      stop: stop,
      temperature: temperature,
      topP: topP,
      toolChoice: toolChoice,
      responseFormat: responseFormat,
      randomSeed: randomSeed,
    );
    return {
      if (model != null) 'model': model,
      if (agentId != null) 'agent_id': agentId,
      'inputs': inputText ?? inputs.map((e) => e.toJson()).toList(),
      if (store != null) 'store': store,
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
      if (guardrails != null)
        'guardrails': guardrails!.map((e) => e.toJson()).toList(),
      'completion_args': ?args?.toJson(),
      'handoff_execution': ?handoffExecution,
      'agent_version': ?_agentVersionToJson(agentVersion),
      'name': ?name,
      'description': ?description,
      'instructions': ?instructions,
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
    List<GuardrailConfig>? guardrails,
    Object? completionArgs = unsetCopyWithValue,
    Object? inputText = unsetCopyWithValue,
    Object? handoffExecution = unsetCopyWithValue,
    Object? agentVersion = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
  }) {
    return StartConversationRequest(
      model: model ?? this.model,
      agentId: agentId ?? this.agentId,
      inputs: inputs ?? this.inputs,
      store: store ?? this.store,
      maxTokens: maxTokens ?? _maxTokens,
      stop: stop ?? _stop,
      temperature: temperature ?? _temperature,
      topP: topP ?? _topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? _toolChoice,
      responseFormat: responseFormat ?? _responseFormat,
      randomSeed: randomSeed ?? _randomSeed,
      metadata: metadata ?? this.metadata,
      guardrails: guardrails ?? this.guardrails,
      completionArgs: completionArgs == unsetCopyWithValue
          ? _replaceCompletionArgs(
              this.completionArgs,
              maxTokens: maxTokens,
              stop: stop,
              temperature: temperature,
              topP: topP,
              toolChoice: toolChoice,
              responseFormat: responseFormat,
              randomSeed: randomSeed,
            )
          : completionArgs as CompletionArgs?,
      inputText: inputText == unsetCopyWithValue
          ? (inputs == null ? this.inputText : null)
          : inputText as String?,
      handoffExecution: handoffExecution == unsetCopyWithValue
          ? this.handoffExecution
          : handoffExecution as String?,
      agentVersion: agentVersion == unsetCopyWithValue
          ? this.agentVersion
          : agentVersion,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
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

/// Appends entries to an existing conversation.
@immutable
class AppendConversationRequest {
  /// The inputs to append to the conversation.
  final List<ConversationEntry>? inputs;

  /// Whether to store the results on Mistral's servers.
  final bool? store;

  /// Maximum number of tokens to generate.
  int? get maxTokens => completionArgs?.maxTokens ?? _maxTokens;
  final int? _maxTokens;

  /// Stop sequences for generation.
  List<String>? get stop => _stopAsList(completionArgs?.stop) ?? _stop;
  final List<String>? _stop;

  /// Sampling temperature (0.0 to 1.0).
  double? get temperature => completionArgs?.temperature ?? _temperature;
  final double? _temperature;

  /// Nucleus sampling parameter.
  double? get topP => completionArgs?.topP ?? _topP;
  final double? _topP;

  /// Legacy field. Tools are configured when the conversation starts.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  ToolChoice? get toolChoice => completionArgs?.toolChoice ?? _toolChoice;
  final ToolChoice? _toolChoice;

  /// The format of the response.
  ResponseFormat? get responseFormat =>
      completionArgs?.responseFormat ?? _responseFormat;
  final ResponseFormat? _responseFormat;

  /// Random seed for reproducibility.
  int? get randomSeed => completionArgs?.randomSeed ?? _randomSeed;
  final int? _randomSeed;

  /// Tool call confirmations for calls requiring user approval.
  final List<ToolCallConfirmation>? toolConfirmations;

  /// Generation settings sent under `completion_args`.
  /// Individually supplied settings provide defaults for fields omitted here.
  final CompletionArgs? completionArgs;

  /// A plain string to send as the input instead of entries.
  final String? inputText;

  /// Whether handoffs run on the server or client.
  final String? handoffExecution;

  /// Creates an [AppendConversationRequest].
  const AppendConversationRequest({
    this.inputs,
    this.store,
    this._maxTokens,
    this._stop,
    this._temperature,
    this._topP,
    this.tools,
    this._toolChoice,
    this._responseFormat,
    this._randomSeed,
    this.toolConfirmations,
    this.completionArgs,
    this.inputText,
    this.handoffExecution,
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
    final args = json['completion_args'] == null
        ? null
        : CompletionArgs.fromJson(
            json['completion_args'] as Map<String, dynamic>,
          );
    final rawInput = json['inputs'];
    return AppendConversationRequest(
      inputs: _decodeEntries(rawInput),
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: _decodeStop(json['stop']),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] == null
          ? null
          : ToolChoice.fromJson(json['tool_choice'] as Object),
      responseFormat: json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            ),
      randomSeed: json['random_seed'] as int?,
      toolConfirmations: (json['tool_confirmations'] as List<dynamic>?)
          ?.map((e) => ToolCallConfirmation.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionArgs: args,
      inputText: rawInput is String ? rawInput : null,
      handoffExecution: json['handoff_execution'] as String?,
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    final args = _completionWithFallbacks(
      completionArgs,
      maxTokens: maxTokens,
      stop: stop,
      temperature: temperature,
      topP: topP,
      toolChoice: toolChoice,
      responseFormat: responseFormat,
      randomSeed: randomSeed,
    );
    return {
      'inputs': ?(inputText ?? inputs?.map((e) => e.toJson()).toList()),
      if (store != null) 'store': store,
      if (toolConfirmations != null)
        'tool_confirmations': toolConfirmations!
            .map((e) => e.toJson())
            .toList(),
      'completion_args': ?args?.toJson(),
      'handoff_execution': ?handoffExecution,
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
    List<ToolCallConfirmation>? toolConfirmations,
    Object? completionArgs = unsetCopyWithValue,
    Object? inputText = unsetCopyWithValue,
    Object? handoffExecution = unsetCopyWithValue,
  }) {
    return AppendConversationRequest(
      inputs: inputs ?? this.inputs,
      store: store ?? this.store,
      maxTokens: maxTokens ?? _maxTokens,
      stop: stop ?? _stop,
      temperature: temperature ?? _temperature,
      topP: topP ?? _topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? _toolChoice,
      responseFormat: responseFormat ?? _responseFormat,
      randomSeed: randomSeed ?? _randomSeed,
      toolConfirmations: toolConfirmations ?? this.toolConfirmations,
      completionArgs: completionArgs == unsetCopyWithValue
          ? _replaceCompletionArgs(
              this.completionArgs,
              maxTokens: maxTokens,
              stop: stop,
              temperature: temperature,
              topP: topP,
              toolChoice: toolChoice,
              responseFormat: responseFormat,
              randomSeed: randomSeed,
            )
          : completionArgs as CompletionArgs?,
      inputText: inputText == unsetCopyWithValue
          ? (inputs == null ? this.inputText : null)
          : inputText as String?,
      handoffExecution: handoffExecution == unsetCopyWithValue
          ? this.handoffExecution
          : handoffExecution as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppendConversationRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(inputs, other.inputs) &&
          store == other.store &&
          maxTokens == other.maxTokens &&
          listsEqual(stop, other.stop) &&
          temperature == other.temperature &&
          topP == other.topP &&
          listsEqual(tools, other.tools) &&
          toolChoice == other.toolChoice &&
          responseFormat == other.responseFormat &&
          randomSeed == other.randomSeed &&
          listsEqual(toolConfirmations, other.toolConfirmations) &&
          completionArgs == other.completionArgs &&
          inputText == other.inputText &&
          handoffExecution == other.handoffExecution;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(inputs ?? []),
    store,
    maxTokens,
    Object.hashAll(stop ?? []),
    temperature,
    topP,
    Object.hashAll(tools ?? []),
    toolChoice,
    responseFormat,
    randomSeed,
    Object.hashAll(toolConfirmations ?? []),
  );

  @override
  String toString() =>
      'AppendConversationRequest(inputs: ${inputs?.length ?? 0})';
}

/// Restarts a conversation from a specific entry.
@immutable
class RestartConversationRequest {
  /// The ID of the entry to restart from.
  final String entryId;

  /// Whether to store the results on Mistral's servers.
  final bool? store;

  /// Maximum number of tokens to generate.
  int? get maxTokens => completionArgs?.maxTokens ?? _maxTokens;
  final int? _maxTokens;

  /// Stop sequences for generation.
  List<String>? get stop => _stopAsList(completionArgs?.stop) ?? _stop;
  final List<String>? _stop;

  /// Sampling temperature (0.0 to 1.0).
  double? get temperature => completionArgs?.temperature ?? _temperature;
  final double? _temperature;

  /// Nucleus sampling parameter.
  double? get topP => completionArgs?.topP ?? _topP;
  final double? _topP;

  /// Legacy field. Tools are configured when the conversation starts.
  final List<Tool>? tools;

  /// How the model should choose which tool to call.
  ToolChoice? get toolChoice => completionArgs?.toolChoice ?? _toolChoice;
  final ToolChoice? _toolChoice;

  /// The format of the response.
  ResponseFormat? get responseFormat =>
      completionArgs?.responseFormat ?? _responseFormat;
  final ResponseFormat? _responseFormat;

  /// Random seed for reproducibility.
  int? get randomSeed => completionArgs?.randomSeed ?? _randomSeed;
  final int? _randomSeed;

  /// Guardrail configurations for content moderation.
  final List<GuardrailConfig>? guardrails;

  /// Generation settings sent under `completion_args`.
  /// Individually supplied settings provide defaults for fields omitted here.
  final CompletionArgs? completionArgs;

  /// A plain string to send as the input instead of entries.
  final String? inputText;

  /// Whether handoffs run on the server or client.
  final String? handoffExecution;

  /// An agent version number or alias.
  final Object? agentVersion;

  /// New entries to append after the restart point.
  final List<ConversationEntry>? inputs;

  /// Metadata for the restarted conversation.
  final Map<String, dynamic>? metadata;

  /// Creates a [RestartConversationRequest].
  const RestartConversationRequest({
    required this.entryId,
    this.store,
    this._maxTokens,
    this._stop,
    this._temperature,
    this._topP,
    this.tools,
    this._toolChoice,
    this._responseFormat,
    this._randomSeed,
    this.guardrails,
    this.completionArgs,
    this.inputText,
    this.handoffExecution,
    this.agentVersion,
    this.inputs,
    this.metadata,
  });

  /// Creates a [RestartConversationRequest] from JSON.
  factory RestartConversationRequest.fromJson(Map<String, dynamic> json) {
    final args = json['completion_args'] == null
        ? null
        : CompletionArgs.fromJson(
            json['completion_args'] as Map<String, dynamic>,
          );
    final rawInput = json['inputs'];
    return RestartConversationRequest(
      entryId:
          json['from_entry_id'] as String? ?? json['entry_id'] as String? ?? '',
      store: json['store'] as bool?,
      maxTokens: json['max_tokens'] as int?,
      stop: _decodeStop(json['stop']),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] == null
          ? null
          : ToolChoice.fromJson(json['tool_choice'] as Object),
      responseFormat: json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>,
            ),
      randomSeed: json['random_seed'] as int?,
      guardrails: (json['guardrails'] as List?)
          ?.map((e) => GuardrailConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionArgs: args,
      inputText: rawInput is String ? rawInput : null,
      handoffExecution: json['handoff_execution'] as String?,
      agentVersion: json['agent_version'] as Object?,
      inputs: _decodeEntries(rawInput),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    final args = _completionWithFallbacks(
      completionArgs,
      maxTokens: maxTokens,
      stop: stop,
      temperature: temperature,
      topP: topP,
      toolChoice: toolChoice,
      responseFormat: responseFormat,
      randomSeed: randomSeed,
    );
    return {
      'from_entry_id': entryId,
      'inputs': ?(inputText ?? inputs?.map((e) => e.toJson()).toList()),
      if (store != null) 'store': store,
      if (guardrails != null)
        'guardrails': guardrails!.map((e) => e.toJson()).toList(),
      'completion_args': ?args?.toJson(),
      'handoff_execution': ?handoffExecution,
      'agent_version': ?_agentVersionToJson(agentVersion),
      'metadata': ?metadata,
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
    List<GuardrailConfig>? guardrails,
    Object? completionArgs = unsetCopyWithValue,
    Object? inputText = unsetCopyWithValue,
    Object? handoffExecution = unsetCopyWithValue,
    Object? agentVersion = unsetCopyWithValue,
    Object? inputs = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return RestartConversationRequest(
      entryId: entryId ?? this.entryId,
      store: store ?? this.store,
      maxTokens: maxTokens ?? _maxTokens,
      stop: stop ?? _stop,
      temperature: temperature ?? _temperature,
      topP: topP ?? _topP,
      tools: tools ?? this.tools,
      toolChoice: toolChoice ?? _toolChoice,
      responseFormat: responseFormat ?? _responseFormat,
      randomSeed: randomSeed ?? _randomSeed,
      guardrails: guardrails ?? this.guardrails,
      completionArgs: completionArgs == unsetCopyWithValue
          ? _replaceCompletionArgs(
              this.completionArgs,
              maxTokens: maxTokens,
              stop: stop,
              temperature: temperature,
              topP: topP,
              toolChoice: toolChoice,
              responseFormat: responseFormat,
              randomSeed: randomSeed,
            )
          : completionArgs as CompletionArgs?,
      inputText: inputText == unsetCopyWithValue
          ? (inputs == unsetCopyWithValue ? this.inputText : null)
          : inputText as String?,
      handoffExecution: handoffExecution == unsetCopyWithValue
          ? this.handoffExecution
          : handoffExecution as String?,
      agentVersion: agentVersion == unsetCopyWithValue
          ? this.agentVersion
          : agentVersion,
      inputs: inputs == unsetCopyWithValue
          ? this.inputs
          : inputs as List<ConversationEntry>?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
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

List<ConversationEntry>? _decodeEntries(Object? input) => switch (input) {
  final List<Object?> values => [
    for (final value in values)
      ConversationEntry.fromJson(value! as Map<String, dynamic>),
  ],
  _ => null,
};

List<String>? _stopAsList(StopSequence? stop) => switch (stop) {
  StopSequenceSingle(stop: final text) => [text],
  StopSequenceMultiple(:final stops) => stops,
  null => null,
};

Object? _agentVersionToJson(Object? value) => switch (value) {
  null || int() || String() => value,
  _ => throw ArgumentError.value(
    value,
    'agentVersion',
    'Expected an integer or alias.',
  ),
};

CompletionArgs? _completionWithFallbacks(
  CompletionArgs? args, {
  int? maxTokens,
  List<String>? stop,
  double? temperature,
  double? topP,
  ToolChoice? toolChoice,
  ResponseFormat? responseFormat,
  int? randomSeed,
}) {
  if (args == null &&
      maxTokens == null &&
      stop == null &&
      temperature == null &&
      topP == null &&
      toolChoice == null &&
      responseFormat == null &&
      randomSeed == null) {
    return null;
  }
  return _replaceCompletionArgs(
    args ?? const CompletionArgs(),
    maxTokens: args?.maxTokens ?? maxTokens,
    stop: args?.stop == null ? stop : null,
    temperature: args?.temperature ?? temperature,
    topP: args?.topP ?? topP,
    toolChoice: args?.toolChoice ?? toolChoice,
    responseFormat: args?.responseFormat ?? responseFormat,
    randomSeed: args?.randomSeed ?? randomSeed,
  );
}

CompletionArgs? _replaceCompletionArgs(
  CompletionArgs? args, {
  int? maxTokens,
  List<String>? stop,
  double? temperature,
  double? topP,
  ToolChoice? toolChoice,
  ResponseFormat? responseFormat,
  int? randomSeed,
}) => args?.copyWith(
  maxTokens: maxTokens ?? args.maxTokens,
  stop: stop == null ? args.stop : StopSequence.multiple(stop),
  temperature: temperature ?? args.temperature,
  topP: topP ?? args.topP,
  toolChoice: toolChoice ?? args.toolChoice,
  responseFormat: responseFormat ?? args.responseFormat,
  randomSeed: randomSeed ?? args.randomSeed,
);

List<String>? _decodeStop(Object? value) =>
    value == null ? null : _stopAsList(StopSequence.fromJson(value));
