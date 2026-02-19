import 'package:meta/meta.dart';

import '../common/finish_reason.dart';
import '../common/logprobs.dart';
import '../common/usage.dart';
import 'chat_message.dart';
import 'reasoning_detail.dart';
import 'tool_call.dart';

/// A chat completion response from the OpenAI API.
///
/// This represents the response from the chat completions endpoint,
/// containing one or more completion choices.
///
/// ## Example
///
/// ```dart
/// final response = await client.chat.completions.create(request);
///
/// // Get the text content
/// print(response.text);
///
/// // Access choices directly
/// for (final choice in response.choices) {
///   print('Choice ${choice.index}: ${choice.message.content}');
/// }
/// ```
@immutable
class ChatCompletion {
  /// Creates a [ChatCompletion].
  const ChatCompletion({
    this.id,
    required this.object,
    this.created,
    required this.model,
    required this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
    this.provider,
  });

  /// Creates a [ChatCompletion] from JSON.
  factory ChatCompletion.fromJson(Map<String, dynamic> json) {
    return ChatCompletion(
      id: json['id'] as String?,
      object: json['object'] as String,
      created: json['created'] as int?,
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
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

  /// The object type (always "chat.completion").
  final String object;

  /// The Unix timestamp when this completion was created.
  ///
  /// May be null with some OpenAI-compatible providers.
  final int? created;

  /// The model used for this completion.
  final String model;

  /// The list of completion choices.
  final List<ChatChoice> choices;

  /// Token usage statistics.
  final Usage? usage;

  /// The system fingerprint for the model configuration.
  ///
  /// Can be used to verify that the same model and configuration
  /// were used across requests.
  final String? systemFingerprint;

  /// The service tier used (if applicable).
  final String? serviceTier;

  /// **OpenRouter only.** The provider that served the request.
  ///
  /// Not part of the official OpenAI API.
  final String? provider;

  /// Gets the text content from the first choice.
  ///
  /// This is a convenience getter for accessing the most common use case.
  /// Returns null if there are no choices or no content.
  String? get text => choices.firstOrNull?.message.content;

  /// Gets the first choice.
  ChatChoice? get firstChoice => choices.firstOrNull;

  /// Gets the creation time as a [DateTime], or null if [created] is null.
  DateTime? get createdAt => created != null
      ? DateTime.fromMillisecondsSinceEpoch(created! * 1000)
      : null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'object': object,
    if (created != null) 'created': created,
    'model': model,
    'choices': choices.map((c) => c.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
    if (serviceTier != null) 'service_tier': serviceTier,
    if (provider != null) 'provider': provider,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          model == other.model;

  @override
  int get hashCode => Object.hash(id, model);

  @override
  String toString() =>
      'ChatCompletion(id: $id, model: $model, choices: ${choices.length})';
}

/// A single completion choice.
@immutable
class ChatChoice {
  /// Creates a [ChatChoice].
  const ChatChoice({
    this.index,
    required this.message,
    this.finishReason,
    this.logprobs,
  });

  /// Creates a [ChatChoice] from JSON.
  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int?,
      message: _parseMessage(json['message'] as Map<String, dynamic>),
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
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter
  /// doesn't return `index` with some responses).
  final int? index;

  /// The message generated by the model.
  final AssistantMessage message;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Log probability information.
  final Logprobs? logprobs;

  /// Whether the model wants to call tools.
  bool get hasToolCalls => message.hasToolCalls;

  /// Whether the model refused to respond.
  bool get isRefusal => message.isRefusal;

  /// Whether the response was truncated due to length.
  bool get isTruncated => finishReason?.isTruncated ?? false;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (index != null) 'index': index,
    'message': message.toJson(),
    if (finishReason != null) 'finish_reason': finishReason!.toJson(),
    if (logprobs != null) 'logprobs': logprobs!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          message == other.message;

  @override
  int get hashCode => Object.hash(index, message);

  @override
  String toString() => 'ChatChoice(index: $index, finishReason: $finishReason)';
}

/// Parses an assistant message from JSON.
AssistantMessage _parseMessage(Map<String, dynamic> json) {
  return AssistantMessage(
    content: json['content'] as String?,
    refusal: json['refusal'] as String?,
    toolCalls: (json['tool_calls'] as List<dynamic>?)
        ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
        .toList(),
    // Reasoning fields for OpenRouter/DeepSeek compatibility
    reasoningContent: json['reasoning_content'] as String?,
    reasoning: json['reasoning'] as String?,
    reasoningDetails: (json['reasoning_details'] as List<dynamic>?)
        ?.map((e) => ReasoningDetail.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
