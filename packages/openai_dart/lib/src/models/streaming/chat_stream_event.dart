import 'package:meta/meta.dart';

import '../chat/reasoning_detail.dart';
import '../chat/tool_call.dart';
import '../common/finish_reason.dart';
import '../common/logprobs.dart';
import '../common/usage.dart';

/// A streaming event from the chat completions API.
///
/// Streaming events are received as the model generates tokens.
/// Each event contains partial content that can be displayed
/// progressively to the user.
///
/// ## Example
///
/// ```dart
/// final stream = client.chat.completions.createStream(request);
///
/// await for (final event in stream) {
///   final content = event.choices?.first.delta.content;
///   if (content != null) {
///     stdout.write(content);
///   }
/// }
/// ```
@immutable
class ChatStreamEvent {
  /// Creates a [ChatStreamEvent].
  const ChatStreamEvent({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
    this.provider,
  });

  /// Creates a [ChatStreamEvent] from JSON.
  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) {
    return ChatStreamEvent(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: json['created'] as int?,
      model: json['model'] as String?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => ChatStreamChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      systemFingerprint: json['system_fingerprint'] as String?,
      serviceTier: json['service_tier'] as String?,
      provider: json['provider'] as String?,
    );
  }

  /// The unique identifier for this completion.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter
  /// doesn't return `id` with some models).
  final String? id;

  /// The object type (usually "chat.completion.chunk").
  ///
  /// May be null with some OpenAI-compatible providers (e.g., FastChat).
  /// Some providers send "chat.completion" instead of "chat.completion.chunk".
  final String? object;

  /// The Unix timestamp when this completion was created.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., FastChat).
  final int? created;

  /// The model used for this completion.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., TogetherAI).
  final String? model;

  /// The list of completion choices.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., Groq doesn't
  /// always return this field).
  final List<ChatStreamChoice>? choices;

  /// Token usage statistics (only in the final event if requested).
  final Usage? usage;

  /// The system fingerprint for the model configuration.
  final String? systemFingerprint;

  /// The service tier used (if applicable).
  final String? serviceTier;

  /// **OpenRouter only.** The provider that served the request.
  ///
  /// Not part of the official OpenAI API.
  final String? provider;

  /// Gets the text delta from the first choice.
  ///
  /// Returns null if there are no choices or no content delta.
  String? get textDelta => choices?.firstOrNull?.delta.content;

  /// Gets the first choice.
  ///
  /// Returns null if there are no choices.
  ChatStreamChoice? get firstChoice => choices?.firstOrNull;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (object != null) 'object': object,
    if (created != null) 'created': created,
    if (model != null) 'model': model,
    if (choices != null) 'choices': choices!.map((c) => c.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
    if (serviceTier != null) 'service_tier': serviceTier,
    if (provider != null) 'provider': provider,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          created == other.created;

  @override
  int get hashCode => Object.hash(id, created);

  @override
  String toString() => 'ChatStreamEvent(id: $id, model: $model)';
}

/// A single choice in a streaming response.
@immutable
class ChatStreamChoice {
  /// Creates a [ChatStreamChoice].
  const ChatStreamChoice({
    this.index,
    required this.delta,
    this.finishReason,
    this.logprobs,
  });

  /// Creates a [ChatStreamChoice] from JSON.
  factory ChatStreamChoice.fromJson(Map<String, dynamic> json) {
    return ChatStreamChoice(
      index: json['index'] as int?,
      delta: ChatDelta.fromJson(json['delta'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] != null
          ? FinishReason.fromJson(json['finish_reason'] as String)
          : null,
      logprobs: json['logprobs'] != null
          ? Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The index of this choice in the list.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter).
  final int? index;

  /// The delta content for this chunk.
  final ChatDelta delta;

  /// The reason the model stopped generating (in the final chunk).
  final FinishReason? finishReason;

  /// Log probability information.
  final Logprobs? logprobs;

  /// Whether this is the final chunk (has a finish reason).
  bool get isFinal => finishReason != null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (index != null) 'index': index,
    'delta': delta.toJson(),
    if (finishReason != null) 'finish_reason': finishReason!.toJson(),
    if (logprobs != null) 'logprobs': logprobs!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          delta == other.delta;

  @override
  int get hashCode => Object.hash(index, delta);

  @override
  String toString() => 'ChatStreamChoice(index: $index)';
}

/// The delta content in a streaming chunk.
///
/// Each delta contains only the new tokens generated since the last chunk.
@immutable
class ChatDelta {
  /// Creates a [ChatDelta].
  const ChatDelta({
    this.role,
    this.content,
    this.refusal,
    this.toolCalls,
    this.reasoningContent,
    this.reasoning,
    this.reasoningDetails,
  });

  /// Creates a [ChatDelta] from JSON.
  factory ChatDelta.fromJson(Map<String, dynamic> json) {
    return ChatDelta(
      role: json['role'] as String?,
      content: json['content'] as String?,
      refusal: json['refusal'] as String?,
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCallDelta.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Reasoning fields for OpenRouter/DeepSeek compatibility
      reasoningContent: json['reasoning_content'] as String?,
      reasoning: json['reasoning'] as String?,
      reasoningDetails: (json['reasoning_details'] as List<dynamic>?)
          ?.map((e) => ReasoningDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The role of the message author (only in the first chunk).
  final String? role;

  /// The new content tokens.
  final String? content;

  /// Refusal content (if the model refused to respond).
  final String? refusal;

  /// Tool call deltas.
  final List<ToolCallDelta>? toolCalls;

  /// **DeepSeek R1 / vLLM only.** Reasoning content delta.
  ///
  /// Not part of the official OpenAI API. Contains new reasoning tokens.
  final String? reasoningContent;

  /// **OpenRouter only.** Reasoning summary delta.
  ///
  /// Not part of the official OpenAI API.
  final String? reasoning;

  /// **OpenRouter only.** Detailed reasoning delta.
  ///
  /// Not part of the official OpenAI API.
  final List<ReasoningDetail>? reasoningDetails;

  /// Whether this delta has content.
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Whether this delta has tool calls.
  bool get hasToolCalls => toolCalls != null && toolCalls!.isNotEmpty;

  /// Whether this delta has reasoning content.
  bool get hasReasoningContent =>
      (reasoningContent != null && reasoningContent!.isNotEmpty) ||
      (reasoning != null && reasoning!.isNotEmpty);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (role != null) 'role': role,
    if (content != null) 'content': content,
    if (refusal != null) 'refusal': refusal,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((tc) => tc.toJson()).toList(),
    if (reasoningContent != null) 'reasoning_content': reasoningContent,
    if (reasoning != null) 'reasoning': reasoning,
    if (reasoningDetails != null)
      'reasoning_details': reasoningDetails!.map((rd) => rd.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDelta &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content &&
          refusal == other.refusal &&
          reasoningContent == other.reasoningContent &&
          reasoning == other.reasoning;

  @override
  int get hashCode =>
      Object.hash(role, content, refusal, reasoningContent, reasoning);

  @override
  String toString() {
    if (hasContent) return 'ChatDelta(content: $content)';
    if (hasReasoningContent) return 'ChatDelta(reasoning: ...)';
    if (hasToolCalls) return 'ChatDelta(toolCalls: ${toolCalls!.length})';
    if (role != null) return 'ChatDelta(role: $role)';
    return 'ChatDelta()';
  }
}

/// A tool call delta in a streaming chunk.
@immutable
class ToolCallDelta {
  /// Creates a [ToolCallDelta].
  const ToolCallDelta({required this.index, this.id, this.type, this.function});

  /// Creates a [ToolCallDelta] from JSON.
  factory ToolCallDelta.fromJson(Map<String, dynamic> json) {
    return ToolCallDelta(
      index: json['index'] as int,
      id: json['id'] as String?,
      type: json['type'] as String?,
      function: json['function'] != null
          ? FunctionCallDelta.fromJson(json['function'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The index of this tool call in the list.
  final int index;

  /// The ID of the tool call (only in the first chunk for this tool call).
  final String? id;

  /// The type of the tool call (only in the first chunk).
  final String? type;

  /// The function call delta.
  final FunctionCallDelta? function;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    if (id != null) 'id': id,
    if (type != null) 'type': type,
    if (function != null) 'function': function!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCallDelta &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          id == other.id;

  @override
  int get hashCode => Object.hash(index, id);

  @override
  String toString() => 'ToolCallDelta(index: $index)';
}

/// A function call delta in a streaming chunk.
@immutable
class FunctionCallDelta {
  /// Creates a [FunctionCallDelta].
  const FunctionCallDelta({this.name, this.arguments});

  /// Creates a [FunctionCallDelta] from JSON.
  factory FunctionCallDelta.fromJson(Map<String, dynamic> json) {
    return FunctionCallDelta(
      name: json['name'] as String?,
      arguments: json['arguments'] as String?,
    );
  }

  /// The name of the function (only in the first chunk for this function).
  final String? name;

  /// The arguments delta (partial JSON string).
  final String? arguments;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallDelta &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(name, arguments);

  @override
  String toString() {
    if (name != null) return 'FunctionCallDelta(name: $name)';
    return 'FunctionCallDelta(arguments: ${arguments?.length ?? 0} chars)';
  }
}

/// Helper class for accumulating streaming chunks into a complete response.
///
/// Use this to merge all streaming deltas into a final [ChatCompletion]-like
/// object.
///
/// ## Example
///
/// ```dart
/// final accumulator = ChatStreamAccumulator();
///
/// await for (final event in stream) {
///   accumulator.add(event);
///   stdout.write(event.textDelta ?? '');
/// }
///
/// final fullContent = accumulator.content;
/// final toolCalls = accumulator.toolCalls;
/// ```
class ChatStreamAccumulator {
  /// Creates a [ChatStreamAccumulator].
  ChatStreamAccumulator();

  String? _id;
  String? _model;
  int? _created;
  String? _systemFingerprint;
  final StringBuffer _content = StringBuffer();
  final StringBuffer _refusal = StringBuffer();
  final StringBuffer _reasoningContent = StringBuffer();
  final StringBuffer _reasoning = StringBuffer();
  String? _role;
  FinishReason? _finishReason;
  Usage? _usage;
  final List<_AccumulatedToolCall> _toolCalls = [];

  /// Adds a streaming event to the accumulator.
  void add(ChatStreamEvent event) {
    _id ??= event.id;
    _model ??= event.model;
    _created ??= event.created;
    _systemFingerprint ??= event.systemFingerprint;
    _usage ??= event.usage;

    // Handle nullable choices for compatibility with providers like Groq
    final choices = event.choices;
    if (choices == null) return;

    for (final choice in choices) {
      final delta = choice.delta;

      _role ??= delta.role;
      _finishReason ??= choice.finishReason;

      if (delta.content != null) {
        _content.write(delta.content);
      }

      if (delta.refusal != null) {
        _refusal.write(delta.refusal);
      }

      // Accumulate reasoning content for OpenRouter/DeepSeek compatibility
      if (delta.reasoningContent != null) {
        _reasoningContent.write(delta.reasoningContent);
      }

      if (delta.reasoning != null) {
        _reasoning.write(delta.reasoning);
      }

      if (delta.toolCalls != null) {
        delta.toolCalls!.forEach(_accumulateToolCall);
      }
    }
  }

  void _accumulateToolCall(ToolCallDelta delta) {
    // Find or create the tool call at this index
    while (_toolCalls.length <= delta.index) {
      _toolCalls.add(_AccumulatedToolCall());
    }

    final accumulated = _toolCalls[delta.index]
      ..id ??= delta.id
      ..type ??= delta.type;

    if (delta.function case final fn?) {
      accumulated.functionName ??= fn.name;
      if (fn.arguments case final args?) {
        accumulated.arguments.write(args);
      }
    }
  }

  /// The completion ID.
  String? get id => _id;

  /// The model used.
  String? get model => _model;

  /// The accumulated text content.
  String get content => _content.toString();

  /// The accumulated refusal content.
  String get refusal => _refusal.toString();

  /// **DeepSeek R1 / vLLM only.** The accumulated reasoning content.
  ///
  /// Not part of the official OpenAI API.
  String get reasoningContent => _reasoningContent.toString();

  /// **OpenRouter only.** The accumulated reasoning summary.
  ///
  /// Not part of the official OpenAI API.
  String get reasoning => _reasoning.toString();

  /// Whether there is any reasoning content.
  bool get hasReasoningContent =>
      _reasoningContent.isNotEmpty || _reasoning.isNotEmpty;

  /// The message role.
  String? get role => _role;

  /// The finish reason.
  FinishReason? get finishReason => _finishReason;

  /// Token usage statistics.
  Usage? get usage => _usage;

  /// The accumulated tool calls.
  List<ToolCall> get toolCalls => _toolCalls
      .where((tc) => tc.id != null && tc.functionName != null)
      .map(
        (tc) => ToolCall(
          id: tc.id!,
          type: tc.type ?? 'function',
          function: FunctionCall(
            name: tc.functionName!,
            arguments: tc.arguments.toString(),
          ),
        ),
      )
      .toList();

  /// Whether there are any tool calls.
  bool get hasToolCalls => _toolCalls.any((tc) => tc.id != null);

  /// Resets the accumulator for reuse.
  void reset() {
    _id = null;
    _model = null;
    _created = null;
    _systemFingerprint = null;
    _content.clear();
    _refusal.clear();
    _reasoningContent.clear();
    _reasoning.clear();
    _role = null;
    _finishReason = null;
    _usage = null;
    _toolCalls.clear();
  }
}

/// Internal helper for accumulating tool call data.
class _AccumulatedToolCall {
  String? id;
  String? type;
  String? functionName;
  final StringBuffer arguments = StringBuffer();
}
