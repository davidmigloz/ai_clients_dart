import 'dart:convert';

import 'package:meta/meta.dart';

import '../chat/chat_completion.dart';
import '../chat/chat_message.dart';
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
      // Some providers may return null or omit the delta field
      delta: json['delta'] is Map<String, dynamic>
          ? ChatDelta.fromJson(json['delta'] as Map<String, dynamic>)
          : const ChatDelta(),
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
  ///
  /// Defaults to an empty delta if null or missing in the JSON response,
  /// which can occur with some OpenAI-compatible providers.
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
      toolCalls: (json['tool_calls'] as List<dynamic>?)?.indexed
          .map(
            (e) => ToolCallDelta.fromJson(
              e.$2 as Map<String, dynamic>,
              fallbackIndex: e.$1,
            ),
          )
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
  ///
  /// If `index` is missing from [json], [fallbackIndex] is used instead
  /// (defaults to 0). This handles OpenAI-compatible providers (e.g. Ollama)
  /// that omit the field.
  factory ToolCallDelta.fromJson(
    Map<String, dynamic> json, {
    int fallbackIndex = 0,
  }) {
    return ToolCallDelta(
      index: json['index'] as int? ?? fallbackIndex,
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
      // Some providers (e.g., Llamafile, custom Bedrock proxies) may return
      // a parsed object instead of a JSON string fragment.
      arguments: switch (json['arguments']) {
        final String s => s,
        final Map<dynamic, dynamic> m => jsonEncode(m),
        _ => null,
      },
    );
  }

  /// The name of the function (only in the first chunk for this function).
  final String? name;

  /// The partial arguments string for this chunk.
  ///
  /// Per the OpenAI spec, this is a JSON string fragment. Some providers
  /// (e.g., Llamafile, custom Bedrock proxies) may return a parsed object
  /// instead. The [fromJson] factory handles both formats.
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

/// A read-only snapshot of a single accumulated choice's state.
///
/// Each instance corresponds to one of the `n` choices in the request.
/// For standard requests (`n=1`), there is a single [AccumulatedChoice].
///
/// Use [ChatStreamAccumulator.choices] to access per-choice state.
@immutable
class AccumulatedChoice {
  const AccumulatedChoice._({
    required this.index,
    required this.content,
    required this.refusal,
    required this.role,
    required this.finishReason,
    required this.toolCalls,
    required this.reasoningContent,
    required this.reasoning,
    required this.reasoningDetails,
    required this.logprobs,
  });

  /// The index of this choice.
  final int index;

  /// The accumulated text content.
  final String content;

  /// The accumulated refusal content.
  final String refusal;

  /// The message role.
  final String? role;

  /// The finish reason.
  final FinishReason? finishReason;

  /// The accumulated tool calls.
  final List<ToolCall> toolCalls;

  /// **DeepSeek R1 / vLLM only.** The accumulated reasoning content.
  final String reasoningContent;

  /// **OpenRouter only.** The accumulated reasoning summary.
  final String reasoning;

  /// **OpenRouter only.** The accumulated reasoning details.
  final List<ReasoningDetail> reasoningDetails;

  /// Log probability information.
  final Logprobs? logprobs;

  /// Whether there are any tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// Whether there is any reasoning content.
  bool get hasReasoningContent =>
      reasoningContent.isNotEmpty || reasoning.isNotEmpty;
}

/// Helper class for accumulating streaming chunks into a complete response.
///
/// Use this to merge all streaming deltas into a final [ChatCompletion]-like
/// object. Supports multi-choice streams (`n > 1`) with independent
/// per-choice accumulation.
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
///
/// // For multi-choice streams, access per-choice state:
/// for (final choice in accumulator.choices) {
///   print('Choice ${choice.index}: ${choice.content}');
/// }
/// ```
class ChatStreamAccumulator {
  /// Creates a [ChatStreamAccumulator].
  ChatStreamAccumulator();

  String? _id;
  String? _model;
  int? _created;
  String? _systemFingerprint;
  String? _serviceTier;
  String? _provider;
  Usage? _usage;
  final List<_AccumulatedChoice> _choices = [];

  _AccumulatedChoice _getOrCreateChoice(int index) {
    while (_choices.length <= index) {
      _choices.add(_AccumulatedChoice());
    }
    return _choices[index];
  }

  /// Adds a streaming event to the accumulator.
  void add(ChatStreamEvent event) {
    _id ??= event.id;
    _model ??= event.model;
    _created ??= event.created;
    _systemFingerprint ??= event.systemFingerprint;
    _serviceTier ??= event.serviceTier;
    _provider ??= event.provider;
    if (event.usage != null) _usage = event.usage;

    // Handle nullable choices for compatibility with providers like Groq
    final choices = event.choices;
    if (choices == null) return;

    for (final choice in choices) {
      final choiceIndex = choice.index ?? 0;
      final accumulated = _getOrCreateChoice(choiceIndex);
      final delta = choice.delta;

      accumulated.role ??= delta.role;
      accumulated.finishReason ??= choice.finishReason;

      if (delta.content != null) {
        accumulated.content.write(delta.content);
      }

      if (delta.refusal != null) {
        accumulated.refusal.write(delta.refusal);
      }

      // Accumulate reasoning content for OpenRouter/DeepSeek compatibility
      if (delta.reasoningContent != null) {
        accumulated.reasoningContent.write(delta.reasoningContent);
      }

      if (delta.reasoning != null) {
        accumulated.reasoning.write(delta.reasoning);
      }

      if (delta.reasoningDetails != null) {
        accumulated.reasoningDetails.addAll(delta.reasoningDetails!);
      }

      if (delta.toolCalls != null) {
        for (final tc in delta.toolCalls!) {
          _accumulateToolCall(accumulated, tc);
        }
      }

      if (choice.logprobs != null) {
        if (choice.logprobs!.content != null) {
          accumulated.logprobsContent.addAll(choice.logprobs!.content!);
        }
        if (choice.logprobs!.refusal != null) {
          accumulated.logprobsRefusal.addAll(choice.logprobs!.refusal!);
        }
      }
    }
  }

  void _accumulateToolCall(_AccumulatedChoice choice, ToolCallDelta delta) {
    // Find or create the tool call at this index
    while (choice.toolCalls.length <= delta.index) {
      choice.toolCalls.add(_AccumulatedToolCall());
    }

    final accumulated = choice.toolCalls[delta.index]
      ..id ??= delta.id
      ..type ??= delta.type;

    if (delta.function case final fn?) {
      accumulated.functionName ??= fn.name;
      if (fn.arguments case final args?) {
        accumulated.arguments.write(args);
      }
    }
  }

  List<ToolCall> _buildToolCalls(_AccumulatedChoice choice) {
    return choice.toolCalls
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
  }

  Logprobs? _buildLogprobs(_AccumulatedChoice choice) {
    if (choice.logprobsContent.isEmpty && choice.logprobsRefusal.isEmpty) {
      return null;
    }
    return Logprobs(
      content: choice.logprobsContent.isNotEmpty
          ? choice.logprobsContent
          : null,
      refusal: choice.logprobsRefusal.isNotEmpty
          ? choice.logprobsRefusal
          : null,
    );
  }

  /// The completion ID.
  String? get id => _id;

  /// The model used.
  String? get model => _model;

  /// The service tier used (if applicable).
  String? get serviceTier => _serviceTier;

  /// **OpenRouter only.** The provider that served the request.
  String? get provider => _provider;

  /// The accumulated text content.
  ///
  /// For multi-choice streams, returns choice 0's content.
  String get content => _choices.isEmpty ? '' : _choices[0].content.toString();

  /// The accumulated refusal content.
  ///
  /// For multi-choice streams, returns choice 0's refusal.
  String get refusal => _choices.isEmpty ? '' : _choices[0].refusal.toString();

  /// **DeepSeek R1 / vLLM only.** The accumulated reasoning content.
  ///
  /// Not part of the official OpenAI API.
  /// For multi-choice streams, returns choice 0's reasoning content.
  String get reasoningContent =>
      _choices.isEmpty ? '' : _choices[0].reasoningContent.toString();

  /// **OpenRouter only.** The accumulated reasoning summary.
  ///
  /// Not part of the official OpenAI API.
  /// For multi-choice streams, returns choice 0's reasoning.
  String get reasoning =>
      _choices.isEmpty ? '' : _choices[0].reasoning.toString();

  /// Whether there is any reasoning content.
  ///
  /// For multi-choice streams, checks choice 0.
  bool get hasReasoningContent =>
      _choices.isNotEmpty &&
      (_choices[0].reasoningContent.isNotEmpty ||
          _choices[0].reasoning.isNotEmpty);

  /// The message role.
  ///
  /// For multi-choice streams, returns choice 0's role.
  String? get role => _choices.isEmpty ? null : _choices[0].role;

  /// The finish reason.
  ///
  /// For multi-choice streams, returns choice 0's finish reason.
  FinishReason? get finishReason =>
      _choices.isEmpty ? null : _choices[0].finishReason;

  /// Token usage statistics.
  Usage? get usage => _usage;

  /// The accumulated tool calls.
  ///
  /// For multi-choice streams, returns choice 0's tool calls.
  List<ToolCall> get toolCalls =>
      _choices.isEmpty ? const [] : _buildToolCalls(_choices[0]);

  /// Whether there are any tool calls.
  ///
  /// For multi-choice streams, checks choice 0.
  bool get hasToolCalls =>
      _choices.isNotEmpty && _choices[0].toolCalls.any((tc) => tc.id != null);

  /// Returns a read-only view of all accumulated choices.
  ///
  /// Each element corresponds to one of the `n` choices in the request.
  /// For standard requests (`n=1`), this list has a single element.
  ///
  /// Note: Each call creates fresh snapshot objects. For hot-path access
  /// during streaming, prefer the flat getters (`content`, `toolCalls`, etc.)
  /// which delegate to choice 0 without allocation.
  List<AccumulatedChoice> get choices => [
    for (var i = 0; i < _choices.length; i++)
      AccumulatedChoice._(
        index: i,
        content: _choices[i].content.toString(),
        refusal: _choices[i].refusal.toString(),
        role: _choices[i].role,
        finishReason: _choices[i].finishReason,
        toolCalls: _buildToolCalls(_choices[i]),
        reasoningContent: _choices[i].reasoningContent.toString(),
        reasoning: _choices[i].reasoning.toString(),
        reasoningDetails: List.unmodifiable(_choices[i].reasoningDetails),
        logprobs: _buildLogprobs(_choices[i]),
      ),
  ];

  /// Builds a [ChatCompletion] from the accumulated stream data.
  ///
  /// This assembles the accumulated content, tool calls, reasoning, and
  /// metadata into a complete [ChatCompletion] object — the same type
  /// returned by the non-streaming chat completions endpoint.
  ///
  /// For multi-choice streams, produces one [ChatChoice] per accumulated
  /// choice with independent content, tool calls, and finish reasons.
  ChatCompletion toChatCompletion() {
    final chatChoices = _choices.isEmpty
        ? [const ChatChoice(index: 0, message: AssistantMessage())]
        : [
            for (var i = 0; i < _choices.length; i++)
              _buildChatChoice(i, _choices[i]),
          ];

    return ChatCompletion(
      id: _id,
      object: 'chat.completion',
      created: _created,
      model: _model ?? '',
      choices: chatChoices,
      usage: _usage,
      systemFingerprint: _systemFingerprint,
      serviceTier: _serviceTier,
      provider: _provider,
    );
  }

  ChatChoice _buildChatChoice(int index, _AccumulatedChoice choice) {
    final contentStr = choice.content.toString();
    final refusalStr = choice.refusal.toString();
    final reasoningContentStr = choice.reasoningContent.toString();
    final reasoningStr = choice.reasoning.toString();
    final tcs = _buildToolCalls(choice);
    final lp = _buildLogprobs(choice);
    final rds = choice.reasoningDetails;

    return ChatChoice(
      index: index,
      finishReason: choice.finishReason,
      logprobs: lp,
      message: AssistantMessage(
        content: contentStr.isNotEmpty ? contentStr : null,
        refusal: refusalStr.isNotEmpty ? refusalStr : null,
        toolCalls: tcs.isNotEmpty ? tcs : null,
        reasoningContent: reasoningContentStr.isNotEmpty
            ? reasoningContentStr
            : null,
        reasoning: reasoningStr.isNotEmpty ? reasoningStr : null,
        reasoningDetails: rds.isNotEmpty ? List.unmodifiable(rds) : null,
      ),
    );
  }

  /// Resets the accumulator for reuse.
  void reset() {
    _id = null;
    _model = null;
    _created = null;
    _systemFingerprint = null;
    _serviceTier = null;
    _provider = null;
    _usage = null;
    _choices.clear();
  }
}

/// Internal helper for accumulating per-choice state.
class _AccumulatedChoice {
  String? role;
  FinishReason? finishReason;
  final StringBuffer content = StringBuffer();
  final StringBuffer refusal = StringBuffer();
  final StringBuffer reasoningContent = StringBuffer();
  final StringBuffer reasoning = StringBuffer();
  final List<ReasoningDetail> reasoningDetails = [];
  final List<_AccumulatedToolCall> toolCalls = [];
  final List<TokenLogprob> logprobsContent = [];
  final List<TokenLogprob> logprobsRefusal = [];
}

/// Internal helper for accumulating tool call data.
class _AccumulatedToolCall {
  String? id;
  String? type;
  String? functionName;
  final StringBuffer arguments = StringBuffer();
}
